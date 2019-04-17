#!/bin/bash

#chmod u+x addMP3tags.sh

myfiles=(*.mp3)
nFiles=${#myfiles[@]};
myfiles=("*.mp3") # if there are white spaces in the name then Bash splits on it
counter=1
for i in ${myfiles[@]}; do
	echo "${i}"
	id3v2 -D "$i"
	id3v2 -a "Nature Podcast" "$i"
  id3v2 -A "Springer Nature" "$i"
  id3v2 -T "$counter"/$nFiles "$i"
  id3v2 -y "2019" "$i"
  id3v2 -g "Podcast" "$i"
	id3v2 -t "$counter" "$i"
	counter=$((counter+1))
	echo $counter
done
