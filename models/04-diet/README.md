# Diet Problem

The Diet problem is one of the earliest optimization problems studied in Linear Programming (LP). The objective is to select a combination of food items that satisfies a set of minimum and maximum daily nutritional requirements at the lowest possible financial cost.

This implementation demonstrates:
- **Object-like structured modeling** using OPL `tuple` definitions for foods and nutrients.
- **Simultaneous lower and upper bounds** ($\ge$ and $\le$) applied to nutrient intake levels.
- **Scripted execution and runtime timing** via an OPL `main` block.

## Mathematical Formulation

**Sets:**
- $F$: Set of available food items.
- $N$: Set of tracked nutritional elements.

**Parameters:**
- $c_f$: Cost per serving of food item $f \in F$.
- $q_{f}^{\min}, q_{f}^{\max}$: Minimum and maximum allowable servings for food $f$.
- $a_{f,n}$: Amount of nutrient $n \in N$ contained in one serving of food $f$.
- $r_{n}^{\min}, r_{n}^{\max}$: Minimum and maximum daily required intake for nutrient $n$.

**Decision Variables:**
- $x_f \ge 0$: Continuous quantity of servings to purchase for food item $f \in F$.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{f \in F} c_f x_f $$

**Constraints:**
$$ r_{n}^{\min} \le \sum_{f \in F} a_{f,n} x_f \le r_{n}^{\max} \quad \forall n \in N \quad \text{(Nutritional intake limits)} $$
$$ q_{f}^{\min} \le x_f \le q_{f}^{\max} \quad \forall f \in F \quad \text{(Food serving bounds)} $$
