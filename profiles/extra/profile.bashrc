# Krang/profiles/extra/profile.bashrc

# ==============================================================================
# CATEGORIE-SPECIFIEKE CORREKTIES (Lokale builds & Perl)
# ==============================================================================
case "${CATEGORY}" in
    dev-perl|perl-core|virtual/perl)
        # Strip LTO volledig en dwing een veilige, snelle -O2 compilatie af
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-flto//g' -e 's/-fuse-ld=mold//g')
        ;;
esac

# ==============================================================================
# PAKKET-SPECIFIEKE UITZONDERINGEN (Gebaseerd op Clang & Zakk's no-lto gids)
# ==============================================================================
case "${CATEGORY}/${PN}" in
    # Systeempakketten die absoluut GCC, de standaard GNU linker en -O2 vereisen
    sys-libs/glibc|app-emulation/wine*)
        CC="gcc"
        CXX="g++"
        CPP="gcc -E"
        AR="ar"
        NM="nm"
        RANLIB="ranlib"
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-fuse-ld=mold//g')
        ;;

    # Wel Clang/-O3, maar GEEN LTO
    dev-libs/jemalloc|dev-build/ninja|dev-lang/perl|sys-print/cups|media-video/ffmpeg|media-video/pipewire)
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-flto//g' -e 's/-fuse-ld=mold//g')
        ;;

    # CHROMIUM & NODEJS: Wel LTO, maar GEEN mold (gebruik standaard lld) + RAM-begrenzing
    www-client/chromium|net-libs/nodejs)
        # Strip mold als die per ongeluk globaal in LDFLAGS staat
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-fuse-ld=mold//g')
        # Dwing de betrouwbare LLVM linker af en begrens de jobs voor je 8GB RAM
        LDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--thinlto-jobs=2"
        ;;

    # ==============================================================================
    # DE GRAFISCHE CORE-STACK: ThinLTO + -O3 + MOLD (RAM BEGRENSD TOT 2 THREADS)
    # ==============================================================================
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
        
        # Voeg hier mold, de jobs-limiet én pack-relative-relocs samen toe!
        LDFLAGS="${LDFLAGS} -flto=thin -fuse-ld=mold -Wl,--thinlto-jobs=2 -Wl,-z,pack-relative-relocs"
        
        # En stel de Rustflags in voor eventuele Rust-onderdelen in de desktop stack (zoals in libadwaita/gtk)
        export RUSTFLAGS="${RUSTFLAGS} -C link-arg=-Wl,-z,pack-relative-relocs"
        ;;

esac

