#!/usr/bin/env sh

usage() {
  echo "
Usage: $(basename ${0}) <file-to-adjust>

Forces the most recent commit to have a different commit hash. A hacky
workaround to allow, for example, erroneous Travis build failures to be
re-triggered by a new commit.

  file-to-adjust: Path to some text file to use for the dummy commits.
"
}

if [ $# -eq 0 ]; then
  usage
else
  echo "REMOVE" >> "${1}" && \
  git commit -a --fixup HEAD && \
  sed -i.bak '$ d' "${1}" && rm "${1}.bak" &&
  git commit -a --fixup HEAD && \
  git rebase -i --autosquash HEAD~3
fi

exit $?

