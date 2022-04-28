vit() {
  cd ~/git/vit && PYTHONPATH=${HOME}/git/vit python vit/command_line.py "$@"
}
export -f vit
