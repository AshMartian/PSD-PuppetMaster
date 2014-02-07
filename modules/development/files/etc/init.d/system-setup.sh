# !/bin/sh

if [ -f /home/psd/.ran ];
then
	puppet agent &&
	rm -rf /home/psd/.ran
else
	clear
	
	r=$((RANDOM%5+1))
	
	
	#if [ $r == 1 ]; then
	#	/usr/games/cowsay "Mooooooooving files...."
	#elif [ $r == 2 ]; then
	#	/usr/games/cowsay -f dragon "Burning files..."
	#elif [ $r == 3 ]; then
	#	/usr/games/cowsay -f sheep "Baaaaaa-ning files..."
	#elif [ $r == 4 ]; then
	#	/usr/games/cowsay -f snowman "File sublimation!"
	#elif [ $r == 5 ]; then
	#	/usr/games/cowsay -f turtle "Slowing file existance"
	#fi

	/usr/games/cowsay "Mooooooooving Files....."

	rm -rf /home/psd/*
	cp -ar /etc/skel/* /home/psd
	cp -ar /etc/skel/. /home/psd
	chown -R psd:psd /home/psd
	echo "setup has been ran" > /home/psd/.ran
	clear
fi

exit 0
