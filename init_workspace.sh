#!/bin/bash
# Fetch source and make workspace compile-ready

workdir=$(pwd)
workdir=${workdir%%/}

NDK_VERSION=0.3.0
NGX_VERSION=1.13.3
NDK_ARCHIVE_PATH=$workdir/third-party/ndk.tar.gz
NGX_ARCHIVE_PATH=$workdir/third-party/ngx.tar.gz

mkdir -p $workdir/third-party 

stat $NDK_ARCHIVE_PATH &> /dev/null || curl -s -o $NDK_ARCHIVE_PATH -L -O "https://github.com/simpl/ngx_devel_kit/archive/v$NDK_VERSION.tar.gz"
stat $NGX_ARCHIVE_PATH &> /dev/null || curl -s -o $NGX_ARCHIVE_PATH -L -O "http://nginx.org/download/nginx-$NGX_VERSION.tar.gz"

cd $workdir/third-party
tar xzvf $NDK_ARCHIVE_PATH &> /dev/null 
tar xzvf $NGX_ARCHIVE_PATH &> /dev/null
cd - 

export NDK_SRC_DIR=$workdir/third-party/ngx_devel_kit-$NDK_VERSION
export NGX_SRC_DIR=$workdir/third-party/nginx-$NGX_VERSION

ln -sf $NGX_SRC_DIR/configure $workdir/configure
ln -sf ${NDK_SRC_DIR%/*}/nginx-$NGX_VERSION $workdir/third-party/nginx
ln -sf ${NDK_SRC_DIR%/*}/ngx_devel_kit-$NDK_VERSION $workdir/third-party/ndk














