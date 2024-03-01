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
	"uuid-runtime" "sed"
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
uuid_no_dashes="${uuid//-}"
sub_uuid1="${uuid_no_dashes:0:8}"
sub_uuid2="${uuid_no_dashes:8:4}"
sub_uuid3="${uuid_no_dashes:12:4}"
sub_uuid4="${uuid_no_dashes:16:2}"
sub_uuid5="${uuid_no_dashes:18:2}"
sub_uuid6="${uuid_no_dashes:20:2}"
sub_uuid7="${uuid_no_dashes:22:2}"
sub_uuid8="${uuid_no_dashes:24:2}"
sub_uuid9="${uuid_no_dashes:26:2}"
sub_uuid10="${uuid_no_dashes:28:2}"
sub_uuid11="${uuid_no_dashes:30}"

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
file_path=""
new_string=""
line_number=-1
app_name_uppercase="${app_name^^}"

# Function to replace a line in a file with a new string
replace_line_in_file() {
	local file_path="$1"
	local new_string="$2"
	local line_number="$3"
	sed -i "${line_number}s/.*/${new_string}/" "$file_path"
}

cd ${app_name}/host/
echo

echo "------- Making host section changes"

echo "host/Makefile..."
replace_line_in_file "./Makefile" "BINARY = optee_example_${app_name}" 15

echo "host/main.c..."
replace_line_in_file "./main.c" "#include <${app_name}_ta.h>" 36

echo "host/main.c..."
replace_line_in_file "./main.c" \
	"	TEEC_UUID uuid = TA_${app_name_uppercase}_UUID;" \
	44

echo "host/main.c..."
replace_line_in_file "./main.c" \
	"        res = TEEC_InvokeCommand(\&sess, TA_${app_name_uppercase}_CMD1, \&op," \
	86
replace_line_in_file "./main.c" \
	"        res = TEEC_InvokeCommand(\&sess, TA_${app_name_uppercase}_CMD2, \&op," \
	94

cd ../ta
echo

echo "------- Making trusted section changes"

mv ./include/my_example_ta.h ./include/${app_name}_ta.h
mv my_example_ta.c ${app_name}_ta.c

echo "ta/Android.mk..."
replace_line_in_file "./Android.mk" "local_module := ${uuid}.ta" 3

echo "ta/user_ta_header_defines.h..."
replace_line_in_file "./user_ta_header_defines.h" "#include <${app_name}_ta.h>" 36

echo "ta/user_ta_header_defines.h..."
replace_line_in_file "./user_ta_header_defines.h" \
	"#define TA_UUID				TA_${app_name_uppercase}_UUID" \
	38

echo "ta/user_ta_header_defines.h..."
replace_line_in_file "./user_ta_header_defines.h" \
	"    { \"org.linaro.${app_name}.property1\", \\\\" \
	60
replace_line_in_file "./user_ta_header_defines.h" \
	"    { \"org.linaro.${app_name}.property2\", \\\\" \
	63

echo "ta/sub.mk..."
replace_line_in_file "./sub.mk" "srcs-y += ${app_name}_ta.c" 2

echo "ta/Makefile..."
replace_line_in_file "./Makefile" "BINARY=${uuid}" 4

echo "ta/${app_name}_ta.c..."
replace_line_in_file "./${app_name}_ta.c" "#include <${app_name}_ta.h>" 31

echo "ta/${app_name}_ta.c..."
replace_line_in_file "./${app_name}_ta.c" \
	"	case TA_${app_name_uppercase}_CMD1:" \
	148
replace_line_in_file "./${app_name}_ta.c" \
	"       case TA_${app_name_uppercase}_CMD2:" \
	150

echo "ta/include/${app_name}_ta.h..."
replace_line_in_file "./include/${app_name}_ta.h" "#define TA_${app_name_uppercase}_UUID \\\\" 36
replace_line_in_file "./include/${app_name}_ta.h" \
	"	{ 0x${sub_uuid1}, 0x${sub_uuid2}, 0x${sub_uuid3}, \\\\" \
	37
replace_line_in_file "./include/${app_name}_ta.h" \
	"		{ 0x${sub_uuid4}, 0x${sub_uuid5}, 0x${sub_uuid6}, \
0x${sub_uuid7}, 0x${sub_uuid8}, 0x${sub_uuid9}, 0x${sub_uuid10}, 0x${sub_uuid11}} } " \
	38

echo "ta/include/${app_name}_ta.h..."
replace_line_in_file "./include/${app_name}_ta.h" \
	"#define TA_${app_name_uppercase}_CMD1		0" \
	41
replace_line_in_file "./include/${app_name}_ta.h" \
	"#define TA_${app_name_uppercase}_CMD2		1" \
	42


echo
cd ..

echo "------- Making high-level build helper changes"

echo "CMakeLists.txt..."
replace_line_in_file "./CMakeLists.txt" "project (optee_example_${app_name} C)" 1

echo "Android.mk..."
replace_line_in_file "./Android.mk" "LOCAL_MODULE := optee_example_${app_name}" 13
replace_line_in_file "./Android.mk" "###################### ${app_name} ######################" 1
