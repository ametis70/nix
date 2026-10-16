<div align="center">

# Nix Configurations

![license](https://img.shields.io/github/license/ametis70/nix?style=flat-square)
![nix](https://img.shields.io/badge/nix-flake-5277C3?style=flat-square&logo=nixos&logoColor=white)
![nixos](https://img.shields.io/badge/NixOS-configurations-5277C3?style=flat-square&logo=nixos&logoColor=white)
![home-manager](https://img.shields.io/badge/Home%20Manager-enabled-7EBAE4?style=flat-square)

A personal collection of NixOS, Home Manager, and nix-darwin configurations. These configurations are tailored to my hardware, hostnames, network, and setup (they are not designed to deploy unchanged on other machines).

</div>

## Overview

This repository manages Linux and macOS machines with a shared Nix flake. NixOS hosts use Home Manager for user configuration; Steam Deck and Windows VM accounts use standalone Home Manager configurations, and the Work Mac is managed with nix-darwin.

The flake provides stable and unstable package sets. Hosts select the channel that best fits their needs, while shared NixOS and Home Manager modules keep common services and user applications configurable through options.

## Flake inputs

The flake pins stable and unstable variants where hosts need different release channels. Its main inputs include:

- [nixpkgs](https://github.com/NixOS/nixpkgs) and `nixpkgs-unstable` — package sets for the stable and unstable host channels.
- [Home Manager](https://github.com/nix-community/home-manager) and `home-manager-unstable` — user environments across NixOS, macOS, and standalone hosts.
- [nix-darwin](https://github.com/LnL7/nix-darwin) and `nix-darwin-unstable` — macOS system configuration.
- [Nixvim](https://github.com/nix-community/nixvim) and `nixvim-unstable` — declarative Neovim configuration.
- [nixGL](https://github.com/nix-community/nixGL) and `nixgl-unstable` — graphics-enabled applications on non-NixOS Linux hosts.
- [Hyprland](https://github.com/hyprwm/Hyprland) and `hyprland-unstable`, with [hy3](https://github.com/outfoxxed/hy3) and `hy3-unstable` — the Wayland compositor and layout plugin used by the VM desktop.
- [NixVirt](https://github.com/AshleyYakeley/NixVirt) — virtual machine management on the hypervisor.
- [nixos-hardware](https://github.com/NixOS/nixos-hardware) and `nixos-hardware-unstable` — hardware-specific configuration, including the Minisforum V3 module.
- [Disko](https://github.com/nix-community/disko) — declarative disk layouts for selected NixOS hosts.
- [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS) — Steam-focused gaming features for desktop and TV hosts.
- [agenix](https://github.com/ryantm/agenix) — encrypted secret management.
- [Catppuccin](https://github.com/catppuccin/nix) and `catppuccin-unstable` — shared theming.
- [Launchscope](https://github.com/ametis70/launchscope) — app launcher and CEC integration for the TV host.

## Hosts

| Host              | Configuration output             | System       | Role                                    |
| ----------------- | -------------------------------- | ------------ | --------------------------------------- |
| Hypervisor        | `ametis70-hypervisor-nixos`      | NixOS        | KVM/libvirt host                        |
| VM desktop        | `ametis70-vm-nixos`              | NixOS        | Hyprland desktop VM                     |
| VM server builder | `vm-nixos-server-builder`        | NixOS        | Build server VM (WIP)                   |
| VM server 1       | `vm-nixos-server-1`              | NixOS        | K3s cluster node                        |
| VM server 2       | `vm-nixos-server-2`              | NixOS        | K3s cluster node                        |
| Intel server      | `intel-nixos-server`             | NixOS        | K3s cluster node and nut server         |
| Intel TV          | `intel-nixos-tv`                 | NixOS        | HTPC and gaming (emulation + streaming) |
| Midtower desktop  | `midtower-nixos-desktop`         | NixOS        | "Steam Machine" + k3s node (WIP)        |
| V3 tablet         | `v3-nixos-tablet`                | NixOS        | Minisforum V3 tablet                    |
| Steam Deck        | `deck@steamdeck`                 | Home Manager | User environment                        |
| Windows VM        | `ametis70@ametis70-vm-windows10` | Home Manager | User environment                        |
| Work Mac          | `AR000H4F609LXL5`                | nix-darwin   | Apple Silicon workstation               |

NixOS and nix-darwin output names follow the host metadata in `flake.nix`; standalone Home Manager outputs use `username@hostname`.

## Repository layout

- `hosts/` — host-specific system, hardware, disk, and user configuration
- `modules/nixos/` — reusable NixOS options and service, hardware, desktop, and homelab modules
- `modules/home/` — reusable Home Manager options and user application configuration
- `secrets/` — encrypted secrets managed with [agenix](https://github.com/ryantm/agenix)
- `utils/` — shared Nix helpers

Keep host-specific details in the corresponding host directory. Put reusable behavior behind module options and enable it from each host configuration.
