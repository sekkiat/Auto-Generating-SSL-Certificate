# Auto-Generating-SSL-Certificate
Tired of generate the certificate one by one (manually)?
Here the solution for you!
You can use thie script to generate the certificate for you.
It is specially design for Splunk Web and Forwarder encrpytion.

All certificates will encrypt with AES256 with SHA256.

Steps

1) Create a CA.
2) Generate Web and Server Certificate as many as you want.

Usage: Generate_SSL.sh 

  -t <type> [1] CA, [2] Web, [3] Server. REQUIRED

  -n <number> How many SSL certificate you need to generate. REQUIRED for generate web and server certificate if you not specify hostname list.

  -p <hostname_list> Generate the Certificate based on the hostname in the file. REQUIRED if you not specify certificate parameters & numbers

  -zc <no_ca_cert> No Required to Define CA Cert

 Certificate Parameters Here  - REQUIRED ALL THE PARAMETERS BELOW IF YOU NOT SPECIFIED YOUR HOSTNAME LIST
==========================================================================================================

  -o <organization_name> Organization Name

  -c <common_name> Common Name

  -e <email_address> Email Address

  -u <organization_unit> Organization Unit

  -r <country> Country

  -s <state> State

  -i <city> City
