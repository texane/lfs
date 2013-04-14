LFS_THIS_SOFT_IS_ENABLED=0

# TODO:
# svn checkout https://mjpg-streamer.svn.sourceforge.net/svnroot/mjpg-streamer, revision 177
# apply r177.diff
# cd mjpg-streamer
# LFLAGS="-L$LFS_SDK_DEPS_DIR/lib" \
# CFLAGS="-I$LFS_SDK_DEPS_DIR/include" \
# CXX=$LFS_SDK_CROSS_COMPILE\g++ \
# CC=$LFS_SDK_CROSS_COMPILE\gcc \
# PREFIX=$LFS_SDK_DEPS_DIR DESTDIR=`pwd`/install \
# make
