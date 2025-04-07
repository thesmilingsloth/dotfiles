function help {
  echo "Usage: prepare/mac.sh <command>"
  echo
  echo "Options:"
  echo "  run-all                 Run all tasks"
  echo "  create-dirs             Create directories"
  echo "  preflight               Initialize preflight checklist"
  echo "  clone-dotfiles          Clone dotfiles repository"
  echo "  homebrew                Install homebrew"
  echo "  packages                Install all packages"
  echo "  link                    Symlink config files and directories"

  echo
  echo "  help                    Display this help message"
  echo
  echo "Examples:"
  echo "  prepare/mac.sh run-all"
  echo "  prepare/mac.sh create-dirs"
  echo "  prepare/mac.sh preflight"
  echo "  prepare/mac.sh clone-dotfiles"
  echo "  prepare/mac.sh homebrew"
  echo "  prepare/mac.sh packages"
  echo "  prepare/mac.sh link"
  echo

  exit 0
}

# Check if no arguments were provided
if [ $# -eq 0 ]; then
  help
fi

readonly __CLONE_DOTFILES_PATH="$HOME/Documents/00-Device/00-Configuration"
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

function install_homebrew {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function install_packages {
  echo "⏳ Starting brew install..."
  echo
  brew bundle
  echo
  echo "✅ Brew install complete."
}

function stow_home {
  echo "🔗 Symlinking config files and directories..."
  echo

  # Unstows(delete symlinks) existing symlinks from the HOME directory
  echo "🔍 Checking for existing symlinks..."
  if stow -t $HOME -D stow; then
    echo "✅ Removed existing symlinks"
  else
    echo "❌ Failed to remove existing symlinks"
    exit 1
  fi

  echo

  # Stows(create symlinks) to the HOME directory
  echo "🔍 Creating symlinks..."
  if stow -v -t $HOME stow; then
    echo "✅ Symlinks created successfully"
  else
    echo "❌ Failed to create symlinks"
    exit 1
  fi
}

function install_zsh_plugins {
  echo "⏳ Installing zsh plugins..."

  if [ ! -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    echo "❌ zsh-autosuggestions not found. Installing..."

    # check if directory exists and is empty, if not empty and then clone
    if [ -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]; then
      rm -rf $ZSH_CUSTOM/plugins/zsh-autosuggestions
    fi

    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
  else
    echo "✅ zsh-autosuggestions found."
  fi

  if [ ! -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    echo "❌ zsh-syntax-highlighting not found. Installing..."
    brew install zsh-syntax-highlighting
  else
    echo "✅ zsh-syntax-highlighting found."
  fi

  if [ ! -f ~/.zsh/you-should-use/you-should-use.plugin.zsh ]; then
    echo "❌ you-should-use not found. Installing..."

    # check if directory exists and is empty, if not empty and then clone
    if [ -d $ZSH_CUSTOM/plugins/you-should-use ]; then
      rm -rf $ZSH_CUSTOM/plugins/you-should-use
    fi

    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
  else
    echo "✅ you-should-use found."
  fi

  echo "✅ zsh plugins installed."
}

function preflight_terminal {
  echo "💻 Setting up terminal..."
  echo

  # Zsh already gets installed in brew bundle, but this is a check to ensure it's installed
  if ! command -v zsh &>/dev/null; then
    echo "❌ zsh not found. Installing..."
    brew install zsh
  else
    echo "✅ zsh found."
  fi

  if [ ! command -v omz ] &>/dev/null; then
    echo "❌ oh-my-zsh not found. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
  else
    echo "✅ oh-my-zsh found."
  fi

  install_zsh_plugins

  echo
  echo "✅ Terminal setup complete."
}

function preflight_checklist {
  echo "🚀 Starting preflight checklist..."
  echo

  echo "🔍 Checking for xcode-select..."

  if ! xcode-select -p &>/dev/null; then
    echo "❌ xcode-select not found. Installing..."
    xcode-select --install
  else
    echo "✅ xcode-select found."
  fi

  echo
  echo "🔍 Checking for Homebrew..."

  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew not found. Installing..."
    install_homebrew
  else
    echo "✅ Homebrew found."
  fi

  echo
  echo "🔍 Checking for Brewfile..."

  if [ ! -f Brewfile ]; then
    echo "❌ Brewfile not found. Exiting..."
    exit 1
  else
    echo "✅ Brewfile found."
    install_packages
  fi

  preflight_terminal

  echo
  echo "✅ Preflight checklist complete."
}

function clone_dotfiles {
  echo "📦 Cloning dotfiles..."
  echo

  if [ ! -d $HOME/Documents/00-Device/00-Configuration ]; then
    echo "❌ dotfiles directory not found. Creating..."
    
    mkdir -p $HOME/Documents/00-Device/00-Configuration
  fi

  if [ -d $HOME/Documents/00-Device/00-Configuration/dotfiles ]; then
    echo "❌ dotfiles directory already exists. Exiting..."
    exit 1
  else
    git clone https://github.com/thesmilingsloth/dotfiles.git $__CLONE_DOTFILES_PATH/dotfiles
  fi

  echo
  echo "✅ dotfiles cloned successfully."
}

function create_directories {
  declare -a directories=(
    "$HOME/Documents/00-Device"
    "$HOME/Documents/00-Device/00-Configuration"
    "$HOME/Documents/00-Device/01-Screenshot"
    "$HOME/Documents/01-Personal"
    "$HOME/Documents/02-Work"
    "$HOME/Documents/99-Archived"
  )

  echo "📁 Creating directories in Documents..."

  for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"

      echo "✅ Directory $dir created."
    else
      echo "❌ Directory $dir already exists."
    fi
  done

  echo "✅ Directory creation process completed."
}

for i in "$@"; do
  case $i in
  run-all)
    create_directories
    preflight_checklist
    clone_dotfiles
    stow_home

    # Setup macOS specific configurations and settings
    for file in $(dirname $0)/mac/*.sh; do
      echo "🔥 Running $file..."

      bash $file
    done
    ;;

  create-dirs)
    create_directories
    ;;

  preflight)
    preflight_checklist
    ;;

  clone-dotfiles)
    clone_dotfiles
    ;;

  homebrew)
    install_homebrew
    ;;

  packages)
    install_packages
    ;;

  link)
    stow_home
    ;;

  help)
    help
    ;;

  *)
    echo "❌ Invalid command. Exiting..."
    ;;

  esac

done

echo
# Reload shell once installed
echo "🔄 Reloading shell..."
exec $SHELL -l
