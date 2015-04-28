#!/bin/bash

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

# Get Build Startup Time
if [ -z "$OUT_TARGET_HOST" ]
then
   res1=$(date +%s.%N)
else
   res1=$(gdate +%s.%N)
fi

# Path to build your kernel
  k=~/kernel/m8-Sense-5.0.1
# Directory for the any kernel updater
  t=$k/out

# Clean Kernel
   echo "${bldcya}Clean ${bldcya}Kernel${txtrst}"
     make clean

# Clean old builds
   echo "${bldred}Clean ${bldred}Out ${bldred}Folder${txtrst}"
     rm -rf $k/out
#     make clean

# Setup the build
 cd $k/arch/arm/configs/Opti_Configs
    for c in *
      do
        cd $k
# Setup output directory
       mkdir -p "out/$c"
       mkdir -p "out/$c/modules/"

  m=$k/out/$c/modules

TOOLCHAIN=/home/talnoah/linaro-4.9.3/bin/arm-cortex_a15-linux-gnueabihf-
export ARCH=arm
export SUBARCH=arm

# make mrproper
#make CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` mrproper
 
# remove backup files
find ./ -name '*~' | xargs rm

#Compile Log
make >& error.log

# make kernel
make 'optikernel_defconfig'
make -j`grep 'processor' /proc/cpuinfo | wc -l` CROSS_COMPILE=$TOOLCHAIN #>> compile.log 2>&1 || exit -1

# Grab modules & zImage
   echo ""
   echo "<<>><<>> ${bldred}Collecting ${bldred}modules ${bldred}and ${bldred}zimage${txtrst} <<>><<>>"
   echo ""
   cp $k/arch/arm/boot/zImage out/$c/boot/zImage
   for mo in $(find . -name "*.ko"); do
		cp "${mo}" $m
   done

# Get Build Time
if [ -z "$OUT_TARGET_HOST" ]
then
   res2=$(date +%s.%N)
else
   res2=$(gdate +%s.%N)
fi

echo "${bldgrn}Total ${bldblu}time ${bldred}elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
echo "************************************************************************"
echo "${bldylw}${bldred}Build ${bldcya}Numba ${bldblu}${VERSION} ${txtrst}"
echo "${bldylw}${bldred}My ${bldcya}Kernels ${bldblu}Build ${bldred}Fast${txtrst}"
echo "************************************************************************"

done
