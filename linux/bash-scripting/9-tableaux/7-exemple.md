# Exemple

> Fichiers d'exemple : [exemples/7-exemple/](exemples/7-exemple/) (lancer les commandes depuis ce répertoire).

```bash
#!/usr/bin/env bash
declare -a lunch_options

work_dir=$(dirname "$(readlink -f "${0}")")
food_places="${work_dir}/food_places.txt"
readonly FILE_NOT_FOUND=150
readonly NO_OPTIONS_LEFT=180

terminate() {
  local msg="$1"
  local code="${2:-$FILE_NOT_FOUND}"
  echo "$msg" >&2
  exit "$code"
}

if [[ ! -f "$food_places" ]]; then
  terminate "Error: food_places.txt file doesn't exist" "$FILE_NOT_FOUND"
fi

fillout_array() {
  mapfile -t lunch_options < "$food_places"
  if [[ ${#lunch_options[@]} -eq 0 ]]; then
    terminate "Error: No food options left. Please add options to food_places.txt" "$NO_OPTIONS_LEFT"
  fi
}

fillout_array

index=$(( RANDOM % ${#lunch_options[@]} ))
chosen="${lunch_options[$index]}"
echo "$chosen"
unset 'lunch_options[index]'

update_options() {
  if [[ ${#lunch_options[@]} -eq 0 ]]; then
    : > "$food_places"
  else
    printf "%s\n" "${lunch_options[@]}" > "$food_places"
  fi
}

update_options
```
