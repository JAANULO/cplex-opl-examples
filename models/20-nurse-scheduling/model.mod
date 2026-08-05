// ==========================================
// 20-nurse-scheduling/model.mod
// ==========================================

// Import parameters and structure from another file (IDE reference test)
include "nurse_params.mod";

// Decision variables in a 3D (3-dimensional) array
dvar boolean x[Nurses][Days][Shifts];

// Demand gap variable, for constraint relaxation
dvar int+ understaff[Days][Shifts];

// Goal: Minimize understaffing
minimize sum(d in Days, s in Shifts) understaff[d][s];

subject to {
    // 1. Demand coverage (including demand gap)
    forall(d in Days, s in Shifts)
        DemandCoverage:
        sum(n in Nurses) x[n][d][s] + understaff[d][s] >= demand[d][s];

    // 2. Mixed Logic: Conditional implications and if-else
    // A nurse cannot work more than 1 shift per day
    forall(n in Nurses, d in Days) {
        sum(s in Shifts) x[n][d][s] <= 1;

        // If working today (shift > 0), resting tomorrow morning (shift 1) (Conditional implication `=>`)
        if (d < numDays) {
            (sum(s in Shifts) x[n][d][s] == 1) => (x[n][d+1][1] == 0);
        }
    }
}
