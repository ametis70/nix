#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import sys
from pathlib import Path


def fix_checksum_block(edid: bytearray, offset: int) -> None:
    """
    Fix checksum of a 128-byte EDID block in-place, starting at 'offset'.
    Sum of bytes[offset..offset+127] must be 0 mod 256.
    """
    block = edid[offset : offset + 128]
    total = sum(block[0:127]) & 0xFF
    edid[offset + 127] = (-total) & 0xFF


def parse_cta_blocks(edid: bytearray):
    """
    Parse CTA-861 extension (assumed to be block 1 at offset 128).
    Returns: (cta_block, data_region, blocks, dtd_start_offset)

    blocks is a list of (tag, start_index, end_index) where start/end
    are indices into data_region (not the whole cta_block).
    """
    cta = edid[128:256]
    if cta[0] != 0x02:
        raise ValueError("No CTA-861 extension (tag 0x02) in block 1")

    dtd_start = cta[2]

    if dtd_start == 0 or dtd_start > 127:
        # No DTDs; treat data as 4..127
        data_region = cta[4:127]
        dtd_start = 127
    else:
        data_region = cta[4:dtd_start]

    blocks = []
    i = 0
    while i < len(data_region):
        tag = data_region[i] >> 5
        length = data_region[i] & 0x1F
        start = i
        end = i + 1 + length
        if end > len(data_region):
            break
        blocks.append((tag, start, end))
        i = end

    return cta, data_region, blocks, dtd_start


def get_first_block(blocks, data, tag, predicate=None):
    """
    Get first CTA data block with given tag, optionally matching predicate.
    Returns the bytes of the block (header + payload) or None.
    """
    for t, s, e in blocks:
        if t != tag:
            continue
        blk = data[s:e]
        if predicate is None or predicate(blk):
            return blk
    return None


def filter_vdb_drop_interlaced(vdb: bytes) -> bytes:
    """
    Given a Video Data Block (tag=2), drop interlaced VICs:
    5, 6, 20, 21  (1080i / 480i / 576i).
    """
    if not vdb:
        return vdb
    header = vdb[0]
    if (header >> 5) != 2:
        # Not actually a VDB
        return vdb

    length = header & 0x1F
    vics = list(vdb[1 : 1 + length])

    drop_vics = {5, 6, 20, 21}
    filtered = [vic for vic in vics if vic not in drop_vics]

    new_length = len(filtered)
    if new_length > 0x1F:
        raise ValueError("Filtered VDB still too long for CTA length field")

    new_header = (2 << 5) | new_length
    return bytes([new_header] + filtered)


def change_display_name(edid: bytearray, name: str) -> None:
    """
    Change Display Product Name (0xFC descriptor) in base EDID block (block 0).
    """
    base = edid[0:128]
    name_bytes = name.encode("ascii", "ignore")
    if len(name_bytes) > 13:
        name_bytes = name_bytes[:13]

    # Detailed descriptors at offsets 0x36, 0x48, 0x5A, 0x6C
    name_pos = None
    for off in range(54, 126, 18):
        if base[off : off + 4] == b"\x00\x00\x00\xfc":
            name_pos = off
            break

    if name_pos is None:
        print(
            "WARNING: No 0xFC Display Product Name descriptor found; name not changed in base block.",
            file=sys.stderr,
        )
        return

    field = bytearray(13)
    field[: len(name_bytes)] = name_bytes
    # Add newline and pad with spaces if room
    if len(name_bytes) < 13:
        field[len(name_bytes)] = 0x0A
        for i in range(len(name_bytes) + 1, 13):
            field[i] = 0x20

    # Write directly into the main EDID bytearray
    start = name_pos + 5
    edid[start : start + 13] = field


def change_manufacturer(edid: bytearray, mfg: str) -> None:
    """
    Change Manufacturer ID (EISA 3-letter code, e.g. 'BNQ') in base EDID.
    Stored in bytes 8–9 as 3×5-bit letters.
    """
    mfg = mfg.strip().upper()
    if len(mfg) != 3 or not all("A" <= c <= "Z" for c in mfg):
        print(
            f"WARNING: Manufacturer '{mfg}' is not a 3-letter A–Z code; leaving original manufacturer.",
            file=sys.stderr,
        )
        return

    word = ((ord(mfg[0]) - 64) << 10) | ((ord(mfg[1]) - 64) << 5) | (ord(mfg[2]) - 64)
    edid[8] = (word >> 8) & 0xFF
    edid[9] = word & 0xFF


