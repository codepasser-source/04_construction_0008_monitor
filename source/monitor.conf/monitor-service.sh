servers=(
    "10.1.36.210:80:nginx-porxy-00"

    "10.1.36.211:80:nginx-porxy-01"

    "10.1.36.220:70:nginx-resource-10"
    "10.1.36.220:80:nginx-mall-10"
    "10.1.36.220:81:nginx-mmall-10"
    "10.1.36.220:81:nginx-pay-10"
    "10.1.36.220:90:nginx-admin-10"

    "10.1.36.221:70:nginx-resource-11"
        "10.1.36.221:80:nginx-mall-11"
        "10.1.36.221:81:nginx-mmall-11"
        "10.1.36.221:81:nginx-pay-11"
        "10.1.36.221:90:nginx-admin-11"

    "10.1.36.230:8080:jetty-mall-00"
    "10.1.36.230:8081:jetty-mmall-00"
    "10.1.36.230:8082:jetty-pay-00"
    "10.1.36.230:9090:jetty-admin-00"

    "10.1.36.231:8080:jetty-mall-01"
        "10.1.36.231:8081:jetty-mmall-01"
        "10.1.36.231:8082:jetty-pay-01"
        "10.1.36.231:9090:jetty-admin-01"

    "10.1.36.240:9200:elasticsearch-00"
        "10.1.36.240:2181:zookeeper-00"
        "10.1.36.240:11211:memcached-00"
        "10.1.36.240:6379:redis-00"
    "10.1.36.240:6380:redis-01"

    "10.1.36.241:9200:elasticsearch-01"
        "10.1.36.241:2181:zookeeper-01"
        #"10.1.36.241:11211:memcached-01"
        "10.1.36.241:6379:redis-10"
        "10.1.36.241:6380:redis-11"

    "10.1.36.242:9200:elasticsearch-02"
        "10.1.36.242:2181:zookeeper-02"
        #"10.1.36.242:11211:memcached-02"
        "10.1.36.242:6379:redis-20"
        "10.1.36.242:6380:redis-21"

    "10.1.36.250:5601:kinbana"

        "10.1.36.251:3306:mysql-00"
    "10.1.36.252:3306:mysql-01"

)

DEBUG="false"

logfile="/var/local/webresource/logs/monitor/monitor-service.log"
function listenerFunc()
{
    size=${#servers[@]}
    index=0
    while [ $index -lt $size ]
    do
        address=`echo ${servers[$index]}|cut -d ":" -f1`
        port=`echo ${servers[$index]}|cut -d ":" -f2`
                server=`echo ${servers[$index]}|cut -d ":" -f3`
        time=`date +%Y-%m-%d" "%H:%M:%S`
        
        result=`echo "" | telnet $address $port 2>/dev/null|grep "\^]"|wc -l`

        if [ $result == 0 ]
        then
            log="{ "
            log=$log"\"@time\":\"$time\", "
            log=$log"\"@server\":\"$server\", "
            log=$log"\"address\":\"$address\", "
            log=$log"\"port\":\"$port\", "
            log=$log"\"result\":\"$result\", "
            log=$log"\"msg\":\"telnet: connect to address $address:$port : No route to host.\"" 
            log=$log" }"
            echo $log >> $logfile
        else
            if [ $DEBUG == "true" ]
            then
                log="{ "
                            log=$log"\"@time\":\"$time\", "
                            log=$log"\"@server\":\"$server\", "
                            log=$log"\"address\":\"$address\", "
                            log=$log"\"port\":\"$port\", "
                            log=$log"\"result\":\"$result\", "
                            log=$log"\"msg\":\"telnet: connect to address $address:$port : Connection success.\""
                            log=$log" }"
                            echo $log >> $logfile 
            fi
        fi

        ((index++))
    done
}

$(listenerFunc)