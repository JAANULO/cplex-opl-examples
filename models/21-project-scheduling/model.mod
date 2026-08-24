/* 
   Model: Project Scheduling (CPM/PERT)
   ====================================
   The purpose of this model is to test the parsing capabilities of the OPL plugin.
   
   Special emphasis is placed on:
   - Variables of type `dexpr` and the maximum function `max()`.
   - Complex comment structures with mathematical notation, e.g.:
     Formula for makespan:
       M = \max_{t \in Tasks} (StartTime[t] + Duration[t])
     Precedence condition for declared pair (pre, post):
       \forall (pre, post) \in Precedences \Rightarrow StartTime[post] \ge StartTime[pre] + Duration[pre]
*/

{string} Tasks = ...;
int Duration[Tasks] = ...;

tuple Precedence {
  string pre;
  string post;
}
{Precedence} Precedences = ...;

dvar int+ StartTime[Tasks];

// Expression calculating the completion time of each task
dexpr int EndTime[t in Tasks] = StartTime[t] + Duration[t];

/* 
  Optimization criterion
  -------------------------
  Minimization of the latest completion time among all tasks.
*/
dexpr int Makespan = max(t in Tasks) EndTime[t];

minimize Makespan;

subject to {
  /*
    Iteration over all defined Precedences tuples.
    Complex `forall` block with a label assigned, to prevent compiler errors.
  */
  forall(p in Precedences)
    ctPrecedence:
      EndTime[p.pre] <= StartTime[p.post];
}
