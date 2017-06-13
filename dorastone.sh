#!/bin/bash
# DoraStone: Casting dynamic maps in stone for off-the-grid explorers
# Required: https://github.com/sindresorhus/pageres-cli
# Prerequisite: Need to run as root `sudo visudo -f /etc/sudoers.d/myOverrides` and add `nico ALL=(dorastone) ALL`
set -x


#ARTICLE="Seoul/Jongno"
while read ARTICLE; do

	# Clean up
	rm -f /tmp/frameset.html /tmp/screenshot.png /tmp/map.png

	# Download wikicode
	WIKICODE="/tmp/wikicode.txt"
	wget -O $WIKICODE "https://en.wikivoyage.org/w/index.php?title=$ARTICLE&action=raw"

	# Parse wikicode
	MAPFRAME=`grep apframe $WIKICODE`
	LATITUDE=`echo $MAPFRAME | sed -e "s/^[^|]*|//g" | sed -e "s/|.*//g"`
	LONGITUDE=`echo $MAPFRAME | sed -e "s/^[^|]*|//g" | sed -e "s/^[^|]*|//g" | sed -e "s/|.*//g"`
	if [[ $MAPFRAME == *width* ]] ; then
	  WIDTH=`echo $MAPFRAME | sed -e "s/.*width=//g" | sed -e "s/|.*//g"`
	else
	  WIDTH=420
	fi
	if [[ $MAPFRAME == *height* ]] ; then
	  HEIGHT=`echo $MAPFRAME |  | sed -e "s/.*height=//g" | sed -e "s/|.*//g"`
	else
	  HEIGHT=420
	fi
	ZOOM=`echo $MAPFRAME | sed -e "s/.*zoom=//g" | sed -e "s/|.*//g"`
	echo "Mapframe: $MAPFRAME"
	echo "Longitude: $LONGITUDE"
	echo "Latitude: $LATITUDE"
	echo "Width: $WIDTH"
	echo "Height: $HEIGHT"
	echo "Zoom: $ZOOM"

	# Take screenshot
	MAPURL="https://tools.wmflabs.org/wikivoyage/w/poimap2.php?lat=$LATITUDE\&lon=$LONGITUDE\&zoom=$ZOOM\&layer=M\&lang=en\&name=$ARTICLE"
	echo '<frameset rows="100%">
	  <frameset cols="100%">
	    <frame src="MAPURL" frameborder="0" scrolling="no">
	  </frameset>
	</frameset>' > /tmp/frameset.html
	sed -i "s#MAPURL#$MAPURL#g" /tmp/frameset.html

	pushd /tmp
        pageres frameset.html 800x800 --filename screenshot
        popd

	# Crop
	XMARGIN=$(((800-$WIDTH)/2))
	YMARGIN=$(((800-$HEIGHT)/2))
	convert /tmp/screenshot.png -crop ${WIDTH}x${HEIGHT}+${XMARGIN}+${YMARGIN} /tmp/map.png

	# Upload /tmp/map.png to Commons
	# TODO

	# Insert in article
	# TODO
done < articles.txt
