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
# 3. DE MULTIMEDIA & GRAPHICS LTO STACK (HARDCODED CASE)
# ==============================================================================
case "${CATEGORY}/${PN}" in
    media-video/ffmpeg|media-libs/x264|media-libs/x265|media-libs/dav1d| \
    media-libs/libvpx|media-libs/libaom|media-libs/flac|media-libs/opus| \
    media-libs/opusfile|media-libs/libvorbis|media-libs/libogg|media-gfx/imagemagick| \
    media-libs/libjpeg-turbo|media-libs/libpng|media-libs/libwebp|app-arch/zstd| \
    app-arch/lz4|media-libs/soxr|app-arch/xz-utils|app-shells/bash| \
    sys-devel/binutils|dev-lang/python|dev-lang/luajit|dev-lang/lua| \
    dev-lang/spidermonkey|llvm-core/llvm|llvm-core/clang|media-video/pipewire| \
    media-video/wireplumber|media-libs/gstreamer|dev-libs/wayland|x11-base/xwayland| \
    media-libs/vulkan-loader|media-libs/libjxl|media-libs/libavif|media-libs/openjpeg| \
    x11-wm/mutter|gnome-base/gnome-shell|gui-libs/gtk|x11-libs/gtk+| \
    gui-libs/libadwaita|media-libs/harfbuzz|media-libs/freetype|x11-libs/cairo| \
    x11-libs/pango|dev-db/sqlite|dev-libs/glib|sys-apps/portage)

        CC="clang"
        CXX="clang++"
        CPP="clang-cpp"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"
        
        # Alleen CFLAGS upgraden en injecteren als het nog niet is gebeurd
        if [[ ! "${CFLAGS}" =~ "-flto=thin" ]]; then
            CFLAGS=$(echo "${CFLAGS}" | sed -E -e 's/-O2/-O3/g' -e 's/-Werror=strict-aliasing//g')
            CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E -e 's/-O2/-O3/g' -e 's/-Werror=strict-aliasing//g')
            
            # -Wno-unused-command-line-argument toegevoegd om de Clang linker warnings te negeren
            CFLAGS="${CFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing -Wno-unused-command-line-argument"
            CXXFLAGS="${CXXFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing -Wno-unused-command-line-argument"
        fi
        
        # Voorkom dubbele flags en forceer de LLD linker met ThinLTO jobs
        LDFLAGS=$(echo "${LDFLAGS}" | sed -E -e 's/-fuse-ld=(mold|lld)//g' -e 's/-flto=thin//g' -e 's/-Wl,--thinlto-jobs=[0-9]+//g' -e 's/-Wl,-z,pack-relative-relocs//g')
        LDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"

        if [[ ! "${RUSTFLAGS}" =~ "pack-relative-relocs" ]]; then
            export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        fi
        ;;
esac

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
# ==============================================================================
# 5. GNOME 50 / CLANG CLEAN-UP (DEMP IRRITANTE COMPILER-RUIS)
# ==============================================================================
case "${CATEGORY}" in
    gnome-base|gui-libs|net-libs|app-accessibility)
        # Alleen toepassen als Clang de actieve compiler is
        if [[ ${CC} == *clang* ]]; then
            if [[ ! "${CFLAGS}" =~ "Wno-typedef-redefinition" ]]; then
                CFLAGS="${CFLAGS} -Wno-typedef-redefinition -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-unused-function -Qunused-arguments"
                CXXFLAGS="${CXXFLAGS} -Wno-typedef-redefinition -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-unused-function -Qunused-arguments"
            fi
        fi
        ;;
esac

