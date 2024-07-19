#!/bin/bash
set -euo pipefail
# Helper script to generate the plugin zip file which can be directly
# installed by Calibre
rm -rf ./calibre-remarkable-device-driver-plugin.zip ./target

mkdir -p target
cp __init__.py config.py LICENSE plugin-import-name-remarkable_plugin.txt target/

(
	cd ./target

	# Do this in case MacOS
	PATH="/Applications/calibre.app/Contents/MacOS:$PATH"
	PATH="$HOME/Applications/calibre.app/Contents/MacOS:$PATH"

	# You need to use the same Python as Calibre itself uses.
	pyver=$(calibre-debug -c 'from sys import version_info as v; print(f"{v.major}.{v.minor}");'||true)
	[ -n "$pyver" ] || {
		echo >&2 'You must have calibre-debug in your $PATH to build the plugin.'
		exit 10
	}

	# Check for pip
	pip${pyver} -V >/dev/null || {
		echo >&2 "Calibre is using Python v$pyver, so to build this plugin you"
		echo >&2 "need a Python $pyver runtime installed, with pip$pyver present."
		exit 20
	}

	# Include all the dependencies in the zip archive
	pip${pyver} install git+https://github.com/nick8325/remarkable-fs -t ./
	zip -r ../calibre-remarkable-device-driver-plugin.zip ./ -x ".*" "*.pyc"
)
