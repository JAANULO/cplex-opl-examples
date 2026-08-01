// Model z execute block (ILOG Script)
int limit = ...;
dvar int+ x;

minimize x;

subject to {
  x >= limit;
}

// Pre-processing
execute INITIALIZE {
  writeln("Uruchamianie pre-processingu...");
  if (limit < 0) {
     limit = 0;
  }
  writeln("Limit wynosi: ", limit);
}

// Post-processing
execute DISPLAY {
  writeln("Uruchamianie post-processingu...");
  writeln("Status rozwiazania: ", cplex.status);
  if (cplex.status == 1) {
    writeln("Znaleziono optymalne rozwiazanie: x = ", x.solutionValue);
  } else {
    writeln("Brak optymalnego rozwiazania.");
  }
  
  var sumTemp = 0;
  for (var i = 1; i <= 5; i++) {
    sumTemp += i;
  }
  writeln("Suma testowa 1..5: ", sumTemp);
}

// Flow control (blok main)
main {
  var source = new OplModelSource("model.mod");
  var def = new OplModelDefinition(source);
  var cplexInstance = new IloCplex();
  var modelInstance = new OplModel(def, cplexInstance);
  
  var dataInstance = new OplDataSource("data.dat");
  modelInstance.addDataSource(dataInstance);
  modelInstance.generate();
  
  if (cplexInstance.solve()) {
    writeln("Rozwiazanie w main: obj = ", cplexInstance.getObjValue());
    modelInstance.postProcess();
  } else {
    writeln("Brak rozwiazania w main.");
  }
  
  modelInstance.end();
  dataInstance.end();
  def.end();
  cplexInstance.end();
  source.end();
}
