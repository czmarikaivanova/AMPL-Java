# Set cardinalities:
param n;      # Number of nodes. Should be of size 2^k*|S|
param s;      # Number of sources
param tmax default n - s;
# Sets:
set V_G = 0..n - 1;        # Set of nodes of the original graph
set V = V_G union {n}; # Set of all nodes
set S = 0..s - 1;          # Set of Sources
set E within {(i,j) in V cross V: i<j} default {(i,j) in V cross V: i<j && j=n};
set I = 1..2^tmax; # set of labels in a binomial tree B_k
set P{i in I} = {ceil(log(i)/log(2))..tmax-1};  # Set of exponents necessary for building the set of descendants of node i in binomial tree
set A = {(i,j) in V cross V: (i,j) in E || (j,i) in E}; 
set N{i in V_G} within V_G = {j in V_G: (i,j) in E || (j,i) in E};
set NONN{i in V_G} within V_G = {j in V_G: j not in N[i]};
set NS{i in V_G} within V_G = union {j in N[i]} N[j];
set NNONN{i in V_G} within V_G = union {j in NONN[i]} N[j];

# Variables:
#var y{(i,j) in A} binary;
var x{i in I, j in S, v in V} binary;

# Objective function: is not necessary, we are interested in a feasible solution
#-1 is there for the bashfile run. The combined version of BT model expects objective n-1, so 
# it is convenient to have this value here as well
maximize objval: -s + sum{v in V_G, i in I, j in S} x[i,j,v];

# Constraints:
subject to nodeInTree {v in V_G}: sum{i in I,j in S} x[i,j,v] <= 1;
subject to labelsInTree {i in I, j in S}: sum {v in V} x[i,j,v] = 1;
subject to sourceOnes {j in S}: x[1,j,j] = 1;

#subject to noReturnFromK {j in S, i in I, l in P[i], u in V_K, v in V_G}: x[i,j,u] + x[2^l+i,j,v] <= 1;

#subject to followArcs {u in V, v in V, i in I, j in S, l in P[i]: (u,v) not in A1 and u != v}: x[i,j,u] + x[2^l+i,j,v] <=1;

#subject to followArcsA {u in V_G, i in I, l in P[i], t in S}: x[i,t,n] +x[i,t,u] + sum {v in V_G: (u,v) not in A} x[2^l+i,t,v] <= 1;

#subject to followArcsB {u in V_G, i in I, l in P[i], t in S}: x[i,t,n] +x[2^l+i,t,u] + sum {v in V_G: (u,v) not in A} x[i,t,v] <= 1;

subject to followArcsA {u in V_G, i in I, l in P[i], t in S}: sum {v in NONN[u]} x[2^l+i,t,v] <= sum {v in NNONN[u]} x[i,t,v];

subject to followArcsB {u in V_G, i in I, l in P[i], t in S}: sum {v in V_G: v not in NNONN[u]} x[2^l+i,t,v] <= sum{v in N[u]}x[i,t,v];

#subject to strength1 {u in V_G, i in I, l in P[i], t in S}: sum{v in V_G: (u,v) not in A} x[2^l+i,t,v]<= sum{w in V_G, v in V_G: (u,w) not in A and (u,v) in A} x[i,t,v];
#subject to strength1 {u in V_G, i in I, l in P[i], t in S}: sum{v in V_G: (u,v) not in A} x[2^l+i,t,v]<= sum{w in V_G, v in V_G: (u,w) not in A and (u,v) in A} x[i,t,v];

#symmetry removal
subject to symrem {i in I, j in P[i], l in P[i],t in S: j < l}: x[2^j+i,t,n] <= x[2^l+i,t,n];
