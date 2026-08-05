// Maximum Flow Model

{string} Nodes = ...;

tuple Edge {
    string u;
    string v;
}

{Edge} Edges = ...;
float Capacity[Edges] = ...;

string Source = ...;
string Sink = ...;

dvar float+ flow[Edges];

// Purposefully used dexpr to define total flow
dexpr float TotalFlow = sum(e in Edges: e.u == Source) flow[e];

maximize TotalFlow;

subject to {
    // Flow conservation
    ctFlowConservation:
        forall(i in Nodes: i != Source && i != Sink)
            sum(e in Edges: e.v == i) flow[e] == sum(e in Edges: e.u == i) flow[e];
            
    // Capacity constraints (anonymous)
    forall(e in Edges)
        flow[e] <= Capacity[e];
        
    // Everything that flows out of the source flows into the sink
    sum(e in Edges: e.u == Source) flow[e] == sum(e in Edges: e.v == Sink) flow[e];
}

execute {
    writeln("--- Maximum Flow Results ---");
    writeln("Total Flow: ", cplex.getObjValue());
    for(var e in Edges) {
        if(flow[e] > 0) {
            writeln(e.u, " -> ", e.v, " [flow: ", flow[e], "/", Capacity[e], "]");
        }
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if(cplex.solve()){
        thisOplModel.postProcess();
    } else {
        writeln("No solution!");
    }
    var end = cplex.getCplexTime();
    writeln("Time: ", end - start, " seconds");
}
