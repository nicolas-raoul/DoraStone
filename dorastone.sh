#!/bin/bash
# DoraStone: Casting dynamic maps in stone for off-the-grid explorers
# Required: https://github.com/sindresorhus/pageres

ARTICLE="Seoul/Jongno"
WIKICODE="jongno.wikicode"
set -x
# Parse wikicode
MAPFRAME=`grep apframe $WIKICODE`
LONGITUDE=`echo $MAPFRAME | sed -e "s/^[^|]*|//g" | sed -e "s/|.*//g"`
LATITUDE=`echo $MAPFRAME | sed -e "s/^[^|]*|//g" | sed -e "s/^[^|]*|//g" | sed -e "s/|.*//g"`
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
MAPURL="https://tools.wmflabs.org/wikivoyage/w/poimap2.php?lat=$LATITUDE\&lon=$LONGITUDE\&zoom=$ZOOM\&lang=en\&name=$ARTICLE"
echo '<frameset rows="100%">
  <frameset cols="100%">
    <frame src="MAPURL" frameborder="0" scrolling="no">
  </frameset>
</frameset>' > /tmp/frameset.html
sed -i "s#MAPURL#$MAPURL#g" /tmp/frameset.html
pageres /tmp/frameset.html 800x800 --filename /tmp/screenshot.png

# Crop
XMARGIN=$(((800-$WIDTH)/2))
YMARGIN=$(((800-$HEIGHT)/2))
convert /tmp/screenshot.png -crop $(WIDTH)x$(HEIGHT)+$(XMARGIN)+$(YMARGIN) $(FILENAME)

# Upload to Commons
# TODO

# Insert in article
# TODO
