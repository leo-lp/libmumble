#!/bin/bash
# Copyright (c) 2013 The libmumble Developers
# The use of this source code is goverened by a BSD-style
# license that can be found in the LICENSE-file.

# This script generates a script that can regenerate the
# OpenSSL source tree's include directory structure.
# This is a destructive operation on the OpenSSL source
# tree. Use with care.

trap exit SIGINT SIGTERM

cd ../openssl

git clean -dfx
git reset --hard

./Configure linux-elf
cd ../opensslbuild

cat > genlinks.bash <<EOF
# This file was generated by gengenlinks.bash
# on $(date +%Y-%m-%d\ %H:%M:%S%z) using $(uname -sr)

function mksymlink {
	rm -f \$2
	if [ "\$(uname -o)" == "Cygwin" ]; then
		cp \$1 \$2 2>/dev/null
	else
		ln -sf \$1 \$2 2>/dev/null
	fi
}

SCRIPT_DIR=\$(dirname \${BASH_SOURCE})
mkdir -p \${SCRIPT_DIR}/../openssl/include/openssl
cd \${SCRIPT_DIR}/../openssl/include/openssl

EOF

for fn in $(ls ../openssl/include/openssl); do
	dst=$(readlink ../openssl/include/openssl/${fn})
	echo "mksymlink ${dst} ${fn}" >> genlinks.bash
done

cat >> genlinks.bash <<EOF

exit 0
EOF

cd ../openssl

git clean -dfx
git reset --hard
