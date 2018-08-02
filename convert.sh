#!/bin/bash
filename=$1
	modFileName=$(echo "$filename" | sed -r "s/.+\/(.+)\..+/\1/")
	modFileName="$modFileName.dat"   # 3 is an output path 
	touch "data/$modFileName"
	i=1;
       while IFS='' read -r line || [[ -n "$line" ]]; do
		if [ "$i" -eq 1 ]; then
			nodeCnt=$(echo $line | awk '{print $1}')
			echo "param k := 10;" >> "$modFileName"
			echo "param n := $nodeCnt;" >> "$modFileName"
			echo "param s := $2;" >> "$modFileName"
			echo "set E :=" >> "$modFileName"
		else
			u=$(echo $line | awk '{print $1}')
			v=$(echo $line | awk '{print $2}')
			echo "($u,$v)" >> "$modFileName"
		fi
		i=$((i+1))
	done < "$filename" 
	echo ";" >> "$modFileName"
#java -cp ../../amplapi/lib/ampl-1.4.0.0.jar:bin Main $modFileName

