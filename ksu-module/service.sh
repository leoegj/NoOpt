#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG=nohello
KO_PATH="$MODDIR/nohello.ko"
CONFIG_PATH="$MODDIR/target_path.conf"
HIDE_DIRENTS_CONFIG="$MODDIR/hide_dirents.conf"
DEFAULT_TARGET_PATH="/data/local/tmp/nohello"
TARGET_PATHS=""
FOUND_TARGET=0
HIDE_DIRENTS=1

log_i() {
	log -p i -t "$LOG_TAG" "$*"
}

log_e() {
	log -p e -t "$LOG_TAG" "$*"
}

add_target_path() {
	CANDIDATE_PATH="$1"

	if [ -z "$CANDIDATE_PATH" ]; then
		return
	fi

	if [ -z "$TARGET_PATHS" ]; then
		TARGET_PATHS="$CANDIDATE_PATH"
	else
		TARGET_PATHS="$TARGET_PATHS,$CANDIDATE_PATH"
	fi

	if [ -e "$CANDIDATE_PATH" ]; then
		FOUND_TARGET=1
	else
		log_i "target does not exist yet, kernel will skip: $CANDIDATE_PATH"
	fi
}

if [ -f "$CONFIG_PATH" ]; then
	while IFS= read -r CONFIG_LINE || [ -n "$CONFIG_LINE" ]; do
		CONFIG_LINE="$(printf '%s' "$CONFIG_LINE" | tr -d '\r')"
		case "$CONFIG_LINE" in
			''|\#*)
				continue
				;;
		esac
		add_target_path "$CONFIG_LINE"
	done < "$CONFIG_PATH"
fi

if [ -z "$TARGET_PATHS" ]; then
	add_target_path "$DEFAULT_TARGET_PATH"
fi

if [ -f "$HIDE_DIRENTS_CONFIG" ]; then
	HIDE_DIRENTS="$(head -n 1 "$HIDE_DIRENTS_CONFIG" | tr -d '\r')"
fi

case "$HIDE_DIRENTS" in
	0|false|False|no|No)
		HIDE_DIRENTS=0
		;;
	*)
		HIDE_DIRENTS=1
		;;
esac

if [ -z "$TARGET_PATHS" ]; then
	log_e "empty target path list"
	exit 1
fi

if [ ! -f "$KO_PATH" ]; then
	log_e "missing module: $KO_PATH"
	exit 1
fi

sleep 10

if grep -q '^nohello ' /proc/modules 2>/dev/null; then
	log_i "nohello is already loaded"
	exit 0
fi

if [ "$FOUND_TARGET" -eq 0 ]; then
	log_i "no configured targets exist, skip loading"
	exit 0
fi

if insmod "$KO_PATH" target_paths="$TARGET_PATHS" hide_dirents="$HIDE_DIRENTS"; then
	log_i "loaded $KO_PATH target_paths=$TARGET_PATHS hide_dirents=$HIDE_DIRENTS"
else
	log_e "failed to load $KO_PATH"
	exit 1
fi
