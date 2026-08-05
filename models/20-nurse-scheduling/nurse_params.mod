// nurse_params.mod
// Declaration module, imported into the main model

int numNurses = ...;
int numDays = ...;
int numShifts = ...;

range Nurses = 1..numNurses;
range Days = 1..numDays;
range Shifts = 1..numShifts;

// Minimum number of nurses needed for a given shift and day
int demand[Days][Shifts] = ...;

// Declaration of maximum consecutive shifts
int maxConsecutiveShifts = 3;
