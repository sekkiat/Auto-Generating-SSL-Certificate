#!/bin/bash

#---------------------------------------------------------------------------------------
#check arguments
#--------------------------------------------------------------------------------------- 
usage() {
	echo "Usage: Generate_SSL.sh "
	echo ""
	echo "  -t <type> [1] CA, [2] Web, [3] Server. ! REQUIRED to define what type of certificate need to generate."
	echo ""
	echo "       [2] passsword certificate will be remove."
    	echo "       [3] password certificate will remain."
	echo ""
	echo "  -n <number> How many SSL certificate you need to generate. ! REQUIRED for generate web and server certificate if you not specify hostname list."
	echo ""
	echo "  -p <hostname_list> Generate the Certificate based on the hostname in the file. ! REQUIRED if you want to generate the certificates based on hostname list."
	echo ""
	echo "  -zc <no_ca_cert> No required to define CA Certificate"
	echo ""
	echo " Certificate Parameters Here - REQUIRED TO DEFINE ALL THE PARAMETERS BELOW "
	echo "=========================================================================================================="
	echo ""
	echo "  -o <organization_name> Organization Name"
	echo ""
	echo "  -c <common_name> Common Name"
	echo ""
	echo "  -e <email_address> Email Address"
	echo ""
	echo "  -u <organization_unit> Organization Unit"
	echo ""
	echo "  -r <country> Country"
	echo ""
	echo "  -s <state> State"
	echo ""
	echo "  -i <city> City"
	echo ""
	exit 1
}

while getopts :t:n:o:c:p:z:e:u:r:s:i: options; 
do
	case $options in
		t) type=$OPTARG;; 
		n) number=$OPTARG;;
		o) organization=$OPTARG;;
		c) commonname=$OPTARG;;
		p) hostnamelist=$OPTARG;;
		z) nocert=$OPTARG;;
		e) emailaddress=$OPTARG;;
		u) organizationunit=$OPTARG;;
		r) country=$OPTARG;;
		s) state=$OPTARG;;
		i) city=$OPTARG;;
		?) echo "-$OPTARG argument is not available!";exit 1;
	esac
done

if [[ $type == "1" ]]
then
 	number=1
	if [ ! -z $hostnamelist ]
	then
		echo "You can't define a hostname list for the CA!"
		exit 1
	fi
fi

if [ -z $hostnamelist ]
then
	if [ -z $commonname ] || [ -z $organization ] || [ -z $emailaddress ] || [ -z $organizationunit ] || [ -z $country ] || [ -z $state ] || [ -z $city ] || [ -z $number ]
		then
        		usage
        		exit 1
	fi
else
	if [ -z $type ]
	then
        echo "Please specifiy a type [2] Web [3] Server you want to generate!"
		usage
        exit 1
	fi
	if [ -z $organization ] || [ -z $emailaddress ] || [ -z $organizationunit ] || [ -z $country ] || [ -z $state ] || [ -z $city ]
	then
		echo "Please define the certificate parameters!"
		usage
		exit 1
	fi
	if [ ! -z $number ]
	then
		echo "Please remove the number if you define the [p] hostname list!"
		usage
		exit 1
	fi
	if [ ! -z $commonname ]
	then
		echo "Please remove common name!"
		usage
		exit 1
	fi
	
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

if [ $cafolder == 1 ]
then
	if [ ! -d "$dir_mycerts$dir_CA" ]
	then
        mkdir $dir_mycerts$dir_CA
        mkdir $dir_mycerts$dir_CA"Private Key" 
		mkdir $dir_mycerts$dir_CA"CSR"
		mkdir $dir_mycerts$dir_CA"PEM"
	fi
else
if [ ! -d "$dir_mycerts$dir_Server" ] && [ $type == 3 ]
then
        mkdir $dir_mycerts$dir_Server
		mkdir $dir_mycerts$dir_Server"Private Key"
        mkdir $dir_mycerts$dir_Server"CSR"
        mkdir $dir_mycerts$dir_Server"PEM"
