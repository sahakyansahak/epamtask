# allows using test.sh local processes from shared processes
local_functions_path="./local_functions.sh"
if test -f "$local_functions_path"; then
  source "$local_functions_path" &> /dev/null
fi

function assume_aws_role() {
  aws_role_arn=$1
  aws_role_session_name=$2

  if test -n "$aws_role_arn"; then
    creds=$(aws sts assume-role --role-arn "$aws_role_arn" --role-session-name "$aws_role_session_name" --query 'Credentials')
    export AWS_ACCESS_KEY_ID=$(echo "$creds" | jq -r .AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | jq -r .SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo "$creds" | jq -r .SessionToken)
  fi
}

function run_remote_command() {
  INSTANCE_ID=$1
  CMD=$2

  local cmd_output=$(aws ssm send-command --instance-ids "$INSTANCE_ID" --document-name "AWS-RunShellScript" --parameters commands="$CMD"  --query 'Command')
  local command_id=$(echo "$cmd_output" | jq -r .CommandId)

  local Status="InProgress"

  while [[ $Status == "Pending" || $Status == "InProgress" ]]
  do
    sleep 4
    local command_details=$(aws ssm list-command-invocations --command-id $command_id --details --query 'CommandInvocations[0]')
    local Status=$(echo "$command_details" | jq -r '.CommandPlugins[].Status')
  done

  if [ $Status == "Success" ]; then
    >&1 echo -e "$(echo "$command_details" | jq -r '.CommandPlugins[].Output')"
  else
    >&2 echo -e "$(echo "$command_details" | jq -r '.CommandPlugins[].Output')"
  fi

  return $(echo "$command_details" | jq -r '.CommandPlugins[].ResponseCode')
}

function setUserCredentials () {
  export AWS_ACCESS_KEY_ID=$1
  export AWS_SECRET_ACCESS_KEY=$2
  unset AWS_SESSION_TOKEN
}

function command_log() {
  # Run command and create STDOUT && STDERR && STATUSCODE files with command result(log)
  command_alias=$1
  command=$2
  logs_folder=$3

  dir_name="${command_alias}"
  path_to_dir="$logs_folder/$dir_name"
  mkdir -p ./$path_to_dir
  bash <<EOF
#!/bin/bash
source "../../../shared_libs/shell_functions.sh" &> /dev/null
echo "$command" > $path_to_dir/command
$command > $path_to_dir/std_out 2> $path_to_dir/std_err
EOF

  echo $? > $path_to_dir/status_code
}

function check_role_admin_permissions(){
  role_name=$1
  admin_present=false

  attached_managed_policies="$(aws iam list-attached-role-policies --role-name $role_name --query AttachedPolicies[*].'PolicyArn')"
  attached_managed_policies="${attached_managed_policies//\"}"		# remove double quotes
  attached_managed_policies=($(echo ${attached_managed_policies:1:-1} | tr ', ' '\n' ))		# convert to bash array

  attached_inline_policies="$(aws iam list-role-policies --role-name $role_name --query PolicyNames[*])"
  attached_inline_policies="${attached_inline_policies//\"}"
  attached_inline_policies=($(echo ${attached_inline_policies:1:-1} | tr ', ' '\n' ))


  # Parse attached managed policies
  for i in "${attached_managed_policies[@]}"
  do
    if [[ "$i" == "arn:aws:iam::aws:policy/AdministratorAccess" ]]
    then
      admin_present=true
      >&2 echo "arn:aws:iam::aws:policy/AdministratorAccess is used"
      return 1
    else
      policy_default_version="$(aws iam get-policy --policy-arn $i --query Policy.DefaultVersionId | tr -d '\"')"
      full_access="$(aws iam get-policy-version --policy-arn "$i" --version-id  $policy_default_version --query "PolicyVersion.Document.Statement[?Effect=='Allow' && Action=='*' && Resource=='*']")"
      if [[ "$full_access" != "[]" && "$full_access" != "null" ]]
      then
        admin_present=true
        >&2 echo "Managed policy with AdministratorAccess is used"
        return 1
      fi
    fi
  done

  # Parse inline managed policies
  for i in "${attached_inline_policies[@]}"
  do
    full_access="$(aws iam get-role-policy --role-name $role_name --policy-name "$i" --query "PolicyDocument.Statement[?Effect=='Allow' && Action=='*' && Resource=='*']")"
    if [[ "$full_access" != "[]" && "$full_access" != "null" ]]
    then
      admin_present=true
      >&2 echo "Inline policy with AdministratorAccess is used"
      return 1
    fi
  done

  if ! $admin_present
  then
    return 0
  fi
}

