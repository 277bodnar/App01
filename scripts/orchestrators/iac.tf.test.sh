#!/bin/bash

source ./tests.runner.sh
pushd "${WORKSPACE_PATH}/IAC/Terraform/test/terraform"

# install junit
echo "install go-junit-report"
go install github.com/jstemmer/go-junit-report@latest

# set test vars
export resource_group_name="${STATE_RG}"
export storage_account_name="${STATE_STORAGE_ACCOUNT}"
export container_name="${STATE_CONTAINER}"

# retrieve client_id, subscription_id, tenant_id from logged in user
azaccount=$(az account show)
subscription_id=$(echo $azaccount | jq -r .id)

export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true

if [[ "${TEST_TAG}" == "module_tests" ]]; then
  echo "Run tests with tag = module_tests"
  terraform module_test true
elif [[ "${TEST_TAG}" == "e2e_test" ]]; then
  echo "Run tests with tag = e2e_test"
  terraform e2e_test true
else
  SAVEIFS=${IFS}
  IFS=$'\n'
  tests=($(find . -type f -name '*end_test.go' -print))
  IFS=${SAVEIFS}

  for test in "${tests[@]}"; do
    terraform ${test/'./'/''}
  done
fi

popd
