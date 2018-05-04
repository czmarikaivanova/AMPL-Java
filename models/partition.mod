# Input parameters:
param k; # Time limit

# Set cardinalities:
param n;      # Number of nodes. Should be of size 2^k*|S|
param s;      # Number of sources

# Sets:
set V_G = 1..n;        # Set of nodes of the original graph
set V_K = n+1..s*2^k;  # Set of nodes comprising the apex clique
set V = V_G union V_K; # Set of all nodes
set S = 1..s;          # Set of Sources
set E within {(i,j) in V cross V: i<j} default {(i,j) in V cross V: i<j && j=n};
set E_K = {(i,j) in V_K cross V_K: i < j};
set E_GK = {(i,j) in V_G cross V_K: i < j};
set I = 1..2^k; # set of labels in a binomial tree B_k
set J = 1..s;   # set of binomial trees that should partition G
set P{i in I} = {ceil(log(i)/log(2))..k-1};  # Set of exponents necessary for building the set of descendants of node i in binomial tree
set E1 := E union E_K union E_GK;
set A = {(i,j) in V cross V: (i,j) in E1 || (j,i) in E1};

# Variables:
#var y{(i,j) in A} binary;
var x{i in I, j in J, v in V} binary;

# Objective function: is not necessary, we are interested in a feasible solution
minimize zero: 0; 

# Constraints:
subject to nodeInTree {v in V}: sum{i in I,j in J} x[i,j,v] = 1;
subject to labelsInTree {i in I, j in J}: sum {v in V} x[i,j,v] = 1;
subject to sourceOnes {v in S}: x[1,v,v] = 1;

subject to noReturnFromK {j in J, i in I, l in P[i], u in V_K, v in V_G}: x[i,j,u] + x[2^l+i,j,v] <= 1;

subject to followArcs {u in V, v in V, i in I, j in J, l in P[i]: (u,v) not in A and u != v}: x[i,j,u] + x[2^l+i,j,v] <=1;