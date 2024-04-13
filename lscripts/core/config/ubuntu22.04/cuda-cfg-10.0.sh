#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
##----------------------------------------------------------
## CUDA Stack 10.0, Nvidia Driver: 410+
## - Do not change the version, if you are not sure what you are doing
##----------------------------------------------------------

local OS="ubuntu22.04"
local CUDA_OS_REL="ubuntu2204"

##----------------------------------------------------------
## CUDA
##----------------------------------------------------------
local CUDA_VER="10.0"
local CUDA_PKG="${CUDA_VER}.130-1"
local CUDA_REL=$(echo ${CUDA_VER} | tr . -) ## 10-0
local CUDA_VERSION="${CUDA_VER}"

local CUDA_CORE_PKG_VERSION="${CUDA_REL}=${CUDA_PKG}"
local CUDA_PKG_VERSION="${CUDA_CORE_PKG_VERSION}"
local CUDA_CUBLAS_PKG_VERSION="${CUDA_PKG_VERSION}"

local NVML_VERSION="${CUDA_PKG_VERSION}"

##----------------------------------------------------------
## cuDNN
##----------------------------------------------------------
local CUDNN_VER="7"
local CUDNN_MAJOR_VERSION="${CUDNN_VER}"
local CUDNN_VERSION="7.6.4.38"
local CUDNN_PKG="${CUDNN_VERSION}-1+cuda${CUDA_VER}"

##----------------------------------------------------------
## NCCL
##----------------------------------------------------------
# local NCCL_VERSION="2.5.6"
local NCCL_VERSION="2.4.8"
local NCCL_PKG="${NCCL_VERSION}-1+cuda${CUDA_VER}"

##----------------------------------------------------------
## TensorRT
##----------------------------------------------------------
local TENSORRT_VER="5"
local LIBNVINFER_PKG="5.1.5-1+cuda${CUDA_VER}"

##----------------------------------------------------------
## AI Frameworks - Todo
##----------------------------------------------------------
local TF_VER="1.15.0"
local TENSORFLOW_VER=${TF_VER}
local TF_RELEASE="v${TF_VER}"
local TF_BAZEL_VER="0.21.0"

local KERAS_VER="2.2.3"
##-------

local PYTORCH_VER="1.1.0"
##-------

## bazel configuration for compiling tensorflow from source
local BAZEL_VER="${TF_BAZEL_VER}"
local BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-x86_64.sh"

##----------------------------------------------------------
## Dockerfile configuration
##----------------------------------------------------------
local __OS="ubuntu20.04"
local __NVIDIA_WHICHONE="devel" ## base, runtime, devel
local __NVIDIA_IMAGE_TAG=${CUDA_VER}-${__NVIDIA_WHICHONE}-${__OS}
## example: 10.0-devel-ubuntu20.04
local __NVIDIA_CUDA_IMAGE_NAME="nvidia/cuda"
local __NVIDIA_BASE_IMAGE="${__NVIDIA_CUDA_IMAGE_NAME}:${__NVIDIA_IMAGE_TAG}"

local DOCKER_BLD_IMG_TAG="${__NVIDIA_IMAGE_TAG}"

local __PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin"
local __LD_LIBRARY_PATH_1="/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
local __LD_LIBRARY_PATH_2="/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64"
local __LIBRARY_PATH="/usr/local/cuda/lib64/stubs"

## nvidia-container-runtime
local __NVIDIA_VISIBLE_DEVICES="all"
local __NVIDIA_DRIVER_CAPABILITIES="compute,utility"
## This has to be fixed for proper nvidia driver
local __NVIDIA_REQUIRE_CUDA="cuda>=${CUDA_VER} brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"
#
# local __CI_BUILD_PYTHON="3"
# local __TF_NEED_CUDA="1"
# local __TF_NEED_TENSORRT="1"
# local __TF_CUDA_COMPUTE_CAPABILITIES="3.5,5.2,6.0,6.1,7.0"
# local __TF_CUDA_VERSION=${CUDA_VER}
# local __TF_CUDNN_VERSION=${CUDNN_VER}
# #
# local __DEBIAN_FRONTEND="noninteractive"
# local __FORCE_CUDA="1"
# local __TORCH_CUDA_ARCH_LIST="Kepler;Kepler+Tesla;Maxwell;Maxwell+Tegra;Pascal;Volta;Turing"
# local __FVCORE_CACHE="/tmp"
