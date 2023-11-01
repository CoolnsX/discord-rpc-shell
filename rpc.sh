#!/bin/sh

### Posix compliant script for Discord Rich presence (no need to have python and pypresence) ###

#encode opcode and payload length in little-endian format and prepend it with payload
encode_data() {
	len=${#1}
	#shellcheck disable=SC2059
	printf "\\00${2:-0}\\000\\000\\000"
	for i in 0 8 16 24; do
		len=$((len >> i))
		#shellcheck disable=SC2059
		printf "\\$(printf "%03o" "$len")"
	done
	printf "%s" "$1"
}

#main
if [ -z "$1" ];then
	printf "Pass client Id please!!" && exit 1
elif [ -z "$2" ];then
	printf "Pass Payload please!!" && exit 1
fi

presence_client_id=$1
discord_ipc="${XDG_RUNTIME_DIR}/discord-ipc-0" #can be 2 discord-IPCs namely discord-ipc-0,discord-ipc-1 if you have both arRPC and discord installed and running

# - activity will be shown as long as this running, if you do (SIGINT)ctrl-c on this script, "activity" will be disappeard from discord
# - netcat should be BSD version and not GNU one, for this to work
# - $1 is client id, buy your own
# - $2 is actually payload json, atleast figure that out from internet
{
	#handshake
	encode_data '{"v":1,"client_id":"'"$presence_client_id"'"}' "0"
	#wait(max 4 seconds) so that we can get the output
	sleep 4
	#set activity
	encode_data "$2" "1"
} | nc -U "$discord_ipc"
