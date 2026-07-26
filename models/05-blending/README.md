# Blending Problem

The Blending problem is a standard Linear Programming (LP) application widely used in chemical, metallurgical, and oil refining industries. The objective is to determine the optimal mixture of raw materials to produce a composite alloy or chemical product of a specified weight while maintaining strict elemental composition ratios at the lowest total production cost.

This model features:
- **Continuous decision variables** (`dvar float+`) representing exact material weights.
- **Proportional constraints** ensuring element concentrations stay within defined percentage limits.
- **Structured OPL tuples** for material properties and element specifications.
- **Scripted lifecycle execution** and timing measurement via an OPL `main` block.

## Mathematical Formulation

**Sets:**
- $R$: Set of raw materials available for blending.
- $E$: Set of chemical elements or components tracked in the blend.

**Parameters:**
- $c_r$: Unit cost per kilogram of raw material $r \in R$.
- $p_{r,e}$: Proportion (fraction) of element $e \in E$ contained in raw material $r$.
- $m_{e}^{\min}, m_{e}^{\max}$: Minimum and maximum required proportion of element $e$ in the final product.
- $W$: Total required weight of the target blend.

**Decision Variables:**
- $x_r \ge 0$: Weight (in kilograms) of raw material $r$ to include in the blend.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{r \in R} c_r x_r $$

**Constraints:**
$$ \sum_{r \in R} x_r = W \quad \text{(Total target weight)} $$
$$ m_{e}^{\min} W \le \sum_{r \in R} p_{r,e} x_r \le m_{e}^{\max} W \quad \forall e \in E \quad \text{(Element proportion limits)} $$
