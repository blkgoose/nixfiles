function __fish_using_command
    set cmd (commandline -opc)

    if [ (count $cmd) -eq (count $argv) ]
        for i in (seq (count $argv))
            if [ $cmd[$i] != $argv[$i] ]
                if [ $argv[$i] = '__anything__' ]
                    return 0
                else
                    return 1
                end
            end
        end
        return 0
    end
    return 1
end

function __suite_py_qa_list
    suite-py qa list | tail -n+5 | awk '{print $4}' | grep -v '│\|^\s*$'
end

function __suite_py_microservice_list
    yq .depends_on.microservices[] .service.yml --raw-output
end

# top level options
complete -c suite-py -n '__fish_using_command suite-py' -l project -d "Path of the project to run the command on (the default is current directory)"
complete -c suite-py -n '__fish_using_command suite-py' -l timeout -d "Timeout in seconds for Captainhook operations"
complete -c suite-py -n '__fish_using_command suite-py' -l verbose -s v -f

#subcommand
# aggregator
complete -c suite-py -n '__fish_using_command suite-py' -a aggregator -d 'Manage CNAMEs of aggregators in QA envs' -f
complete -c suite-py -n '__fish_using_command suite-py aggregator' -a change -d 'Change aggregator record' -f
complete -c suite-py -n '__fish_using_command suite-py aggregator' -a list -d 'List all aggregators with the current record' -f

# ask-review
complete -c suite-py -n '__fish_using_command suite-py' -a ask-review -d 'Request a PR review' -f

# bump
complete -c suite-py -n '__fish_using_command suite-py' -a bump -d 'Bumps the project version based on the .versions.yml file' -f
complete -c suite-py -n '__fish_using_command suite-py bump' -l project

# check
complete -c suite-py -n '__fish_using_command suite-py' -a check -d 'Verify authorisations for third party services' -f

# create-branch
complete -c suite-py -n '__fish_using_command suite-py' -a create-branch -d 'Create local branch and set the YouTrack card in progress' -f
complete -c suite-py -n '__fish_using_command suite-py create-branch' -l card -d 'YouTrack card number (ex. PRIMA-123)'

# deploy
complete -c suite-py -n '__fish_using_command suite-py' -a deploy -d 'Deploy master branch in production' -f

# docker
complete -c suite-py -n '__fish_using_command suite-py' -a docker -d 'Manage docker images' -f
complete -c suite-py -n '__fish_using_command suite-py docker' -a release -d 'Release new docker image' -f
complete -c suite-py -n '__fish_using_command suite-py docker' -a versions -d 'List all available versions of specific image' -f

# generator
complete -c suite-py -n '__fish_using_command suite-py' -a generator -d 'Generate different files from templates' -f

# id
complete -c suite-py -n '__fish_using_command suite-py' -a id -d 'Get the ID of the hosts where the task is running' -f

# ip
complete -c suite-py -n '__fish_using_command suite-py' -a ip -d 'Get the IP addresses of the hosts where the task is running' -f

# lock
complete -c suite-py -n '__fish_using_command suite-py' -a lock -d 'Lock project on staging or prod' -f

# login
complete -c suite-py -n '__fish_using_command suite-py' -a login -d 'Manage login against Auth0' -f

# merge-pr
complete -c suite-py -n '__fish_using_command suite-py' -a merge-pr -d 'Merge the selected branch to master if all checks are OK' -f

# open-pr
complete -c suite-py -n '__fish_using_command suite-py' -a open-pr -d 'Open a PR on GitHub' -f

# qa
complete -c suite-py -n '__fish_using_command suite-py' -a qa -d 'Manage QA envs' -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a check -d 'Check QA conf' -f
complete -c suite-py -n '__fish_using_command suite-py qa check' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a create -d 'Create QA env' -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a delete -d 'Delete QA env' -f
complete -c suite-py -n '__fish_using_command suite-py qa delete' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a describe -d 'Describe QA environment' -f
complete -c suite-py -n '__fish_using_command suite-py qa describe' -l json -d 'Get response as JSON'
complete -c suite-py -n '__fish_using_command suite-py qa describe' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a freeze -d 'Freeze QA env' -f
complete -c suite-py -n '__fish_using_command suite-py qa freeze' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a list -d 'List QA envs for user: all to show qa of all users.' -f
complete -c suite-py -n '__fish_using_command suite-py qa list' -l user -s u
complete -c suite-py -n '__fish_using_command suite-py qa list' -l status -s s
complete -c suite-py -n '__fish_using_command suite-py qa list' -l card -s c
complete -c suite-py -n '__fish_using_command suite-py qa' -a toggle-maintenance -d 'Toggle maintenance mode (requires \'manage:maintenance\' permission)' -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a unfreeze -d 'Unfreeze QA env' -f
complete -c suite-py -n '__fish_using_command suite-py qa unfreeze' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a update -d 'Update QA env' -f
complete -c suite-py -n '__fish_using_command suite-py qa update' -a "(__suite_py_qa_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa update __anything__' -a "(__suite_py_microservice_list)" -f
complete -c suite-py -n '__fish_using_command suite-py qa' -a update-quota -d 'Update quota in QA for a user' -f

# release
complete -c suite-py -n '__fish_using_command suite-py' -a release -d 'Manage releases' -f
complete -c suite-py -n '__fish_using_command suite-py release' -a create -d 'Create a github release' -f
complete -c suite-py -n '__fish_using_command suite-py release create' -l deploy -d 'Trigger deploy after release creation' -f
complete -c suite-py -n '__fish_using_command suite-py release' -a deploy -d 'Deploy a github release' -f
complete -c suite-py -n '__fish_using_command suite-py release' -a rollback -d 'Rollback a release' -f

# secret
complete -c suite-py -n '__fish_using_command suite-py' -a secret -d 'Manage secrets grants in multiple countries (aws-vault needed)' -f
complete -c suite-py -n '__fish_using_command suite-py secret' -a create -d 'Create a new secret' -f
complete -c suite-py -n '__fish_using_command suite-py secret create' -l base-profile -s b
complete -c suite-py -n '__fish_using_command suite-py secret create' -l secret-file -s f
complete -c suite-py -n '__fish_using_command suite-py secret' -a grant -d 'Grant permission to an existing secret' -f
complete -c suite-py -n '__fish_using_command suite-py secret grant' -l base-profile -s b
complete -c suite-py -n '__fish_using_command suite-py secret grant' -l secret-file -s f

# status
complete -c suite-py -n '__fish_using_command suite-py' -a status -d 'Current status of a project' -f

# unlock
complete -c suite-py -n '__fish_using_command suite-py' -a unlock -d 'Unlock project on staging or prod' -f
