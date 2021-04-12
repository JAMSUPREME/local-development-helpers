
# some basic functions that I almost always end up rewriting in my bash profile

generate_ssh_key(){
  if [ -z "$1" ]; then
    echo 'Arg $1 should be email!'
    return
  fi
  ssh-keygen -t rsa -b 4096 -C $1
}