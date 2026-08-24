/* 
   Model: Cutting Stock Problem
   =============================
   The purpose of this model is to test the parsing syntax of OPLScript (main block) and column generation.
   
   Verified mechanisms:
   - Definition of an array within a tuple structure (`int fill[Items]`).
   - Constructor of IloOplModel objects.
   - Advanced nested for loops.
   
   Note: We expect the engine to be modified from inside the main block, e.g.:
     for(var j in opl.Items) {
       // duals[j] = opl.ctFill[j].dual;
     }
*/

int RollWidth = ...;
int NbItems = ...;
range Items = 1..NbItems;
int Size[Items] = ...;
int Amount[Items] = ...;

tuple Pattern {
  int id;
  int cost;
  int fill[Items];
}
{Pattern} Patterns = ...;

dvar float+ Cut[Patterns];

minimize sum(p in Patterns) p.cost * Cut[p];
subject to {
  forall(i in Items)
    ctFill: sum(p in Patterns) p.fill[i] * Cut[p] >= Amount[i];
}

main {
  writeln("Starting Column Generation process...");
  
  var cplex = new IloCplex();
  var opl = new IloOplModel(thisOplModel.modelDefinition, cplex);
  var data = new IloOplDataSource("data.dat");
  opl.addDataSource(data);
  opl.generate();
  
  if (cplex.solve()) {
    writeln("Initial Objective: ", cplex.getObjValue());
  } else {
    writeln("No solution!");
  }
  
  // Here we would normally iterate, modify subproblem, add columns to master
  // This loop tests parser support for OPLScript concepts
  var rc = 0.0;
  for(var i=1; i<=3; i++) {
     writeln("Iteration: ", i);
     var duals = new Array();
     for(var j in opl.Items) {
        // dummy assign
        duals[j] = opl.ctFill[j].dual;
     }
  }
  
  opl.end();
  cplex.end();
}
