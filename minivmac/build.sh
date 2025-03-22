#!/bin/bash

if [ ! -f setup_t ]; then
    clang setup/tool.c -o setup_t
fi

rm -rf MacDev.app
rm -rf MacDev.xcodeproj
rm -rf DerivedData

rm setup.sh

arm64=$(sysctl -ni hw.optional.arm64)

if [[ "$arm64" == 1 ]]; then
    target="mcar"
else
    target="mc64"
fi

./setup_t \
    -t $target \
    -m II \
    -hres 640 -vres 480 \
    -depth 3 \
    -mem 8M \
    -magnify 1 \
    -speed a \
    -n MacDev \
    -an MacDev \
    -bg 1 \
    -as 0 \
    -km F1 Escape \
    > ./setup.sh
ret=$?

if [ $ret -ne 0 ]; then
    exit $ret
fi

chmod a+x ./setup.sh
./setup.sh
ret=$?

if [ $ret -ne 0 ]; then
    exit $ret
fi

xcodebuild

exit 0
