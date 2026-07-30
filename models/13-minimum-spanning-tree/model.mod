// Minimum Spanning Tree Model (MIP Formulation)

{string} Nodes = ...;

tuple Edge {
    string u;
    string v;
}

{Edge} Edges = ...;
float Cost[Edges] = ...;

// Zmienna decyzyjna: 1 jeśli krawędź jest w MST, 0 w przeciwnym razie
dvar boolean x[Edges];

minimize sum(e in Edges) Cost[e] * x[e];

subject to {
    // MST musi zawierać dokładnie |V| - 1 krawędzi (anonimowe)
    sum(e in Edges) x[e] == card(Nodes) - 1;
    
    // Eliminacja podcykli dla każdego podzbioru S o rozmiarze >= 2
    // Użyto powerset do wygenerowania wszystkich podzbiorów
    ctSubtourElimination:
        forall(S in powerset(Nodes): card(S) >= 2)
            sum(e in Edges: e.u in S && e.v in S) x[e] <= card(S) - 1;
}

execute {
    writeln("--- Minimum Spanning Tree Results ---");
    writeln("Total Cost: ", cplex.getObjValue());
    for(var e in Edges) {
        if(x[e] == 1) {
            writeln("Edge included: ", e.u, " - ", e.v, " (cost: ", Cost[e], ")");
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if(cplex.solve()){
        thisOplModel.postProcess();
    } else {
        writeln("No spanning tree possible!");
    }
    var end = cplex.getCplexTime();
    writeln("Time: ", end - start, " seconds");
}
