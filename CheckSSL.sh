#!/bin/bash
# Check SSL Expiration on common Ports
# 09/03/2022
# Igor A.
# SysOps LatAm

#JUST CHANGE THIS VARIABLE

DomainList="
hostname1.domain.com
hostname2.domain.com
hostname3.domain.com
hostname4.domain.com
hostname5.domain.com
"

# DONT CHANGE ANYTHING FROM HERE
LogZ="/var/log/checkSSL.log"
echo -e "Starting..." | tee $LogZ

for domains in $DomainList 
do 
  echo -e "$domains" | tee -a $LogZ
    if [ -z "$domains" ]
    then
      echo "Domain is NULL or invalid"
      exit 1
    fi
  name=$domains
  shift
  now_epoch=$( date +%s )
  
  echo -e "################# ANALYZING APACHE PORTS #################" | tee -a $LogZ
  dig +noall +answer $name | while read _ _ _ _ ip;
  do
    echo -n "$ip:"
    expiry_date=$( echo | openssl s_client -showcerts -servername $name -connect $ip:443 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
    echo -n " $expiry_date";
    expiry_epoch=$( date -d "$expiry_date" +%s )
    expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
    echo "    $expiry_days days"
  done | tee -a $LogZ
  
  echo -e "################# ANALYZING dovecot PORTS #################" | tee -a $LogZ
  dig +noall +answer $name | while read _ _ _ _ ip;
    do
      echo -n "$ip:"
      expiry_date=$( echo | openssl s_client -showcerts -servername $name -connect $ip:995 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
      echo -n " $expiry_date";
      expiry_epoch=$( date -d "$expiry_date" +%s )
      expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
      echo "    $expiry_days days"
    done | tee -a $LogZ
    
  echo -e "################# ANALYZING cpanel PORTS #################" | tee -a $LogZ
  dig +noall +answer $name | while read _ _ _ _ ip;
    do
      echo -n "$ip:"
      expiry_date=$( echo | openssl s_client -showcerts -servername $name -connect $ip:2087 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
      echo -n " $expiry_date";
      expiry_epoch=$( date -d "$expiry_date" +%s )
      expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
      echo "    $expiry_days days"
    done | tee -a $LogZ
    
  echo -e "################# ANALYZING SMTP PORTS #################" | tee -a $LogZ
  dig +noall +answer $name | while read _ _ _ _ ip;
    do
      echo -n "$ip:"
      expiry_date=$( echo | openssl s_client -showcerts -servername $name -connect $ip:465 2>/dev/null | openssl x509 -inform pem -noout -enddate | cut -d "=" -f 2 )
      echo -n " $expiry_date";
      expiry_epoch=$( date -d "$expiry_date" +%s )
      expiry_days="$(( ($expiry_epoch - $now_epoch) / (3600 * 24) ))"
      echo "    $expiry_days days"
    done | tee -a $LogZ
  echo -e "------------------------------------------------------------" | tee -a $LogZ
done
echo -e "Check the logs $LogZ"
