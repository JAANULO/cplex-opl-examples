# Traveling Salesperson Problem (TSP)

The Traveling Salesperson Problem asks the following question: "Given a list of cities and the distances between each pair of cities, what is the shortest possible route that visits each city exactly once and returns to the origin city?"

## Mathematical Formulation (MTZ Subtour Elimination)

**Sets:**
- $V$: Set of cities $\{1, 2, \dots, n\}$.

**Parameters:**
- $c_{i,j}$: Distance from city $i$ to city $j$.

**Decision Variables:**
- $x_{i,j} \in \{0, 1\}$: 1 if the path goes directly from city $i$ to city $j$, 0 otherwise.
- $u_i \in \mathbb{R}^+$: Auxiliary continuous variables representing the order of visit for city $i$ (for $i \in \{2, \dots, n\}$).

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{i \in V} \sum_{j \in V, j \neq i} c_{i,j} x_{i,j} $$

**Constraints:**
$$ \sum_{j \in V, j \neq i} x_{i,j} = 1 \quad \forall i \in V \quad \text{(Leave each city once)} $$
$$ \sum_{i \in V, i \neq j} x_{i,j} = 1 \quad \forall j \in V \quad \text{(Enter each city once)} $$
$$ u_i - u_j + n x_{i,j} \le n - 1 \quad \forall i, j \in \{2, \dots, n\}, i \neq j \quad \text{(MTZ Subtour Elimination)} $$
