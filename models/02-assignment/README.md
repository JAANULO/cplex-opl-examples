# Assignment Problem

The Assignment problem is a fundamental combinatorial optimization problem in the domain of Linear and Binary Integer Programming (BIP). Given a set of workers and a set of tasks, along with the cost or effort required for each worker to perform each task, the objective is to assign exactly one worker to each task and exactly one task to each worker such that the total cost is minimized.

## Mathematical Formulation

**Sets:**
- $W$: Set of available workers.
- $T$: Set of required tasks.

**Parameters:**
- $c_{w,t}$: Cost of assigning worker $w \in W$ to task $t \in T$.

**Decision Variables:**
- $x_{w,t} \in \{0, 1\}$: 1 if worker $w$ is assigned to task $t$, 0 otherwise.

**Objective Function:**
$$ \text{Minimize} \quad Z = \sum_{w \in W} \sum_{t \in T} c_{w,t} x_{w,t} $$

**Constraints:**
$$ \sum_{t \in T} x_{w,t} = 1 \quad \forall w \in W \quad \text{(Each worker is assigned exactly one task)} $$
$$ \sum_{w \in W} x_{w,t} = 1 \quad \forall t \in T \quad \text{(Each task is assigned to exactly one worker)} $$
