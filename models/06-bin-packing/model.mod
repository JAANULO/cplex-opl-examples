// Bin Packing Problem Model (MIP with indexed variables and logical coupling)

int nbItems = ...;
int nbBins = ...;
int binCapacity = ...;

range Items = 1..nbItems;
range Bins = 1..nbBins;

int weight[Items] = ...;

// Decision variables: 1 if item i is assigned to bin j, 0 otherwise
dvar boolean Assign[Items][Bins];

// Decision variables: 1 if bin j is used, 0 otherwise
dvar boolean UseBin[Bins];

// Objective: Minimize the total number of bins used
minimize
    sum(j in Bins) UseBin[j];

// Constraints
subject to {
    // Each item must be assigned to exactly one bin
    forall(i in Items)
        OneBinPerItem:
            sum(j in Bins) Assign[i][j] == 1;

    // Total weight in each bin cannot exceed bin capacity,
    // and items can only be put in a bin if that bin is used.
    forall(j in Bins)
        CapacityAndCoupling:
            sum(i in Items) weight[i] * Assign[i][j] <= binCapacity * UseBin[j];

    // Symmetry breaking: order bins by usage (bin j+1 used only if bin j is used)
    forall(j in 1..nbBins-1)
        SymmetryBreaking:
            UseBin[j] >= UseBin[j+1];
}

execute {
    writeln("--- Bin Packing Problem Results ---");
    writeln("Total Bins Used: ", cplex.getObjValue());
    for (var j in Bins) {
        if (UseBin[j] == 1) {
            write(" - Bin ", j, " contains items: ");
            for (var i in Items) {
                if (Assign[i][j] == 1) {
                    write(i, " (w: ", weight[i], ") ");
                }
            }
            writeln();
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible bin packing solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
