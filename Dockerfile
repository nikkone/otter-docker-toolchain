FROM ubuntu:20.04

LABEL Nikolai Lauvås "nikolai.lauvas@ntnu.no"

# USAGE: docker run -it -v ~/raspberry/hello:/build nikolai/pi-cross-compile
# USAGE with CMAKE: sudo docker run -it -v ~/raspberry/dune:/build -v ~/lststools/dune:/project pi-cross-compile bash -c "cmake -DCMAKE_TOOLCHAIN_FILE=/ompl/build/toolchain.cmake ../project && cmake --build . -j 14 && make package"
LABEL com.nikolai.pi-cross-compile="{\"Description\":\"Cross Compile for Raspberry Pi\",\"Usage\":\"docker run -it -v ~/myprojects/mybuild:/build nikolai/pi-cross-compile\",\"Version\":\"0.1.0\"}"

RUN dpkg --add-architecture arm64
RUN sed 's/deb http/deb \[arch=amd64\] http/' -i /etc/apt/sources.list
RUN echo "\
deb [arch=arm64] http://ports.ubuntu.com/ focal main restricted \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-updates main restricted \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-security main restricted \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-security universe\n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-security multiverse \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal universe \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-updates universe \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal multiverse \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-updates multiverse \n\
deb [arch=arm64] http://ports.ubuntu.com/ focal-backports main restricted universe multiverse \n\
    " >> /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y git && apt-get install -y build-essential g++-aarch64-linux-gnu cmake

RUN apt-get -y install libeigen3-dev:arm64 libboost-dev:arm64 libgps-dev:arm64 libboost-system-dev:arm64 libgpiod-dev:arm64
RUN apt-get -y install libboost-serialization-dev:arm64 libboost-filesystem-dev:arm64 libboost-system-dev:arm64 libboost-program-options-dev:arm64 libboost-test-dev:arm64 libeigen3-dev:arm64 libode-dev:arm64 libyaml-cpp-dev:arm64

RUN git clone --recurse-submodules https://github.com/ompl/ompl.git
RUN cd ompl
RUN mkdir -p ompl/build/Release
RUN echo "\
set(CMAKE_SYSTEM_NAME Linux)\n\
set(CMAKE_SYSTEM_PROCESSOR aarch64)\n\
set(tools /usr/bin)\n\
set(CMAKE_C_COMPILER \${tools}/aarch64-linux-gnu-gcc-9)\n\
set(CMAKE_CXX_COMPILER \${tools}/aarch64-linux-gnu-g++-9)\n\
add_compile_options(-mcpu=cortex-a72 -mtune=cortex-a72)\n\
" >> ompl/build/toolchain.cmake



RUN cd ompl/build/Release && cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake ../..
RUN cd ompl/build/Release && make -j14 && make install

# Reload the list of system-wide library paths
RUN ldconfig

ENV BUILD_FOLDER /build

WORKDIR ${BUILD_FOLDER}

CMD ["/bin/bash", "-c", "make", "-f", "${BUILD_FOLDER}/Makefile"]
# CMD ["make", "clean"]
