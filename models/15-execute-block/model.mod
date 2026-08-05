// Model with execute block (ILOG Script)
int limit = ...;
dvar int+ x;

minimize x;

subject to {
  x >= limit;
}

// Pre-processing
execute INITIALIZE {
  writeln("Running pre-processing...");
  if (limit < 0) {
     limit = 0;
  }
  writeln("Limit is: ", limit);
}

// Post-processing
execute DISPLAY {
  writeln("Running post-processing...");
  writeln("Solution status: ", cplex.status);
  if (cplex.status == 1) {
    writeln("Optimal solution found: x = ", x.solutionValue);
  } else {
    writeln("No optimal solution.");
  }
  
  var sumTemp = 0;
  for (var i = 1; i <= 5; i++) {
    sumTemp += i;
  }
  writeln("Test sum 1..5: ", sumTemp);
}

// Flow control (main block)
main {
  var source = new OplModelSource("model.mod");
  var def = new OplModelDefinition(source);
  var cplexInstance = new IloCplex();
  var modelInstance = new OplModel(def, cplexInstance);
  
  var dataInstance = new OplDataSource("data.dat");
  modelInstance.addDataSource(dataInstance);
  modelInstance.generate();
  
  if (cplexInstance.solve()) {
    writeln("Solution in main: obj = ", cplexInstance.getObjValue());
    modelInstance.postProcess();
  } else {
    writeln("No solution in main.");
  }
  
  modelInstance.end();
  dataInstance.end();
  def.end();
  cplexInstance.end();
  source.end();
}
