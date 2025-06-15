local function get_pass_entry(entry)
  local handle = io.popen("pass " .. entry)
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result and result:gsub("%s+$", "")
  end
end

vim.g.openai_api_key = get_pass_entry("Credentials/keys/openai")
vim.g.gemini_api_key = get_pass_entry("Credentials/keys/gemini")
vim.g.ha_token       = get_pass_entry("Credentials/tokens/home-assistant")
