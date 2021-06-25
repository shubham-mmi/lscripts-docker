#!/bin/bash

## Copyright (c) 2021 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
## Lscripts common configurations
## NOTE:
## - Do not change the order of scripts being sourced or variable initialized.
###----------------------------------------------------------

source $( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )/config/__init__.sh

###----------------------------------------------------------
## logger and then functions
###----------------------------------------------------------
source $( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )/utils/_log_.sh
source $( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )/utils/_fn_.sh
