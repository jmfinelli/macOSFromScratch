#!/usr/bin/env zsh
# Run on a fresh macOS machine to install all packages and configure the shell.
# Usage: zsh packages_installation.sh
#
# - Skips steps that are already complete (idempotent)
# - Continues past failures and prints a summary at the end

set -uo pipefail

FAILED_STEPS=()

step() {
    local name="$1"; shift
    printf "\n-> %s\n" "$name"
    if "$@"; then
        printf "   [ok]\n"
    else
        printf "   [FAIL] — will continue\n" >&2
        FAILED_STEPS+=("$name")
    fi
}

# Append a single line to ~/.zshrc only if the marker string is not already present.
# Adds a blank line before the new line.
zshrc_append() {
    local marker="$1"
    local line="$2"
    grep -qF "$marker" ~/.zshrc 2>/dev/null || printf '\n%s\n' "$line" >> ~/.zshrc
}

clone_if_missing() {
    local url="$1"
    local dest="$2"
    shift 2
    [ -d "$dest" ] || git clone "$@" "$url" "$dest"
}

summary() {
    printf "\n%s\n" "=================================================="
    if [ ${#FAILED_STEPS[@]} -eq 0 ]; then
        printf "All steps completed successfully.\n"
    else
        printf "Completed with %d failure(s):\n" "${#FAILED_STEPS[@]}"
        for s in "${FAILED_STEPS[@]}"; do printf "  - %s\n" "$s"; done
        printf "\nRe-run the script or install failed steps manually.\n"
    fi
}

# ============================================================
# Shell: zsh, oh-my-zsh, plugins, fonts
# ============================================================
printf "\n=== Shell ===\n"

step "git" brew install git
step "zsh" brew install zsh

install_ohmyzsh() {
    if [ -d ~/.oh-my-zsh ]; then
        printf "   already installed, skipping\n"; return 0
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
step "oh-my-zsh" install_ohmyzsh

step "powerlevel10k theme" \
    clone_if_missing \
    "https://github.com/romkatv/powerlevel10k.git" \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" \
    --depth=1

step "zshrc: ZSH_THEME=powerlevel10k" \
    zshrc_append 'ZSH_THEME="powerlevel10k/powerlevel10k"' 'ZSH_THEME="powerlevel10k/powerlevel10k"'

step "zsh-autosuggestions plugin" \
    clone_if_missing \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

step "zsh-completions plugin" \
    clone_if_missing \
    "https://github.com/zsh-users/zsh-completions.git" \
    "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions"

step "zsh-syntax-highlighting plugin" \
    clone_if_missing \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

step "zsh-you-should-use plugin" \
    clone_if_missing \
    "https://github.com/MichaelAquilina/zsh-you-should-use.git" \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use"

step "font: Hack Nerd Font"         brew install --cask font-hack-nerd-font
step "font: JetBrains Mono Nerd"    brew install --cask font-jetbrains-mono-nerd-font

# ============================================================
# Terminals
# ============================================================
printf "\n=== Terminals ===\n"

step "ghostty"  brew install --cask ghostty
step "iterm2"   brew install --cask iterm2

# ============================================================
# Python (pyenv)
# ============================================================
printf "\n=== Python ===\n"

step "pyenv dependencies" \
    brew install openssl@3 readline sqlite3 xz tcl-tk@8 libb2 zstd zlib pkgconfig

step "pyenv" brew install pyenv

setup_pyenv_zshrc() {
    if grep -qF 'pyenv init' ~/.zshrc 2>/dev/null; then
        printf "   already in .zshrc, skipping\n"; return 0
    fi
    cat >> ~/.zshrc << 'ZSHRC'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
ZSHRC
}
step "zshrc: pyenv init" setup_pyenv_zshrc

# ============================================================
# Java (sdkman)
# ============================================================
printf "\n=== Java ===\n"

install_sdkman() {
    if [ -d ~/.sdkman ]; then
        printf "   already installed, skipping\n"; return 0
    fi
    curl -s https://get.sdkman.io | zsh
}
step "sdkman" install_sdkman

install_java() {
    if [ ! -d ~/.sdkman ]; then
        printf "   sdkman not found, skipping\n" >&2; return 1
    fi
    # shellcheck disable=SC1091
    source ~/.sdkman/bin/sdkman-init.sh
    sdk install java
}
step "java (latest LTS via sdkman)" install_java

install_maven() {
    if [ ! -d ~/.sdkman ]; then
        printf "   sdkman not found, skipping\n" >&2; return 1
    fi
    source ~/.sdkman/bin/sdkman-init.sh
    sdk install maven
}
step "maven (via sdkman)" install_maven

# ============================================================
# IDEs & Editors
# ============================================================
printf "\n=== IDEs & Editors ===\n"

step "intellij-idea" brew install --cask intellij-idea

# ============================================================
# CLI Utilities
# ============================================================
printf "\n=== CLI Utilities ===\n"

step "gh (GitHub CLI)"  brew install gh
step "openssh"          brew install openssh
step "gpg"              brew install gpg
step "pinentry"         brew install pinentry

setup_gpg() {
    mkdir -p ~/.gnupg
    grep -qF 'pinentry-program' ~/.gnupg/gpg-agent.conf 2>/dev/null || \
        printf 'pinentry-program %s/bin/pinentry\n' "$(brew --prefix)" >> ~/.gnupg/gpg-agent.conf
    grep -qF 'use-agent' ~/.gnupg/gpg.conf 2>/dev/null || \
        printf 'use-agent\n' >> ~/.gnupg/gpg.conf
    grep -qF 'GPG_TTY' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc << 'ZSHRC'

# Allow GPG to prompt with pinentry
export GPG_TTY=$(tty)
ZSHRC
}
step "GPG config" setup_gpg

step "grep (GNU)"   brew install grep
step "coreutils"    brew install coreutils
step "gnu-sed"      brew install gnu-sed
step "findutils"    brew install findutils

setup_gnu_paths() {
    grep -qF 'opt/grep/libexec/gnubin' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc << 'ZSHRC'

# GNU grep (use grep instead of ggrep)
PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
ZSHRC
    grep -qF 'opt/gnu-sed/libexec/gnubin' ~/.zshrc 2>/dev/null || cat >> ~/.zshrc << 'ZSHRC'

# GNU sed and other GNU bin files
PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
ZSHRC
}
step "zshrc: GNU tool paths" setup_gnu_paths

step "helm"             brew install helm
step "hugo"             brew install hugo
step "node"             brew install node
step "openshift-cli"    brew install openshift-cli

setup_oc_completion() {
    if grep -qF '# autocompletion for openshift cli' ~/.zshrc 2>/dev/null; then
        printf "   already in .zshrc, skipping\n"; return 0
    fi
    cat >> ~/.zshrc << 'ZSHRC'

# autocompletion for openshift cli
if command -v oc &>/dev/null; then
  source <(oc completion zsh)
  compdef _oc oc
fi
ZSHRC
}
step "zshrc: openshift CLI completion" setup_oc_completion

step "rclone"           brew install rclone
step "git-filter-repo"  brew install git-filter-repo
step "git-gui"          brew install git-gui
step "bfg"              brew install bfg
step "act"              brew install act
step "ollama"           brew install ollama

# ============================================================
# Apps
# ============================================================
printf "\n=== Apps ===\n"

step "firefox"          brew install --cask firefox
step "zen-browser"      brew install --cask zen-browser
step "breaktimer"       brew install --cask breaktimer
step "maccy"            brew install --cask maccy
step "monitorcontrol"   brew install --cask monitorcontrol
step "logseq"           brew install --cask logseq
step "spotify"          brew install --cask spotify
step "netnewswire"      brew install --cask netnewswire
step "logi-options+"    brew install --cask logi-options+
step "gimp"             brew install --cask gimp
step "utm"              brew install --cask utm
step "cyberduck"        brew install --cask cyberduck
step "bitwarden"        brew install --cask bitwarden
step "nordvpn"          brew install --cask nordvpn
step "session"          brew install --cask session

# ============================================================
# Cloud
# ============================================================
printf "\n=== Cloud ===\n"

step "gcloud-cli" brew install --cask gcloud-cli
printf "\n   NOTE: Run 'gcloud init' manually after the script completes.\n"

# ============================================================
# AI
# ============================================================
printf "\n=== AI ===\n"

step "nono"         brew install nono
step "opencode"     brew install anomalyco/tap/opencode-v2
step "claude-code"  brew install --cask claude-code

install_pi() {
    if command -v pi &>/dev/null; then
        printf "   already installed, skipping\n"; return 0
    fi
    curl -fsSL https://pi.dev/install.sh | sh
}
step "pi" install_pi

# ============================================================
# Summary
# ============================================================
summary
