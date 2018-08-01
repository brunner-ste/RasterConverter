#!/bin/bash

# ICAO Poland 2018

NAME='icao_pol_2018'
GROUP='icao'
CATEGORY='aero'
PUBLISHED='2018-08'
ISO='pol'

RAW=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/raw'
SHP=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/shp'
RGBA=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/tif_rgba'
ARCHIVE=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/icao_'$ISO'_2018.tar.gz'
CONVERTED=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/icao_'$ISO'_2018'
PACK=''$HOME'/server/Eanserver18/raster/tmp/BR/itcom_lpr/500k/icao_'$ISO'_2018/icao_'$ISO'_2018.pck*'

clear

##################################
echo ' '
date
echo Gestartet um: > log_$NAME
date >> log_$NAME
##################################

mkdir $NAME
mkdir tif_rgba

# Immer letzte Version verwenden!
CRUNCHER=''$HOME'/server/Eanserver18/raster/tmp/BR/'
PACKER='/usr/libexec'

echo ' '
date
echo 'Croppen und reproject gestartet...'
find $RAW -iname *.tif -print0 | xargs -0 -P4 -I{} bash -c 'gdalwarp -q -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -cutline '$SHP/*.shp' -dstalpha -r cubic -t_srs EPSG:4326 -of GTiff {} '$RGBA'/$(basename {})_rgba.tif'

cd $RGBA
gdalbuildvrt $NAME.vrt -srcnodata 0 *.tif

echo ' '
date
echo 'Konvertierung gestartet...'
echo ' '
# Mapcruncher

$CRUNCHER/mapcruncher -n $NAME -g $GROUP -c $CATEGORY -p $PUBLISHED $NAME.vrt ../$NAME.pck && date && do_refurbish-raster-map ../$NAME.pck ../$NAME/$NAME.pck && extract-map.def-zl.def ../$NAME/$NAME.pck ../$NAME

rm ../$NAME.pck*

# Tar Archiv fuer EN5 erstellen
echo ' '
date
echo ' '
echo 'EN5 Archiv erstellen...'
$PACKER/pack2tar $PACK >$ARCHIVE

date
echo ' '
echo 'MD5 Summen erstellen...'
cd ..
cd $CONVERTED

md5sum *.pck* >$NAME.md5

cd ..
mkdir en7
mv $CONVERTED en7

date
echo ' '
echo 'Konvertierung und Ablage aller Daten abgeschlossen...'
echo ' '

##################################
echo ' ' >> log_$NAME
echo Fertig um: >> log_$NAME
date >> log_$NAME
##################################

read -p "Temporaere Daten loeschen? (j/n)?" WAHL

if [[ "$WAHL" == [j,J] ]]; then
	
	
	rm -r $RGBA
		echo "Alles geloescht..."
		
	else 
		echo "Nichts geloescht..."
			fi
			
