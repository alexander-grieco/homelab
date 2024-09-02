#!/bin/bash

set -e

BASE_DIR="$(git rev-parse --show-toplevel)"
NOMAD_BOOTSTRAP_TOKEN="$BASE_DIR/nomad.token"
NOMAD_USER_TOKEN="$BASE_DIR/user.token"
ACL_DIRECTORY="$BASE_DIR/config/nomad"

OUTPUT=$(nomad acl bootstrap 2>&1)
if [ $? -eq 0 ]; then
  echo $OUTPUT
  echo "$OUTPUT" | grep -i secret | awk -F '=' '{print $2}' | xargs | awk 'NF' > $NOMAD_BOOTSTRAP_TOKEN
  if [ -s $NOMAD_BOOTSTRAP_TOKEN ]; then
      echo "nomad bootstrapped"
  else
    echo "Failed: $(OUTPUT)"
    exit 1
  fi
fi

nomad acl policy apply -token "$(cat $NOMAD_BOOTSTRAP_TOKEN)" -description "Policy to allow reading of agents and nodes and listing and submitting jobs in all namespaces." node-read-job-submit $ACL_DIRECTORY/nomad-acl-user.hcl

nomad acl token create -token "$(cat $NOMAD_BOOTSTRAP_TOKEN)" -name "read-token" -policy node-read-job-submit | grep -i secret | awk -F "=" '{print $2}' | xargs > $NOMAD_USER_TOKEN

