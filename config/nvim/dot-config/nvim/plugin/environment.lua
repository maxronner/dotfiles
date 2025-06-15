local function is_gpg_locked(err_msg)
  return err_msg:match("gpg: decryption failed") or
      err_msg:match("no secret key") or
      err_msg:match("no agent running") or
      err_msg:match("batchmode") or
      err_msg:match("sorry") or
      err_msg:match("gpg:")
end

local function get_pass_entry(entry, callback)
  local output = {}
  local err_output = {}

  vim.fn.jobstart({ "pass", entry }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(output, line) end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(err_output, line) end
        end
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        local result = table.concat(output, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
        callback(result, nil)
      else
        local err_msg = table.concat(err_output, "\n")
        -- Detect common GPG lock/failure messages
        if is_gpg_locked(err_msg:lower()) then
          -- fallback to blocking system() call
          local result = vim.fn.system({ "pass", entry })
          if vim.v.shell_error == 0 then
            result = result:gsub("^%s+", ""):gsub("%s+$", "")
            callback(result, nil)
          else
            callback(nil, result)
          end
        else
          callback(nil, err_msg ~= "" and err_msg or "Unknown error")
        end
      end
    end,
  })
end

local function load_key(name, env_var)
  get_pass_entry(name, function(key, err)
    if key then
      vim.env[env_var] = key
      vim.notify(env_var .. " loaded", vim.log.levels.INFO)
    else
      vim.notify("Failed to load " .. env_var .. ": " .. err, vim.log.levels.WARN)
    end
  end)
end

load_key("Credentials/keys/openai", "OPENAI_API_KEY")
load_key("Credentials/keys/gemini", "GEMINI_API_KEY")
