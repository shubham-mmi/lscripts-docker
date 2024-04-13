#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## slowmovideo
###----------------------------------------------------------
#
## References:
## * http://slowmovideo.granjow.net/download.php
###----------------------------------------------------------


function slowmovideo-ppa-install.main() {
  sudo add-apt-repository -y ppa:brousselle/slowmovideo
  sudo apt -y update
  sudo apt -y install slowmovideo
}

slowmovideo-ppa-install.main "$@"
