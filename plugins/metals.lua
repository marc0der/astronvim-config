return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "mfussenegger/nvim-dap",
      config = function(self, opts)
        -- Debug settings if you're using nvim-dap
        local dap = require("dap")

        dap.configurations.scala = {
          {
            type = "scala",
            request = "launch",
            name = "RunOrTest",
            metals = {
              runType = "runOrTestFile",
              --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
            },
          },
          {
            type = "scala",
            request = "launch",
            name = "Test Target",
            metals = {
              runType = "testTarget",
            },
          },
        }
      end,
    },
  },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals_config = require("metals").bare_config()

    -- Example of settings
    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
    }

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to true, however if you do,
    -- you *have* to have a setting to display this in your statusline or else
    -- you'll not see any messages from metals. There is more info in the help
    -- docs about this
    -- metals_config.init_options.statusBarProvider = "on"

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()

      -- LSP mappings
      -- LSP keymaps
      local nmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = desc })
      end

      nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
      nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
      nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
      nmap("gsd", require("telescope.builtin").lsp_document_symbols, "[G]oto [S]ymbols [D]ocument")
      nmap("gsw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[G]oto [S]ymbols [W]orkspace")
      nmap("K", vim.lsp.buf.hover, "Hover Documentation")

      nmap("<leader>ma", vim.lsp.buf.code_action, "[M]etals [A]ction")
      nmap("<leader>md", vim.diagnostic.setqflist, "[M]etals [D]iagnostics")
      nmap("<leader>mf", vim.lsp.buf.format, "[M]etals [F]ormat")
      nmap("<leader>mr", vim.lsp.buf.rename, "[M]etals [R]ename")
      nmap("<leader>ms", vim.lsp.buf.signature_help, "[M]etals [S]ignature")

      -- vim.keymap.set('n', '<leader>de', vim.diagnostic.setqflist({ severity = "E" }), { desc = '[D]iagnostics [E]errors'})
      -- vim.keymap.set('n', '<leader>dw', vim.diagnostic.setqflist({ severity = "W" }), { desc = '[D]iagnostics [W]arnings'})
      -- vim.keymap.set('n', '<leader>dn', vim.diagnostic.setqflist({ severity = "W" }), { desc = '[D]iagnostics [W]arnings'})
      -- vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next({ wrap = false }), { desc = '[D]iagnostics [N]ext'})
      -- vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev({ wrap = false }), { desc = '[D]iagnostics [P]revious'})
      -- vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = '[D]iagnostics [F]loat'})

      -- See `:help K` for why this keymap
      local map = vim.keymap.set
      map("n", "<leader>ws", function()
        require("metals").hover_worksheet()
      end)

      -- all workspace diagnostics
      map("n", "<leader>aa", vim.diagnostic.setqflist)

      -- all workspace errors
      map("n", "<leader>ae", function()
        vim.diagnostic.setqflist({ severity = "E" })
      end)

      -- all workspace warnings
      map("n", "<leader>aw", function()
        vim.diagnostic.setqflist({ severity = "W" })
      end)

      -- buffer diagnostics only
      map("n", "<leader>d", vim.diagnostic.setloclist)

      map("n", "[c", function()
        vim.diagnostic.goto_prev({ wrap = false })
      end)

      map("n", "]c", function()
        vim.diagnostic.goto_next({ wrap = false })
      end)

      -- Example mappings for usage with nvim-dap. If you don't use that, you can
      -- skip these
      map("n", "<leader>dc", function()
        require("dap").continue()
      end)

      map("n", "<leader>dr", function()
        require("dap").repl.toggle()
      end)

      map("n", "<leader>dK", function()
        require("dap.ui.widgets").hover()
      end)

      map("n", "<leader>dt", function()
        require("dap").toggle_breakpoint()
      end)

      map("n", "<leader>dso", function()
        require("dap").step_over()
      end)

      map("n", "<leader>dsi", function()
        require("dap").step_into()
      end)

      map("n", "<leader>dl", function()
        require("dap").run_last()
      end)
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = self.ft,
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
