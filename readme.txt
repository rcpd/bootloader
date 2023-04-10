# abridged steps from https://www.ryanstan.com/assmToC.html
# VGA driver code: https://dev.to/frosnerd/writing-my-own-vga-driver-22nn

# install gcc + dependencies, qemu, nasm, gdb, tmux
sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo
sudo apt install qemu-system-i386 nasm gdb tmux

# get binutils & compile/install from src
curl https://mirror.freedif.org/GNU/binutils/binutils-2.40.tar.gz -o ~/binutils-2.40.tar.gz
tar -zxvf binutils-2.40.tar.gz --directory ~/src
printf '\n# bootloader gcc settings\nexport PREFIX="$HOME/opt/cross"\nexport TARGET=i686-elf\nexport PATH="$PREFIX/bin:$PATH"\n' >> ~/.profile
source ~/.profile
cd ~/src
mkdir build-binutils
cd build-binutils
../binutils-2.40/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

# get gcc & compile/install from src
curl https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz -o ~/gcc-12.2.0.tar.gz
tar -zxvf gcc-12.2.0.tar.gz --directory ~/src
cd ~/src
which -- $TARGET-as || echo $TARGET-as is not in the PATH
mkdir build-gcc
cd build-gcc
../gcc-12.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
printf 'export PATH="$HOME/opt/cross/bin:$PATH"\n' >> ~/.profile

# compile bootloader
source ~/.profile && make

# run (multi-pane: ctrl+b, % // ctrl+b, <- or ->)
tmux

# qemu: load disk but don't start CPU yet (terminal 1)
# VGA Blank mode = successly loaded, alt+2: quit to exit
make debug

# gdb: connect to remote and load symbols (terminal 2)
gdb -ex "target remote localhost:1234" -ex "add-symbol-file bin/kernel.elf 0x100000"

# set bp, continue, step through
b main
c
n

# Screen will now read "Hello World!" if successful

# alternatively to run without debugging:
make run



