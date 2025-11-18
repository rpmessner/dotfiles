local M = {}
M.setup = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp", {}),
    callback = function(args)
      local bufnr = args.buf -- The buffer number
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

      require("config.keymaps").lsp_mappings()

      local existing_capabilities = client.config.capabilities or vim.lsp.protocol.make_client_capabilities()
      -- merge blink cmp capabilities
      client.config.capabilities = require("blink.cmp").get_lsp_capabilities(existing_capabilities)
    end,
  })
end
return M
