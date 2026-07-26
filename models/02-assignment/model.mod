// Assignment Problem Model (BIP)

{string} Workers = ...;
{string} Tasks = ...;

float Cost[Workers][Tasks] = ...;

// Decision variables: 1 if worker w is assigned to task t, 0 otherwise
dvar boolean x[Workers][Tasks];

// Objective: Minimize total assignment cost
minimize
    sum(w in Workers, t in Tasks) Cost[w][t] * x[w][t];

// Constraints: One-to-one matching between Workers and Tasks
subject to {
    forall(w in Workers)
        RowSum:
            sum(t in Tasks) x[w][t] == 1;

    forall(t in Tasks)
        ColSum:
            sum(w in Workers) x[w][t] == 1;
}

execute {
    writeln("--- Assignment Problem Results ---");
    writeln("Total Optimal Cost: ", cplex.getObjValue());
    writeln("Assignments:");
    for (var w in Workers) {
        for (var t in Tasks) {
            if (x[w][t] == 1) {
                writeln(" - Worker ", w, " -> Task ", t, " (Cost: ", Cost[w][t], ")");
            }
        }
    }
}
