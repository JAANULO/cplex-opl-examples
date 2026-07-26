// Capacitated Vehicle Routing Problem (CVRP) Model using 3D Indexed Variables (MIP)
// Stress-test for IDE plugin highlighting: 3D tuple/range indexing and MTZ subtour elimination across vehicles.

int nbNodes = ...;
int nbVehicles = ...;
float vehicleCapacity = ...;

range Nodes = 1..nbNodes;
range Clients = 2..nbNodes;
range Vehicles = 1..nbVehicles;

// Distance matrix between all nodes (Node 1 is the depot)
float Dist[Nodes][Nodes] = ...;

// Demand of each client node (Depot demand is 0)
float Demand[Nodes] = ...;

// Decision variables: 1 if vehicle v travels directly from node i to node j
dvar boolean x[Vehicles][Nodes][Nodes];

// Auxiliary continuous variables: cumulative load of vehicle v after visiting node i
dvar float+ u[Vehicles][Nodes];

// Objective: Minimize total travel distance across all vehicles
minimize
    sum(v in Vehicles, i, j in Nodes: i != j) Dist[i][j] * x[v][i][j];

subject to {
    // No vehicle can travel from a node to itself
    forall(v in Vehicles, i in Nodes)
        NoSelfLoop:
            x[v][i][i] == 0;

    // Every client must be visited by exactly one vehicle (entering the node)
    forall(j in Clients)
        VisitClientOnce:
            sum(v in Vehicles, i in Nodes: i != j) x[v][i][j] == 1;

    // Flow conservation: if a vehicle enters a node, it must also leave that node
    forall(v in Vehicles, h in Nodes)
        FlowConservation:
            sum(i in Nodes: i != h) x[v][i][h] == sum(j in Nodes: j != h) x[v][h][j];

    // Every vehicle must leave the depot at most once
    forall(v in Vehicles)
        LeaveDepot:
            sum(j in Clients) x[v][1][j] <= 1;

    // Vehicle capacity constraint and MTZ subtour elimination for each vehicle
    // If vehicle v travels from i to j, load increases by demand of j
    forall(v in Vehicles, i, j in Clients: i != j)
        SubtourAndCapacity:
            u[v][i] + Demand[j] - vehicleCapacity * (1 - x[v][i][j]) <= u[v][j];

    // Bounds on cumulative load for client nodes
    forall(v in Vehicles, i in Clients)
        LoadBounds:
            Demand[i] <= u[v][i] <= vehicleCapacity;
}

execute {
    writeln("--- CVRP Problem Results ---");
    writeln("Total Routing Distance: ", cplex.getObjValue());
    for (var v in Vehicles) {
        var used = false;
        for (var j in Clients) {
            if (x[v][1][j] == 1) {
                used = true;
                break;
            }
        }
        if (used) {
            writeln("Vehicle ", v, " route:");
            for (var i in Nodes) {
                for (var j in Nodes) {
                    if (x[v][i][j] == 1) {
                        writeln("  - Edge: ", i, " -> ", j, " (Dist: ", Dist[i][j], ")");
                    }
                }
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
        writeln("No feasible VRP routing solution found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
