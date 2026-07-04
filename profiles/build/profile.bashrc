# Krang/profiles/build/profile.bashrc (BUILD SERVER ONLY)

# 1. JEMALLOC RAM BESPARING & SNELHEID
if [ -f "/usr/lib64/libjemalloc.so" ]; then
    case "${CATEGORY}/${PN}" in
        dev-lang/python|sys-apps/portage|llvm-core/clang|llvm-core/llvm|sys-devel/llvm|sys-devel/clang)
            export LD_PRELOAD="/usr/lib64/libjemalloc.so"
            ;;
    esac
fi

# 2. BEGRENS THREADS EN OPTIMALISEER STACKS
case "${CATEGORY}/${PN}" in
    www-client/chromium|net-libs/nodejs)
        # Verwijder mold en eventuele oude lld/thinlto/pack-relative flags om dubbelen te voorkomen
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-fuse-ld=(mold|lld)//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g' -e 's/-Wl,-z,pack-relative-relocs//g')
        
        # Voeg de flags proper één keer toe
        LDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        
        # Voeg RUSTFLAGS veilig toe zonder duplicatie
        if [[ ! "${RUSTFLAGS}" =~ "pack-relative-relocs" ]]; then
            export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        fi
        ;;

    # ==============================================================================
    # DE GRAFISCHE CORE-STACK: ThinLTO + -O3 + STANDAARD LLD (TIJDELIJK ZONDER MOLD)
    # ==============================================================================
    media-libs/mesa|dev-libs/glib|x11-libs/gtk+|gui-libs/gtk|gui-libs/libadwaita)
        CC="clang"
        CXX="clang++"
        CPP="clang-cpp"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"
        
        # Alleen CFLAGS/CXXFLAGS injecteren en upgraden als het nog niet is gebeurd
        if [[ ! "${CFLAGS}" =~ "-flto=thin" ]]; then
            CFLAGS=$(echo "${CFLAGS}" | sed 's/-O2/-O3/g')
            CXXFLAGS=$(echo "${CXXFLAGS}" | sed 's/-O2/-O3/g')
            
            CFLAGS="${CFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
            CXXFLAGS="${CXXFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        fi
        
        # TIJDELIJKE FIX: Vervang mold door lld en voorkom dubbele flags
        if [[ ! "${LDFLAGS}" =~ "-fuse-ld=lld" ]]; then
            # Strip mold en bestaande thinlto/jobs/pack-relative flags voor de zekerheid
            LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-fuse-ld=(mold|lld)//g' -e 's/-flto=thin//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g' -e 's/-Wl,-z,pack-relative-relocs//g')
            LDFLAGS="${LDFLAGS} -flto=thin -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        fi

        if [[ ! "${RUSTFLAGS}" =~ "pack-relative-relocs" ]]; then
            export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        fi
        ;;
        
    sys-libs/glibc|app-emulation/wine*)
        CC="gcc"
        CXX="g++"
        CPP="gcc -E"
        # Rigoureuze opschoning van LTO, O3 en linkers voor stabiliteit
        CFLAGS=$(echo "${CFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-flto(=thin)?//g' -e 's/-fuse-ld=(mold|lld)//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g')
        ;;
esac

# Glycin specifieke fix voor headless/TTY-loze containers
if [ "${CATEGORY}/${PN}" = "media-libs/glycin" ]; then
    if [[ ! "${FEATURES}" =~ "-test" ]]; then
        export FEATURES="${FEATURES} -test"
    fi
fi

