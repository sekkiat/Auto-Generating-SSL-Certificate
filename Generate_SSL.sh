#!/bin/bash

#---------------------------------------------------------------------------------------
#check arguments
#--------------------------------------------------------------------------------------- 
usage() {
	echo "Usage: Generate_SSL.sh "
	echo ""
	echo "  -t <type> [1] CA, [2] Web, [3] Server. REQUIRED"
	echo ""
	echo "  -n <number> How many SSL certificate you need to generate. REQUIRED for  generate web and server certificate."
	echo ""
	echo "  -o <organization_name> Organization Name. REQUIRED"
	echo ""
	echo "  -c <common_name> Common Name. REQUIRED"
	echo ""
	echo ""
	exit 1
}

while getopts :t:n:o:c: options; 
do
	case $options in
		t) type=$OPTARG;; 
		n) number=$OPTARG;;
		o) organization=$OPTARG;;
		c) commonname=$OPTARG;;
		?) echo "-$OPTARG argument is not available!";exit 1;
	esac
done

if [[ $type == "1" ]]
then
 	number=1
fi

if [ $# -le 7 ]
then
        usage
        exit 1
fi

#------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------
#random password
#------------------------------------------------------------------------------------
random_password() {
	openssl rand -base64 16 | tr -d "=+/" | cut -c1-12
}

#------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------
#create main folders & sub folder
#------------------------------------------------------------------------------------
dir_mycerts="mycerts/"
dir_CA="CACertificate/"
dir_Server="ServerCertificate/"
dir_Web="WebCertificate/"

make_directory() {
if [ ! -d "$dir_mycerts" ]
then
	mkdir $dir_mycerts
fi

if [ ! -d "$dir_mycerts$dir_CA" ]
then
        mkdir $dir_mycerts$dir_CA
        mkdir $dir_mycerts$dir_CA"Private Key" 
	mkdir $dir_mycerts$dir_CA"CSR"
	mkdir $dir_mycerts$dir_CA"PEM"
fi

if [ ! -d "$dir_mycerts$dir_Server" ]
then
        mkdir $dir_mycerts$dir_Server
	mkdir $dir_mycerts$dir_Server"Private Key"
        mkdir $dir_mycerts$dir_Server"CSR"
        mkdir $dir_mycerts$dir_Server"PEM"
fi

if [ ! -d "$dir_mycerts$dir_Web" ]
then
        mkdir $dir_mycerts$dir_Web
	mkdir $dir_mycerts$dir_Web"Private Key"
        mkdir $dir_mycerts$dir_Web"CSR"
        mkdir $dir_mycerts$dir_Web"PEM"
fi
}

if [ $type == "1" ]
then
	make_directory
fi
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
#create cert
#-----------------------------------------------------------------------------------
create_cert() {
if [ "$type" = "1" ]
then
	echo "[+] Generating CA Certificate"
	openssl genrsa -aes256 -out $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -passout pass:$password 2048 > /dev/null 2>&1  
	openssl req -new -key $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -passin pass:$password -out $dir_mycerts$dir_CA"CSR/"myCACertificate.csr -subj "/C=SG/ST=SG/L=SG/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1
	openssl x509 -req -in $dir_mycerts$dir_CA"CSR/"myCACertificate.csr -sha512 -signkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$password -out $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -days 1095 > /dev/null 2>&1
	echo "myCACertificate: $password" >> $dir_mycerts"password.txt"
elif [ "$type" = "2" ]
then
        if ! find  $dir_mycerts$dir_CA"Private Key/myCAPrivateKey.key" > /dev/null 2>&1
        then
                echo "No CA Certificate Found!"
		exit 1
        else
		echo "[+] Generating Web Certificate $i"
		CA_password=$( cat $dir_mycerts"password.txt" | grep myCACertificate  | cut -d " "  -f 2,2) 
		openssl genrsa -aes256 -out $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey$i.key -passout pass:$password 2048 > /dev/null 2>&1
                openssl rsa -in $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey$i.key -passin pass:$password -out $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey$i.key > /dev/null 2>&1
                openssl req -new -key $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey$i.key -out $dir_mycerts$dir_Web"CSR/"mySplunkWebCert$i.csr -subj "/C=SG/ST=SG/L=SG/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1
		openssl x509 -req -in 	$dir_mycerts$dir_Web"CSR/"mySplunkWebCert$i.csr -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem  -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem -days 1095 > /dev/null 2>&1
                cat $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Web"PEM/"mySplunkWebCertificate$i.pem
                rm $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem
		echo "mySplunkWebCertificate"$i": $password" >> $dir_mycerts"password.txt"
        fi
elif [ "$type" = "3" ]
then
        if ! find  $dir_mycerts$dir_CA"Private Key/myCAPrivateKey.key" > /dev/null 2>&1 
        then
                echo "No CA Certificate Found!"
		exit 1        
	else 
		echo "[+] Generating Server Certificate $i"
		CA_password=$( cat $dir_mycerts"password.txt" | grep myCACertificate  | cut -d " "  -f 2,2)
		openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key 2048  > /dev/null 2>&1
                openssl req -new -key $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key -passin pass:$password -out $dir_mycerts$dir_Server"CSR/"myServerCertificate$i.csr -subj "/C=SG/ST=SG/L=SG/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1
                openssl x509 -req -in $dir_mycerts$dir_Server"CSR/"myServerCertificate$i.csr -SHA256 -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem -days 1095  > /dev/null 2>&1
                cat $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Server"PEM/"myServerCertificate$i.pem 
		rm  $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem
                echo "myServerCertificate"$i": $password" >> $dir_mycerts"password.txt"
        fi
fi
}
#-----------------------------------------------------------------------------------------------
if [ "$type" = "1" ] && [ -f $dir_mycerts$dir_CA"PEM/myCACertificate.pem" ]
then
	echo "CA is already generated"
	exit 1
elif [ "$type" = "2" ] && [ -f $dir_mycerts$dir_Web"PEM/mySplunkWebCertificate1.pem" ]
then
	rm -v $dir_mycerts$dir_Web"Private Key/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Web"CSR/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Web"PEM/"* > /dev/null 2>&1
	sed -i "/mySplunkWebCertificate/d" $dir_mycerts"password.txt" 
elif [ "$type" = "3" ]  && [ -f $dir_mycerts$dir_Server"PEM/myServerCertificate1.pem" ]
then
	rm -v $dir_mycerts$dir_Server"Private Key/"*  > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Server"CSR/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Server"PEM/"* > /dev/null 2>&1
	sed -i "/myServerCertificate/d" $dir_mycerts"password.txt" 
fi

#-----------------------------------------------------------------------------------------------

for i in $(seq 1 $number);
do
        password=$(random_password)
	create_cert
done
echo "[+] Done "
