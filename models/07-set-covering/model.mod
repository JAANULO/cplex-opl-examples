// Set Covering / Set Partitioning Problem Model (BIP with subset sum indexing)

int nbElements = ...;
int nbSubsets = ...;

range Elements = 1..nbElements;
range Subsets = 1..nbSubsets;

// Cost of selecting each subset
float Cost[Subsets] = ...;

// Binary incidence matrix: 1 if element e is covered by subset s, 0 otherwise
int Covers[Elements][Subsets] = ...;

// Decision variables: 1 if subset s is selected in the cover, 0 otherwise
dvar boolean Select[Subsets];

// Objective: Minimize total cost of selected subsets
minimize
    sum(s in Subsets) Cost[s] * Select[s];

// Constraints: Every element must be covered by at least one selected subset
subject to {
    forall(e in Elements)
        CoveringConstraint:
            sum(s in Subsets) Covers[e][s] * Select[s] >= 1;
}

execute {
    writeln("--- Set Covering Problem Results ---");
    writeln("Total Cover Cost: ", cplex.getObjValue());
    write("Selected Subsets: ");
    for (var s in Subsets) {
        if (Select[s] == 1) {
            write(s, " (Cost: ", Cost[s], ") ");
        }
    }
    writeln();
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible set covering solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
