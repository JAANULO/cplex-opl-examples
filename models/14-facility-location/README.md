# 14-facility-location

This model implements the classic Facility Location Problem. 
It is used to test the parsing correctness of the following elements in the CPLEX OPL plugin:
- Coexistence of binary variables (`dvar boolean`) and continuous variables (`dvar float+`).
- Logical constraints with the implication operator (`=>`).
