// Facility Location Problem
int nbWarehouses = ...;
int nbStores = ...;

range Warehouses = 1..nbWarehouses;
range Stores = 1..nbStores;

float capacity[Warehouses] = ...;
float fixedCost[Warehouses] = ...;
float demand[Stores] = ...;
float transitionCost[Stores][Warehouses] = ...;

// Zmienne binarne i ciągłe razem
dvar boolean open[Warehouses];
dvar float+ ship[Stores][Warehouses];

minimize
  sum(w in Warehouses) fixedCost[w] * open[w] +
  sum(s in Stores, w in Warehouses) transitionCost[s][w] * ship[s][w];

subject to {
  // Zaspokojenie popytu
  forall(s in Stores)
    DemandConstraint:
      sum(w in Warehouses) ship[s][w] == demand[s];

  // Pojemność magazynu
  forall(w in Warehouses)
    CapacityConstraint:
      sum(s in Stores) ship[s][w] <= capacity[w] * open[w];

  // Ograniczenie logiczne (=>)
  forall(s in Stores, w in Warehouses)
    LogicConstraint:
      (ship[s][w] > 0) => (open[w] == 1);
}
