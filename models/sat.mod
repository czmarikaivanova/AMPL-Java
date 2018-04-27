# Set cardinalities:
param k; # Not used here, only in the straightforward model
param n; # Total number of satellites
param s; # Number of source satellites
param tmax = n - 1;
# Sets:
set V = 0 .. n; # 0 is the ground antenna
set S = 1 .. s;
set E within {(i,j) in V cross V: i<j};
set E0 = {(0,i) in (V cross V): i in S};
let E := E union E0;
set A={(i,j) in V cross V: (i,j) in E || (j,i) in E};
set N{i in V} within V = {j in V: (i,j) in E || (j,i) in E};
#param u{(i,j) in V cross V: (i,j) in E || (j,i) in E} in V = min(i,j);
#param v{(i,j) in V cross V: (i,j) in E || (j,i) in E} in V = max(i,j);

# Variables:
var x{(i,j) in A, t in 0..tmax} binary;
var c >= 0, <= tmax, integer;

# Objective function:
minimize time: c;

# Constraints:

subject to sourceFirst {i in S}:
	x[0,i,0] = 1;

subject to allReceive {i in (V diff S): i != 0}:
	sum{t in 1 .. tmax, j in N[i]} x[j,i,t] = 1;

subject to oneAtATime {t in 1..tmax, i in V: i != 0}:
	sum{j in N[i]} x[i,j,t] <= 1;

subject to inIfOut {(i,j) in A, t in 1..tmax: i != 0}:
	x[i,j,t] <= sum{u in 0..t-1, l in N[i]: l != j} x[l,i,u];

subject to xcrel {(i,j) in A}:
	sum{t in 0..tmax} (t*x[i,j,t]) <= c;

subject to noFirst{(i,j) in A: i != 0}:
	x[i,j,0] = 0;