function cm_ecr_login () {
  #Login to Cloud-Mentor ECR

  region=$1
  account_id=$2
  aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $account_id.dkr.ecr.$region.amazonaws.com >/dev/null
}

function save_test_vars() {
  # Save Test Variables
  #
  # Description:
  #   Sets the variables for the test definition and saves them into a test.vars file.
  #   This file will later be used by validation.py to fill in the placeholders in the test definition.
  #
  # Arguments:
  #   --testname=<testname>          The name of the current test.
  #   --logs_folder=<logs_folder>    The folder where the test.sh outputs will be saved.
  #   --var1=value1                  The name of the variable followed by its value.
  #   --var2=value2
  #   ...
  #   --varN=valueN
  #
  # Outputs:
  #   The test.vars file containing the set of variables in the specified logs folder under the specified test name.
  #
  # Example usage:
  #   save_test_vars \
  #     --testname="test_1" \
  #     --logs_folder="${logs_folder}" \
  #     --bucket_name="cmtr-12345678-bucket" \
  #     --lambda_function="cmtr-12345678-lambda"
  #
  # Notes:
  #   - If the test.vars file already exists, it will be overwritten.
  #   - The function ensures that the directory structure is created for the specified logs folder and test name.
  #

  local filename="test.vars"
  local testname logs_folder varsfile

  declare -A variables

  # Extract arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --testname=*)
      testname="${1#*=}"
      shift
      ;;
    --logs_folder=*)
      logs_folder="${1#*=}"
      shift
      ;;
    --*=*)
      var="${1%%=*}"  # remove everything after the =
      var="${var#--}" # remove the -- prefix
      value="${1#*=}" # remove everything before the =
      variables["${var}"]="${value}"
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  # Delete the vars file if already exists
  varsfile="${logs_folder}/${testname}/${filename}"
  if [ -f "${varsfile}" ]; then
    rm -f "${varsfile}"
  fi
  mkdir -p "./${logs_folder}/${testname}"

  # Write variables to test.vars file
  {
    for var in "${!variables[@]}"; do
      echo "${var}=${variables[$var]}"
    done
  } >"${varsfile}"
}

function load_test_var() {
  # Load Test Variable
  #
  # Description:
  #   Reads a variable saved by the save_test_vars function from the corresponding test.vars file.
  #
  # Arguments:
  #   --var=<varname>              The name of the variable to load.
  #   --testname=<testname>        The name of the test whose variables are to be loaded.
  #   --logs_folder=<logs_folder>  The folder where the test.sh outputs are saved.
  #
  # Outputs:
  #   Outputs the value of the specified variable.
  #
  # Example usage:
  #   variable=$(load_test_var --var="bucket_name" --testname="test_1" --logs_folder="validation_logs")
  #
  # Notes:
  #   - The function relies on the existence of the test.vars file generated by save_test_vars
  #     function in the specified logs folder for the specified test.
  #
  # Dependencies:
  #   The function relies on grep for pattern matching in the test.vars file.
  #

  local varname testname logs_folder filename varsfile
  filename="test.vars"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --testname=*)
      testname="${1#*=}"
      shift
      ;;
    --logs_folder=*)
      logs_folder="${1#*=}"
      shift
      ;;
    --var=*)
      varname="${1#*=}"
      shift
      ;;
    *)
      shift
      ;;
    esac
  done

  # Check if the test.vars file exists
  varsfile="${logs_folder}/${testname}/${filename}"
  if [ -f "$varsfile" ]; then
    # Read the variable value from the test.vars file
    local value
    value=$(grep -Po "(?<=^${varname}=).*" "$varsfile")

    # Output the variable value
    echo "${value}"
  fi

}

function log() {
  local message="$1"
  local logfile="test.log"
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ${BASH_SOURCE[1]}:${FUNCNAME[1]} (line ${BASH_LINENO[0]}):: $message" >>"${logfile}"
}

report_error() {
  local output_file="validation_output.json"
  local output='{
    "result": "failed",
    "validation_steps": [
      {
        "index": 1,
        "description": "Run verification",
        "meta": "Deployment failed. You can try again or submit a support request SupportEPM-CMTRL2@epam.com",
        "step_passed": false
      }
    ]
  }'
  echo "$output" >"${output_file}"
}

# Function to export environment variables from a JSON file
function load_vars_from_json_file () {

    # The first argument to the function becomes 'jsonFile'
    local jsonFile="$1"

    # Check if the 'jsonFile' file exists
    if [ -f "$jsonFile" ] ; then

        # Read the keys and values from the JSON file
        while IFS="=" read -r key value
        do
            # Each key and value is exported as an environment variable
            export "$key"="$value"
        done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' "$jsonFile")
    else
        echo "file $jsonFile wasn't found, check the path"
    fi
}