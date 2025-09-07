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

# Command that will be used to edit the current line buffer with Ctrl+O.
# If unset, uses $env.VISUAL and then $env.EDITOR
#
# Tip: Set to "editor" to use the default editor on Unix platforms using
#      the Alternatives system or equivalent
$env.config.buffer_editor = "
{{- if lookPath "nvim" -}}
nvim
{{- else if lookPath "vim" -}}
vim
{{- else if lookPath "notepad" -}}
notepad
{{- end -}}
"

# ---------------------------
# Other
# ---------------------------

source .zoxide.nu
source .carapace.nu
{{- if lookPath "winget" }}
source .winget.nu
{{- end }}
