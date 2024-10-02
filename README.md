# otter-docker-toolchain
Docker based toolchain for building software for the NTNU FishOtter

## Toolchain setup
* Install docker
* Get the toolchain:

      git clone https://github.com/nikkone/otter-docker-toolchain/
* Build the docker image

      sudo docker build -t pi-cross-compile .
## Build DUNE for the Fishotter
* Use the shell script

      sh setupOtterDune.sh
## Use the image to build dune
    sudo docker run -it -v ~/raspberry/dune:/build -v ~/lststools/dune:/project pi-cross-compile bash -c "cmake -DCMAKE_TOOLCHAIN_FILE=/ompl/build/toolchain.cmake ../project && cmake --build . -j 14 && make package"
