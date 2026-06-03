USER_COMPLETION_DIR="${HOME}/.bash_completion.d"

prefix=""
brewpath="$(command -v brew 2>/dev/null || true)"
if [ "${OS}" = "Darwin" ] && [ -n "${brewpath}" ]; then
  prefix="$(brew --prefix)"
fi

should_skip_completion_loading() {
  if [ -n "${CODEX_THREAD_ID:-}" ]; then
    return 0
  fi
  return 1
}

if [ -f "${prefix}/etc/bash_completion" ]; then
  . "${prefix}/etc/bash_completion"
fi

if ! should_skip_completion_loading && [ -d "${USER_COMPLETION_DIR}" ]; then
  for i in "${USER_COMPLETION_DIR}"/*; do
    . "${i}"
  done
fi
