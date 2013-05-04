#!/bin/sh
##
## CreateBoost.sh -- derived from CreateBoost.R
##
## Jay Emerson and Dirk Eddelbuettel,  2012 - 2013

## First, download the new version of the Boost Libraries and
## set the variables boostall and version, here:
boostall="boost_1_51_0.tar.gz"
version="1.51.0-1"
date="2013-05-02"
pkgdir="pkg/BoostHeaders"          
## September 2, 2012

## Additional resources we require and need to test for
## 'sources' lists the directories we scan for Boost components
sources="../bigmemory"
## 'progs' lists the programs we need
progs="bcp"


## Derive the 'bootroot' name from the tarball, using basename(1)
boostroot=$(basename ${boostall} ".tar.gz")

## DEBUG display
echo "Check: ${boostall} ${version} ${date} ${pkgdir} ${boostroot}"

## A sanity check here before continuing:
if [ ! -f ${boostall} ] && [ ! -d ${boostroot} ]; then
    echo "The Boost input file or directory do not exist. Exiting."
    exit -1
fi

## DE: Needed? Can we not just overwrite?
#if [ -d ${pkgdir} ]; then
#    echo "svn rmdir pkg/BoostHeaders"
#    echo "Then when this is done and tested, add it back into the svn"
#    echo "stop 'Move aside the old BoostHeaders'"
#fi

## Another sanity check
for prog in ${progs}; do
    if [ ! -x /usr/bin/${prog} ] && [ ! -x /usr/local/bin/${prog} ]; then
	echo "** Program '${prog}' not found, exiting"
	exit -1
    fi
done
    
## Check for sources
for dir in ${sources}; do
    if [ ! -d ${dir} ]; then
	echo "** Source directory ${dir} not found, exiting"
	exit -1
    fi
done

########################################################################
# Unpack, copy from boost to BoostHeaders/inst/include,
# and build the supporting infrastructure of the package.

if [ ! -d ${boostroot} ]; then
    tar -zxf ${boostall}
fi

mkdir -p ${pkgdir} \
         ${pkgdir}/inst \
         ${pkgdir}/man \
         ${pkgdir}/inst/include

# bcp --scan --boost=boost_1_51_0 ../bigmemory/pkg/bigmemory/src/*.cpp test

# The bigmemory Boost dependencies:
bcp --scan --boost=${boostroot} ../bigmemory/pkg/bigmemory/src/*.cpp \
    ${pkgdir}/inst/include > bcp.log

# Plus filesystem
bcp --boost=${boostroot} filesystem ${pkgdir}/inst/include >> bcp.log

# Plus foreach (cf issue ticket #2527)
bcp --boost=${boostroot} foreach ${pkgdir}/inst/include >> bcp.log

# Plus math/distributions (cf issue ticket #2533)
bcp --boost=${boostroot} math/distributions ${pkgdir}/inst/include >> bcp.log

# Plus iostream (cf issue ticket #2768) -- thia is a null-op, why?
bcp --boost=${boostroot} iostream ${pkgdir}/inst/include >> bcp.log

# TODO: check with other packages


## Some post processing
rm -r ${pkgdir}/inst/include/libs \
      ${pkgdir}/inst/include/Jamroot \
      ${pkgdir}/inst/include/boost.png \
      ${pkgdir}/inst/include/doc

cp BoostHeadersROOT/LICENSE* \
   BoostHeadersROOT/NAMESPACE ${pkgdir}
cp -p BoostHeadersROOT/man/*.Rd ${pkgdir}/man

sed -e "s/XXX/${version}/g" \
    -e "s/YYY/${date}/g"    \
    BoostHeadersROOT/DESCRIPTION  >  ${pkgdir}/DESCRIPTION
sed -e "s/XXX/${version}/g" -e "s/YYY/${date}/g" \
    BoostHeadersROOT/man/BoostHeaders-package.Rd >
    ${pkgdir}/man/BoostHeaders-package.Rd 


########################################################################
# Now fix up things that don't work.  Here, we need to stay
# organized and decide who is the maintainer of what, but this script
# is the master record of any changes made to the boost tree.

## bigmemory et.al. will require changes to support Windows; we
## believe the Mac and Linux versions will be fine without changes.

## We'll invite co-maintainers who identify changes needed to support
## their specific libraries.
