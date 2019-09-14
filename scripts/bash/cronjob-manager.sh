#!/bin/bash

MODE=$1
CRONJOB=$2

validate_cronjob_format() {
  local cronjob=$1

  local special_keywords_pattern
  special_keywords_pattern="^@(reboot|daily|midnight|hourly|weekly|monthly|annually|yearly).+"
  if [[ $cronjob =~ $special_keywords_pattern ]]; then
    return
  fi

  local pattern
  local i=0
  for part in $cronjob
  do
    case $i in
    0)
      pattern="^(\\\\\*|\/?0?([0-9]|[1-4][0-9]|5[0-9]))$"
      ;;
    1)
      pattern="^(\\\\\*|\/?0*([0-9]|1[0-9]|2[0-3]))$"
      ;;
    2)
      pattern="^(\\\\\*|\/?0*([1-9]|[12][0-9]|3[01]))$"
      ;;
    3)
      pattern="^(\\\\\*|\/?0*([1-9]|1[0-2]))$"
      ;;
    4)
      pattern="^(\\\\\*|\/?0*([0-7]))$"
      ;;
    5)
      pattern="^.+$"
      ;;
    esac
    if [[ $part =~ $pattern ]]; then
      a=0
    else
      echo "Cronjob '$cronjob' is invalid (at position $i ('$part'))."
      exit 1
    fi

    i=$((i+1))
  done
}

reg_replace() {
  local pattern=$1
  local replacement=$2
  local subject=$3

  echo "${subject//"$pattern"/$replacement}"
}

escape_special_chars() {
  local subject=$1
  subject=$(reg_replace "*" "\*" "$subject")
  echo "$subject"
}

str_contains() {
  local needle=$1
  local haystack=$2
  local str_contains=0
  if [[ $haystack == *"$needle"* ]]; then
    str_contains=1
  fi
  echo "$str_contains"
}

cronjob_exists() {
  local cronjob=$1
  local crontab
  crontab=$(crontab -l)
  local cronjob_exists
  cronjob_exists=$(str_contains "$cronjob" "$crontab")
  echo "$cronjob_exists"
}

add_cronjob() {
  local cronjob=$1
  local escaped_cronjob
  escaped_cronjob=$(escape_special_chars "$cronjob")
  validate_cronjob_format "$escaped_cronjob"
  echo "Adding cronjob '$cronjob' to crontab."
  crontab -l | { cat; echo "$cronjob"; } | crontab -
}

add_cronjob_if_not_exists() {
  local cronjob=$1
  local cronjob_exists
  cronjob_exists=$(cronjob_exists "$cronjob")
  if [[ $cronjob_exists == "0" ]]; then
    add_cronjob "$cronjob"
  else
    echo "Cronjob '$cronjob' already exists."
  fi
}

remove_cronjob() {
  local cronjob=$1
  local escaped_cronjob
  escaped_cronjob=$(escape_special_chars "$cronjob")
  echo "Removing cronjob '$cronjob' from crontab."
  local crontab
  crontab=$(crontab -l)
  local new_crontab="${crontab//$escaped_cronjob/}"
  echo "$new_crontab" | crontab -
}



if [[ $MODE == "add" ]]; then
  add_cronjob_if_not_exists "$CRONJOB"
elif [[ $MODE == "remove" ]]; then
  remove_cronjob "$CRONJOB"
fi