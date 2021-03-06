#!/bin/bash
# Copyright (c) 2013 The libmumble Developers
# The use of this source code is goverened by a BSD-style
# license that can be found in the LICENSE-file.

# This script generates the canonical versions of opensslconf.h
# for the architectures we support in 3rdparty/openssl.
# The script is destructive, and will wipe any changes in your
# 3rdparty/openssl submodule, so run with care.

# Notes:
# We strip OPENSSL_CPUID_OBJ and define it in the gyp file instead.

trap exit SIGINT SIGTERM

cd ../openssl

function writehdr {
	command=${1}
	out=${2}
	echo "// This file was generated by generate-opensslconf.bash" > ${out}
	echo "// by executing '${command}' in the OpenSSL source tree." >> ${out}
	echo >> ${out}
}

# dist (generic)
git clean -dfx
git reset --hard
./Configure dist
writehdr "./Configure dist" ../opensslbuild/opensslconf-dist.h
tail -n+4 crypto/opensslconf.h >> ../opensslbuild/opensslconf-dist.h

# x86_32
git clean -dfx
git reset --hard
rm crypto/opensslconf.h
./Configure linux-elf
writehdr "./Configure linux-elf" ../opensslbuild/opensslconf-x86.h
tail -n+4 crypto/opensslconf.h | sed 's,#define OPENSSL_CPUID_OBJ,,' >> ../opensslbuild/opensslconf-x86.h

# x86_64
git clean -dfx
git reset --hard
rm crypto/opensslconf.h
./Configure linux-x86_64
writehdr "./Configure linux-x86_64" ../opensslbuild/opensslconf-x86_64.h
tail -n+4 crypto/opensslconf.h | sed 's,#define OPENSSL_CPUID_OBJ,,' >> ../opensslbuild/opensslconf-x86_64.h

# x86_64 LLP64
git clean -dfx
git reset --hard
rm crypto/opensslconf.h
./Configure mingw64
writehdr "./Configure mingw64" ../opensslbuild/opensslconf-x86_64-llp64.h
tail -n+4 crypto/opensslconf.h | sed 's,#define OPENSSL_CPUID_OBJ,,' >> ../opensslbuild/opensslconf-x86_64-llp64.h

# ARM
git clean -dfx
git reset --hard
rm crypto/opensslconf.h
./Configure linux-armv4
writehdr "./Configure linux-armv4" ../opensslbuild/opensslconf-arm.h
tail -n+4 crypto/opensslconf.h | sed 's,#define OPENSSL_CPUID_OBJ,,' >> ../opensslbuild/opensslconf-arm.h

# final cleanup
git clean -dfx
git reset --hard