def merge_edid(video_raw: bytes, audio_raw: bytes, name: str, mfg: str) -> bytearray:
    """
    Merge video EDID (projector) and audio EDID (AVR) into a single EDID:
      - Base block from video EDID, with:
          * display name changed
          * manufacturer ID changed
      - CTA block:
          * Video Data Block from video (with interlaced VICs removed)
          * Audio Data Block from audio
          * Speaker Allocation Data Block from audio
          * Other CTA blocks from video, added only if they fit
          * Dolby VSADB (if present) from audio, added only if it fits
      - Preserve ALL original CTA DTDs from video (e.g. 2560x1440@119.997).
      - Recalculate checksums for both blocks.
    """
    if len(video_raw) < 256 or len(audio_raw) < 256:
        raise ValueError(
            "Both EDIDs must be at least 256 bytes (base + CTA extension)."
        )

    # Work on first 256 bytes only (base + one CTA extension)
    edid = bytearray(video_raw[:256])
    audio = bytearray(audio_raw[:256])

    # 1) Change base-block identity fields
    change_display_name(edid, name)
    change_manufacturer(edid, mfg)

    # 2) Parse CTA blocks
    cta_v, data_v, blocks_v, dtd_start_v = parse_cta_blocks(edid)
    cta_a, data_a, blocks_a, dtd_start_a = parse_cta_blocks(audio)

    # Video Data Block (VDB, tag 2) from video
    vdb_v = get_first_block(blocks_v, data_v, 2)
    if not vdb_v:
        raise RuntimeError("No Video Data Block (tag 2) found in video EDID CTA block.")

    # Filter interlaced VICs out of the VDB
    vdb_v = filter_vdb_drop_interlaced(vdb_v)

    # Audio Data Block (ADB, tag 1) from audio
    adb_a = get_first_block(blocks_a, data_a, 1)
    if not adb_a:
        raise RuntimeError("No Audio Data Block (tag 1) found in audio EDID CTA block.")

    # Speaker Allocation Data Block (SADB, tag 4) from audio
    sadb_a = get_first_block(blocks_a, data_a, 4)
    if not sadb_a:
        raise RuntimeError(
            "No Speaker Allocation Data Block (tag 4) found in audio EDID CTA block."
        )

    # Dolby VSADB (tag 7, containing OUI 00-D0-46) from audio, if present
    dolby_a = get_first_block(
        blocks_a,
        data_a,
        7,
        predicate=lambda b: b.find(b"\x00\xd0\x46") != -1,
    )

    # 3) Build new CTA data region IN ORDER, but only up to max_data_len
    dtd_offset = dtd_start_v  # original offset of the DTDs
    max_data_len = max(0, dtd_offset - 4)  # data region is [4 .. dtd_offset)

    new_data = bytearray()

    def maybe_add(block: bytes, label: str) -> None:
        nonlocal new_data
        if not block:
            return
        if len(new_data) + len(block) <= max_data_len:
            new_data.extend(block)
        else:
            print(
                f"INFO: Skipping CTA block '{label}' due to size limit.",
                file=sys.stderr,
            )

    # 1) Video Data Block from video EDID (filtered)
    maybe_add(vdb_v, "Video Data Block (VDB)")

    # 2) Audio Data Block from AVR
    maybe_add(adb_a, "Audio Data Block (ADB)")

    # 3) Speaker Allocation from AVR
    maybe_add(sadb_a, "Speaker Allocation Data Block (SADB)")

    # 4) Other CTA blocks from video EDID (HDR, HDMI VSDB, Forum VSDB, etc),
    #    excluding tag 1/2/4 which we already handled.
    for t, s, e in blocks_v:
        if t in (1, 2, 4):
            continue
        blk = data_v[s:e]
        maybe_add(blk, f"CTA tag {t}")

    # 5) Dolby VSADB from audio, if not already present and if it fits
    if dolby_a and new_data.find(b"\x00\xd0\x46") == -1:
        maybe_add(dolby_a, "Dolby VSADB")

    # 4) Construct a new CTA block
    new_cta = bytearray(128)
    new_cta[0] = 0x02  # CTA-861 tag
    new_cta[1] = cta_v[1]  # keep revision
    new_cta[2] = dtd_offset  # DTD start offset unchanged
    new_cta[3] = cta_v[3]  # keep flags/native VIC info

    # Copy new data region
    new_cta[4 : 4 + len(new_data)] = new_data

    # Copy original DTD area (and unused space up to 127) from video CTA
    if dtd_start_v < 127:
        new_cta[dtd_offset:127] = cta_v[dtd_start_v:127]

    # 5) Write new CTA back and fix checksums
    edid[128:256] = new_cta
    fix_checksum_block(edid, 0)  # base block
    fix_checksum_block(edid, 128)  # CTA block

    return edid


def main(argv):
    if len(argv) != 5:
        print(
            f"Usage: {argv[0]} <video-edid.bin> <audio-edid.bin> <display-name> <manufacturer-3letters>",
            file=sys.stderr,
        )
        return 1

    video_path = Path(argv[1])
    audio_path = Path(argv[2])
    display_name = argv[3]
    manufacturer = argv[4]

    if not video_path.is_file():
        print(f"Video EDID file not found: {video_path}", file=sys.stderr)
        return 1
    if not audio_path.is_file():
        print(f"Audio EDID file not found: {audio_path}", file=sys.stderr)
        return 1

    video_raw = video_path.read_bytes()
    audio_raw = audio_path.read_bytes()

    try:
        merged = merge_edid(video_raw, audio_raw, display_name, manufacturer)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1

    # Write merged EDID to stdout
    sys.stdout.buffer.write(merged)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
