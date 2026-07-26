// Diet Problem Model (LP with Structured Tuples and Main Script)

tuple Food {
    string name;
    float cost;
    float minQty;
    float maxQty;
}

tuple Nutrient {
    string name;
    float minIntake;
    float maxIntake;
}

{Food} Foods = ...;
{Nutrient} Nutrients = ...;

// Nutrient content per unit of food: indexed by Food and Nutrient tuples
float Amount[Foods][Nutrients] = ...;

// Decision variables: Continuous quantity of each food to purchase
dvar float Buy[Foods];

// Objective: Minimize total cost of food
minimize
    sum(f in Foods) f.cost * Buy[f];

// Constraints: Nutritional norms and individual food serving limits
subject to {
    forall(f in Foods)
        NonNegative:
            Buy[f] >= 0;

    forall(f in Foods) {
        MinFood: Buy[f] >= f.minQty;
        MaxFood: Buy[f] <= f.maxQty;
    }

    forall(n in Nutrients) {
        MinNutrient: sum(f in Foods) Amount[f][n] * Buy[f] >= n.minIntake;
        MaxNutrient: sum(f in Foods) Amount[f][n] * Buy[f] <= n.maxIntake;
    }
}

execute {
    writeln("--- Diet Problem Results ---");
    writeln("Minimal Daily Diet Cost: ", cplex.getObjValue());
    writeln("Selected Foods:");
    for (var f in Foods) {
        if (Buy[f] > 0.001) {
            writeln(" - ", f.name, ": ", Buy[f], " units (Cost: ", f.cost * Buy[f], ")");
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible diet solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
