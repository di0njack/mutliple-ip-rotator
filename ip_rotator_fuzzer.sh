#!/bin/bash
#Author: @Di0nj@ck - 10/1/19
#Version: 1.0
# DEVELOPED BY Di0nJ@ck - October 2019 - v1.0

#GLOBAL VARIABLES
rotate_methods=("original_ip" "tor" "aws") #TOR SOCKS6 is useful if not blocked on WAF/CDN, if it is just try your own t2.micro AWS chaning Internet Gateway IP
choose_method=1 #INDEX FROM THE ABOVE ARRAY
tor_socks_proxy="127.0.0.1:9050" #ADDRESS AND PORT OF OUR TOR SOCKS5 PROXY

#REQUEST PARAMS
user_agent="User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.19 (KHTML, like Gecko) Chrome/0.2.153.1 Safari/525.19"
x_req_with="X-Requested-With: XMLHttpRequest" #CUSTOMIZE WITH YOUR REQUEST
content_type="Content-Type: application/x-www-form-urlencoded; charset=UTF-8" #CUSTOMIZE WITH YOUR REQUEST
content_length="Content-Length: 15" #CUSTOMIZE WITH YOUR REQUEST
referer="Referer: https://www.mywebsite.com" #CUSTOMIZE WITH YOUR REQUEST
body_params="myparam=value"
http_method="-X POST"
socks_curl="--socks5"

#URLs
url="https://www.mytargetsite.com/login"



#ROTATE IP FROM TOR SOCKS5 SERVICE
function  rotate_ip {
    if [[ $1 == "original_ip" ]];then
        printf '\n          [!] Original public IP, not modified'
    elif [[ $1 == "tor" ]];then
        sudo killall -HUP tor
        printf '\n          [!] Rotated TOR service. Done!'
    elif [[ $1 == "aws" ]];then
        echo "nothing"
    fi
}

#FUZZING FUNCTION
function  fuzzing {
    if [[ $1 == "original_ip" ]];then
        curl $http_method -H "$user_agent" -H "$x_req_with" -H "$content_type" -H "$content_length" -H "$referer" -d "$body_params" $url

    elif [[ $1 == "tor" ]];then
        printf '\n          [!] CURL Request through TOR SOCKS5. Done!' 
        curl $socks_curl $tor_socks_proxy $http_method -H "$user_agent" -H "$x_req_with" -H "$content_type" -H "$content_length" -H "$referer" -d "$body_params" $url
    fi
}

#**** MAIN CODE ****

#START GETTING A NEW TOR EXIT IP
printf '\n[*] Obtaining new TOR Exit node IP...' 
rotate_ip "${rotate_methods[$choose_method]}"

#INFINITE LOOP FOR FUZZING FROM DIFFERENT IPs
printf '\n[*] Entering into an infinite loop until stopped by user...' 
while true; do 
    printf '\n      [*] Calling fuzzing function...' 
    fuzzing "${rotate_methods[$choose_method]}"
    s_time=$((1 + RANDOM % 10)) #RANDOMIZE SLEEP TIME (1-10 seconds)
    printf '\n      [*] Waiting a randomized amount of time (1-10 seconds)...' 
    sleep $s_time
    printf '\n      [*] Rotate IP again' 
    rotate_ip "${rotate_methods[$choose_method]}" #CHANGE IP 
done