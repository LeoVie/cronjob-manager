#!/bin/bash

CRONJOB="\* \* /4 \* \* foo"

validate_cronjob_format() {
  CRONJOB=$1

  i=0
  for part in $CRONJOB
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
      echo "Cronjob '$CRONJOB' is not valid (at position $i ('$part'))."
      exit 1
    fi

    i=$((i+1))
  done
}

reg_replace() {
  PATTERN=$1
  REPLACEMENT=$2
  SUBJECT=$3

  echo "${SUBJECT//"$PATTERN"/$REPLACEMENT}"
}

escape_special_chars() {
  SUBJECT=$1
  SUBJECT=$(reg_replace "*" "\*" "$SUBJECT")
  echo "$SUBJECT"
}

str_contains() {
  NEEDLE=$1
  HAYSTACK=$2
  STR_CONTAINS=0
  if [[ $HAYSTACK == *"$NEEDLE"* ]]; then
    STR_CONTAINS=1
  fi
  echo "$STR_CONTAINS"
}

cronjob_exists() {
  NEW_CRONJOB=$1
  CRONJOB_LIST=$(crontab -l)
  CRONJOB_EXISTS=$(str_contains "$NEW_CRONJOB" "$CRONJOB_LIST")
  echo "$CRONJOB_EXISTS"
}

add_cronjob() {
  NEW_CRONJOB=$1
  ESCAPED_NEW_CRONJOB=$(escape_special_chars "$NEW_CRONJOB")
  validate_cronjob_format "$ESCAPED_NEW_CRONJOB"
  echo "Adding cronjob '$NEW_CRONJOB' to crontab."
  crontab -l | { cat; echo "$NEW_CRONJOB"; } | crontab -
}

add_cronjob_if_not_exists() {
  NEW_CRONJOB=$1
  CRONJOB_EXISTS=$(cronjob_exists "$NEW_CRONJOB")
  if [[ $CRONJOB_EXISTS == "0" ]]; then
    add_cronjob "$NEW_CRONJOB"
  else
    echo "Cronjob '$NEW_CRONJOB' already exists."
  fi
}

remove_cronjob() {
  CRONJOB_TO_REMOVE=$1
  ESCAPED_CRONJOB_TO_REMOVE=$(escape_special_chars "$CRONJOB_TO_REMOVE")
  echo "Removing cronjob '$CRONJOB_TO_REMOVE' from crontab."
  CRONJOB_LIST=$(crontab -l)
  NEW_CRONJOB_LIST="${CRONJOB_LIST//$ESCAPED_CRONJOB_TO_REMOVE/}"
  echo "$NEW_CRONJOB_LIST" | crontab -
}

add_cronjob_if_not_exists "0 9 * * * curl http://localhost"
add_cronjob_if_not_exists "0 21 * * * curl http://localhost"
