// 0-1 Knapsack Problem Model

tuple Item {
    int weight;
    int value;
}

int maxCapacity = ...;
{Item} items = ...;

dvar boolean take[items];

maximize sum(i in items) i.value * take[i];

subject to {
    CapacityConstraint:
        sum(i in items) i.weight * take[i] <= maxCapacity;
}

execute {
    writeln("--- Knapsack Problem Results ---");
    writeln("Total Value: ", cplex.getObjValue());
    writeln("Items taken:");
    for (var i in items) {
        if (take[i] == 1) {
            writeln(" - Weight: " + i.weight + ", Value: " + i.value);
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
