#!/bin/bash

# Some helpers for getting an MFA token locally from AWS

# 1: Your AWS profile designating the desired account so you don't mix them up
# 2: The MFA token (123456) from your MFA authenticator
get-mfa-token(){
    if [ -z "$1" ]; then
        echo 'Arg $1 must be a profile from your ~/.aws/credentials file!'
        return
    fi
    if [ -z "$2" ]; then
        echo 'Arg $2 must be a MFA token!'
        return
    fi
    TARGET_AWS_PROFILE=$1
    MFA_TOKEN=$2
    MFA_ARN=arn:aws:iam::123456:mfa/put.account.here

    export AWS_PROFILE=$TARGET_AWS_PROFILE
    aws sts get-session-token --serial-number $MFA_ARN --token-code $MFA_TOKEN
}

# Gets session token and exports necessary AWS variables
# 1: Your AWS profile designating the desired account so you don't mix them up
# 2: The MFA token (123456) from your MFA authenticator
set-mfa-token(){
    JQ_LOC=$(which jq)
    if [ -z "$JQ_LOC" ]; then
        echo 'You need jq to use this function!'
        return
    fi

    MFA_OUTPUT=$(get-mfa-token $1 $2)
    KEY_ID=$(jq .Credentials.AccessKeyId <<< $MFA_OUTPUT -r)
    KEY=$(jq .Credentials.SecretAccessKey <<< $MFA_OUTPUT -r)
    TOKEN=$(jq .Credentials.SessionToken <<< $MFA_OUTPUT -r)

    export AWS_ACCESS_KEY_ID=$KEY_ID
    export AWS_SECRET_ACCESS_KEY=$KEY
    export AWS_SESSION_TOKEN=$TOKEN

    echo 'Successfully assigned AWS variables'
}