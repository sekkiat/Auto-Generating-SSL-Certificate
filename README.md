# SSL Certificate Generation

Tired of generating the certificate one by one? </br>
Here the solution for you! </br>
Just use a script to generate the certificate and help you do the manual job. </br>
It is specially designed for Splunk Web and Forwarder encryption. However, if it can fit into your apps, you are welcome to use the script. </br>

All certificates will encrypt with AES256 with SHA256. </br>

## Steps

1) Create a CA.
2) Generate Web and Server Certificate as many as you want.

or 

1) Specify the hostname list using -p options to generate the Web and Server Certificate.

## Usage: Generate_SSL.sh 
---------------------------------------------------------------------------------------------------------------------

  -t <type> [1] CA, [2] Web, [3] Server. </br></br>
 
 :exclamation: REQUIRED to define what type of certificate needs to generate. 
  
        [2] password certificate will be removed.
        [3] password certificate will remain.
 </br>

  -n <number> How many SSL certificates you need to generate. </br></br>
  
  :exclamation: REQUIRED to generate a web and server certificate if you do not specify the hostname list.</br></br>

  -p <hostname_list> Generate the Certificate based on the hostname in the file. </br></br>
  
 :exclamation: REQUIRED if you want to generate the certificates based on the hostname list. </br></br>

  -zc <no_ca_cert> No required to define CA Certificate </br></br>

###### Certificate Parameters Here  - REQUIRED TO DEFINE ALL THE PARAMETERS BELOW ######
------------------------------------------------------------------------------------------------------------------------------------------------

  -o <organization_name> Organization Name

  -c <common_name> Common Name

  -e <email_address> Email Address

  -u <organization_unit> Organization Unit

  -r <country> Country

  -s <state> State

  -i <city> City
