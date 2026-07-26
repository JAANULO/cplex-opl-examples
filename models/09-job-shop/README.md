# Job-Shop Scheduling Problem

The Job-Shop Scheduling Problem (JSSP) is a popular scheduling optimization problem where a set of jobs must be processed on a set of machines. Each job consists of a sequence of tasks that must be processed in a predefined order on specific machines, and each machine can process at most one task at a time.

## Mathematical Formulation (Constraint Programming)

This implementation uses the **CP Optimizer** engine (`using CP;`) in OPL, which provides native scheduling primitives.

**Sets:**
- $J$: Set of jobs.
- $M$: Set of machines.
- $T$: Set of tasks per job (equal to $|M|$).

**Parameters:**
- $\mu_{j,t}$: Required machine for task $t$ of job $j$.
- $d_{j,t}$: Processing duration for task $t$ of job $j$.

**Decision Variables:**
- $I_{j,t}$: Interval variable representing the execution period of task $t$ of job $j$ with fixed size $d_{j,t}$.
- $S_m$: Sequence variable representing the ordered set of interval variables assigned to machine $m$.

**Objective Function:**
$$ \text{Minimize} \quad C_{\max} = \max_{j \in J} \text{endOf}(I_{j,|T|}) $$

**Constraints:**
1. **Precedence Constraints:** For a given job $j$, task $t+1$ must start after task $t$ terminates:
$$ \text{endBeforeStart}(I_{j,t}, I_{j,t+1}) \quad \forall j \in J, \forall t \in \{1, \dots, |T|-1\} $$
2. **Disjunctive Machine Constraints:** Intervals assigned to the same machine cannot overlap in time:
$$ \text{noOverlap}(S_m) \quad \forall m \in M $$
