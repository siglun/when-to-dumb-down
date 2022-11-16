#!/bin/bash


source "parameters.sh"

$SAXON  experience.xml  tei-to-markdown.xsl > experience.md


