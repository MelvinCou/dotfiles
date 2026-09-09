# config.nu
#
# Installed by:
# version = "0.106.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# ----------------------
# Miscellaneous Settings
# ----------------------

# show_banner (bool|string): Enable or disable the welcome banner at startup
# true | "full": show the full banner
# "short": just show the start-up time
# false | "none": don't show a banner
$env.config.show_banner = false

# ---------------------------
# Commandline Editor Settings
# ---------------------------

# edit_mode (string) "vi" or "emacs" sets the editing behavior of Reedline
$env.config.edit_mode = "vi"

# buffer_editor (string|list|null): Command to edit the current line buffer with Ctrl+O.
# null: Uses $env.VISUAL, then $env.EDITOR, then falls back to default.
# string: Command name to invoke (e.g., "vim", "nano", "code --wait").
# list: Command with arguments as a list (e.g., ["vim", "-p"]).
# Default: null
$env.config.buffer_editor = [ "nvim", "vim", "notepad", "nano" ] | where {|x| which $x | is-not-empty} | first

# cursor_shape.vi_normal (string): Cursor shape when in vi normal mode.
# One of: "block", "underscore", "line", "blink_block", "blink_underscore", "blink_line", or "inherit".
# Default: "inherit"
$env.config.cursor_shape.vi_normal = "blink_block"

# cursor_shape.vi_insert (string): Cursor shape when in vi insert mode.
# One of: "block", "underscore", "line", "blink_block", "blink_underscore", "blink_line", or "inherit".
# Default: "inherit"
$env.config.cursor_shape.vi_insert = "blink_line"

# --------------------
# Completions Behavior
# --------------------

# completions.algorithm (string): The algorithm used for matching completions.
# "prefix": Match from the beginning of the text.
# "substring": Match anywhere in the text.
# "fuzzy": Match using fuzzy matching algorithm.
# Default: "prefix"
$env.config.completions.algorithm = "fuzzy"

# ---------------------------------------------------------------------------------------
# Environment Variables
# ---------------------------------------------------------------------------------------
# The following are environment variables (not $env.config settings) that affect Nushell.

# ------
# Prompt
# ------
# PROMPT_ variables accept either a string or a closure that returns a string.

# PROMPT_INDICATOR_VI_NORMAL: Prompt indicator in vi normal mode.
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# PROMPT_INDICATOR_VI_INSERT: Prompt indicator in vi insert mode.
$env.PROMPT_INDICATOR_VI_INSERT = ""
