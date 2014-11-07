# assume LFS_THIS_SOFT_TAR
# assume LFS_THIS_SOFT_TAR_EXT

# remove trailing extension
tmp_path=${LFS_THIS_SOFT_TAR::-${#LFS_THIS_SOFT_TAR_EXT}}
mkdir -p $tmp_path

repo=https://deg-svn.esrf.fr/svn
compos='libepci libefspi libpmem libuirq compat'
for c in $compos; do
 url=$repo/$c/dev
 svn export $url $tmp_path//components/$c ;
done

cd `dirname $tmp_path`
tar czvf $LFS_THIS_SOFT_TAR `basename $tmp_path`
rm -rf $tmp_path
