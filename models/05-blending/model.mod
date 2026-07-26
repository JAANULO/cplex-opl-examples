// Blending Problem Model (LP with Proportional Constraints and Main Script)

tuple RawMaterial {
    string name;
    float cost;
}

tuple Element {
    string name;
    float minProportion;
    float maxProportion;
}

{RawMaterial} RawMaterials = ...;
{Element} Elements = ...;

// Fraction (0.0 to 1.0) of element e contained in raw material r
float Composition[RawMaterials][Elements] = ...;

// Required total weight of the produced alloy / blend
float TargetWeight = ...;

// Decision variables: Continuous weight of each raw material to use
dvar float Use[RawMaterials];

// Objective: Minimize total cost of raw materials in the blend
minimize
    sum(r in RawMaterials) r.cost * Use[r];

// Constraints: Meet target weight and satisfy elemental proportion bounds
subject to {
    forall(r in RawMaterials)
        NonNegative:
            Use[r] >= 0;

    TotalWeight:
        sum(r in RawMaterials) Use[r] == TargetWeight;

    forall(e in Elements) {
        MinElement:
            sum(r in RawMaterials) Composition[r][e] * Use[r] >= e.minProportion * TargetWeight;
        MaxElement:
            sum(r in RawMaterials) Composition[r][e] * Use[r] <= e.maxProportion * TargetWeight;
    }
}

execute {
    writeln("--- Blending Problem Results ---");
    writeln("Total Blend Cost: ", cplex.getObjValue());
    writeln("Raw Material Composition:");
    for (var r in RawMaterials) {
        if (Use[r] > 0.001) {
            writeln(" - ", r.name, ": ", Use[r], " kg (Cost: ", r.cost * Use[r], ")");
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible blending solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
