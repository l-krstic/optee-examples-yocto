#!/bin/bash

# Check if host system is debian-based
echo "Checking system configuration..."
if [ -f /etc/debian_version ]; then
	echo
else
	echo "This script is intended for Debian-based systems only. Exiting..."
	exit 1
fi

# SW prerequisites list
dependencies=("android-tools-adb" "android-tools-fastboot" "autoconf"
	"automake" "bc" "bison" "build-essential" "ccache" "cpio"
	"cscope" "curl" "device-tree-compiler" "expect" "flex"
	"ftp-upload" "gdisk" "git" "iasl" "libattr1-dev" "libcap-ng-dev"
	"libfdt-dev" "libftdi-dev" "libglib2.0-dev" "libgmp3-dev"
	"libhidapi-dev" "libmpc-dev" "libncurses5-dev" "libpixman-1-dev"
	"libslirp-dev" "libssl-dev" "libtool" "make" "mtools" "netcat"
	"ninja-build" "python-is-python3" "python3-crypto" "python3-cryptography"
	"python3-pip" "python3-pyelftools" "python3-serial" "rsync" "unzip"
	"uuid-dev" "wget" "xdg-utils" "xterm" "xz-utils" "zlib1g-dev"
	"uuid-runtime"
)

# Function to check if some sw is already installed
is_dependency_installed() {
	local dep="$1"
	dpkg -s "$dep" >/dev/null 2>&1
}

# Install sw that is missing on the system
echo "Checking software prerequisites..."
for dep in "${dependencies[@]}"; do
	if ! is_dependency_installed "$dep"; then
		echo "Installing $dep..."
		sudo apt install -y "$dep"
		echo
	else
		# echo "$dep is already installed."
		continue
	fi
done

# Generate UUID and store it in a variable
echo
echo "Generating UUID..."
uuid=$(uuidgen)

# Ask user for application name
echo
echo "Enter application name:"
read app_name

# Clone repo with template app "my_example"
echo
git clone https://github.com/l-krstic/optee-template-app.git
cd optee-template-app

# Rename application directory
echo
echo "Renaming my_example directory name to $app_name..."
mv my_example/ $app_name

# Save UUID in file
echo
echo "Saving uuid in ${app_name}_UUID.txt..."
touch ${app_name}_UUID.txt
echo $uuid > ${app_name}_UUID.txt

# Making changes in application files
echo
echo "------- Making host section changes"
cd ${app_name}/host/
echo "host/Makefile..."
#...
echo "host/main.c..."
#...
echo "host/main.c..."
#...
echo "host/main.c..."
#...

echo
echo "------- Making trusted section changes"
cd ../ta
echo "ta/Android.mk..."
#...
echo "ta/user_ta_header_defines.h..."
#...
echo "ta/user_ta_header_defines.h..."
#...
echo "ta/user_ta_header_defines.h..."
#...
echo "ta/sub.mk..."
#...
echo "ta/Makefile..."
#...
echo "ta/${app_name}_ta.c..."
#...
echo "ta/${app_name}_ta.c..."
#...
echo "ta/include/${app_name}_ta.h..."
#...
echo "ta/include/${app_name}_ta.h..."
#...

echo
echo "------- Making high-level build helper changes"
cd ..
echo "CMakeLists.txt..."
#...
echo "Android.mk..."
#...
