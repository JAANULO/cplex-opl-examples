# 21-project-scheduling

This model implements a simple Critical Path Method (CPM) for project scheduling.
It is used to test the parsing correctness of the following elements in the CPLEX OPL plugin:
- Definition and mathematical manipulation of `dexpr` block types.
- Extreme aggregations like `max()`.
- Complex, multi-line mathematical comments (e.g. `/* ... */`) mixed with source code.
