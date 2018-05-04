# Input parameters:
param k; # Time limit

# Set cardinalities:
param n;      # Number of nodes. Should be of size 2^k*|S|
param s;      # Number of sources

# Sets:
set V = 1..n;        # Set of nodes of the original graph
set S = 1..s;          # Set of Sources
set E within {(i,j) in V cross V: i<j} default {(i,j) in V cross V: i<j && j=n};
set I = 1..2^k; # set of labels in a binomial tree B_k
set P{i in I} = {ceil(log(i)/log(2))..k-1};  # Set of exponents necessary for building the set of descendants of node i in binomial tree
set A = {(i,j) in V cross V: (i,j) in E || (j,i) in E};

# Variables:
#var y{(i,j) in A} binary;
var x{i in I, j in S, v in V} binary;

# Objective function: is not necessary, we are interested in a feasible solution
minimize zero: 0; 

# Constraints:
subject to nodeInTree {v in V}: sum{i in I,j in S} x[i,j,v] = 1;
subject to labelsInTree {i in I, j in S}: sum {v in V} x[i,j,v] <= 1;
subject to sourceOnes {v in S}: x[1,v,v] = 1;
subject to followArcs {u in V, v in V, i in I, j in S, l in P[i]: (u,v) not in A and u != v}: x[i,j,u] + x[2^l+i,j,v] <=1;
