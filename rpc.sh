#!/bin/sh

### Posix compliant script for Discord Rich presence (no need to have python and pypresence) ###

#encode opcode and payload length in little-endian format and prepend it with payload
set_activity() {
	#length of payload
	len=${#1}
	#outputs opcode in little endian encoding
	printf "\\001\\000\\000\\000"
	#loop for length to encode in little endian encoding
	for i in 0 8 16 24; do
		len=$((len >> i))
		#shellcheck disable=SC2059
		printf "\\$(printf "%03o" "$len")"
	done
	#print the payload that need to be sent
	printf "%s" "$1"
}

start_rich_presence() {
	rm -f "$handshook" >/dev/null
	tail -f "$presence" | nc -U "$discord_ipc" >"/tmp/ipclog"
}

update_rich_presence() {
 	payload=$1
	if [ ! -e "$handshook" ]; then
		handshake='{"v":1,"client_id":"'$presence_client_id'"}'
		# handshake with opcode
		printf "\\000\\000\\000\\000\\$(printf "%03o" "${#handshake}")\\000\\000\\000%s" "$handshake" >"$presence"
		sleep 2
		touch "$handshook"
	fi
	set_activity "$payload" >"$presence"
}



#main
if [ -z "$1" ];then
	printf "Pass client Id please!!" && exit 1
elif [ -z "$2" ];then
	printf "Pass Payload please!!" && exit 1
fi

presence_client_id=$1
discord_ipc="${XDG_RUNTIME_DIR}/discord-ipc-0" #can be 2 discord-IPCs namely discord-ipc-0,discord-ipc-1 if you have both arRPC and discord installed and running
payload=$2
presence="/tmp/${0##*/}-presence"
handshook="/tmp/${0##*/}-handshook"

# - netcat should be BSD version and not GNU one, for this to work
# - $1 is client id, buy your own
# - $2 is actually payload json, atleast figure that out from internet
pgrep -f "nc -U $discord_ipc" >/dev/null || nohup start_rich_presence & >/dev/null

#update the discord rich presence, requires client id
update_rich_presence "$payload"
