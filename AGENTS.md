# Neovim Configuration Guide

## Repository Layout

This repository is the live Neovim configuration:

- `~/.config/nvim` is a symlink to `/Users/rs10/dotfiles/nvim`.
- `nvim/` is a Git submodule of the parent dotfiles repository. Inspect file
  changes with `git -C /Users/rs10/dotfiles/nvim status` and `git diff` from
  this directory; the parent repository only reports the submodule state.

## Configuration Architecture

- `init.lua` sets leaders and loads `lua/core/init.lua`.
- `lua/core/` owns options, autocmds, keymaps, highlights, and Lazy setup.
- `lua/plugin/` contains one Lazy plugin spec per file, grouped by feature.
- `lsp/` contains Neovim 0.11+ native LSP configurations.
- `after/ftplugin/` contains buffer-local language settings.
- Lazy imports `lua/plugin/` plus each immediate subdirectory dynamically;
  adding another immediate feature directory does not require a central list.

## LSP and Darwin Details

- Use the public Neovim 0.12 APIs `vim.lsp.config()` and `vim.lsp.enable()`.
- Prefer `vim.filetype.add()` over `BufRead`/`BufNewFile` autocmds for filetype
  detection.
- Neovim merges LSP configuration in this priority order: wildcard `"*"`,
  runtime `lsp/<name>.lua`, `after/lsp/<name>.lua`, then explicit named user
  configuration.
- Reading `vim.lsp.config[name]` resolves and evaluates that server's runtime
  configuration. Never enumerate and resolve every `lsp/*.lua` file during
  startup.
- On macOS, `vim.lsp._watchfiles` uses libuv/kqueue (`vim._watch.watch`) and
  can EMFILE in large repos. `lua/plugin/lsp/darwin/watchers.lua` no-ops
  `_watchfunc` and stubs `register` so no server can re-enable it; do not
  reintroduce capability/`before_init` hacks.
- Preserve server-specific `before_init` functions.

## Startup Performance Invariants

- Optional plugins must load by `event`, `cmd`, `ft`, `keys`, or on-demand Lua
  module loading. Avoid `lazy = false` unless the initial UI requires it.
- `nvim-ufo` is an intentional eager-load exception. Commit `801d4c3` fixed
  broken fold initialization by replacing `BufReadPost` loading with
  `lazy = false`; do not defer it without reproducing and solving that issue.
- UFO's internal `BufWinEnter` retry can precede its asynchronous provider
  result and leave the first displayed file pending. Keep the one-time delayed
  refresh in the UFO config; it waits for Normal mode and uses `enableFold()`.
- fzf-lua preview windows disable folding. A previewed buffer selected as the
  real file can leave UFO ranges pending, so keep the deferred public
  `ufo.enableFold()` recovery in fzf-lua's `winopts.on_close` callback.
- The rewritten `main` branch of `nvim-treesitter` explicitly does not support
  lazy-loading. Keep its plugin spec at `lazy = false`; parser installation
  remains asynchronous.
- Colorscheme plugins should use `lazy = true`; Lazy's `ColorSchemePre` loader
  loads the requested scheme automatically.
- Apply configured themes through `lua/core/theme.lua`. Neovim 0.12 includes a
  built-in `catppuccin` scheme which otherwise prevents Lazy from loading the
  configured Catppuccin plugin on a name collision.
- Keep Lazy's automatic update checker disabled. Its post-start Git metadata
  scan blocks the main thread; use `:Lazy check` manually.
- Keep Lazy change detection disabled to avoid its periodic filesystem timer.
- Avoid synchronous processes, network access, and broad filesystem scans on
  the startup path.
- `VeryLazy` is after the first UI frame but still affects perceived
  responsiveness. Prefer command, key, filetype, or module loading for tools
  that are not needed every session.
- Treesitter parser installation is asynchronous, but do not add `:wait()` to
  normal startup configuration.

## Validation

Run these from this repository:

```sh
stylua --check .
git diff --check
nvim --headless -i NONE +qa
nvim --headless -i NONE \
  '+lua print(vim.inspect(require("lazy").stats()))' +qa
nvim --headless -i NONE --startuptime /dev/stdout +qa
```

For startup comparisons, use multiple warm runs. Disable ShaDa with `-i NONE`
so profiling does not write editor state. A headless run does not trigger
`UIEnter`/`VeryLazy` exactly like an interactive TUI, so measure post-UI work
separately when investigating perceived responsiveness.

Do not run plugin install, update, sync, or cache-clearing commands unless
explicitly requested.

## Editing Conventions

- Format Lua with StyLua and preserve tab indentation.
- Keep changes scoped and retain unrelated user modifications.
- Prefer small, feature-local modules over adding work to `core/init.lua`.
- Update comments when an API or performance assumption changes.
