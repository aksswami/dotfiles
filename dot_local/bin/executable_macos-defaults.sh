#!/usr/bin/env bash
#
# macOS defaults — opt-in. Run manually: `macos-defaults.sh`
# NOT auto-run by chezmoi apply. Salvaged + modernized from the 2017 dotfiles
# (holman fork). Dated Safari debug-menu tweaks were dropped.
#
set -euo pipefail

echo "Applying macOS defaults…"

# --- Keyboard -------------------------------------------------------------
# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false
# Fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- Finder ---------------------------------------------------------------
# Always use list view.
defaults write com.apple.Finder FXPreferredViewStyle -string "Nlsv"
# Show the ~/Library folder.
chflags nohidden ~/Library || true
# Show external + removable drives on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# --- Sharing / network ----------------------------------------------------
# Use AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# --- Dock / hot corners ---------------------------------------------------
# Bottom-left hot corner starts the screensaver.
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

echo "Restarting affected apps…"
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "Done. Some settings take effect after logout/restart."
