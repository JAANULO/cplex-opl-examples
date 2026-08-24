# 22-cutting-stock

This model implements the Master Problem of the classic Cutting Stock algorithm.
It is primarily used to test the parser support for OPLScript concepts in JetBrains.

Specifically, it verifies:
- `main { ... }` block structure parsing.
- Dynamic instantiation of ILOG interfaces (e.g., `new IloCplex()`, `new IloOplModel()`).
- Data extraction from model entities during Column Generation (e.g. `.dual` calls).
- Array properties inside tuple definitions (`int fill[Items]`).
