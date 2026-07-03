# Krang/profiles/extra/profile.bashrc

# Categorieën die lokaal bouwen op laptop/Steam Deck (zoals Perl) 
# OF kritieke systeempakketten die falen met -O3/LTO.
case "${CATEGORY}" in
    dev-perl|perl-core|virtual/perl)
        # Strip LTO volledig en dwing een veilige, snelle -O2 compilatie af
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-Werror=odr//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-flto//g')
        ;;
esac

# Specifieke individuele pakketten die bekend staan om -O3 of LTO fouten
case "${CATEGORY}/${PN}" in
    sys-libs/glibc|app-emulation/wine*)
        # Glibc en Wine NOOIT met Clang of -O3/LTO bouwen (altijd GCC en -O2)
        CC="gcc"
        CXX="g++"
        CPP="gcc -E"
        CFLAGS=$(echo "${CFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed -e 's/-flto\(=thin\)*//g' -e 's/-O3/-O2/g')
        LDFLAGS=$(echo "${LDFLAGS}" | sed -e 's/-flto\(=thin\)*//g')
        ;;

    # De zware grafische core-stack: Hier wil je de maximale winst!
    media-libs/mesa|dev-libs/glib|x11-libs/gtk+|gui-libs/gtk|gui-libs/libadwaita)
        CC="clang"
        CXX="clang++"
        CPP="clang-cpp"
        AR="llvm-ar"
        NM="llvm-nm"
        RANLIB="llvm-ranlib"
        
        # Dwing hier keihard -O3 én ThinLTO af voor maximale desktop-performance
        CFLAGS=$(echo "${CFLAGS}" | sed 's/-O2/-O3/g')
        CXXFLAGS=$(echo "${CXXFLAGS}" | sed 's/-O2/-O3/g')
        
        CFLAGS="${CFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        CXXFLAGS="${CXXFLAGS} -flto=thin -Werror=odr -Werror=strict-aliasing"
        LDFLAGS="${LDFLAGS} -flto=thin"
        ;;
esac
