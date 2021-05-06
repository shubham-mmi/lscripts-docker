#!/bin/bash

## Copyright (c) 2021 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## librecad - cad tool
###----------------------------------------------------------
#
## References:
## * http://librecad.org/cms/home.html
###----------------------------------------------------------


function librecad-ppa-install() {
  sudo add-apt-repository -y ppa:librecad-dev/librecad-stable
  sudo apt -y update
  sudo apt -y install librecad
}

librecad-ppa-install
