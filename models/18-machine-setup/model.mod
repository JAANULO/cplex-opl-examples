using CP;

// ==========================================
// 18-machine-setup/model.mod
// ==========================================

int numTasks = 3;
range Tasks = 1..numTasks;

int duration[Tasks] = ...;
int powerRequirement[Tasks] = ...;

tuple Transition {
    int task1;
    int task2;
    int setupTime;
}
{Transition} setups = ...;

tuple State {
    int id;
    int stateValue;
}
{State} states = ...;

// Power limit for concurrent tasks
int maxPower = 100;

// Task execution time - intervals
dvar interval taskInt[t in Tasks] size duration[t];

// Machine sequence for intervals
dvar sequence machineSeq in all(t in Tasks) taskInt[t];

// Accumulated function of constrained resources (in this case power consumption)
cumulFunction powerUsage = sum(t in Tasks) pulse(taskInt[t], powerRequirement[t]);

// State function for handling special tool changes
stateFunction toolState;

minimize max(t in Tasks) endOf(taskInt[t]);

subject to {
    // 1. Constraints on peak power
    PowerConstraint:
    powerUsage <= maxPower;

    // 2. No overlap with setup times on the machine
    SetupConstraint:
    noOverlap(machineSeq, setups);

    // 3. Constraints for state function (not fully used, just syntax test)
    forall(s in states)
        alwaysEqual(toolState, 0, 10, s.stateValue);
}

// OPLScript JS block
execute {
    writeln("CP scheduling completed.");
    var totalPower = 0;
    for(var t in Tasks) {
        // Testing OPLScript IloOplIntervalVar object
        writeln("Task ", t, " Start: ", taskInt[t].start, " End: ", taskInt[t].end);
    }
}
