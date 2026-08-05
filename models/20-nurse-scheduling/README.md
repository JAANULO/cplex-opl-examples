# Nurse Scheduling

Model for assigning nurses to shifts broken down into time windows during the day (shifts) and over the entire week/month (days). 

## Mathematical Formulation

Let $N$ denote the staff set (nurses), $D$ the set of days in the period, and $S$ the set of shifts during the day. The hospital demand is $R_{d,s}$.

3D Variable (3D Tensor):
$x_{n,d,s} \in \{0,1\}$, determining whether nurse $n$ on day $d$ on shift $s$ is on duty.

**Objective Function:**
Minimization of potential staff shortages (so-called "demand gaps" - deviation variables $u_{d,s}$):
$$ \min \sum_{d \in D} \sum_{s \in S} u_{d,s} $$

**Constraints:**
1. Fulfilling shift demand:
   $$ \forall d \in D, s \in S \quad \sum_{n \in N} x_{n,d,s} + u_{d,s} \geq R_{d,s} $$
2. Maximum one shift per day:
   $$ \forall n \in N, d \in D \quad \sum_{s \in S} x_{n,d,s} \leq 1 $$
3. Rest time (Implication):
   $$ \forall n \in N, d < |D| \quad \left( \sum_{s \in S} x_{n,d,s} = 1 \right) \implies \left( x_{n, d+1, 1} = 0 \right) $$

## Tested Constructs (OPL)
- Testing cross-references `include "nurse_params.mod";`.
- Conditional statements `if (...)` applied directly inside the constraint definition section `subject to { ... }`.
- Logical implication operator `=>` to simplify dependencies.
- Parsing three-dimensional variable arrays `x[Nurses][Days][Shifts]`.
