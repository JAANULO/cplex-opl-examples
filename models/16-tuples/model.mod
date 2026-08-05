// Model with advanced tuples
tuple Address {
  string street;
  int number;
  string city;
}

tuple Warehouse {
  key string id;
  string name;
  Address location; // Nested tuple
  int capacity;
}

tuple Connection {
  string fromId;
  string toId;
  float distance;
}

{Warehouse} warehouses = ...;
{Connection} connections = ...;

// Array of tuples
float connectionCost[connections] = ...;

dvar float+ ship[connections];

minimize sum(c in connections) connectionCost[c] * ship[c];

subject to {
  forall(w in warehouses)
    CapacityConstraint:
      sum(c in connections : c.fromId == w.id) ship[c] <= w.capacity;
}
