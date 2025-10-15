# px-to-rem.nvim

A simple Neovim plugin to convert px to rem, with a source for the fantastic [blink.cmp](https://github.com/saghen/blink.cmp) completion plugin.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'DaanHoogendoorn/px-to-rem.nvim',
  lazy = false, -- handled internally
  ---@type PxToRemConfig
  opts = {},
}
```

### blink.cmp source

Add `px-to-rem` to your blink sources like so:

```lua
sources = {
  default = { 'lsp', 'px_to_rem', 'path', 'snippets', 'buffer' },
  providers = {
    px_to_rem = {
      name = 'px_to_rem',
      module = 'px-to-rem.integrations.blink_cmp',
    },
  },
}
```

<details>
  <summary>Example from my own config</summary>

```lua
return {
  {
    'saghen/blink.cmp',
    lazy = false, -- lazy loading handled internally
    -- optional: provides snippets for the snippet source
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        event = 'BufRead',
      },
      {
        'L3MON4D3/LuaSnip',
        event = 'BufRead',
        init = function()
          require 'config.snippets'
        end,
      },
    },

    -- use a release tag to download pre-built binaries
    version = 'v1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },

      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      signature = {
        enabled = true,
      },

      snippets = {
        preset = 'luasnip',
      },

      sources = {
        default = { 'lsp', 'lazydev', 'px_to_rem', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'lazydev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          px_to_rem = {
            name = 'px_to_rem',
            module = 'px-to-rem.integrations.blink_cmp',
          },
        },
      },
    },
    -- allows extending the enabled_providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.completion.enabled_providers' },
  },
}
```
</details>

### Configuration

Below is a full example of the configuration with all the default values:

```lua
{
  'DaanHoogendoorn/px-to-rem.nvim',
  lazy = false,
  ---@type PxToRemConfig
  opts = {
    root_font_size = 16,                -- The root font size to use for rem conversion
    max_decimals = 3,                   -- The maximum number of decimals to round to
    filetypes = {                       -- The filetypes to enable the plugin for
      'css',
      'scss',
      'sass',
      'less',
    },
    notify = true,                      -- Whether to show notifications (see the commands)
    integrations = {
      vscode_cipchk_cssrem = false,     -- Support for determining the root font size and rounding decimals
    },
  },
}
```

## Usage

### `blink.cmp`

Simply start typing a number and the source will provide a suggestion for the value in rem.

### Commands

- `PxToRemConvertAtCursor`: Convert the number under the cursor to rem (can notify if there is an error)
- `PxToRemConvertAtLine`: Convert the px values in the current line to rem
- `PxToRemConvertBuffer`: Convert all px values in the current buffer to rem
- `PxToRemSetRootFontSize`: Set the root font size (can notify on change)
- `PxToRemSetDecimals`: Set the maximum number of decimals to round to (can notify on change)

## Integrations

### `vscode-cssrem`

The plugin can integrate with the [vscode-cssrem](https://github.com/cipchk/vscode-cssrem) extension to determine the root font size and rounding decimals based on the configuration for that extension.

## License

MIT
