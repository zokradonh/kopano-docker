#!/bin/bash

php_cfg_gen() {
	local cfg_file="$1"
	local cfg_setting="$2"
	local cfg_value="$3"
	if [ -e "$cfg_file" ]; then
		echo "Setting $cfg_setting = $cfg_value in $cfg_file"
		if ! grep -q "$cfg_setting" "$cfg_file"; then
			echo "WARNING: Config option $cfg_setting not found in $cfg_file! You may have misspelled the confing setting."
			echo "define('$cfg_setting', '$cfg_value');" >> "$cfg_file"
			cat "$cfg_file"
			return
		fi
		case $cfg_value in
		# TODO stop after the first match
		true|TRUE|false|FALSE)
			sed -ri "s#(\s*define).+${cfg_setting}.+#\tdefine(\x27${cfg_setting}\x27, ${cfg_value}\);#g" "$cfg_file"
			;;
		*)
			sed -ri "s#(\s*define).+${cfg_setting}.+#\tdefine(\x27${cfg_setting}\x27, \x27${cfg_value}\x27\);#g" "$cfg_file"
			;;
		esac
	else
		echo "Error: Config file $cfg_file not found. Plugin not installed?"
		local dir
		dir=$(dirname "$cfg_file")
		ls -la "$dir"
		exit 1
	fi
}