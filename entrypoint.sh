#!/bin/bash

cd "${GITHUB_WORKSPACE}" \
  || (echo "Workspace is unavailable" >&2; exit 1)

set -eu
set -x

BRANCH=$(git symbolic-ref -q --short HEAD) \
  || (echo "You are in 'detached HEAD' state." >&2; exit 1)

echo -e "machine github.com\nlogin ${INPUT_GITHUB_TOKEN}" > ~/.netrc
git config user.name ${INPUT_GIT_USER}
git config user.email ${INPUT_GIT_EMAIL}

GRADLE_BIN="${GITHUB_WORKSPACE}/gradlew"

find . -type f \( -name build.gradle -o -name build.gradle.kts \) | while read dir
do
  cd $(dirname ${dir})
  ${GRADLE_BIN} dependencies --write-locks
done

files=$(git diff --name-only)
if [[ -z "${files}" ]]
then
  echo "Up-to-date"
  exit 0
fi

case ${INPUT_COMMIT_STYLE:-add} in
  add)
    git add ${files};
    git commit -m ${INPUT_COMMIT_MESSAGE:-"Fix go.sum"};
    ;;
  squash)
    git add ${files};
    git commit --amend --no-edit;
    ;;
  *)
    echo "Unknown commit_style value: ${INPUT_COMMIT_STYLE}" >&2;
    exit 1;
    ;;
esac

case ${INPUT_PUSH:-no} in
  no)
    ;;
  yes)
    git push origin ${BRANCH};
    ;;
  force)
    git push --force-with-lease origin ${BRANCH};
    ;;
  *)
    echo "Unknown push value: ${INPUT_PUSH}" >&2;
    exit 1;
    ;;
esac
