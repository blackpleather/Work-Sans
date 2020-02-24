#!/bin/bash
set -e
### WIP macOS build script for Work Sans Upright and Italic VF, based on a build script by Mike LaGuttuta

# Setting the Source and VF name, determine if it's for Italic or Upright source from the argument passed to this script

glyphsSource="WorkSans.glyphs WorkSans-Italic.glyphs"

mkdir -p ../fonts/ ../fonts/static/TTF ../fonts/static/OTF ../fonts/variable ../fonts/static/WOFF ../fonts/static/WOFF2

# Generate VFs
VF_ROMAN=../fonts/variable/WorkSans[wght].ttf
VF_ITALIC=../fonts/variable/WorkSans-Italic[wght].ttf
fontmake -g WorkSans.glyphs -o variable --output-path $VF_ROMAN
fontmake -g WorkSans-Italic.glyphs -o variable --output-path $VF_ITALIC

for ttf in ../fonts/variable/*.ttf
do
  ./tools/ttfautohint-vf $ttf $ttf.fix
  mv $ttf.fix $ttf
  gftools fix-dsig -f $ttf
  gftools fix-hinting $ttf
  mv $ttf.fix $ttf
done
# Fix VF Metadata
gftools fix-vf-meta ../fonts/variable/*.ttf

for f in ../fonts/variable/*.ttf
do
	mv $f.fix $f;
done

# Generate TTFs
TTF_OUT=../fonts/static/TTF
fontmake -g WorkSans.glyphs -o ttf -i --output-dir $TTF_OUT
fontmake -g WorkSans-Italic.glyphs -o ttf -i --output-dir $TTF_OUT
# Generate OTFS
OTF_OUT=../fonts/static/OTF
fontmake -g WorkSans.glyphs -o ttf -i --output-dir $OTF_OUT
fontmake -g WorkSans-Italic.glyphs -o ttf -i --output-dir $OTF_OUT

rm -rf master_ufo/ instance_ufo/
for ttf in ../fonts/static/TTF/*.ttf
do
  ./tools/ttfautohint-vf $ttf $ttf.fix
  mv $ttf.fix $ttf
  gftools fix-dsig -f $ttf
  gftools fix-hinting $ttf
  mv $ttf.fix $ttf
done
# Generate woff
for ttf in ../fonts/static/TTF/*.ttf
do
  sfnt2woff $ttf
  mv ${ttf/.ttf/.woff} ../fonts/static/WOFF
done
# Generate woff2
for ttf in ../fonts/static/WOFF2/*.ttf
do
  woff2_compress $ttf
  mv ${ttf/.ttf/.woff2} ../fonts/static/WOFF2
done
