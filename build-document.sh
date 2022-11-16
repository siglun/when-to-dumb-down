#!/bin/bash

# If you wan't to the pdf in the same way as you use an eps
# this is for my memory
# ps2pdf  -dEPSCrop  distro.eps

# where saxon is on my Ubuntu installations as of June 14 2022

source "parameters.sh"

$SAXON  experience.xml  render.xsl  > shit.html
xmllint  --xinclude shit.html > experience.html
rm shit.html

./to-markdown.sh

xsltproc teip5toms.xsl  experience.xml | grep -v '^$' >  experience.ms
groff -U  -m pdfpic -m pdfmark -ms -k  -s -t -P-pa4 -Tpdf parameters.ms  experience.ms >  experience.pdf




