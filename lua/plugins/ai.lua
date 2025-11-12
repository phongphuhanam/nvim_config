-- Custom Parameters (with defaults)
return {
  -- quick LLM task
  {
    "phongphuhanam/gen.nvim",
    enable = true,
    opts = {
      model = "llama3.1", -- The default model to use.
      quit_map = "q", -- set keymap for close the response window
      retry_map = "<c-r>", -- set keymap to re-send the current prompt
      accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
      host = (os.getenv("OLLAMA_HOST") or "127.0.0.1"),
      port = "11434", -- The port on which the Ollama service is listening.
      display_mode = "vertical-split", -- The display mode. Can be "float" or "split" or "horizontal-split".
      show_prompt = false, -- Shows the prompt submitted to Ollama.
      show_model = true, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
      init = function(options)
        pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
      end,
      -- Function to initialize Ollama
      command = function(options)
        local body = { model = options.model, stream = true }
        return "curl --silent --no-buffer -X POST http://"
          .. options.host
          .. ":"
          .. options.port
          .. "/api/chat -d $body"
      end,
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a command string.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      -- list_models = '<omitted lua function>', -- Retrieves a list of model names
      debug = false, -- Prints errors and the command which is run.
    },
    keys = {
      { "<leader>as", ':lua require("gen").select_model()<cr>', desc = "Select model" },
    },
  },
  { -- LLMs
    "olimorris/codecompanion.nvim",
    version = "*",
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>ac", ":CodeCompanionChat Toggle<cr>", desc = "[a]i [c]hat" },
      { "<leader>aa", ":CodeCompanionActions<cr>", desc = "[a]i [a]actions" },
    },
    config = function()
      require("codecompanion").setup({
        display = {
          diff = {
            enabled = true,
          },
        },
        adapters = {
          http = {
            ollama = function()
              return require("codecompanion.adapters").extend("ollama", {
                name = "gpt-oss:latest",
                env = {
                  url = (os.getenv("OLLAMA_HOST") or "127.0.0.1") .. ":" .. tonumber(os.getenv("OLLAMA_PORT") or 11434),
                  -- api_key = "OLLAMA_API_KEY",
                },
                headers = {
                  ["Content-Type"] = "application/json",
                  -- ["Authorization"] = "Bearer ${api_key}",
                },
                parameters = {
                  sync = true,
                },
              })
            end,
          },
        },
        strategies = {
          chat = {
            adapter = "ollama",
            -- adapter = 'copilot',
          },
          inline = {
            adapter = "ollama",
            -- adapter = 'copilot',
          },
          agent = {
            adapter = "ollama",
            -- adapter = 'copilot',
          },
        },
      })
    end,
  },
}
