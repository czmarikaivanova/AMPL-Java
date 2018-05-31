# Set cardinalities:
param k; # Not used here, only in the straightforward model
param n; # Total number of satellites
param s; # Number of source satellites
param tmax = n - 1;
# Sets:
set V = 1 .. n; # 0 is the ground antenna
set S = 1 .. s;
set E within {(i,j) in V cross V: i<j};
#set E0 = {(0,i) in (V cross V): i in S};
#let E := E union E0;
set A={(i,j) in V cross V: (i,j) in E || (j,i) in E};
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E};

# Variables:
var x{(i,j) in A, t in 1..tmax} binary;
var c >= 0, <= tmax, integer;

# Objective function:
minimize time: c;

# Constraints:

subject to sourceFirst {v in S}:
	sum{i in N[v]} x[v,i,1] <= 1;

subject to allReceive {i in (V diff S)}:
	sum{t in 1 .. tmax, j in N[i]} x[j,i,t] = 1;

subject to oneAtATime {t in 1..tmax, i in V}:
	sum{j in N[i]} x[i,j,t] <= 1;

#subject to inIfOut {(i,j) in A, t in 2..tmax: i not in S}:
#	x[i,j,t] <= sum{u in 1..t-1, l in N[i]: l !=j} x[l,i,u];

subject to inIfOut {i in V, t in 2..tmax: i not in S}:
	sum{j in N[i]} x[i,j,t] <= sum{u in 1..t-1, l in N[i]} x[l,i,u];

subject to xcrel {(i,j) in A}:
	sum{t in 1..tmax} (t *x[i,j,t]) <= c;

#subject to xcrel {i in V}:
#	sum{t in 1..tmax} t * (sum{j in N[i]} x[i,j,t]) <= c;

subject to noFirst{(i,j) in A: i not in S}:
	x[i,j,1] = 0;
