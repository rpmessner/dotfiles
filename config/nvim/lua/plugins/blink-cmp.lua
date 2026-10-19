--- ultra fast completion plugin with a native rust core
---@type LazySpec
return {
  "saghen/blink.cmp",
  event = { "CmdlineEnter", "InsertEnter" },
  -- use a release tag to download pre-built binaries
  version = "1.*",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-Z>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = {
        "select_next",
        "snippet_forward",
        function(cmp)
          if require("config.utils").has_words_before() or vim.api.nvim_get_mode().mode == "c" then
            return cmp.show()
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        "select_prev",
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then
            return cmp.show()
          end
        end,
        "fallback",
      },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      -- use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    cmdline = {
      -- keymap = {
      --   -- recommended, as the default keymap will only show and select the next item
      --   ["<Tab>"] = { "show", "accept" },
      -- },
      completion = {
        menu = {
          draw = {
            columns = {
              { "kind_icon", "label", gap = 1 },
              { "label_description" },
            },
          },
        },
      },
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      menu = {
        auto_show = true,
        border = "rounded",
        draw = {
          components = {
            label = {
              text = function(ctx)
                -- Fix for weird rendering in ElixirLS structs/behaviours etc
                -- structs, behaviours and others have a label_detail emitted
                -- by ElixirLS, and it looks bad when there's no space between
                -- the module label and the label_detail.
                --
                -- The label_detail has no space because it is normally meant
                -- for function signatures, e.g. `my_function(arg1, arg2)` -
                -- this case the label is `my_function` and the label_detail
                -- is `(arg1, arg2)`.
                --
                -- In an ideal world ElixirLS would not emit them for these
                -- types - these belong in `kind` only.
                if ctx.item.client_name == "elixirls" and ctx.kind ~= "Function" and ctx.kind ~= "Macro" then
                  return ctx.label
                end

                return ctx.label .. ctx.label_detail
              end,
            },
          },
          treesitter = { "lsp" },
          columns = {
            { "kind_icon", "label", gap = 1 },
            { "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = {
          -- for each of the possible menu window directions,
          -- falling back to the next direction when there's not enough space
          direction_priority = {
            menu_north = { "e", "w", "n", "s" },
            menu_south = { "e", "w", "s", "n" },
          },
        },
      },
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      -- providers = {
      -- copilot = {
      --   name = "copilot",
      --   module = "blink-cmp-copilot",
      --   -- score_offset = 10,
      --   async = true,
      -- },
      -- },
      per_filetype = {
        codecompanion = { "codecompanion" },
      },
    },
  },
}
