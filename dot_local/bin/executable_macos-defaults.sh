#!/usr/bin/env bash
#
# macOS defaults — opt-in. Run manually: `macos-defaults.sh`
# NOT auto-run by chezmoi apply.
#
set -euo pipefail

echo "Applying macOS defaults…"

# --- Keyboard -------------------------------------------------------------
# Hold a key = repeat, not the accent picker.
defaults write -g ApplePressAndHoldEnabled -bool false
# Fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- Text / typing (nicer for code) ---------------------------------------
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# --- Finder ---------------------------------------------------------------
# List view by default.
defaults write com.apple.Finder FXPreferredViewStyle -string "Nlsv"
# Show all filename extensions and hidden files.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show the path bar and status bar.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# Search the current folder by default.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Keep folders on top when sorting by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Show the ~/Library folder, and external/removable drives on the Desktop.
chflags nohidden ~/Library || true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Don't litter .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Dock (no auto-hide) --------------------------------------------------
# Smaller icons; don't rearrange Spaces by most-recent use.
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock mru-spaces -bool false
# Bottom-left hot corner starts the screensaver.
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# --- Screenshots ----------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Dialogs --------------------------------------------------------------
# Expand save and print panels by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
# Save new documents to disk (not iCloud) by default.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# --- Trackpad -------------------------------------------------------------
# Tap to click.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Sharing / network ----------------------------------------------------
# AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

echo "Restarting affected apps…"
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "Done. Some settings take effect after logout/restart."
