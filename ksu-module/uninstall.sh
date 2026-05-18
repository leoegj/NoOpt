#!/system/bin/sh

if grep -q '^noopt ' /proc/modules 2>/dev/null; then
	rmmod noopt 2>/dev/null
fi
