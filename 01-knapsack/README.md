# 0-1 Knapsack Problem

The 0-1 Knapsack problem is a classic combinatorial optimization problem. Given a set of items, each with a weight and a value, determine the items to include in a collection so that the total weight is less than or equal to a given limit and the total value is as large as possible.

## Mathematical Formulation

**Sets:**
- $I$: Set of available items.

**Parameters:**
- $v_i$: Value of item $i \in I$.
- $w_i$: Weight of item $i \in I$.
- $C$: Maximum capacity of the knapsack.

**Decision Variables:**
- $x_i \in \{0, 1\}$: 1 if item $i$ is selected, 0 otherwise.

**Objective Function:**
$$ \text{Maximize} \quad Z = \sum_{i \in I} v_i x_i $$

**Constraints:**
$$ \sum_{i \in I} w_i x_i \le C $$
