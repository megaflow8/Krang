# Krang/profiles/run/profile.bashrc (LAPTOP & STEAM DECK ONLY)

# 1. JEMALLOC VOOR SNELLERE LOKALE EMERGE
if [ -f "/usr/lib64/libjemalloc.so" ]; then
    case "${CATEGORY}/${PN}" in
        dev-lang/python|sys-apps/portage)
            export LD_PRELOAD="/usr/lib64/libjemalloc.so"
            ;;
    esac
fi

# 2. STRIP LTO VOOR LOKALE PERL BUILDS (GEEN MOLD NODIG OP CLIENTS)
case "${CATEGORY}" in
    dev-perl|perl-core|virtual/perl)
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-flto//g' -e 's/-fuse-ld=mold//g')
        ;;
esac

# 3. FAST COLD START VOOR RUST DESKTOP APPS
case "${CATEGORY}/${PN}" in
    */*resources*|gui-apps/resources|gui-util/resources)
        export RUSTFLAGS=$(echo "${RUSTFLAGS}" | sed -e 's/-C lto=thin//g' -e 's/-C lto=fat//g')
        export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        ;;
esac
