if $nu.os-info.name == windows {
    source nu_scripts/custom-completions/git/git-completions.nu

    source nu_scripts/custom-completions/windows/windows-completions.nu
    source nu_scripts/custom-completions/winget/winget-completions.nu
} else {
    source nu_scripts/custom-completions/git/git-completions.nu
}
