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
set A = {(i,j) in V cross V: (i,j) in E || (j,i) in E};
set I = 1..2^k; # set of labels in a binomial tree B_k
set J = 1..s;   # set of binomial trees that should partition G
set P{i in I} = {ceil(log(i)/log(2))..k-1};  # Set of exponents necessary for building the set of descendants of node i in binomial tree

# Variables:
var y{(i,j) in A} binary;
var x{i in I, j in J, v in V} binary;

# Objective function: is not necessary, we are interested in a feasible solution
minimize arcCnt: sum {(i,j) in A} y[i,j];

# Constraints:
subject to nodeInTree {v in V}: sum{i in I,j in J} x[i,j,v] = 1;
subject to labelsInTree {i in I, j in J}: sum {v in V} x[i,j,v] = 1;
subject to sourceOnes {v in S}: x[1,v,v] = 1;
#subject to conTrees {v in V, u in V, i in I,l in I, j in J: (u,v) not in A and i != l }: x[i,j,v] + x[l,j,u] <= 1;


# constraint of the form x[_,_,_]*x[_,_,_]=y[_,_] is linearized by the follwoing:
subject to tree1 {j in J,i in I,l in P[i], (u,v) in A}: x[i,j,u] + x[2^l+i,j,v] - 1 <= y[u,v];
#subject to tree2 {j in J,i in I,l in P[i], (u,v) in A}: x[i,j,u] >= y[u,v];
#subject to tree3 {j in J,i in I,l in P[i], (u,v) in A}: x[2^l+i,j,v] >= y[u,v];

subject to ascArcs {i in I, l in I, j in J, (u,v) in A: l < i}: x[i,j,u] + x[l,j,v] + y[u,v] <= 2; 
subject to followArcs {u in V, v in V, i in I, j in J, l in P[i]: (u,v) not in A and u != v}: x[i,j,u] + x[2^l+i,j,v] <=1;
#subject to followArcs {i in I, l in I, j in J, (u,v) in A: i != l}: x[i,j,u] + x[l,j,v] -1 <= y[u,v];
