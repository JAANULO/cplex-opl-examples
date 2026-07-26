# Capacitated Vehicle Routing Problem (CVRP)

The Capacitated Vehicle Routing Problem (CVRP) is a generalization of the TSP where a fleet of vehicles with uniform carrying capacity must service a set of client nodes from a central depot. The goal is to minimize total traveled route cost without exceeding vehicle capacities.

## Mathematical Formulation (3D Indexing Stress-Test)

This model uses 3-dimensional decision variables $x_{v,i,j}$ to explicitly track routes per vehicle $v \in \{1, \dots, K\}$, serving as an advanced syntax check for OPL IDE analyzers.

**Sets:**
- $V$: Set of available vehicles $\{1, \dots, K\}$.
- $N$: Set of all nodes $\{1, 2, \dots, n\}$, where $1$ is the depot.
- $C$: Set of client nodes $N \setminus \{1\}$.

**Parameters:**
- $c_{i,j}$: Distance from node $i$ to node $j$.
- $d_i$: Demand of client node $i$ ($d_1 = 0$).
- $Q$: Carrying capacity of each vehicle.

**Decision Variables:**
- $x_{v,i,j} \in \{0, 1\}$: 1 if vehicle $v$ travels directly from node $i$ to node $j$, 0 otherwise.
- $u_{v,i} \in \mathbb{R}^+$: Cumulative load carried by vehicle $v$ after visiting node $i$.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{v \in V} \sum_{i \in N} \sum_{j \in N, j \neq i} c_{i,j} x_{v,i,j} $$

**Key Constraints:**
1. **Client Service:** Each client is entered exactly once across all vehicles:
$$ \sum_{v \in V} \sum_{i \in N, i \neq j} x_{v,i,j} = 1 \quad \forall j \in C $$
2. **Flow Conservation:** Whatever vehicle enters a node must also exit it:
$$ \sum_{i \in N, i \neq h} x_{v,i,h} = \sum_{j \in N, j \neq h} x_{v,h,j} \quad \forall v \in V, \forall h \in N $$
3. **Capacity & Subtour Elimination:**
$$ u_{v,i} + d_j - Q(1 - x_{v,i,j}) \le u_{v,j} \quad \forall v \in V, \forall i, j \in C, i \neq j $$
