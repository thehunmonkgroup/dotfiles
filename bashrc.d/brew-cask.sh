# During rsync/ssh commands, brew isn't initialized, so test for it here
# before using it.
brew_initialized=`which brew` 2> /dev/null
if [ -n "$brew_initialized" ]; then
  alias casktoken="$(brew --repository)/Library/Taps/caskroom/homebrew-cask/developer/bin/generate_cask_token"
  alias caskrepo="cd $(brew --repository)/Library/Taps/caskroom/homebrew-cask"
  alias caskupgrade="brew update && brew cleanup && brew cask cleanup"
fi
