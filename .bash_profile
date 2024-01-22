
# some basic functions that I almost always end up rewriting in my bash profile

generate_ssh_key(){
  if [ -z "$1" ]; then
    echo 'Arg $1 should be email!'
    return
  fi
  ssh-keygen -t rsa -b 4096 -C $1
}

dmysql-start(){
  docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=pass -e -d mysql:latest
}
dmysql-env(){
  export RDS_HOSTNAME=127.0.0.1
  export RDS_USERNAME=root
  export RDS_PASSWORD=pass
}