##using image magick to make a gif

convert -resize 768x576 -delay 20 -loop 0 *.jpg myimage.gif


mogrify -font Liberation-Sans -fill white -shadow '#00000080' \
-pointsize 26 -gravity NorthEast -annotate +10+10 %t *.jpg

mogrify -font Roboto-Mono-Thin -fill white -stroke white \
-pointsize 45 -gravity NorthEast -annotate +10+10 %t *.jpeg


convert -delay 30 -quality 95 *.tif movie.mp4