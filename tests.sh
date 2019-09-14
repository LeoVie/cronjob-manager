#!/bin/bash

TEST_INDEX=0
declare -A MESSAGES

beforeTestsuite() {
  docker-compose down > /dev/null 2>&1
  docker-compose build > /dev/null 2>&1
}

setUp() {
  TEST_INDEX=$((TEST_INDEX+1))
  docker-compose up -d > /dev/null 2>&1
}

tearDown() {
  docker-compose down > /dev/null 2>&1
}

afterTestsuite() {
  for index in "${!MESSAGES[@]}"; do
    local message=${MESSAGES[$index]}
    printf "Test %s -> %s\n" "$index" "$message"
  done

  TEST_INDEX=0
  MESSAGES=()
}

assertThat() {
  local expected=$1
  local actual=$2
  local message=$3

  if [[ "$expected" != "$actual" ]]; then
    MESSAGES[$TEST_INDEX]="$message"
    printf "E"
  else
    printf "."
  fi
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

testAddsCronjob() {
  local cronjob=$1
  docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE add \"$cronjob\"" > /dev/null 2>&1
  local crontab
  crontab=$(docker exec cronjob-manager_alpine bash -c "crontab -l")

  cronjob_is_in_crontab=$(str_contains "$cronjob" "$crontab")
  assertThat "1" "$cronjob_is_in_crontab" "Failed asserting that cronjob is in crontab."
}

testAddsCronjobOnlyOnce() {
  local cronjob=$1
  docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE add \"$cronjob\"" > /dev/null 2>&1
  local command_output
  command_output=$(docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE add \"$cronjob\"")

  local command_output_says_cronjob_exists
  command_output_says_cronjob_exists=$(str_contains "already exists" "$command_output")
  assertThat "1" "$command_output_says_cronjob_exists" "Failed asserting that cronjob only gets added once."
}

testAddsNoInvalidCronjob() {
  local cronjob=$1
  local command_output
  command_output=$(docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE add \"$cronjob\"")

  local command_output_says_cronjob_is_invalid
  command_output_says_cronjob_is_invalid=$(str_contains "is invalid" "$command_output")
  assertThat "1" "$command_output_says_cronjob_is_invalid" "Failed asserting that no invalid cronjob gets added."
}

testRemovesCronjob() {
  local cronjob=$1
  docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE add \"$cronjob\"" > /dev/null 2>&1
  docker exec cronjob-manager_alpine bash -c "$COMMAND_EXECUTABLE remove \"$cronjob\"" > /dev/null 2>&1

  local crontab
  crontab=$(docker exec cronjob-manager_alpine bash -c "crontab -l")

  local cronjob_is_in_crontab
  cronjob_is_in_crontab=$(str_contains "$cronjob" "$crontab")
  assertThat "0" "$cronjob_is_in_crontab" "Failed asserting that cronjob is not in crontab."
}

tests() {
  date
  beforeTestsuite
  setUp && testAddsCronjob "0 9 * * * curl http://localhost" && tearDown
  setUp && testAddsCronjob "/10 * * /8 * curl http://localhost" && tearDown
  setUp && testAddsCronjob "@reboot curl http://localhost" && tearDown
  setUp && testAddsCronjobOnlyOnce "0 9 * * * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "* * * * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "60 * * * * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "* 24 * * * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "* * 32 * * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "* * * 13 * curl http://localhost" && tearDown
  setUp && testAddsNoInvalidCronjob "* * * * 8 curl http://localhost" && tearDown
  setUp && testRemovesCronjob "0 9 * * * curl http://localhost" && tearDown
  printf "\n"
  afterTestsuite
}

command_executables[0]="/home/cronjob-manager/bash/cronjob-manager.sh"
command_executables[1]="php /home/cronjob-manager/php/src/cronjob-manager.php cronjob-manager"

for COMMAND_EXECUTABLE in "${command_executables[@]}"
do
  echo "$COMMAND_EXECUTABLE"
  tests
done