elif [ ! -d "$dir_mycerts$dir_Web" ] && [ $type == 2 ]
then
        mkdir $dir_mycerts$dir_Web
		mkdir $dir_mycerts$dir_Web"Private Key"
        mkdir $dir_mycerts$dir_Web"CSR"
        mkdir $dir_mycerts$dir_Web"PEM"
fi
fi
}

if [ ! -z $hostnamelist ]
then
	cafolder=0
	make_directory
elif [ $type == "1" ]
then
	cafolder=1
	make_directory
elif [ $type == "2" ] || [ $type == "3" ]
then
	cafolder=0
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
	openssl req -new -key $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -passin pass:$password -out $dir_mycerts$dir_CA"CSR/"myCACertificate.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1 
	openssl x509 -req -in $dir_mycerts$dir_CA"CSR/"myCACertificate.csr -sha512 -signkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$password -out $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -days 1095 > /dev/null 2>&1
	echo "myCACertificate: $password" >> $dir_mycerts"password.txt"
elif [ "$type" = "2" ] && [ -z $hostnamelist ]
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
                openssl req -new -key $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey$i.key -out $dir_mycerts$dir_Web"CSR/"mySplunkWebCert$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1
		openssl x509 -req -in 	$dir_mycerts$dir_Web"CSR/"mySplunkWebCert$i.csr -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem  -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem -days 1095 > /dev/null 2>&1
		cat $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Web"PEM/"mySplunkWebCertificate$i.pem
        rm $dir_mycerts$dir_Web"PEM/"mySplunkWebCert$i.pem
		echo "mySplunkWebCertificate"$i": $password" >> $dir_mycerts"password.txt"
        fi
elif [ "$type" = "3" ]  && [ -z $hostnamelist ]
then
        if ! find  $dir_mycerts$dir_CA"Private Key/myCAPrivateKey.key" > /dev/null 2>&1 
        then
                echo "No CA Certificate Found!"
				exit 1        
	else 
		echo "[+] Generating Server Certificate $i"
		CA_password=$( cat $dir_mycerts"password.txt" | grep myCACertificate  | cut -d " "  -f 2,2)
		openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key 2048  > /dev/null 2>&1
        openssl req -new -key $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key -passin pass:$password -out $dir_mycerts$dir_Server"CSR/"myServerCertificate$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$commonname" > /dev/null 2>&1 
        openssl x509 -req -in $dir_mycerts$dir_Server"CSR/"myServerCertificate$i.csr -SHA256 -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem -days 1095 > /dev/null 2>&1 
        cat $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey$i.key $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Server"PEM/"myServerCertificate$i.pem 
		rm  $dir_mycerts$dir_Server"PEM/"myServerCert$i.pem
        echo "myServerCertificate"$i": $password" >> $dir_mycerts"password.txt"
        fi
elif [ "$type" = "2" ]  && [ ! -z $hostnamelist ]
then
		if [ ! -z $nocert ]
		then 
			echo "[+] Generating Web Certificate $i"
			openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey_$i.key 2048  > /dev/null 2>&1
			openssl req -new -key $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey_$i.key -passin pass:$password -out $dir_mycerts$dir_Web"CSR/"mySplunkWebCert_$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$i" > /dev/null 2>&1
			echo "mySplunkWebCertificate_"$i": $password" >> $dir_mycerts"password.txt"
		else
			if ! find  $dir_mycerts$dir_CA"Private Key/myCAPrivateKey.key" > /dev/null 2>&1 
			then
                echo "No CA Certificate Found!"
				exit 1 
			else
				echo "[+] Generating Server Certificate $i"
				CA_password=$( cat $dir_mycerts"password.txt" | grep myCACertificate  | cut -d " "  -f 2,2)
				openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey_$i.key 2048  > /dev/null 2>&1
				openssl req -new -key $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey_$i.key -passin pass:$password -out $dir_mycerts$dir_Web"CSR/"mySplunkWebCert_$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$i" > /dev/null 2>&1
				openssl x509 -req -in $dir_mycerts$dir_Web"CSR/"mySplunkWebCert_$i.csr -SHA256 -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Web"PEM/"mySplunkWebCert_$i.pem -days 1095  > /dev/null 2>&1
				cat $dir_mycerts$dir_Web"PEM/"mySplunkWebCert_$i.pem $dir_mycerts$dir_Web"Private Key/"mySplunkWebPrivateKey_$i.key $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Web"PEM/"mySplunkWebCertificate_$i.pem 
				rm  $dir_mycerts$dir_Web"PEM/"mySplunkWebCert_$i.pem
				echo "mySplunkWebCertificate_"$i": $password" >> $dir_mycerts"password.txt"
			fi
		fi
