return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              -- Recognize the `vim` global
              globals = { "vim" },
            },
            workspace = {
              -- Make lua_ls aware of our custom type definitions
              library = {
                [vim.fn.expand("$HOME/.config/nvim/lua")] = true,
              },
            },
          },
        },
      },
      -- python = {
      --   -- Force Pyright to use your asdf Python
      --   pythonPath = "/Users/ryanmessner/.asdf/shims/python",
      --   analysis = {
      --     -- Add your site-packages path explicitly
      --     extraPaths = {
      --       "/Users/ryanmessner/.asdf/installs/python/3.14.0/lib/python3.14/site-packages",
      --     },
      --   },
      -- },
      clangd = {
        cmd = {
          "clangd",
          "--compile-commands-dir=build", -- Or use symlink
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
      },
      -- Ruby LSP configuration (optimized for Rails)
      ruby_lsp = {
        init_options = {
          enabledFeatures = {
            "documentSymbols",
            "documentHighlights",
            "foldingRanges",
            "selectionRanges",
            "semanticHighlighting",
            "formatting",
            "codeActions",
            "diagnostics",
            "rename",
            "hover",
            "completion",
            "signatureHelp",
          },
          featuresConfiguration = {
            inlayHint = {
              enableAll = false,
            },
          },
        },
        settings = {},
      },
      -- Solargraph as fallback/complement for better intellisense
      solargraph = {
        settings = {
          solargraph = {
            diagnostics = false, -- Disable to avoid conflicts with ruby-lsp
            completion = true,
            hover = true,
            symbols = true,
            definitions = true,
            references = true,
          },
        },
      },
      -- Elixir LSP configuration
      elixirls = {
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls") },
        settings = {
          elixirLS = {
            dialyzerEnabled = true,
            fetchDeps = false,
            enableTestLenses = true,
            suggestSpecs = true,
            signatureAfterComplete = true,
          },
        },
      },
    },
  },
}
