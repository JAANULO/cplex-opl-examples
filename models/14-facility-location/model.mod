// Facility Location Problem
int nbWarehouses = ...;
int nbStores = ...;

range Warehouses = 1..nbWarehouses;
range Stores = 1..nbStores;

float capacity[Warehouses] = ...;
float fixedCost[Warehouses] = ...;
float demand[Stores] = ...;
float transitionCost[Stores][Warehouses] = ...;

// Binary and continuous variables together
dvar boolean open[Warehouses];
dvar float+ ship[Stores][Warehouses];

minimize
  sum(w in Warehouses) fixedCost[w] * open[w] +
  sum(s in Stores, w in Warehouses) transitionCost[s][w] * ship[s][w];

subject to {
  // Satisfy demand
  forall(s in Stores)
    DemandConstraint:
      sum(w in Warehouses) ship[s][w] == demand[s];

  // Warehouse capacity
  forall(w in Warehouses)
    CapacityConstraint:
      sum(s in Stores) ship[s][w] <= capacity[w] * open[w];

  // Logical constraint (=>)
  forall(s in Stores, w in Warehouses)
    LogicConstraint:
      (ship[s][w] > 0) => (open[w] == 1);
}
