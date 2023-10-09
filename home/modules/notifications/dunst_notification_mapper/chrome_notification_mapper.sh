#!/usr/bin/env bash

appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"

echo "$appname" "$summary" "$body" "$icon" "$urgency" >~/notification

declare -A icon_mapping
icon_mapping["reddit"]="web-reddit"

appname=$(echo "${body}" | head -1 | grep -oP ">[^.]*\.[^.]*" | cut -d. -f2)
body=$(echo "${body}" | tail -n+3)

icon_default=$(echo "${appname}" | tr "[:upper:]" "[:lower:]")
icon=${icon_mapping["${appname}"]}

# in case there is no overwriting icon to use
if [[ -z "${icon}" ]]; then
	icon="${icon_default}"
fi

if [[ "${body}" == "This site has been updated in the background." ]]; then
	exit 0
fi

# instagram
if [[ "${appname}" == "instagram" ]] && [[ "${body}" == "You have unseen notifications." ]]; then
	exit 0
fi

notify-send \
	-a "${appname^}" \
	-u "${urgency}" \
	-i "${icon}" \
	"${summary}" \
	"${body}"
