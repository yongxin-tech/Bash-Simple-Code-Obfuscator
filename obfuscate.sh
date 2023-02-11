#!/usr/bin/env bash

# preparation:
#   chmod 400 func.list
#	chmod 700 obfuscate.sh
# run: ./obfuscate.sh -d ./Runner -f "*.swift" -s symbols-ios.db -l func-example.list 

while getopts ":d:f:s:l:" opt; do
    case $opt in
        d) 
 	    workDir="$OPTARG"
	    ;;
        f) 
	    filter="$OPTARG"
	    ;;
        s) 
	    storage="$OPTARG"
	    ;;
        l) 
	    symbol="$OPTARG"
	    ;;
        ?) ;;
    esac
done

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Table Name
tableName="symbols"

# Sqlite3 File
symbolStorage="$scriptDir/$storage"

# Symbol List
symbolList="$scriptDir/$symbol"

export LANG="zh_TW.UTF-8"

makesureTableExist() {
    echo "create table if not exists $tableName(orig text, dest text, file text, count integer);" | sqlite3 $symbolStorage
}

saveMapping() {
    sqlite3 $symbolStorage "insert into $tableName values('$1', '$2', '$3', $4);"
}

getExistedByOrig() {
    # 依symbol取得dest symbol(會有多行)，取第一行值
    sqlite3 $symbolStorage "select dest from $tableName where orig='$1' order by rowid asc limit 1;"
}

getRandomText() {
    openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16
}

makesureTableExist

find "$workDir" -name "$filter" | while read -r lineFile;
do
    #echo "[start]: $lineFile >>>>>>>>>> "
    
    # 去除print("") logs(改為註解)
    sed -i '' 's/print("/\/\/print("/g' $lineFile
    # 讀取資料行: 排除#開頭行並使用awk去重複
    sed -e "/^#/d" $symbolList | awk ' !x[$0]++' | while read -r lineSymbol;
    do
        if [[ -n "$lineSymbol" ]]; then
            # 去除行尾符號
            pureSymbol=$(echo "$lineSymbol" | sed "s/\r//g")
            existedDestSymbol=$(getExistedByOrig "$pureSymbol")
            
            # 如果已有轉譯過的字串，則使用轉譯過的取代
            # 否則新產生後取代
            if [[ -n "$existedDestSymbol" ]]; then
                random=$existedDestSymbol
            else
                random=`getRandomText`
                #echo "[do]: $pureSymbol to $random"
            fi
            
            # 將symbol取代為隨機字串
            sed -i '' "s/$pureSymbol/$random/g" $lineFile
            
            count=$(grep -o -i $random $lineFile | wc -l)
            
            # 如果有取代字串才放入symbol db
            if [ $count -gt 0 ]; then
                saveMapping $pureSymbol $random $lineFile $count
                echo "[finish]: $pureSymbol to $random, count: $count <<<<<<<<<< "
            fi
        fi
    done
done

# Render database content as SQL
sqlite3 $symbolStorage .dump
