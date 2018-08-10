#!/bin/bash
filename=$1
	modFileName=`basename $filename .txt`
	echo "$modFileName"
	modFileName="datafiles/n100/x$modFileName.txt"   # 3 is an output path 
	touch "$modFileName"
	i=1;
       while IFS='' read -r line || [[ -n "$line" ]]; do
		if [ "$i" -eq 1 ]; then
			echo $line >> $modFileName
		else
			
			u=$(echo $line | awk '{print $1}')
			v=$(echo $line | awk '{print $2}')
			u=$((u-1))
			v=$((v-1))
			if [ "$u" -gt "$v" ]; then
				tmp=$u
				u=$v
				v=$tmp
			fi
			echo "$u $v" >> "$modFileName"
		fi
		i=$((i+1))
	done < "$filename" 

