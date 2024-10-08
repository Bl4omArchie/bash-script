sudo apt update
sudo apt install build-essential libpcap-dev libpcre3-dev libdnet-dev zlib1g-dev

wget https://www.snort.org/downloads/snort/daq-3.0.0.tar.gz
tar -xzvf daq-3.0.0.tar.gz
cd daq-3.0.0
./configure
make
sudo make install

wget https://www.snort.org/downloads/snort/snort3-3.1.60.0.tar.gz

tar -xzvf snort3-3.1.60.0.tar.gz
cd snort3-3.1.60.0

./configure_cmake.sh --prefix=/usr/local/snort
cd build
make
sudo make install

sudo mkdir /etc/snort /var/log/snort
sudo cp /usr/local/snort/etc/snort/snort.lua /etc/snort/

sudo snort -c /etc/snort/snort.lua -i eth0 -A alert_fast
