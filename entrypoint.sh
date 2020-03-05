#!/bin/sh -l

GITHUB_TOKEN=$1

last_commit=$(git log --format=%B -n 1)
current_branch=$(git rev-parse --abbrev-ref HEAD)

regex="^Bump.*to.[0-9]+\.[0-9]+\.[0-9]+"
pre_regex="^Bump.*to.[0-9]+\.[0-9]+\.[0-9]+\.pre[0-9]+"

# Only release gem if has a correct bump commit
if [ "$current_branch" == "master" ] && echo "$last_commit" | grep -Eq $regex || [ "$current_branch" != "master" ] && echo "$last_commit" | grep -Eq $pre_regex; then
  if [ -z "${GITHUB_TOKEN}" ]
    echo "Missing GITHUB_TOKEN!"
    exit 2
  fi

  echo "Setting up access to GitHub Package Registry"
  mkdir -p ~/.gem
  touch ~/.gem/credentials
  chmod 600 ~/.gem/credentials
  echo ":github: Bearer ${GITHUB_TOKEN}" >> ~/.gem/credentials

  echo "Building the gem"
  gem build *.gemspec
  echo "Pushing the built gem to GitHub Package Registry"
  gem push --key github --host "https://rubygems.pkg.github.com/appfolio" *.gem
else
  if [ "$current_branch" == "master" ]; then
    echo "Last commit was not in the proper format of 'Bump <gem_name> to <major>.<minor>.<patch>'"
  else
    echo "Last commit was not in the proper format of 'Bump <gem_name> to <major>.<minor>.<patch>.pre<pre>'"
  fi
  echo "Use the command \`gem bump --version 'major|minor|patch|pre'\`"
  echo "Gem not pushed to Github Package Registry"
fi
