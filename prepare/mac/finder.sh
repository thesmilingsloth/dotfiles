#!/bin/bash

#####################
# Finder's Settings #
#####################

# Set default Finder location to documents
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/sloth/Documents/"

# IMPORTANT: Keep all Finder related settings above this line
# Restart Finder for above settings to reflect
killall Finder

#####################
# Finder's Settings #
#####################
