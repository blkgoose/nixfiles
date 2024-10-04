{ lib, pkgs, secret_dots, ... }:
let
  openai_key =
    lib.removeSuffix "\n" (builtins.readFile "${secret_dots}/openai_key");

  prompt = ''
    Here you have 20 lines of commits, use these as an example.
    The lines after the first 20 are the diff of the current changes, the '-' indicate removed lines and '+' added lines.
    Use the unchanged lines and file names for context.
    Rewrite the following Git diff into a concise and informative commit message:
  '';

  generator = pkgs.writers.writeBash "generator" ''
    set -e
    model="gpt-3.5-turbo"

    diff=$(${pkgs.coreutils}/bin/cat /dev/stdin)
    escaped_diff=$(echo "$diff" | ${pkgs.jq}/bin/jq -sR)
    previous_commits=$(git log --oneline | head -20)
    escaped_commits=$(echo "$previous_commits" | ${pkgs.jq}/bin/jq -sR)

    payload=$(${pkgs.jq}/bin/jq \
        -n \
        --arg prompt "${prompt}\n" \
        --arg diff "$escaped_diff\n" \
        --arg commits "$escaped_commits\n" \
        --arg model "$model" '{model: $model, messages: [{role: "user", content: ($prompt + $commits + $diff)}] }'\
    )

    response=$(${pkgs.curl}/bin/curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${openai_key}" \
        -d "$payload"\
    )

    commit_message=$(\
        echo "$response" \
        | ${pkgs.jq}/bin/jq -r '.choices[0].message.content' \
        | ${pkgs.coreutils}/bin/tr -d '\n' \
        | ${pkgs.gnused}/bin/sed 's/\.$//'\
    )

    if [ -z "$commit_message" ] || [ "$commit_message" = "null" ]; then
        echo "Error: Failed to generate commit message." >&2
        echo "Response from API:" >&2
        echo "$response" >&2
        exit 1
    fi

    echo "$commit_message"
  '';
in { home.file.".local/bin/commit-generator".source = generator; }
