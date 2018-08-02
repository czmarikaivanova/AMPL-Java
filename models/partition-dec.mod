# Input parameters:
param k; # Time limit

# Set cardinalities:
param n;      # Number of nodes. Should be of size 2^k*|S|
param s;      # Number of sources
param tmax = n - s;
# Sets:
set V_G = 0..n - 1;        # Set of nodes of the original graph
set V_K = {n};  # Set of nodes comprising the apex clique
set V = V_G union V_K; # Set of all nodes
set S = 0..s - 1;          # Set of Sources
set E within {(i,j) in V cross V: i<j} default {(i,j) in V cross V: i<j && j=n};
set E_K = {(n,n)};
set E_GK = {(i,j) in V_G cross V_K};
set I = 1..2^k; # set of labels in a binomial tree B_k
set P{i in I} = {ceil(log(i)/log(2))..k-1};  # Set of exponents necessary for building the set of descendants of node i in binomial tree
set E1 := E union E_K union E_GK;
set A1 = {(i,j) in V cross V: (i,j) in E || (j,i) in E} union E_GK union E_K ;
set A = {(i,j) in V cross V: (i,j) in E || (j,i) in E}; 

# Variables:
#var y{(i,j) in A} binary;
var x{i in I, j in S, v in V} binary;

# Objective function: is not necessary, we are interested in a feasible solution
minimize zero: 0;

# Constraints:
subject to nodeInTree {v in V_G}: sum{i in I,j in S} x[i,j,v] = 1;
subject to labelsInTree {i in I, j in S}: sum {v in V} x[i,j,v] = 1;
subject to sourceOnes {j in S}: x[1,j,j] = 1;

#subject to noReturnFromK {j in S, i in I, l in P[i], u in V_K, v in V_G}: x[i,j,u] + x[2^l+i,j,v] <= 1;

subject to followArcs {u in V, v in V, i in I, j in S, l in P[i]: (u,v) not in A1 and u != v}: x[i,j,u] + x[2^l+i,j,v] <=1;

subject to followArcsA {u in V_G, i in I, l in P[i], t in S}: x[i,t,n] +x[i,t,u] + sum {v in V_G: (u,v) not in A} x[2^l+i,t,v] <= 1;

subject to followArcsB {u in V_G, i in I, l in P[i], t in S}: x[i,t,n] +x[2^l+i,t,u] + sum {v in V_G: (u,v) not in A} x[i,t,v] <= 1;

#symmetry removal
subject to symrem {i in I, j in P[i], l in P[i],t in S: j < l}: x[2^j+i,t,n] <= x[2^l+i,t,n];
