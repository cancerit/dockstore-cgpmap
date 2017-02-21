#!/bin/bash
LIBMAUSVERSION=2.0.312-release-20170208002133
BIOBAMBAMVERSION=2.0.69-release-20170127133459
SNAPPYVERSION=1.1.4
IOLIBVERSION=1.14.8
CHRPATHVERSION=0.16.1
BUILDDIR=${PWD}
INSTALLDIR=${BUILDDIR}/install-dir
TOOLSDIR=${BUILDDIR}/tools-dir
PAR=`cat /proc/cpuinfo | egrep "^processor" | wc -l`

set -uxe

# get chrpath
if [ ! -f chrpath-${CHRPATHVERSION}.tar.gz ] ; then
	curl -sSL "https://alioth.debian.org/frs/download.php/file/3979/chrpath-${CHRPATHVERSION}.tar.gz" > chrpath-${CHRPATHVERSION}.tar.gz
fi

# get iolib
if [ ! -f io_lib-${IOLIBVERSION}.tar.gz ] ; then
	curl -sSL "http://downloads.sourceforge.net/project/staden/io_lib/${IOLIBVERSION}/io_lib-${IOLIBVERSION}.tar.gz?&use_mirror=kent" \
		> io_lib-${IOLIBVERSION}.tar.gz
fi

# get snappy
if [ ! -f snappy-${SNAPPYVERSION}.tar.gz ] ; then
  curl -sSL https://github.com/google/snappy/archive/${SNAPPYVERSION}.tar.gz > snappy-${SNAPPYVERSION}.tar.gz
fi

# get libmaus
if [ ! -f libmaus-${LIBMAUSVERSION}.tar.gz ] ; then
	curl -sSL https://github.com/gt1/libmaus2/archive/${LIBMAUSVERSION}.tar.gz > libmaus-${LIBMAUSVERSION}.tar.gz
fi

# get biobambam
if [ ! -f biobambam-${BIOBAMBAMVERSION}.tar.gz ] ; then
	curl -sSL https://github.com/gt1/biobambam2/archive/${BIOBAMBAMVERSION}.tar.gz > biobambam-${BIOBAMBAMVERSION}.tar.gz
fi

mkdir -p chrpath-${CHRPATHVERSION}-src
tar -C chrpath-${CHRPATHVERSION}-src --strip-components=1 -xzf chrpath-${CHRPATHVERSION}.tar.gz
mkdir -p chrpath-${CHRPATHVERSION}-build
cd chrpath-${CHRPATHVERSION}-build
${BUILDDIR}/chrpath-${CHRPATHVERSION}-src/configure --prefix=${TOOLSDIR}
make -j${PAR}
make -j${PAR} install
cd ..
rm -fR chrpath-${CHRPATHVERSION}-src chrpath-${CHRPATHVERSION}-build

rm -fR ${INSTALLDIR}
mkdir -p ${INSTALLDIR}

# build iolib
mkdir -p io_lib-${IOLIBVERSION}-src
tar -C io_lib-${IOLIBVERSION}-src --strip-components=1 -xzf io_lib-${IOLIBVERSION}.tar.gz
mkdir -p io_lib-${IOLIBVERSION}-build
cd io_lib-${IOLIBVERSION}-build
LDFLAGS="-Wl,-rpath=XORIGIN/../lib" ${BUILDDIR}/io_lib-${IOLIBVERSION}-src/configure --prefix=${INSTALLDIR}
make -j${PAR}
make -j${PAR} install
cd ..
rm -fR io_lib-${IOLIBVERSION}-src io_lib-${IOLIBVERSION}-build

# build snappy
mkdir -p snappy-${SNAPPYVERSION}-src
tar -C snappy-${SNAPPYVERSION}-src --strip-components=1 -xzf snappy-${SNAPPYVERSION}.tar.gz
cd snappy-${SNAPPYVERSION}-src
autoreconf -i -f
cd ../
mkdir -p snappy-${SNAPPYVERSION}-build
cd snappy-${SNAPPYVERSION}-build
LDFLAGS="-Wl,-rpath=XORIGIN/../lib" ${BUILDDIR}/snappy-${SNAPPYVERSION}-src/configure --prefix=${INSTALLDIR}
make -j${PAR}
make -j${PAR} install
cd ..
rm -fR snappy-${SNAPPYVERSION}-src snappy-${SNAPPYVERSION}-build

# build libmaus
mkdir -p libmaus-${LIBMAUSVERSION}-src
tar -C libmaus-${LIBMAUSVERSION}-src --strip-components=1 -xzf libmaus-${LIBMAUSVERSION}.tar.gz
mkdir -p libmaus-${LIBMAUSVERSION}-build
cd libmaus-${LIBMAUSVERSION}-build
LDFLAGS="-Wl,-rpath=XORIGIN/../lib" ${BUILDDIR}/libmaus-${LIBMAUSVERSION}-src/configure --prefix=${INSTALLDIR} \
	--with-snappy=${INSTALLDIR} \
	--with-io_lib=${INSTALLDIR}
make -j${PAR}
make -j${PAR} install
cd ..
rm -fR libmaus-${LIBMAUSVERSION}-src libmaus-${LIBMAUSVERSION}-build

# build biobambam
mkdir -p biobambam-${BIOBAMBAMVERSION}-src
tar -C biobambam-${BIOBAMBAMVERSION}-src --strip-components=1 -xzf biobambam-${BIOBAMBAMVERSION}.tar.gz
mkdir -p biobambam-${BIOBAMBAMVERSION}-build
cd biobambam-${BIOBAMBAMVERSION}-build
LDFLAGS="-Wl,-rpath=XORIGIN/../lib" ${BUILDDIR}/biobambam-${BIOBAMBAMVERSION}-src/configure --prefix=${INSTALLDIR} \
	--with-libmaus2=${INSTALLDIR}
make -j${PAR}
make -j${PAR} install
cd ..
rm -fR biobambam-${BIOBAMBAMVERSION}-src biobambam-${BIOBAMBAMVERSION}-build

for i in `find ${INSTALLDIR} -name \*.so\*` ; do
	ORIG=`objdump -x ${i} | grep RPATH | awk '{print $2}'`
	MOD=`echo "$ORIG" | sed "s/XORIGIN/\\$ORIGIN/"`
	${TOOLSDIR}/bin/chrpath -r "${MOD}" ${i}
done

for i in ${INSTALLDIR}/bin/* ; do
	if [ ! -z `LANG=C file ${i} | egrep "ELF.*executable" | awk '{print $1}' | perl -p -e "s/://"` ] ; then
		ORIG=`objdump -x ${i} | grep RPATH | awk '{print $2}'`
		MOD=`echo "$ORIG" | sed "s/XORIGIN/\\$ORIGIN/"`
		${TOOLSDIR}/bin/chrpath -r "${MOD}" ${i}
	fi
done

rm -fR ${TOOLSDIR}

# my additions
mv ${INSTALLDIR} biobambam
rm -f chrpath-${CHRPATHVERSION}.tar.gz
rm -f io_lib-${IOLIBVERSION}.tar.gz
rm -f snappy-${SNAPPYVERSION}.tar.gz
rm -f libmaus-${LIBMAUSVERSION}.tar.gz
rm -f biobambam-${BIOBAMBAMVERSION}.tar.gz
