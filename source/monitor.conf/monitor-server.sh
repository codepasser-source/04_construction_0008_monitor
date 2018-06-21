####
DEBUG="false"
server="kibana"
logfile="/var/local/webresource/logs/monitor/monitor-server.log"
tempfile="top.temp"

startline=2
maxline=6
####
function topFunc()
{
    top -b -s -n 1 > $tempfile
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    hostname=$(hostname)
    log="{"
    log=$log"\"@time\":\"$timestamp\", "
    log=$log"\"@server\":\"$server\", "
    log=$log"\"@hostname\":\"$hostname\", "
    while [ $startline -lt $maxline ] 
    do
         line=`cat $tempfile |tail -n +$startline|head -n 1`
         log=$log" "$(sqlitItems "$line" $startline)
         ((startline++))
         if [ $startline -lt $maxline ]
         then
           log=$log", "
         fi
    done
    log=$log" }"

    echo $log >> $logfile

    if [ $DEBUG == "true" ]
    then
        echo "debug" >> $tempfile
    else
        rm -rf $tempfile
    fi
}

function sqlitItems()
{
    #itemName=`echo $1|cut -d ":" -f1`
    #itemName=$(trim "$itemName")
    
    if [ $2 == 2 ]
    then
    itemName="Task"
    fi
    if [ $2 == 3 ]
    then
    itemName="Cpu"
    fi
    if [ $2 == 4 ]
    then
    itemName="Memary"
    fi
    if [ $2 == 5 ]
    then
    itemName="Swap"
    fi

    items=`echo $1|cut -d ":" -f2`
    items=$(trim "$items")

    obj="\"$itemName\" : { "
    
    count=$(charOf "$items" ",")
    for i in `seq $[$count+1]`
    do
        item=`echo $items|cut -d "," -f$i`
        key=`echo $item|cut -d " " -f2`
        key=$(replaceAll "$key" "\/" "_")
        value=`echo $item|cut -d " " -f1`
        obj="$obj\"$key\" : $value" 
        if [ $i -lt $[$count+1] ]
        then
            obj=$obj", "
        fi
    done
    obj=$obj" }"

    echo $obj
}

function trim()
{
    echo $1 | sed 's/^ //;s/ $//'
}

function charOf()
{
    echo "$1" | awk -F"$2" "{print NF-1}"
}

function replaceAll()
{  rep=$1
   echo ${rep//$2/$3}
}

$(topFunc)