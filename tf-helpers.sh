#
# Some terraform helpers (based on convention)
# You can either run them from the project root or from the /terraform directory
#

# Profiles should follow this convention:
# myproj_dev
# myproj_qa
# myproj_qa_nongov (when using gov/nongov, it is assumed that GovCloud is your "default")
#    The helper should still work as long as you consistently invert this and Commercial is your default
export ACTIVE_TF_PROFILE='unknown'

# Default version of TF to use (can be "terraform")
export ACTIVE_TF=terraform@1.2.9

# If you have several projects, this is useful to set the correct prefix
tfprofile(){
  export ACTIVE_TF_PROFILE=$1
}

# NOTE: Following isn't working - need to figure out why taps aren't working as desired
# If you have several projects with varied TF versions, this can set the desired one
# brew extract --version=1.5.7 terraform hashicorp/tap
# brew install hashicorp/tap/terraform@1.5.7
# terraform@1.5.7 --version

# Set the active version of Terraform
# tfversion terraform@1.5.7   # use specific version
# tfversion terraform         # use latest
tfversion(){
  export ACTIVE_TF=$1
}

#
# Initialize terraform against a particular tfstate
#
tfinit(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi
  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  $ACTIVE_TF init -upgrade -reconfigure -backend-config=config/backend-$1.conf

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

# 
# Run the expected execution plan
# 
tfplan(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi

  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  $ACTIVE_TF plan -var-file="config/$TARGET_ENV.tfvars"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

# 
# Destroy all resources
# 
tfdestroy(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi

  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  $ACTIVE_TF destroy -var-file="config/$TARGET_ENV.tfvars"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

# 
# Apply the terraform execution plan with before/after timestamps
# 
tfapply(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi

  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  echo "Apply started at $(date)"
  $ACTIVE_TF apply -var-file="config/$TARGET_ENV.tfvars"
  echo "Apply completed at $(date)"

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

# 
# Import existing resources into your tfstate
# 
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

  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  $ACTIVE_TF import -var-file="config/$TARGET_ENV.tfvars" $2 $3

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}

# 
# Migrate your current state into a new state file
# 
tfmigrate(){
  if [ -d "terraform" ]; then
    POP_TF="yes"
    pushd ./terraform
  fi

  if [ -z "$1" ]; then
    echo 'Arg $1 should be environment!'
    return
  fi

  if [ $1 = "sbx" ] || [ $1 = "dev" ] || [ $1 = "qa" ] || [ $1 = "prod" ]; then
    echo "You are not allowed to migrate into normal state files. You should migrate into a suffixed environment, e.g. 'dev-gandalf'"
    return
  fi

  TARGET_ENV=$(echo "$1" | awk '{split($0,env_arr,"-"); print env_arr[1]}')

  echo "Using profile ${ACTIVE_TF_PROFILE}_$TARGET_ENV"
  export AWS_PROFILE="${ACTIVE_TF_PROFILE}_$TARGET_ENV"

  echo "Migrating into $1"
  $ACTIVE_TF init -migrate-state -force-copy -backend-config=config/backend-$1.conf

  if [ ! -z "$POP_TF" ]; then
    POP_TF=''
    popd
  fi
}
