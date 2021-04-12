
togit(){
    cd ~/Github
}

# Reset everything to master and stash any locals
reset-repos(){
    togit
    for repo in *
    do
        echo "Resetting $repo ..."
        cd $repo
        git stash
        git checkout master
        git pull -p
        togit
    done
}

# Clean branches
# NOTE: the asterisk (*) in "git branch" output expands to local dir files,
# So we must wrap this in string quotes to avoid executing * as a command
# And it is not advised to use that command anyhow, so using git for-each-ref
prune-branches(){
  LOCAL_BRANCHES=$(git for-each-ref --format '%(refname:short)' refs/heads)
  for branch in $LOCAL_BRANCHES
  do
    if [ $branch = "main" ] || [ $branch = "master" ]; then
      echo "Ignoring main/master branch"
    else
      echo "Deleting branch $branch"
      git branch -D $branch
    fi
  done
}

# Clones all repos for an org
# Assumes you've set up a $GITHUB_TOKEN personal access token and have jq installed
clone-github-repos(){
  if [ -z "$1" ]; then
    echo 'Arg $1 should be org name!'
    return
  fi

  RAW_JSON=$(curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$1/repos?per_page=100)
  SSH_URLS=$(jq '.[] .ssh_url' <<< $RAW_JSON -r)
  
  togit

  for url in $SSH_URLS
  do
    echo "Cloning $url ..."

    git clone $url
  done

  echo "Cloned all repos!"
}