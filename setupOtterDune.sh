##### REQUIREMENTS ######
# otter toolchain: 
# In host: https://github.com/nikkone/otter-docker-toolchain
cd ~
git clone https://github.com/LSTS/dune.git dune
cd dune
git clone https://github.com/nikkone/dune-otter-public user
mkdir build
BLUE='\033[0;34m'         # Blue
NC='\033[0m' # No Color
printf "I ${RED}love${NC} Stack Overflow\n"
# Add build with otter IMC
sudo docker run -it -v ~/dune:/project pi-cross-compile bash -c "cd /project/build &&\
cmake -DCMAKE_TOOLCHAIN_FILE=/ompl/build/toolchain.cmake \\
-DPYTHON_INCLUDE_DIR=$(python -c "import sysconfig; print(sysconfig.get_path('include'))")  \
-DPYTHON_LIBRARY=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
-DPYTHON_EXE:FILEPATH=`which python3` \
-DIMC_TAG=ntnuOtterASV \
-DIMC_URL=https://github.com/nikkone/imc/ \
 ../"

sudo docker run -it -v ~/dune:/project pi-cross-compile bash -c "cd /project/build && make imc_download && make imc"

sudo docker run -it -v ~/dune:/project pi-cross-compile bash -c "cd /project/build && cmake --build . -j 14 && make package -j14"