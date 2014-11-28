cd $LFS_THIS_SOFT_SRC


# build zeromq

cd $LFS_THIS_SOFT_SRC/zeromq

CC=$LFS_CROSS_COMPILE\gcc \
CXX=$LFS_CROSS_COMPILE\g++ \
./configure \
--prefix=$LFS_TARGET_INSTALL_DIR \
--host=$LFS_TARGET_ARCH \
--build=x86_64-linux

make && make install


# build omnirb
# http://www.omniorb-support.com/omniwiki/CrossCompiling

cd $LFS_THIS_SOFT_SRC/omniORB

CC=$LFS_CROSS_COMPILE\gcc \
CXX=$LFS_CROSS_COMPILE\g++ \
./configure \
--prefix=$LFS_TARGET_INSTALL_DIR \
--host=$LFS_TARGET_ARCH \
--build=x86_64-linux

make CC=gcc -C src/tool/omniidl/cxx/cccp
make CXX=g++ -C src/tool/omniidl/cxx
make CC=gcc -C src/tool/omkdepend
make && make install


# build tango

cd $LFS_THIS_SOFT_SRC/tango

CC=$LFS_CROSS_COMPILE\gcc \
CXX=$LFS_CROSS_COMPILE\g++ \
./configure \
--host=$LFS_TARGET_ARCH \
--build=x86_64-linux \
--prefix=$LFS_TARGET_INSTALL_DIR \
--with-zlib=$LFS_TARGET_INSTALL_DIR \
--with-omni=$LFS_TARGET_INSTALL_DIR \
--with-zmq=$LFS_TARGET_INSTALL_DIR \
--disable-java

make && make install
