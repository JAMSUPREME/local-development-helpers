
# Some terraform helpers (based on convention)
tfinit(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  terraform init -backend-config=config/backend-$1.conf

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

tfplan(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  terraform plan -var-file="config/$1.tfvars"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

tfdestroy(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  terraform destroy -var-file="config/$1.tfvars"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

tfapply(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  echo "Apply started at $(date)"
  terraform apply -var-file="config/$1.tfvars"
  echo "Apply completed at $(date)"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

tfimport(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  if [ -z "$2" ]; then
    echo 'Arg $2 should be the resource name!'
    return
  fi
  if [ -z "$3" ]; then
    echo 'Arg $3 should be the ID of the resource to import!'
    return
  fi
  terraform import -var-file="config/$1.tfvars" $2 $3

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}