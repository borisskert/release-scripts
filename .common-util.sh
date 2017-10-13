 #!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_PARENT_PATH="$( dirname ${SCRIPT_PATH} )"


source $SCRIPT_PATH/hooks-default.sh
if [ -f "${SCRIPT_PARENT_PATH}/.release-hooks.sh" ]; then
	echo "Found .release-hooks.sh. Using it as master hooks"
	source "${SCRIPT_PARENT_PATH}/.release-scripts-hooks.sh"
else
	source $SCRIPT_PATH/hooks.sh
fi

DEVELOP_BRANCH=`get_develop_branch_name`
MASTER_BRANCH=`get_master_branch_name`
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

function check_local_workspace_state {
	if ! git diff-index --quiet HEAD --
	then
		echo "This script is only safe when your have a clean workspace."
		echo "Please clean your workspace by stashing or commiting and pushing changes before processing this $1 script."
		exit 1
	fi
}

