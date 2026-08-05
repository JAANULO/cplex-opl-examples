# Exam Timetabling

This model implements the Exam Timetabling problem, minimizing the number of timeslots used while avoiding conflicts (no student can attend two exams simultaneously).

## Mathematical Formulation

Let $C$ denote the set of courses, and $S$ the set of timeslots.
We define a set of conflict edges $E \subseteq C \times C$ such that $(c_1, c_2) \in E$ if both courses share students.

Decision variable:
$x_{c,s} \in \{0,1\}$, where $x_{c,s} = 1$ means that course $c$ takes place in timeslot $s$.

**Objective Function:**
Minimize the number of used assignments:
$$ \min \sum_{c \in C} \sum_{s \in S} x_{c,s} $$

**Constraints:**
1. Single assignment:
   $$ \forall c \in C, \quad \sum_{s \in S} x_{c,s} = 1 $$
2. No overlapping (conflicts):
   $$ \forall (c_1, c_2) \in E, \forall s \in S, \quad x_{c_1, s} + x_{c_2, s} \leq 1 $$

## Tested Constructs (OPL)
- Building sets based on a query (`{ <c1, c2> | ... }`) and `in` operators.
- Pre-processing `assert { ... }` blocks used for data validation.
- Constraint labels (`Assignment:`, `Collision:`).
