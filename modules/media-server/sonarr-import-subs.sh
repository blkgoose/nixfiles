#!/bin/bash

[ "$sonarr_eventtype" = "Download" ] || exit 0

src="$sonarr_episodefile_sourcepath"
dst="$sonarr_episodefile_path"
[ -n "$src" ] && [ -n "$dst" ] || exit 0

subdir="$(dirname "$src")/Subs/$(basename "${src%.*}")"
[ -d "$subdir" ] || exit 0

dststem="${dst%.*}"
declare -A groups

for f in "$subdir"/*.srt; do
  [ -f "$f" ] || continue
  name=$(basename "$f" .srt | sed -E 's/^[0-9]+_//')
  lang=$(echo "${name%%.*}" | tr '[:upper:]' '[:lower:]')
  case "$lang" in
    en | eng | english) code=en ;;
    it | ita | italian | italiano) code=it ;;
    *)
      echo "skipping $f: unknown language '$lang'"
      continue
      ;;
  esac
  groups[$code]+="$f"$'\n'
done

for code in "${!groups[@]}"; do
  mapfile -t files < <(printf '%s' "${groups[$code]}" | xargs -d '\n' ls -Sr)
  targets=("$dststem.$code.srt" "$dststem.$code.hi.srt")
  for i in 0 1; do
    [ -n "${files[$i]}" ] || break
    [ -e "${targets[$i]}" ] && continue
    cp "${files[$i]}" "${targets[$i]}"
    echo "imported ${files[$i]} -> ${targets[$i]}"
  done
done
