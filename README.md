**#Instruction and help document**

sudo apt install git

git clone https://github.com/jodhpurlaxman/websitemanager

cd websitemanager

chmod +x ./websitemanager

sudo ./websitemanager -install

sudo systemmanager

#Now your system is ready for use

**#the default php version is 8.0 but you can set custom php version via -pv  perameter. Also -pv not applicable if -t is "node" and -p is not applicable if -t is default or laravel**

**#sample vhost // below command has -d as a mandatory perameter other perameter if required**
websitemanager -d localhost.local -pv {7.0 - 8.3} -t {default,laravel,node} -f {wordpress,laravel} -u {othersystemusername} -p {3000 - XXXX}

**#defination of perameters**
-d == domainname
-t == predefined vhost sample for {default,laravel,node}
-f == if you want install framework along with vhost configuration
-p == proxy port for node application
-pv == custom php version like 7.0 to 8.3
-u == other or own username of your system






