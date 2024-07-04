# Discord RPC shell
  A posix shell script to connect to discord RPC without using too much dependencies.

# Example Payload
```sh
payload='{"cmd": "SET_ACTIVITY", "args": {"activity": {"details": "'$title'", "state": "'$state'", "timestamps": {"start": '"$start"',"end": '"$end"'}, "assets": {"large_image": "'$image_url'","large_text":"'$image_text'"},"buttons": [{"label":"'$button_label'", "url": "'$button_url'"}]},"pid":786}, "nonce": "'$(date +%s%N)'"}'
```
