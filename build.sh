#!/bin/sh

PRG0="47ba60fad332fdea5ae44b7979fe1ee78de1d316ee027fea2ad5fe3c0d86f25a"


compareHash() {
	echo $1 $2 | sha256sum --check > /dev/null 2>&1
}

build() {
	tools/asm6f vulpreich.asm -n -c -L bin/vulpreich.nes "$@" > bin/assembler.log
}



if [ "$1" = "test" ] ; then

	buildErr=0

	build

	if [ $? -ne 0 ] ; then
		echo 'Failed building PRG0!'
		buildErr=1
	
	elif ! compareHash $PRG0 'bin/vulpreich.nes' ; then
		echo 'PRG0 build did not match PRG0!'
		buildErr=1
	fi

fi

echo 'Assembling...'
build $@

if [ $? -ne 0 ] ; then
	echo 'Build failed!'
	exit 1
fi

echo 'Build succeeded.'

if compareHash $PRG0 'bin/vulpreich.nes' -eq 0 ; then
	echo 'Matched PRG0 ROM'
	exit 0
else
	echo 'Did not match either ROM'
	exit -1
fi



