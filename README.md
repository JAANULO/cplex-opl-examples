# CPLEX OPL Examples & Portfolio

A collection of optimization models written in IBM ILOG CPLEX Optimization Programming Language (OPL). 
This repository serves as a learning portfolio and a source of test cases for the [CPLEX OPL JetBrains Plugin](https://github.com/JAANULO/CPLEX-Plugin).

## Repo structure

This repo serves two purposes:

- **`models/`** — sample OPL models (`.mod`/`.dat`) for review and learning. This is the main part worth checking out if you are looking for OPL code examples.
- **`test-harness/`** — an automated test harness for the [cplex-opl-jetbrains](https://github.com/JAANULO/cplex-opl-jetbrains) plugin: it downloads the latest plugin release, runs it headless (without an IDE window) on all files in `models/`, and generates a JSON report with the number of errors/warnings detected by the plugin. See `PLAN.md` for details.

Tests run automatically after each plugin release (via `repository_dispatch`) or manually: *Actions* tab → *Plugin regression tests* → *Run workflow*.

## Prerequisites

To run these models, you need a local installation of **IBM ILOG CPLEX Studio**.

```bash
oplrun model.mod data.dat
```

## Models Status

| Model Name | Type | Difficulty | 
|---|---|---|---|
| Knapsack Problem | MIP | Easy |
| Assignment Problem | BIP | Easy |
| Traveling Salesperson (TSP) | MIP | Medium |
