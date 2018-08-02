#!/bin/bash

function logid {
	id=`head -n 1 $1`
	printf "$id\t"  >> objlog.txt
	printf "$id\t"  >> timelog.txt
}
function ceil {                                                                       
  echo "define ceil (x) {if (x<0) {return x/1} \
        else {if (scale(x)==0) {return x} \
        else {return x/1 + 1 }}} ; ceil($1)" | bc
}


function makeAMPLRun {
	logid $1
	javac -cp . LowerBounds.java
	java -cp . LowerBounds $1 objlog.txt			
	touch cmds.run
	echo "
		reset;
		option solver '../cplex';
		option cplex_options 'timing 1';
		model ./models/sat.mod;
		data ./$1;
		
		print '---------------------------------Solving SAT IP';		
		option relax_integrality 0;
	 	option cplex_options 'mipdisplay 2';	
		option cplex_options 'timelimit=1200'; 
		solve;
		printf '%4.2f\t', _solve_elapsed_time >> timelog.txt;
		printf '%2.2f\t', time >> objlog.txt;

#		print '---------------------------------Solving SAT LP';		
#		option relax_integrality 1;
#	 	option cplex_options 'lpdisplay 1';	
#		solve;
#		printf '%4.2f\t', _solve_elapsed_time >> timelog.txt;
#		printf '%2.2f\t', time >> objlog.txt;

		print '---------------------------------Solving PART IP - DAG ';
		option relax_integrality 0;
		reset; 
		model ./models/partition-dec.mod;
		data ./$1;
		drop followArcs;
		display k;
		for {i in k..n} {
		        reset data;
			data ./$1;
		        let k := i;
			option cplex_options 'timelimit=1200'; 
		        solve;
		        if solve_result = 'solved' then {
				printf '%4.2f\t', _solve_elapsed_time >> timelog.txt;
				printf '%2.2f\t', i >> objlog.txt;
				display x;
		                printf 'Optimal value: %d',i;
		                break;
		        }
			printf 'Solve result status number: %d', solve_result_num;
			 if solve_result = 'limit' then {
				printf '%4.2f\t', _solve_elapsed_time >> timelog.txt;
				printf '%2.2f\t', i >> objlog.txt;
		                printf 'Time limit exceeded. Best value found (LB): %d',i;
		                break;
		        }

		        printf 'Infeasible for k = %d',i;
	        }	
		print '---------------------------------Solving PART IP - MARIKA';		
		option relax_integrality 0;
		reset;
		model ./models/partition-dec.mod;
		data ./$1;
		drop followArcsA;
		drop followArcsB;
		display k;
		for {i in k..n} {
		        reset data;
			data ./$1;
		        let k := i;
			option cplex_options 'timelimit=1200'; 
		        solve;
		        if solve_result = 'solved' then {
				printf '%4.2f\n', _solve_elapsed_time >> timelog.txt;
				printf '%2.2f\t', i >> objlog.txt;
				display x;
		                printf 'Optimal value: %d',i;
		                break;
		        }
			printf 'Solve result status number: %d', solve_result_num;
			 if solve_result = 'limit' then {
				printf '%4.2f\n', _solve_elapsed_time >> timelog.txt;
				printf '%2.2f\t', i >> objlog.txt;
		                printf 'Time limit exceeded. Best value found (LB): %d',i;
		                break;
		        }

		        printf 'Infeasible for k = %d',i;
		
		}

                print '---------------------------------Solving MATCHING';
                option relax_integrality 0;
                reset;
                model ./models/matching.mod;
                data ./$1;
                let k := 2;
		param iterCnt default 0;
                repeat while card(S) < n {
                        let iterCnt := iterCnt + 1;
                        solve;
                        display S;
                        display x;
                        for {j in S} {
                                for {v in V_G} {
                                        if x[2,j,v] == 1 then let S := S union {v};
                                }
                        }
                }
		printf '%2.2f\n', iterCnt >> objlog.txt;
 
	" > cmds.run	
	../ampl cmds.run
#	rm cmds.run
}


case $1 in
	raw)
		sourceCnt=$2;
		shift 2
		for filename in "$@"; do #iterate over params except the last (number of sources)
			echo "Processing: $filename"
#			dataFileName=$(echo "$filename" | sed -r "s/.+\/(.+)\..+/\1/")
			i=1;
		       while IFS='' read -r line || [[ -n "$line" ]]; do
				if [ "$i" -eq 1 ]; then
					nodeCnt=$(echo $line | awk '{print $1}')
					myFrac=$(echo "$nodeCnt/$sourceCnt" | bc -l);
					myLog=$(echo $myFrac | awk '{printf "%11.9f\n",log($1)/log(2)}')
					paramK=`awk -v ml=$myLog 'BEGIN{printf("%.f\n", ml)}'`
					echo "$paramK"
					fileCnt=`ls ampldata/ | wc -w`
					dataFileName="ampldata/inst-$nodeCnt-$sourceCnt-$fileCnt.dat"   # 3 is an output path 
					touch "$dataFileName"
					echo -n > "$dataFileName"
					echo "# $RANDOM" >> $dataFileName	
					echo "param k := $paramK;" >> "$dataFileName"
					echo "param n := $nodeCnt;" >> "$dataFileName"
					echo "param s := $sourceCnt;" >> "$dataFileName"
					echo "set E :=" >> "$dataFileName"
				else
					u=$(echo $line | awk '{print $1}')
					v=$(echo $line | awk '{print $2}')
					echo "($u,$v)" >> "$dataFileName"
				fi
				i=$((i+1))
			done < "$filename" 
			echo ";" >> "$dataFileName"
			makeAMPLRun "$dataFileName"
		done
	;;
	ampl)
		shift 1
		for filename in "$@"; do #iterate over params except the last (number of sources)
			echo "Processing: $filename"
			makeAMPLRun "$filename"
		done
	;;
	rand)
       		javac -cp . RandomGraph.java
		java -cp . RandomGraph $2 $3 $4 $5 $6 
	        files=$6* 
		for filename in $(ls $6);
       		 do
			echo "Processing: $filename"
			#echo "" >> objlog.txt	
			makeAMPLRun  "$6$filename" 8
			filecnt=`ls ampldata/random/ | wc -w`
			mv $6$filename "ampldata/random/ampl-$3-$4-$filecnt.dat"
		 done
	 
;;
esac

