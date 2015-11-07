# Pull base image
FROM ubuntu:14.04

# Environment Variables for Config
ENV LLVM_SRC /usr/local/llvm
ENV POCL /usr/local/pocl
ENV CLOOG_SRC /usr/local/cloog_src
ENV LLVM_BUILD /usr/local/llvm-build

# Compiler choice
ENV CC gcc-4.6
ENV CXX g++-4.6

# Number of cores (for make)
ENV N_PROC $(grep processor /proc/cpuinfo | wc -1)

# Home is root
ENV HOME /root

# Install Ubuntu (boilerplate)
RUN	sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y upgrade && \
  	apt-get install -y software-properties-common && \
  	apt-get install -y byobu curl git htop man unzip vim wget && \
	rm -rf /var/lib/apt/lists/*

# Add files
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts

# Set working directory
WORKDIR /root

# Get required packages from apt repo
RUN 	apt-get install -y \
	git\
	$CC\
	$CXX\
	man\
	make\
	autoconf\
	libtool\
	pkg-config\
	libhwloc-dev\
	build-essential; \

# Download source, build, etc.
RUN 	git clone -b release_37 http://llvm.org/git/llvm.git $LLVM_SRC;\
	git clone -b release_37 http://llvm.org/git/polly.git $LLVM_SRC/tools/polly;\
	git clone -b release_37 http://llvm.org/git/clang.git $LLVM_SRC/tools/clang;\

	$LLVM_SRC/tools/polly/utils/checkout_cloog.sh $CLOOG_SRC;\
	cd $CLOOG_SRC;\
	./configure;\
	make;\
	make install;\
	cd ..;\
	rm -rf $CLOOG_SRC;\
	mkdir $LLVM_BUILD;\
	cd $LLVM_BUILD;\
	$LLVM_SRC/configure \
		--disable-assertations\
		--disable-bindings\
		--disable-docs\
		--enable-optimized\
		--enable-targets=host-only\
		--enable-shared;\
	make -jN_PROC REQUIRES_RTTI=1;\
	make install;

# Install POCL
RUN 	git clone -b release_1_2 https://github.com/pocl/pocl.git $POCL;\
	cd $POCL;\
	./autogen.sh;\
	./configure --disable-icd;\
	make -jN_PROC;\
	make install;

# User configureation stuff
RUN 	apt-get install -y vim;

# Install & Start ssh service
RUN 	apt-get install -y openssh-server;\
	mkdir /var/run/sshd;

# Open port 22
EXPOSE 22

CMD /usr/sbin/sshd -D
