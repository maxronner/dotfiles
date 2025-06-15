local function get_pass_entry_async(entry, callback)
  local cmd = { "pass", entry }
  local output = {}
  local err_output = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then -- Filter out empty lines
            table.insert(output, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then -- Filter out empty lines
            table.insert(err_output, line)
          end
        end
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        local result = table.concat(output, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
        callback(result, nil)
      else
        local error_msg = table.concat(err_output, "\n")
        callback(nil, error_msg ~= "" and error_msg or "Unknown error")
      end
    end,
  })
end

local function load_openai_key()
  get_pass_entry_async("Credentials/keys/openai", function(key, err)
    if key then
      vim.env.OPENAI_API_KEY = key
      vim.notify("OpenAI API key loaded", vim.log.levels.INFO)
    else
      vim.notify("Failed to load OpenAI key: " .. (err or "unknown error"), vim.log.levels.WARN)
    end
  end)
end

local function load_gemini_key()
  get_pass_entry_async("Credentials/keys/gemini", function(key, err)
    if key then
      vim.env.GEMINI_API_KEY = key
      vim.notify("Gemini API key loaded", vim.log.levels.INFO)
    else
      vim.notify("Failed to load Gemini key: " .. (err or "unknown error"), vim.log.levels.WARN)
    end
  end)
end

-- Start loading keys asynchronously (non-blocking)
load_openai_key()
load_gemini_key()
