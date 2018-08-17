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

function decProcedure {
	echo "
		print '-----------------xxx-------------Solving $1';		
		option relax_integrality 0;
		reset; 
		model ./models/$1;
		#data ./$2;
		param tlim default 1200;
		for {i in $3..$4} {
		        reset data;
			data ./$2;
		        let tmax := i;
			let tlim := tlim - _solve_time;
			option cplex_options ('timelimit ' & tlim); 
			if '$1' = 'BT-int-com.mod' or '$1' = 'partition-bin-com.mod' then {
				option cplex_options \$cplex_options 'mipdisplay 2 mipinterval 1 absmipgap 0.99999 lowercutoff $5'; 
			}
			else {
				option cplex_options \$cplex_options 'mipdisplay 2 mipinterval 1 absmipgap 0.99999'; 
			}
		        solve;
		        if solve_result = 'solved' then {
				if '$1' = 'BT-int-com.mod' or '$1' = 'partition-bin-com.mod' then {
					if objval = n-s then {
						printf '%4.2f\t', _total_solve_elapsed_time  >> timelog.txt;
						printf '%2.0f\t', i >> objlog.txt;
		        		        printf 'Optimal value: %d',i;
		        		        break;
					}
				}
				else {
					printf '%4.2f\t', _total_solve_elapsed_time  >> timelog.txt;
					printf '%2.0f\t', i >> objlog.txt;
		        	        printf 'Optimal value: %d',i;
		        	        break;
				}
		        }
			if solve_result = 'infeasible' then {
				if i = $4-1 then {
					printf 'Infeasible solution for iteration %d, but upper bound %d can now be used',i,$4;
					printf '%4.2f\t',  _total_solve_elapsed_time  >> timelog.txt;
					printf '%2.0f\t', $4 >> objlog.txt;
		                	break;
				}
			}
			printf 'Solve result status number: %d', solve_result_num;
			 if solve_result = 'limit' then {
				printf '%4.2f\t',  _total_solve_elapsed_time  >> timelog.txt;
				printf '%2.0f\t', i >> objlog.txt;
		                printf 'Time limit exceeded. Best value found (LB): %d',i;
		                break;
		        }

		        printf 'Infeasible for k = %d',i;
		}
	" >> cmds.run
}

function makeAMPLRun {
	logid $1
	javac -cp . LowerBounds.java -d ./bin
	java -cp ./bin LowerBounds $1 objlog.txt
	lb=$?
	javac -cp . UpperBounds.java -d ./bin
	java -cp ./bin UpperBounds $1
	ub=$?
#	touch cmds-ub.run
#	echo "
#		option solver '/opt/ibm/ILOG/CPLEX_Studio1251/cplex/bin/x86-64_sles10_4.1/cplexamp';
#		option cplex_options 'timing 1';
#		print '---------------------------------Solving MATCHING';
#                option relax_integrality 0;
#                reset;
#	 	option cplex_options 'mipdisplay 3';	
#                model ./models/matching.mod;
#                data ./$1;
#                let k := 2;
#		param iterCnt default 0;
#                repeat while card(S) < n {
#                        let iterCnt := iterCnt + 1;
#                        solve;
#                        #display S;
#                        #display x;
#                        for {j in S} {
#                                for {v in V_G} {
#                                        if x[2,j,v] == 1 then let S := S union {v};
#                                }
#                        }
#                }
#		print iterCnt > iterCnt.txt;
#		print  _total_solve_elapsed_time > matchTime.txt;
#	" > cmds-ub.run
#	ampl-bin cmds-ub.run
#	read ub < iterCnt.txt	
#	rm iterCnt.txt
#	read matchTime < matchTime.txt
#	rm matchTime.txt

	echo lower bound is $lb
	echo upper bound is $ub
	if [ "$lb" -eq "$ub" ]; then
		echo "$ub" >> objlog.txt
		echo "0" >> timelog.txt
	else
		touch cmds.run
		echo "created cmds"
		echo "  
			option solver '/opt/ibm/ILOG/CPLEX_Studio1251/cplex/bin/x86-64_sles10_4.1/cplexamp';
			option cplex_options 'timing 1';
			option eexit -10000;
			print '---------------------------------Solving BT-int-opt';		
			reset;
			model ./models/BT-int-opt.mod;
			data ./$1;
			let tmax := $ub;		
			option relax_integrality 0;
		 	option cplex_options 'mipdisplay 3';	
			option cplex_options 'timelimit=1200'; 
			solve;
			# display x;
			printf '%4.2f\t', _total_solve_elapsed_time  >> timelog.txt;
			printf '%2.0f\t', objval >> objlog.txt;
		" > cmds.run
		decProcedure BT-int-dec.mod $1 $lb $ub $2
		decProcedure BT-int-com.mod $1 $lb $ub $2
		decProcedure partition-bin-dec.mod $1 $lb $ub $2
		decProcedure partition-bin-com.mod $1 $lb $ub $2
		echo "
			printf '%2.0f\n', $ub >> objlog.txt;
#			printf '%4.1f\n', $matchTime >> timelog.txt;
			printf '\n' >> timelog.txt;
 
		" >> cmds.run	
		ampl-bin cmds.run
	fi
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
					edgeCnt=$(echo $line | awk '{print $2}')
					printf "$nodeCnt \t $edgeCnt \t" >> objlog.txt
					printf "$nodeCnt \t $edgeCnt \t" >> timelog.txt
					myFrac=$(echo "$nodeCnt/$sourceCnt" | bc -l);
					myLog=$(echo $myFrac | awk '{printf "%11.9f\n",log($1)/log(2)}')
					paramK=`awk -v ml=$myLog 'BEGIN{printf("%.f\n", ml)}'`
					echo "$paramK"
					fileCnt=`ls ampldata/ | wc -w`
					dataFileName="ampldata/inst-$nodeCnt-$sourceCnt-$fileCnt.dat"   # 3 is an output path 
					touch "$dataFileName"
					echo -n > "$dataFileName"
					echo "# $RANDOM" >> $dataFileName	
					#echo "param k := $paramK;" >> "$dataFileName"
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
			lco=`echo $nodeCnt'-'$sourceCnt'-0.0000001' | bc -l`
			makeAMPLRun "$dataFileName" "$lco"
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

