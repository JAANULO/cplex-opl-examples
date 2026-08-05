# 15-execute-block

This model is used to test the parsing correctness of the imperative part of the OPL language (IBM ILOG Script).
The main goal is to verify if the parser correctly distinguishes declarative constructs from scripting ones:
- `execute` blocks (pre-processing and post-processing).
- `for` loops and local variables `var` inside the script.
- Advanced flow control in the `main` block using the `OplModelSource`, `OplModelDefinition`, `OplDataSource`, and `OplModel` classes.
