#!/usr/bin/bash

configSudo() {
	# This function should always be run as superuser

	# If sudo isn't installed, install it
	echo -e "\033[0;90m[\033[1;92mInfo\033[0;90m] :\033[0m Installing sudo if it is not already installed"
	[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Checking to see if app-admin/sudo is already installed"
	if [ ! -v sudo > /dev/null ]; then
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m app-admin/sudo is not already installed"
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Installing app-admin/sudo"
		EMERGE_DEFAULT_OPTS="$emerge_default_opts" emerge -vq app-admin/sudo || return 1
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m app-admin/sudo has been installed successfully"
	else
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m app-admin/sudo is already installed"
	fi

	# Add $USER to wheel group
	echo -e "\033[0;90m[\033[1;92mInfo\033[0;90m] :\033[0m Giving $USER sudo privileges if not already present"
	[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Checking to see if $USER is a superuser"
	if [[ $(getent group "wheel" | grep -w "$USER") ]]; then
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m $USER is already a superuser"
	else
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m $USER is not a superuser"
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Adding $USER to the \`wheel\` group"
		useradd -aG wheel $USER || return 1
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m $USER added to \`wheel\` group successfully"
	fi

	# Copy VISUDO config
	echo -e "\033[0;90m[\033[1;92mInfo\033[0;90m] :\033[0m Copying sudo configuration"
	[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Checking to see if $sudo_conf_path exists"
	if [ -e $sudo_conf_path ]; then
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Copying $sudo_conf_path -> /etc/sudoers"
		cp -f "$sudo_conf_path" "/etc/sudoers" || return 1
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Changing owner of /etc/sudoers to root:root"
		chown root:root /etc/sudoers || return 1
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Changing /etc/sudoers permissions to 110"
		chmod 110 /etc/sudoers || return 1
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Sudo configured succcessfully"
	else
		[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m No sudo configuration detected at $sudo_conf_path"
	fi
}

# Define variables
debug=1
rebos_path="$HOME/.config/rebos"
sudo_conf_path="$rebos_path/system_files/sudo.conf"
emerge_default_opts="--jobs ${($(nproc) / 2)}"

# Configure sudo
echo -e "\033[0;90m[\033[1;92mInfo\033[0;90m] :\033[0m Configuring sudo (if needed)"
[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Checking to see if sudo needs to be configured"
if [ ! -v sudo ] || [[ ! $(sudo -l $USER) ]]; then #TODO: probably change me
	echo -e "\033[0;90m[\033[1;93mWarning\033[0;90m] :\033[0m Sudo is not configured"
	echo -e "\033[0;90m[\033[1;92mInfo\033[0;90m] :\033[0m Configuring sudo"
	export -f configSudo
	su -c "debug=$debug sudo_conf_path=$sudo_conf_path emerge_default_opts=$emerge_default_opts configSudo" || exit 1
fi
[[ $debug == 1 ]] && echo -e "\033[0;90m[\033[1;94mDebug\033[0;90m] :\033[0m Sudo is configured properly"

#TODO: make.conf

#TODO: cpuid2cpuflags
