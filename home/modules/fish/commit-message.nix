{ lib, pkgs, secret_dots, ... }:
let
  openai_key =
    lib.removeSuffix "\n" (builtins.readFile "${secret_dots}/openai_key");

  generator = pkgs.writers.writeBash "generator" ''
    set -e
    model="gpt-3.5-turbo"

    diff=$(${pkgs.coreutils}/bin/cat /dev/stdin)
    escaped_diff=$(echo "$diff" | ${pkgs.jq}/bin/jq -sR)

    prompt_template="Rewrite the following Git diff into a concise and informative commit message using the conventional commit standard, within 75 characters preferably less, using the '-' to indicate removed lines and '+' for added lines. Use unchanged lines for context only:\n"
    instruction='\n\nProvide a short and concise imperative single-line commit message that briefly describes the changes made in this diff.'

    payload=$(${pkgs.jq}/bin/jq \
        -n \
        --arg prompt_template "$prompt_template" \
        --arg diff "$escaped_diff" \
        --arg instruction "$instruction" \
        --arg model "$model" '{model: $model, messages: [{role: "user", content: ($prompt_template + $diff + $instruction)}] }'\
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