elif [ "$type" = "3" ]  && [ ! -z $hostnamelist ]
then
		if [ ! -z $nocert ]
		then 
			echo "[+] Generating Server Certificate $i"
			openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey_$i.key 2048  > /dev/null 2>&1
			openssl req -new -key $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey_$i.key -passin pass:$password -out $dir_mycerts$dir_Server"CSR/"myServerCertificate_$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$i" > /dev/null 2>&1
			echo "myServerCertificate_"$i": $password" >> $dir_mycerts"password.txt"
		else
			if ! find  $dir_mycerts$dir_CA"Private Key/myCAPrivateKey.key" > /dev/null 2>&1 
			then
                echo "No CA Certificate Found!"
				exit 1 
			else
				echo "[+] Generating Server Certificate $i"
				CA_password=$( cat $dir_mycerts"password.txt" | grep myCACertificate  | cut -d " "  -f 2,2)
				openssl genrsa -aes256 -passout pass:$password -out $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey_$i.key 2048  > /dev/null 2>&1
				openssl req -new -key $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey_$i.key -passin pass:$password -out $dir_mycerts$dir_Server"CSR/"myServerCertificate_$i.csr -subj "/C=$country/ST=$state/L=$city/emailAddress=$emailaddress/O=$organization/OU=IT/CN=$i" > /dev/null 2>&1
				openssl x509 -req -in $dir_mycerts$dir_Server"CSR/"myServerCertificate_$i.csr -SHA256 -CA $dir_mycerts$dir_CA"PEM/"myCACertificate.pem -CAkey $dir_mycerts$dir_CA"Private Key/"myCAPrivateKey.key -CAcreateserial -passin pass:$CA_password -out $dir_mycerts$dir_Server"PEM/"myServerCert_$i.pem -days 1095  > /dev/null 2>&1
				cat $dir_mycerts$dir_Server"PEM/"myServerCert_$i.pem $dir_mycerts$dir_Server"Private Key/"myServerPrivateKey_$i.key $dir_mycerts$dir_CA"PEM/"myCACertificate.pem > $dir_mycerts$dir_Server"PEM/"myServerCertificate_$i.pem 
				rm  $dir_mycerts$dir_Server"PEM/"myServerCert_$i.pem
				echo "myServerCertificate_"$i": $password" >> $dir_mycerts"password.txt"
			fi
		fi
		
		
fi
}
#-----------------------------------------------------------------------------------------------
if [ "$type" = "1" ] && [ -f $dir_mycerts$dir_CA"PEM/myCACertificate.pem" ]
then
	echo "CA is already generated"
	exit 1
elif [ "$type" = "2" ] && [ -d $dir_mycerts$dir_Web"PEM" ]
then
	rm -v $dir_mycerts$dir_Web"Private Key/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Web"CSR/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Web"PEM/"* > /dev/null 2>&1
	sed -i "/mySplunkWebCertificate/d" $dir_mycerts"password.txt" 
elif [ "$type" = "3" ]  && [ -d $dir_mycerts$dir_Server"PEM" ]
then
	rm -v $dir_mycerts$dir_Server"Private Key/"*  > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Server"CSR/"* > /dev/null 2>&1
	rm -v $dir_mycerts$dir_Server"PEM/"* > /dev/null 2>&1
	sed -i "/myServerCertificate/d" $dir_mycerts"password.txt" 
fi


#-----------------------------------------------------------------------------------------------

if [ ! -z "$number" ] 
then
	for i in $(seq 1 $number);
	do
        password=$(random_password)
	create_cert
	done
else
	for i in $(cat $hostnamelist); 
	do
        password=$(random_password)
		create_cert
	done
fi

echo "[+] Done "
