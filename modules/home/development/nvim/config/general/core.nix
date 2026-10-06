{
  extraConfigLuaPre = ''
    _G.Nix = _G.Nix or {}
    local Nix = _G.Nix

    Nix.icons = {
      misc = { dots = "󰇘" },
      ft = {
        octo = " ",
        gh = " ",
        ["markdown.gh"] = " ",
      },
      dap = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = " ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
      },
      diagnostics = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
      kinds = {
        Array = " ",
        Boolean = "󰨙 ",
        Class = " ",
        Codeium = "󰘦 ",
        Color = " ",
        Control = " ",
        Collapsed = " ",
        Constant = "󰏿 ",
        Constructor = " ",
        Copilot = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = "󰊕 ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = "󰊕 ",
        Module = " ",
        Namespace = "󰦮 ",
        Null = " ",
        Number = "󰎠 ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = "󱄽 ",
        String = " ",
        Struct = "󰆼 ",
        Supermaven = " ",
        TabNine = "󰏚 ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = "󰀫 ",
      },
    }

    Nix.kind_filter = {
      default = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        "Package",
        "Property",
        "Struct",
        "Trait",
      },
      markdown = false,
      help = false,
      lua = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        "Property",
        "Struct",
        "Trait",
      },
    }

    Nix.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
    function Nix.create_undo()
      if vim.api.nvim_get_mode().mode == "i" then
        vim.api.nvim_feedkeys(Nix.CREATE_UNDO, "n", false)
      end
    end

    local function notify(level)
      return function(msg, opts)
        opts = opts or {}
        vim.notify(msg, vim.log.levels[level], opts)
      end
    end
    Nix.info = notify("INFO")
    Nix.warn = notify("WARN")
    Nix.error = notify("ERROR")

    Nix.lsp = {}
    Nix.lsp.action = setmetatable({}, {
      __index = function(_, action)
        return function()
          vim.lsp.buf.code_action({
            apply = true,
            context = {
              only = { action },
              diagnostics = {},
            },
          })
        end
      end,
    })

    function Nix.lsp.execute(opts)
      local params = {
        command = opts.command,
        arguments = opts.arguments,
      }
      if opts.open and package.loaded["trouble"] then
        require("trouble").open({
          mode = "lsp_command",
          params = params,
        })
      else
        return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
      end
    end

    if not package.loaded["lazy.stats"] and not package.preload["lazy.stats"] then
      package.preload["lazy.stats"] = function()
        return {
          stats = function()
            return { startuptime = 0, loaded = 0, count = 0 }
          end,
        }
      end
    end

    function Nix.get_pkg_path(pkg, path)
      local ok, registry = pcall(require, "mason-registry")
      if not ok then
        return ""
      end
      local ok_pkg, package = pcall(registry.get_package, pkg)
      if not ok_pkg or not package:is_installed() then
        return ""
      end
      return package:get_install_path() .. path
    end

    Nix.root = {}
    Nix.root.spec = { "lsp", { ".git", "lua" }, "cwd" }
    Nix.root.detectors = {}

    function Nix.root.detectors.cwd()
      return { vim.uv.cwd() }
    end

    function Nix.root.detectors.lsp(buf)
      local bufpath = Nix.root.bufpath(buf)
      if not bufpath then
        return {}
      end
      local roots = {}
      local clients = vim.lsp.get_clients({ bufnr = buf })
      clients = vim.tbl_filter(function(client)
        return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
      end, clients)
      for _, client in pairs(clients) do
        local workspace = client.config.workspace_folders
        for _, ws in pairs(workspace or {}) do
          roots[#roots + 1] = vim.uri_to_fname(ws.uri)
        end
        if client.root_dir then
          roots[#roots + 1] = client.root_dir
        end
      end
      return vim.tbl_filter(function(path)
        path = Nix.root.realpath(path)
        return path and bufpath:find(path, 1, true) == 1
      end, roots)
    end

    function Nix.root.detectors.pattern(buf, patterns)
      patterns = type(patterns) == "string" and { patterns } or patterns
      local path = Nix.root.bufpath(buf) or vim.uv.cwd()
      local found = vim.fs.find(function(name)
        for _, p in ipairs(patterns) do
          if name == p then
            return true
          end
          if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
            return true
          end
        end
        return false
      end, { path = path, upward = true })[1]
      return found and { vim.fs.dirname(found) } or {}
    end

    function Nix.root.bufpath(buf)
      return Nix.root.realpath(vim.api.nvim_buf_get_name(assert(buf)))
    end

    function Nix.root.cwd()
      return Nix.root.realpath(vim.uv.cwd()) or ""
    end

    function Nix.root.realpath(path)
      if path == "" or path == nil then
        return nil
      end
      path = vim.fn.has("win32") == 0 and vim.uv.fs_realpath(path) or path
      return vim.fs.normalize(path)
    end

    function Nix.root.resolve(spec)
      if Nix.root.detectors[spec] then
        return Nix.root.detectors[spec]
      elseif type(spec) == "function" then
        return spec
      end
      return function(buf)
        return Nix.root.detectors.pattern(buf, spec)
      end
    end

    function Nix.root.detect(opts)
      opts = opts or {}
      opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or Nix.root.spec
      opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

      local ret = {}
      for _, spec in ipairs(opts.spec) do
        local paths = Nix.root.resolve(spec)(opts.buf)
        paths = paths or {}
        paths = type(paths) == "table" and paths or { paths }
        local roots = {}
        for _, p in ipairs(paths) do
          local rp = Nix.root.realpath(p)
          if rp and not vim.tbl_contains(roots, rp) then
            roots[#roots + 1] = rp
          end
        end
        table.sort(roots, function(a, b)
          return #a > #b
        end)
        if #roots > 0 then
          ret[#ret + 1] = { spec = spec, paths = roots }
          if opts.all == false then
            break
          end
        end
      end
      return ret
    end

    Nix.root.cache = {}

    function Nix.root.get(opts)
      opts = opts or {}
      local buf = opts.buf or vim.api.nvim_get_current_buf()
      local ret = Nix.root.cache[buf]
      if not ret then
        local roots = Nix.root.detect({ all = false, buf = buf })
        ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
        Nix.root.cache[buf] = ret
      end
      if opts and opts.normalize then
        return ret
      end
      return vim.fn.has("win32") == 1 and ret:gsub("/", "\\") or ret
    end

    function Nix.root.git()
      local root = Nix.root.get()
      local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
      local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
      return ret
    end

    vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("nix_root_cache", { clear = true }),
      callback = function(event)
        Nix.root.cache[event.buf] = nil
      end,
    })

    Nix.pick = {}
    Nix.pick.picker = { name = "snacks" }

    function Nix.pick._root(opts)
      opts = opts or {}
      local buf = opts.buf or vim.api.nvim_get_current_buf()
      if opts.root == false then
        return vim.uv.cwd()
      end
      return Nix.root.get({ buf = buf, normalize = true })
    end

    function Nix.pick.files(opts)
      opts = opts or {}
      opts.cwd = Nix.pick._root(opts)
      return Snacks.picker.files(opts)
    end

    function Nix.pick.grep(opts)
      opts = opts or {}
      opts.cwd = Nix.pick._root(opts)
      return Snacks.picker.grep(opts)
    end

    function Nix.pick.oldfiles(opts)
      opts = opts or {}
      opts.cwd = Nix.pick._root(opts)
      return Snacks.picker.recent(opts)
    end

    function Nix.pick.grep_word(opts)
      opts = opts or {}
      opts.cwd = Nix.pick._root(opts)
      return Snacks.picker.grep_word(opts)
    end

    function Nix.pick.config_files()
      return function()
        return Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end
    end

    function Nix.pick.make(name, opts)
      return function()
        if name == "files" then
          return Nix.pick.files(opts)
        elseif name == "grep" or name == "live_grep" then
          return Nix.pick.grep(opts)
        elseif name == "oldfiles" then
          return Nix.pick.oldfiles(opts)
        elseif name == "grep_word" then
          return Nix.pick.grep_word(opts)
        end
      end
    end

    Nix.format = { formatters = {} }

    function Nix.format.register(formatter)
      Nix.format.formatters[#Nix.format.formatters + 1] = formatter
      table.sort(Nix.format.formatters, function(a, b)
        return a.priority > b.priority
      end)
    end

    function Nix.format.formatexpr()
      if pcall(require, "conform") then
        return require("conform").formatexpr()
      end
      return vim.lsp.formatexpr({ timeout_ms = 3000 })
    end

    function Nix.format.enabled(buf)
      buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
      local gaf = vim.g.autoformat
      local baf = vim.b[buf].autoformat
      if baf ~= nil then
        return baf
      end
      return gaf == nil or gaf
    end

    function Nix.format.enable(enable, buf)
      if enable == nil then
        enable = true
      end
      if buf then
        vim.b.autoformat = enable
      else
        vim.g.autoformat = enable
        vim.b.autoformat = nil
      end
    end

    function Nix.format.toggle(buf)
      Nix.format.enable(not Nix.format.enabled(), buf)
    end

    function Nix.format.resolve(buf)
      buf = buf or vim.api.nvim_get_current_buf()
      local have_primary = false
      return vim.tbl_map(function(formatter)
        local sources = formatter.sources(buf)
        local active = #sources > 0 and (not formatter.primary or not have_primary)
        have_primary = have_primary or (active and formatter.primary) or false
        return setmetatable({ active = active, resolved = sources }, { __index = formatter })
      end, Nix.format.formatters)
    end

    function Nix.format.info(buf)
      buf = buf or vim.api.nvim_get_current_buf()
      local gaf = vim.g.autoformat == nil or vim.g.autoformat
      local baf = vim.b[buf].autoformat
      local enabled = Nix.format.enabled(buf)
      local lines = {
        "# Status",
        ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
        ("- [%s] buffer **%s**"):format(enabled and "x" or " ", baf == nil and "inherit" or baf and "enabled" or "disabled"),
      }
      local have = false
      for _, formatter in ipairs(Nix.format.resolve(buf)) do
        if #formatter.resolved > 0 then
          have = true
          lines[#lines + 1] = "\n# " .. formatter.name .. (formatter.active and " ***(active)***" or "")
          for _, line in ipairs(formatter.resolved) do
            lines[#lines + 1] = ("- [%s] **%s**"):format(formatter.active and "x" or " ", line)
          end
        end
      end
      if not have then
        lines[#lines + 1] = "\n***No formatters available for this buffer.***"
      end
      local notify = enabled and Nix.info or Nix.warn
      notify(table.concat(lines, "\n"), { title = "Format (" .. (enabled and "enabled" or "disabled") .. ")" })
    end

    function Nix.format.format(opts)
      opts = opts or {}
      local buf = opts.buf or vim.api.nvim_get_current_buf()
      if not ((opts and opts.force) or Nix.format.enabled(buf)) then
        return
      end
      local done = false
      for _, formatter in ipairs(Nix.format.resolve(buf)) do
        if formatter.active then
          done = true
          local ok, err = pcall(function()
            return formatter.format(buf)
          end)
          if not ok then
            Nix.warn("Formatter `" .. formatter.name .. "` failed: " .. tostring(err))
          end
        end
      end
      if not done and opts and opts.force then
        Nix.warn("No formatter available")
      end
    end

    function Nix.format.snacks_toggle(buf)
      return Snacks.toggle({
        name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
        get = function()
          if not buf then
            return vim.g.autoformat == nil or vim.g.autoformat
          end
          return Nix.format.enabled()
        end,
        set = function(state)
          Nix.format.enable(state, buf)
        end,
      })
    end

    function Nix.format.setup()
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("NixFormat", { clear = true }),
        callback = function(event)
          Nix.format.format({ buf = event.buf })
        end,
      })

      vim.api.nvim_create_user_command("Format", function()
        Nix.format.format({ force = true })
      end, { desc = "Format selection or buffer" })

      vim.api.nvim_create_user_command("FormatInfo", function()
        Nix.format.info()
      end, { desc = "Show info about the formatters for the current buffer" })
    end

    Nix.mini = {}

    function Nix.mini.ai_buffer(ai_type)
      local start_line, end_line = 1, vim.fn.line("$")
      if ai_type == "i" then
        local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
        if first_nonblank == 0 or last_nonblank == 0 then
          return { from = { line = start_line, col = 1 } }
        end
        start_line, end_line = first_nonblank, last_nonblank
      end
      local to_col = math.max(vim.fn.getline(end_line):len(), 1)
      return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
    end

    function Nix.mini.ai_whichkey(opts)
      local objects = {
        { " ", desc = "whitespace" },
        { '"', desc = '" string' },
        { "'", desc = "' string" },
        { "(", desc = "() block" },
        { ")", desc = "() block with ws" },
        { "<", desc = "<> block" },
        { ">", desc = "<> block with ws" },
        { "?", desc = "user prompt" },
        { "U", desc = "use/call without dot" },
        { "[", desc = "[] block" },
        { "]", desc = "[] block with ws" },
        { "_", desc = "underscore" },
        { "`", desc = "` string" },
        { "a", desc = "argument" },
        { "b", desc = ")]} block" },
        { "c", desc = "class" },
        { "d", desc = "digit(s)" },
        { "e", desc = "CamelCase / snake_case" },
        { "f", desc = "function" },
        { "g", desc = "entire file" },
        { "i", desc = "indent" },
        { "o", desc = "block, conditional, loop" },
        { "q", desc = "quote `\"'" },
        { "t", desc = "tag" },
        { "u", desc = "use/call" },
        { "{", desc = "{} block" },
        { "}", desc = "{} with ws" },
      }

      local ret = { mode = { "o", "x" } }
      local mappings = vim.tbl_extend("force", {}, {
        around = "a",
        inside = "i",
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",
      }, opts.mappings or {})
      mappings.goto_left = nil
      mappings.goto_right = nil

      for name, prefix in pairs(mappings) do
        name = name:gsub("^around_", ""):gsub("^inside_", "")
        ret[#ret + 1] = { prefix, group = name }
        for _, obj in ipairs(objects) do
          local desc = obj.desc
          if prefix:sub(1, 1) == "i" then
            desc = desc:gsub(" with ws", "")
          end
          ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
        end
      end
      require("which-key").add(ret, { notify = false })
    end

    function Nix.mini.pairs(opts)
      Snacks.toggle({
        name = "Mini Pairs",
        get = function()
          return not vim.g.minipairs_disable
        end,
        set = function(state)
          vim.g.minipairs_disable = not state
        end,
      }):map("<leader>up")

      local pairs = require("mini.pairs")
      pairs.setup(opts)
      local open = pairs.open
      pairs.open = function(pair, neigh_pattern)
        if vim.fn.getcmdline() ~= "" then
          return open(pair, neigh_pattern)
        end
        local o, c = pair:sub(1, 1), pair:sub(2, 2)
        local line = vim.api.nvim_get_current_line()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local next = line:sub(cursor[2] + 1, cursor[2] + 1)
        local before = line:sub(1, cursor[2])
        if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
          return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
        end
        if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
          return o
        end
        if opts.skip_ts and #opts.skip_ts > 0 then
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if vim.tbl_contains(opts.skip_ts, capture.capture) then
              return o
            end
          end
        end
        if opts.skip_unbalanced and next == c and c ~= o then
          local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
          local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
          if count_close > count_open then
            return o
          end
        end
        return open(pair, neigh_pattern)
      end
    end

    Nix.cmp = { actions = {} }

    Nix.cmp.actions.snippet_forward = function()
      if vim.snippet.active({ direction = 1 }) then
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
        return true
      end
    end

    Nix.cmp.actions.snippet_stop = function()
      if vim.snippet then
        vim.snippet.stop()
      end
    end

    function Nix.cmp.map(actions, fallback)
      return function()
        for _, name in ipairs(actions) do
          if Nix.cmp.actions[name] then
            local ret = Nix.cmp.actions[name]()
            if ret then
              return true
            end
          end
        end
        return type(fallback) == "function" and fallback() or fallback
      end
    end

    function Nix.cmp.snippet_replace(snippet, fn)
      return snippet:gsub("%$%b{}", function(m)
        local n, name = m:match("^%$" .. "{(%d+):(.+)}$")
        return n and fn({ n = n, text = name }) or m
      end) or snippet
    end

    function Nix.cmp.snippet_preview(snippet)
      local ok, parsed = pcall(function()
        return vim.lsp._snippet_grammar.parse(snippet)
      end)
      return ok and tostring(parsed)
        or Nix.cmp.snippet_replace(snippet, function(placeholder)
          return Nix.cmp.snippet_preview(placeholder.text)
        end):gsub("%$0", "")
    end

    function Nix.cmp.snippet_fix(snippet)
      local texts = {}
      return Nix.cmp.snippet_replace(snippet, function(placeholder)
        texts[placeholder.n] = texts[placeholder.n] or Nix.cmp.snippet_preview(placeholder.text)
        return "$" .. "{" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
      end)
    end

    function Nix.cmp.expand(snippet)
      local session = vim.snippet.active() and vim.snippet._session or nil
      local ok, err = pcall(vim.snippet.expand, snippet)
      if not ok then
        local fixed = Nix.cmp.snippet_fix(snippet)
        ok = pcall(vim.snippet.expand, fixed)
        local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
          or ("Failed to parse snippet.\n" .. err)
        local level = ok and Nix.warn or Nix.error
        level(([[%s
```%s
%s
```]]):format(msg, vim.bo.filetype, snippet), { title = "vim.snippet" })
      end
      if session then
        vim.snippet._session = session
      end
    end

    Nix.lualine = {}

    function Nix.lualine.status(icon, status)
      local colors = {
        ok = "Special",
        error = "DiagnosticError",
        pending = "DiagnosticWarn",
      }
      return {
        function()
          return icon
        end,
        cond = function()
          return status() ~= nil
        end,
        color = function()
          return { fg = Snacks.util.color(colors[status()] or colors.ok) }
        end,
      }
    end

    function Nix.lualine.format(component, text, hl_group)
      text = text:gsub("%%", "%%%%")
      if not hl_group or hl_group == "" then
        return text
      end
      component.hl_cache = component.hl_cache or {}
      local lualine_hl_group = component.hl_cache[hl_group]
      if not lualine_hl_group then
        local utils = require("lualine.utils.utils")
        local gui = vim.tbl_filter(function(x)
          return x
        end, {
          utils.extract_highlight_colors(hl_group, "bold") and "bold",
          utils.extract_highlight_colors(hl_group, "italic") and "italic",
        })

        lualine_hl_group = component:create_hl({
          fg = utils.extract_highlight_colors(hl_group, "fg"),
          gui = #gui > 0 and table.concat(gui, ",") or nil,
        }, "NX_" .. hl_group)
        component.hl_cache[hl_group] = lualine_hl_group
      end
      return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
    end

    function Nix.lualine.pretty_path(opts)
      opts = vim.tbl_extend("force", {
        relative = "cwd",
        modified_hl = "MatchParen",
        directory_hl = "",
        filename_hl = "Bold",
        modified_sign = "",
        readonly_icon = " 󰌾 ",
        length = 3,
      }, opts or {})

      return function(self)
        local path = vim.fn.expand("%:p")
        if path == "" then
          return ""
        end

        local root = Nix.root.get({ normalize = true })
        local cwd = Nix.root.cwd()
        local norm_path = vim.fs.normalize(path)

        if vim.fn.has("win32") == 1 then
          norm_path = norm_path:lower()
          root = root:lower()
          cwd = cwd:lower()
        end

        if opts.relative == "cwd" and norm_path:find(cwd, 1, true) == 1 then
          path = path:sub(#cwd + 2)
        elseif norm_path:find(root, 1, true) == 1 then
          path = path:sub(#root + 2)
        end

        local sep = package.config:sub(1, 1)
        local parts = vim.split(path, "[\\/]")

        if opts.length ~= 0 and #parts > opts.length then
          parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
        end

        if opts.modified_hl and vim.bo.modified then
          parts[#parts] = parts[#parts] .. opts.modified_sign
          parts[#parts] = Nix.lualine.format(self, parts[#parts], opts.modified_hl)
        else
          parts[#parts] = Nix.lualine.format(self, parts[#parts], opts.filename_hl)
        end

        local dir = ""
        if #parts > 1 then
          dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
          dir = Nix.lualine.format(self, dir .. sep, opts.directory_hl)
        end

        local readonly = ""
        if vim.bo.readonly then
          readonly = Nix.lualine.format(self, opts.readonly_icon, opts.modified_hl)
        end
        return dir .. parts[#parts] .. readonly
      end
    end

    function Nix.lualine.root_dir(opts)
      opts = vim.tbl_extend("force", {
        cwd = false,
        subdirectory = true,
        parent = true,
        other = true,
        icon = "󱉭 ",
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      }, opts or {})

      local function get()
        local cwd = Nix.root.cwd()
        local root = Nix.root.get({ normalize = true })
        local name = vim.fs.basename(root)

        if root == cwd then
          return opts.cwd and name
        elseif root:find(cwd, 1, true) == 1 then
          return opts.subdirectory and name
        elseif cwd:find(root, 1, true) == 1 then
          return opts.parent and name
        else
          return opts.other and name
        end
      end

      return {
        function()
          return (opts.icon and opts.icon .. " ") .. get()
        end,
        cond = function()
          return type(get()) == "string"
        end,
        color = opts.color,
      }
    end
  '';
}
