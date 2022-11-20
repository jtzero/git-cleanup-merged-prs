
COMPLETED_STATES=('merged' 'closed')

pre_init_hook() {
  local -r has_errors="$(glab auth status 2>&1 |grep 'x')"
  if [ -n "${has_errors}" ]; then
    exec < /dev/tty
    glab auth login || exit 1
  fi
}

get_states() {
  local -r branch="${1}"
  glab api /projects/:id/merge_requests -Fsource_branch="${branch}" -X GET | jq -r '[.[] | {state: .state, id: .id, iid: .iid }]'
}

get_any_open_states() {
  local -r states="${@}"
  printf '%s\n' "${states}" | jq 'map(select(.state == "opened")) | length > 0'
}

get_only_completed() {
  local -r states="${@}"
  printf '%s\n' "${states}" | jq 'map(select(.state != "merged" and .state != "closed")) | length == 0'
}
