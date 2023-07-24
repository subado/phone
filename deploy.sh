#!/usr/bin/env sh

BLOATWARE=bloatware
APPIDS=appids

install_apps() {
	fdroidcl update
	while read -r file; do
		while read -r appid; do
			case "$appid" in
			'#'* | '')
				continue
				;;
			*)
				fdroidcl install "$appid"
				;;
			esac
		done <"$file"
	done <<-_EOF
		$(find "$APPIDS" -type f)
	_EOF

}

remove_proprietaries() {
	while read -r file; do
		temp="$(mktemp)"
		while read -r pkg; do
			echo "printf '%s ' \"uninstall $pkg\";pm uninstall -k --user 0 $pkg" >> "$temp"
		done <"$file"
		adb shell <"$temp"
		rm "$temp"
	done <<-_EOF
		$(find "$BLOATWARE" -type f)
	_EOF
}

remove_proprietaries
install_apps
