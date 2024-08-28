#!/bin/bash

###################
# Dock's Settings #
###################

# Remove all icons from the Dock
defaults write com.apple.dock persistent-apps -array

# Disable Show Recent applications from Dock
defaults write com.apple.dock show-recents -bool FALSE

# Reduce icon size in the dock -- default size is 64
defaults write com.apple.dock tilesize -int 32

# Enable auto hide dock
defaults write com.apple.dock autohide -bool TRUE

# Disabl auto-rearrange spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool FALSE

# Show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool TRUE

# IMPORTANT: Keep all Dock related settings above this line
# Restart Dock for above settings to reflect
killall Dock

###################
# Dock's Settings #
###################
