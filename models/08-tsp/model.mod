// Traveling Salesperson Problem (TSP) Model using MTZ Subtour Elimination (MIP)

int nbCities = ...;
range Cities = 1..nbCities;

// Distance matrix between cities
float Dist[Cities][Cities] = ...;

// Decision variables: x[i][j] = 1 if travel from city i directly to city j
dvar boolean x[Cities][Cities];

// Auxiliary variables for Miller-Tucker-Zemlin (MTZ) subtour elimination
// u[i] represents the order of visited city i in the tour
dvar float+ u[Cities];

// Objective: Minimize total traveled distance
minimize
    sum(i, j in Cities: i != j) Dist[i][j] * x[i][j];

subject to {
    // Cannot travel from a city to itself
    forall(i in Cities)
        NoSelfLoop:
            x[i][i] == 0;

    // Leave every city exactly once
    forall(i in Cities)
        LeaveOnce:
            sum(j in Cities: j != i) x[i][j] == 1;

    // Enter every city exactly once
    forall(j in Cities)
        EnterOnce:
            sum(i in Cities: i != j) x[i][j] == 1;

    // Miller-Tucker-Zemlin (MTZ) subtour elimination constraints
    // For all pairs of cities (i, j) where i != 1 and j != 1 and i != j
    forall(i, j in 2..nbCities: i != j)
        SubtourElimination:
            u[i] - u[j] + nbCities * x[i][j] <= nbCities - 1;

    // Bounds for auxiliary variables u[i]
    forall(i in 2..nbCities)
        OrderBounds:
            1 <= u[i] <= nbCities - 1;
}

execute {
    writeln("--- TSP Problem Results ---");
    writeln("Total Distance: ", cplex.getObjValue());
    writeln("Tour edges:");
    for (var i in Cities) {
        for (var j in Cities) {
            if (x[i][j] == 1) {
                writeln(" - From City ", i, " to City ", j, " (Dist: ", Dist[i][j], ")");
            }
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cplex.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible TSP solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
