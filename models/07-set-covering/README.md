# Set Covering Problem

The Set Covering Problem (SCP) is a classical question in combinatorics and computer science. Given a universe of elements and a family of subsets of the universe, each with an associated cost, find a minimum-cost sub-collection of subsets whose union equals the universe.

## Mathematical Formulation

**Sets:**
- $E$: Set of universe elements.
- $S$: Set of available subsets.

**Parameters:**
- $c_s$: Cost of subset $s \in S$.
- $a_{e,s} \in \{0, 1\}$: 1 if element $e$ is contained in subset $s$, 0 otherwise.

**Decision Variables:**
- $x_s \in \{0, 1\}$: 1 if subset $s$ is selected, 0 otherwise.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{s \in S} c_s x_s $$

**Constraints:**
$$ \sum_{s \in S} a_{e,s} x_s \ge 1 \quad \forall e \in E $$
