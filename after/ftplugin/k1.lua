local stdlib_dir = "/Users/knix/dev/k1/k1lib"
-- local lsp_binary = "/Users/knix/dev/k1/target/release/lsp"
local lsp_binary = "/Users/knix/dev/k1/target/debug/lsp"

-- vim.diagnostic.config({
--   update_in_insert = true
-- })

function Start_K1(reuse)
  local opts = nil
  if reuse then
    opts = {
      reuse_client = function(client, config)
        return false
      end
    }
  end
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  local root_dir = vim.fs.dirname(file)
  vim.lsp.start({
    name = 'k1-lsp',
    cmd = { lsp_binary },
    cmd_env = { K1_LIB_DIR = stdlib_dir, RUST_BACKTRACE = '1' },
    -- root_dir = vim.fs.dirname(vim.buf),
    root_dir = root_dir
  }, opts)
end

Start_K1()

vim.api.nvim_create_user_command("K1reload", function(args)
  local c = vim.system({ './build_lsp.sh' }):wait()
  if c.code ~= 0 then
    vim.cmd.echomsg('Failed')
    return
  end
  local k1_clients = vim.lsp.get_clients({ name = 'k1-lsp' })
  for i, client in ipairs(k1_clients) do
    -- Only detaches the current buffer, good enough for now
    vim.lsp.buf_detach_client(0, client.id)
  end
  vim.lsp.stop_client(k1_clients)
  Start_K1()
end, { desc = "Re-compile and reload K1 lsp server" })
