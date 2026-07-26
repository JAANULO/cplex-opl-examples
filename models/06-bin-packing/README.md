# Bin Packing Problem

The Bin Packing Problem is a classic combinatorial optimization problem. Given a set of items of various weights and a set of bins with a fixed capacity, assign each item to a bin such that the total weight in each bin does not exceed its capacity, and the minimum number of bins is used.

## Mathematical Formulation

**Sets:**
- $I$: Set of available items.
- $B$: Set of available bins.

**Parameters:**
- $w_i$: Weight of item $i \in I$.
- $C$: Maximum capacity of each bin $b \in B$.

**Decision Variables:**
- $y_b \in \{0, 1\}$: 1 if bin $b$ is used, 0 otherwise.
- $x_{i,b} \in \{0, 1\}$: 1 if item $i$ is assigned to bin $b$, 0 otherwise.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{b \in B} y_b $$

**Constraints:**
$$ \sum_{b \in B} x_{i,b} = 1 \quad \forall i \in I $$
$$ \sum_{i \in I} w_i x_{i,b} \le C y_b \quad \forall b \in B $$
