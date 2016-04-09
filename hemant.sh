#########Script to check the fail2ban IP#######
# this will check for the ban ip and unban it##
#Author :Hemant B Khot date:18 Mar 2016########
###############################################
#!/bin/sh
#set -x
echo "Enter a IP to be checked "
read ip
function validateIP()
 {
         local ip=$1
         local stat=1
         if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                OIFS=$IFS
                IFS='.'
                ip=($ip)
                IFS=$OIFS
                [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
                && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
                stat=$?
        fi
        return $stat
}

validateIP $ip

if [[ $? -ne 0 ]];then
  echo "Invalid IP Address ($ip)";exit 0
else
  echo "$ip is a Perfect IP Address"
fi

####IP validate##
alias check="iptables -L -n|grep $ip"
echo check $ip
if [ "`echo $?`" == 0 ]
then
sleep 3
fail2ban-client set sasl  unbanip $ip  2> /dev/null 
if [ "`echo $?`" == 0 ] ;then echo "Found Blocked doing multiple wrong login....Now removed" ;else echo "checking in other List";fi
fail2ban-client set cyrusauth unbanip $ip 2> /dev/null
if [ "`echo $?`" == 0 ] ;then echo "Found Blocked doing multiple wrong attemtpt to login to  mailbox ....Now removed" ;else echo "checking in other List";fi
fail2ban-client set mailflood unbanip $ip 2> /dev/null
if [ "`echo $?`" == 0 ] ;then echo "Found Blocked doing mail bombarding....Now removed" ;else echo "checking in other List";fi
fail2ban-client set postfix unbanip $ip 2> /dev/null
if [ "`echo $?`" == 0 ] ;then echo "Found Blocked multiple mails received in short time....Now removed" ;else echo "checking in other List";fi
fail2ban-client set ssh-iptables  unbanip $ip 2> /dev/null
if [ "`echo $?`" == 0 ] ;then echo "Found Blocked trying to access server....Now removed" ;else
echo "IP is not Blocked anywhere"
fi
fi