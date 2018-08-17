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

set SS = {(u,v) in E: u in S and v in S};

# Objective function:
maximize objval: sum{v in V, t in 1..tmax, u in N[v]: v not in S} x[u,v,t];

# Constraints:

subject to sourceFirst {v in S}:
	sum{i in N[v]} x[v,i,1] <= 1;

subject to allReceive {u in (V diff S)}:
	sum{t in 1 .. tmax, v in N[u]} x[v,u,t] <= 1;

subject to sourceNoReceive {u in S}:
	sum{t in 1 .. tmax, v in N[u]} x[v,u,t] = 0;

subject to oneAtATime {t in 1..tmax, u in V}:
	sum{v in N[u]} x[u,v,t] <= 1;

subject to inIfOut {u in (V diff S), t in 2..tmax}:
	sum{v in N[u]} x[u,v,t] <= sum{l in 1..t-1, w in N[u]} x[w,u,l];

subject to noFirst{(u,v) in A: u not in S}:
	x[u,v,1] = 0;


