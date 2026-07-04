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
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-fuse-ld=(mold|lld)//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g' -e 's/-Wl,-z,pack-relative-relocs//g')
        LDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        if [[ ! "${RUSTFLAGS}" =~ "pack-relative-relocs" ]]; then
            export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        fi
        ;;
esac

# ==============================================================================
# 3. DYNAMISCHE LTO & MULTIMEDIA OPTIMALISATIE VIA TEXT-FILE
# ==============================================================================
# ==============================================================================
# 3. DYNAMISCHE LTO & MULTIMEDIA OPTIMALISATIE VIA TEXT-FILE
# ==============================================================================
# Vind het tekstbestand in exact dezelfde map als deze profile.bashrc
LTO_LIST_FILE="$(dirname "${BASH_SOURCE[0]}")/lto_packages.txt"

if [ -f "${LTO_LIST_FILE}" ]; then
    # Lees regels, filter witruimtes/commentaar/lege regels, voeg samen met |
    LTO_PACKAGES=$(grep -v '^#' "${LTO_LIST_FILE}" | grep -v '^$' | tr -d ' ' | tr '\n' '|' | sed 's/|$//')
    
    # Gebruik een flexibelere match zodat dev-lang/python altijd matcht
    IS_LTO_PACKAGE=0
    case "${CATEGORY}/${PN}" in
        www-client/chromium|net-libs/nodejs) ;; # Sla over, deze hebben hun eigen case hierboven
        *)
            if [[ "${CATEGORY}/${PN}" =~ ^(${LTO_PACKAGES})$ ]]; then
                IS_LTO_PACKAGE=1
            fi
            ;;
    esac

    if [ "${IS_LTO_PACKAGE}" -eq 1 ]; then
        CC="clang"
        CXX="clang++"
        CPP="clang-cpp"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"
        
        # Alleen CFLAGS upgraden en injecteren als het nog niet is gebeurd
        if [[ ! "${CFLAGS}" =~ "-flto=thin" ]]; then
            CFLAGS=$(echo "${CFLAGS}" | sed 's/-O2/-O3/g')
            CXXFLAGS=$(echo "${CXXFLAGS}" | sed 's/-O2/-O3/g')
            
            CFLAGS="${CFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
            CXXFLAGS="${CXXFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        fi
        
        # Voorkom dubbele flags en forceer de LLD linker met ThinLTO jobs
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-fuse-ld=(mold|lld)//g' -e 's/-flto=thin//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g' -e 's/-Wl,-z,pack-relative-relocs//g')
        LDFLAGS="${LDFLAGS} -flto=thin -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"

        if [[ ! "${RUSTFLAGS}" =~ "pack-relative-relocs" ]]; then
            export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        fi
    fi
fi

# ==============================================================================
# 4. EXCLUSIES & FALLBACKS (GCC/O2 FORCED)
# ==============================================================================
case "${CATEGORY}/${PN}" in
    sys-libs/glibc|app-emulation/wine*)
        CC="gcc"
        CXX="g++"
        CPP="gcc -E"
        CFLAGS=$(echo "${CFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-fuse-ld=(mold|lld)//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g')
        ;;
        
    media-libs/glycin)
        if [[ ! "${FEATURES}" =~ "-test" ]]; then
            export FEATURES="${FEATURES} -test"
        fi
        ;;
esac

