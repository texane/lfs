LFS_THIS_SOFT_IS_ENABLED=0

# TOOD:
# at v4l-utils-0.8.9
# depends on libjpeg
# use Makefile and Make.rules to install only libs
# ~/repo/v4l-utils-0.8.9$ LDFLAGS="-L$LFS_SDK_DEPS_DIR/lib" CFLAGS="-I$LFS_SDK_DEPS_DIR/include" CXX=$LFS_SDK_CROSS_COMPILE\g++ CC=$LFS_SDK_CROSS_COMPILE\gcc PREFIX=$LFS_SDK_DEPS_DIR DESTDIR=$LFS_SDK_DEPS_DIR make install
