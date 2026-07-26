# Transportation Problem

The Transportation problem is a classic supply chain optimization model formulated as an Integer Programming (IP) or Linear Programming problem. The goal is to determine the most cost-effective shipping distribution plan from several origins (warehouses or factories) with given supply capacities to several destinations (retail stores or customers) with specific demand requirements.

## Mathematical Formulation

**Sets:**
- $O$: Set of origins (warehouses/supply centers).
- $D$: Set of destinations (stores/customers).

**Parameters:**
- $S_o$: Supply available at origin $o \in O$.
- $D_d$: Demand required at destination $d \in D$.
- $c_{o,d}$: Unit transportation cost from origin $o$ to destination $d$.

**Decision Variables:**
- $x_{o,d} \in \mathbb{Z}^+$: Non-negative integer quantity shipped from origin $o$ to destination $d$.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{o \in O} \sum_{d \in D} c_{o,d} x_{o,d} $$

**Constraints:**
$$ \sum_{d \in D} x_{o,d} \le S_o \quad \forall o \in O \quad \text{(Supply capacity limit)} $$
$$ \sum_{o \in O} x_{o,d} \ge D_d \quad \forall d \in D \quad \text{(Demand requirement satisfaction)} $$
