# Set cardinalities:
param k; # Not used here, only in the straightforward model
param n; # Total number of satellites
param s; # Number of source satellites
param tmax default n - 1;
# Sets:
set V = 0 .. n - 1; # 0 is the ground antenna
set S = 0 .. s - 1;
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

subject to allReceive {u in (V diff S)}:
	sum{t in 1 .. tmax, v in N[u]} x[v,u,t] = 1;

subject to oneAtATime {t in 1..tmax, u in V}:
	sum{v in N[u]} x[u,v,t] <= 1;

#subject to inIfOut {(i,j) in A, t in 2..tmax: i not in S}:
#	sum{l in 1..t}x[i,j,l] <= sum{u in 1..t-1, l in N[i]: l !=j} x[l,i,u];

subject to inIfOut {u in (V diff S), t in 2..tmax}:
	sum{v in N[u]} x[u,v,t] <= sum{l in 1..t-1, w in N[u]} x[w,u,l];

#subject to xcrel {(u,v) in A, t in 1..tmax}:
#	(t *x[u,v,t]) <= c;

subject to xcrel {(u,v) in A}:
	sum{t in 1..tmax} (t *x[u,v,t]) <= c;
#subject to xcrel {u in V, t in 1..tmax}:
#	sum{v in N[u]} x[u,v,t] <= c;

#subject to xcrel {i in V}:
#	sum{t in 1..tmax} t * (sum{j in N[i]} x[i,j,t]) <= c;

subject to noFirst{(u,v) in A: u not in S}:
	x[u,v,1] = 0;
