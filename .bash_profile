
# some basic functions that I almost always end up rewriting in my bash profile

# Go to git parent directory
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