local function is_gpg_locked(err_msg)
  return err_msg:match("decryption failed") or
      err_msg:match("no secret key") or
      err_msg:match("No secret key") or
      err_msg:match("No agent running") or
      err_msg:match("can't open") or
      err_msg:match("Permission denied") or
      err_msg:match("Inappropriate ioctl") -- common in terminal-less jobs
end

local function get_pass_entry(entry)
  local res = vim.system({ "pass", entry }, { text = true }):wait()
  if res.code == 0 then
    return vim.trim(res.stdout), nil
  end

  local err_msg = vim.trim(res.stderr or "")
  if is_gpg_locked(err_msg) then
    local fallback = vim.fn.system({ "pass", entry })
    if vim.v.shell_error == 0 then
      return vim.trim(fallback), nil
    else
      return nil, vim.trim(fallback)
    end
  end

  return nil, err_msg ~= "" and err_msg or "Unknown error"
end

local M = {}
M.keys = {}
local lazy_loaders = {}

local function register_lazy_key(pass_entry, var)
  lazy_loaders[var] = function()
    if M.keys[var] ~= nil then
      return
    end

    local key, err = get_pass_entry(pass_entry)
    if key then
      M.keys[var] = key
      return key
    else
      vim.notify("Failed to load " .. var .. ": " .. err, vim.log.levels.ERROR)
      return nil
    end
  end
end

local function load_var(var)
  local loader = lazy_loaders[var]
  if loader then
    loader()
  else
    vim.notify("No lazy loader registered for " .. var, vim.log.levels.DEBUG)
  end
end

function M.get_var(var)
  local val = M.keys[var]
  if val then return val end
  load_var(var)
  return M.keys[var]
end

function M.export_var(var)
  local val = M.get_var(var)
  if val then
    vim.env[var] = val
    return true
  end
  return false
end

register_lazy_key("Credentials/keys/openai", "OPENAI_API_KEY")
register_lazy_key("Credentials/keys/gemini", "GEMINI_API_KEY")
register_lazy_key("Credentials/keys/tavily", "TAVILY_API_KEY")

return M
