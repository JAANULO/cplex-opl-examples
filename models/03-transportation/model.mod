// Transportation Problem Model (IP)

{string} Origins = ...;
{string} Destinations = ...;

int Supply[Origins] = ...;
int Demand[Destinations] = ...;
float Cost[Origins][Destinations] = ...;

// Decision variables: Integer quantity shipped from origin o to destination d
dvar int Ship[Origins][Destinations];

// Objective: Minimize total transportation cost
minimize
    sum(o in Origins, d in Destinations) Cost[o][d] * Ship[o][d];

// Constraints: Meet destination demands without exceeding origin supplies
subject to {
    forall(o in Origins, d in Destinations)
        NonNegative:
            Ship[o][d] >= 0;

    forall(o in Origins)
        SupplyConstraint:
            sum(d in Destinations) Ship[o][d] <= Supply[o];

    forall(d in Destinations)
        DemandConstraint:
            sum(o in Origins) Ship[o][d] >= Demand[d];
}

execute {
    writeln("--- Transportation Problem Results ---");
    writeln("Total Transportation Cost: ", cplex.getObjValue());
    writeln("Shipping Plan:");
    for (var o in Origins) {
        for (var d in Destinations) {
            if (Ship[o][d] > 0) {
                writeln(" - From ", o, " -> To ", d, ": ", Ship[o][d], " units (Unit cost: ", Cost[o][d], ")");
            }
        }
    }
}
