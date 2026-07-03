# Krang/profiles/build/profile.bashrc (BUILD SERVER ONLY)

# 1. JEMALLOC RAM BESPARING & SNELHEID
if [ -f "/usr/lib64/libjemalloc.so" ]; then
    case "${CATEGORY}/${PN}" in
        dev-lang/python|sys-apps/portage|llvm-core/clang|llvm-core/llvm|sys-devel/llvm|sys-devel/clang)
            export LD_PRELOAD="/usr/lib64/libjemalloc.so"
            ;;
    esac
fi

# 2. CHROMIUM & CORE-STACK: BEGRENS THREADS VOOR 8GB RAM
case "${CATEGORY}/${PN}" in
    www-client/chromium|net-libs/nodejs)
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-fuse-ld=mold//g')
        LDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        ;;

    media-libs/mesa|dev-libs/glib|x11-libs/gtk+|gui-libs/gtk|gui-libs/libadwaita)
        CC="clang"
        CXX="clang++"
        CPP="clang-cpp"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"
        CFLAGS=$(echo "${CFLAGS}" | sed 's/-O2/-O3/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed 's/-O2/-O3/g')
        CFLAGS="${CFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        CXXFLAGS="${CXXFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        # Gebruik mold maar houd het RAM in bedwang via jobs=2
        LDFLAGS="${LDFLAGS} -flto=thin -fuse-ld=mold -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        ;;
        
    sys-libs/glibc|app-emulation/wine*)
        CC="gcc"
        CXX="g++"
        CPP="gcc -E"
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-fuse-ld=mold//g')
        ;;
esac
