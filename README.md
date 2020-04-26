# Auto-Generating-SSL-Certificate
Designated for Splunk.
Doesn't required to generate the certificate one by one (manually).

1) Create a CA.
2) Generate Web and Server Certificate as many as you want.

Usage: Generate_SSL.sh

  -t <type> [1] CA, [2] Web, [3] Server. REQUIRED

  -n <number> How many SSL certificate you need to generate. REQUIRED for  gener                                                                                                                                                             ate web and server certificate.

  -o <organization_name> Organization Name. REQUIRED

  -c <common_name> Common Name. REQUIRED

