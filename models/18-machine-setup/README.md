# Machine Setup (Constraint Programming)

Machine scheduling model tested in the **CP Optimizer** engine.

## Mathematical Formulation (CP)

Let $T$ denote the set of tasks, and each $t \in T$ is characterized by size (time) $D_t$ and energy usage $P_t$.
We define interval variables $x_t$.

**Objective Function (Makespan):**
$$ \min \max_{t \in T} \text{endOf}(x_t) $$

**Cumulative Function (CumulFunction):**
Calculation of renewable resource usage at each time point $\tau$:
$$ \text{PowerUsage}(\tau) = \sum_{t \in T} \text{pulse}(x_t, P_t)(\tau) $$

**Constraints:**
1. No Overlap with a strict transition matrix $S_{i,j}$:
   $$ \text{noOverlap}(\text{sequence}(x_t), S) $$
2. Maintaining power usage at level $M$:
   $$ \text{PowerUsage}(\tau) \leq M, \quad \forall \tau $$

## Tested Constructs (OPL)
- `using CP;` - CPO engine activation.
- Interval and sequence declarations: `dvar interval`, `dvar sequence`.
- Accumulation functions: `cumulFunction`, `pulse` function.
- CP transition matrix.
- `execute { ... }` using task attributes (`taskInt[t].start`) through OPLScript.
- Configuration in `settings.ops` format.
