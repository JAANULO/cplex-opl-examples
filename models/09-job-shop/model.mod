// Job-Shop Scheduling Problem Model using Constraint Programming (CP)
// Tests CP keywords: using CP, dvar interval, sequence, noOverlap, endBeforeStart, and dexpr.

using CP;

int nbJobs = ...;
int nbMachines = ...;

range Jobs = 1..nbJobs;
range Machines = 1..nbMachines;
range Tasks = 1..nbMachines;

// Machine required for task t of job j
int Machine[Jobs][Tasks] = ...;

// Duration of task t of job j
int Duration[Jobs][Tasks] = ...;

// Decision variables: interval variables for each task of each job
dvar interval TaskInterval[j in Jobs][t in Tasks] size Duration[j][t];

// Decision variables: sequence of intervals on each machine
dvar sequence MachineSequence[m in Machines] in all(j in Jobs, t in Tasks: Machine[j][t] == m) TaskInterval[j][t];

// Decision expressions (dexpr): end times and makespan
dexpr int EndTime[j in Jobs][t in Tasks] = endOf(TaskInterval[j][t]);
dexpr int Makespan = max(j in Jobs) EndTime[j][nbMachines];

// Objective: Minimize total completion time (makespan)
minimize Makespan;

subject to {
    // Precedence constraints within each job: task t+1 must start after task t ends
    forall(j in Jobs, t in 1..nbMachines-1)
        Precedence:
            endBeforeStart(TaskInterval[j][t], TaskInterval[j][t+1]);

    // No overlap constraints on each machine sequence
    forall(m in Machines)
        NoMachineOverlap:
            noOverlap(MachineSequence[m]);
}

execute {
    writeln("--- Job-Shop Scheduling (CP) Results ---");
    writeln("Optimal Makespan: ", Makespan);
    for (var j in Jobs) {
        write("Job ", j, ": ");
        for (var t in Tasks) {
            write("Task ", t, " [M", Machine[j][t], ": ", TaskInterval[j][t].start, "..", TaskInterval[j][t].end, "] ");
        }
        writeln();
    }
}

main {
    var start = cplex.getCplexTime();
    thisOplModel.generate();
    if (cp.solve()) {
        thisOplModel.postProcess();
    } else {
        writeln("No feasible Job-Shop schedule found.");
    }
    var end = cplex.getCplexTime();
    writeln("--------------------------------");
    writeln("Solve time (OPL): ", end - start, " seconds");
}
