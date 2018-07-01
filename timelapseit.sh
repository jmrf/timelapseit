#!/usr/bin/env bash

say() {
 echo "$@" | sed \
         -e "s/\(\(@\(red\|green\|yellow\|blue\|magenta\|cyan\|white\|reset\|b\|u\)\)\+\)[[]\{2\}\(.*\)[]]\{2\}/\1\4@reset/g" \
         -e "s/@red/$(tput setaf 1)/g" \
         -e "s/@green/$(tput setaf 2)/g" \
         -e "s/@yellow/$(tput setaf 3)/g" \
         -e "s/@blue/$(tput setaf 4)/g" \
         -e "s/@magenta/$(tput setaf 5)/g" \
         -e "s/@cyan/$(tput setaf 6)/g" \
         -e "s/@white/$(tput setaf 7)/g" \
         -e "s/@reset/$(tput sgr0)/g" \
         -e "s/@b/$(tput bold)/g" \
         -e "s/@u/$(tput sgr 0 1)/g"
}


sort_rename() {
   src_dir=$1
   ext=$2
   say @green[["Working directory: $src_dir. Renaming pictures to ensure order is preserved"]]
   cd $src_dir
   say @cyan[["Creating new directory: 'renamed'"]]
   if [ ! -d renamed ]; then
      mkdir -p renamed
      counter=1
      ls -1tr *.$ext | while read filename; do cp $filename renamed/$(printf %05d $counter)_$filename; ((counter++)); done
   fi
   cd renamed
}

resize() {
   say @green[["Resizing images..."]]
   say @cyan[["Creating new directory: 'resized'"]]
   ext=$1
   if [ ! -d resized ]; then
      mkdir -p resized
      # If you want to keep the aspect ratio, remove the exclamation mark (!) in 1920x1080!
      mogrify -path resized -resize 1920x1080 *.$ext
   fi
   cd resized
}

combine() {
   ext=$1
   fps=$2
   say @green[["Combining at $fps fps..."]]
   # Change -r 25 to define the frame rate. 25 here means 25 fps
   ffmpeg -r $fps -pattern_type glob -i "*.$ext" -c:v copy output.avi
}


# check number of arguments supplied
if [ $# -lt 3 ]; then
   msg=$"Mising arguments: 'Source folder' | 'image file extension' | 'frames per seconds'"
   say @red[[$msg]]
   exit
fi

# assign arguments to named variables
src_dir=$1
img_extension=$2
fps=$3 || 25

# 1. sort the pictures and rename to preserve proper order
sort_rename $src_dir $img_extension || { say @red[["Error while copying and renaming source iamges..."]] ; exit 1; }

# 2. Resize
resize $img_extension || { say @red[["Error while resizing images..."]]; exit 1; }

# 3. Optional we could deflickr the images
say @yellow[["No deflickering for now..."]]

# 4. Combine the pictures
combine $img_extension $fps || { say @red[["Error while combining images..."]]; exit 1; }
