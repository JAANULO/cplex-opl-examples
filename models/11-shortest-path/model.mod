// Shortest Path Model

{string} Nodes = ...;

tuple Edge {
    string u;
    string v;
}

{Edge} Edges = ...;
float Cost[Edges] = ...;

string Source = ...;
string Sink = ...;

// Assertions - testing validation
assert Source in Nodes;
assert Sink in Nodes;
assert card(Nodes) > 0;

dvar boolean x[Edges];

minimize sum(e in Edges) Cost[e] * x[e];

subject to {
    // Named and unnamed constraints for testing parser
    ctFlow:
        forall(i in Nodes)
            sum(e in Edges: e.v == i) x[e] - sum(e in Edges: e.u == i) x[e] == 
            (i == Sink ? 1 : (i == Source ? -1 : 0));
            
    sum(e in Edges: e.u == Sink) x[e] == 0; // sink has no outgoing edges in the path (anonymous)
}

execute {
    writeln("--- Shortest Path Results ---");
    writeln("Total Cost: ", cplex.getObjValue());
    for(var e in Edges) {
        if(x[e] == 1) {
            writeln(e.u, " -> ", e.v, " [cost: ", Cost[e], "]");
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if(cplex.solve()){
        thisOplModel.postProcess();
    } else {
        writeln("No path found!");
    }
    var end = cplex.getCplexTime();
    writeln("Time: ", end - start, " seconds");
}
