local init_dap = function()
	local wk = require("which-key")

	wk.register({
		d = {
			name = "Debug",
			b = {
				function()
					require("dap").toggle_breakpoint()
				end,
				"Toggle breakpoint",
			},
			c = {
				function()
					require("dap").continue()
				end,
				"Launch or resume session",
			},
			o = {
				function()
					require("dap").step_over()
				end,
				"Step over",
			},
			i = {
				function()
					require("dap").step_into()
				end,
				"Step into",
			},
			p = {
				function()
					require("dap.ext.vscode").load_launchjs(
						nil,
						{ ["pwa-node"] = { "typescriptreact", "typescript", "javascript", "javascriptreact", "json" } }
					)
				end,
				"Load project config",
			},
			P = {
				function()
					local config_dir = vim.loop.cwd() .. "/.vscode"
					local config_file = config_dir .. "/launch.json"
					if not vim.fn.filereadable(config_file) then
						vim.ui.input(
							{ prompt = "Debugger config not found at " .. config_file .. ". Create? [Y/n]" },
							function(input)
								if input == "" or input == "y" or input == "Y" then
									vim.fn.mkdir(config_dir)
								end
							end
						)
					end

					if vim.fn.filereadable(config_file) then
						vim.cmd("edit " .. config_file)
					end
				end,
				"Open project config",
			},
		},
	}, {
		prefix = "<leader>",
	})
end

local setup_dap = function()
	local dap = require("dap")

	require("dap").adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = vim.env.HOME .. "/.asdf/installs/nodejs/lts/bin/node",
			args = {
				vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
				"${port}",
			},
		},
	}

	for _, language in ipairs({ "typescript", "javascript" }) do
		dap.configurations[language] = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				cwd = "${workspaceFolder}",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach",
				processId = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
			{
				type = "pwa-node",
				request = "launch",
				name = "Debug Jest Tests",
				-- trace = true, -- include debugger info
				runtimeExecutable = "node",
				runtimeArgs = {
					"./node_modules/jest/bin/jest.js",
					"--runInBand",
				},
				rootPath = "${workspaceFolder}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				internalConsoleOptions = "neverOpen",
			},
		}
	end
end

local setup_dap_ui = function()
	local wk = require("which-key")

	wk.register({
		d = {
			name = "Debug",
			d = {
				function()
					require("dapui").toggle()
				end,
				"Toggle debugger UI",
			},
		},
	}, {
		prefix = "<leader>",
	})
end

return {
	{ "mfussenegger/nvim-dap", init = init_dap, config = setup_dap },
	{ "rcarriga/nvim-dap-ui", init = setup_dap_ui },
}
