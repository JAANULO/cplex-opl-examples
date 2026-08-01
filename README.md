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

> **Note:** Models starting with the declaration `using CP;` (such as Job-Shop Scheduling) use the **CP Optimizer** constraint programming engine instead of the standard CPLEX MIP/LP solver. The `oplrun` command handles this switch automatically.

## Models Status

| Model Name | Type | Difficulty | Directory |
|---|---|---|---|
| 0-1 Knapsack Problem | MIP | Easy | `models/01-knapsack` |
| Assignment Problem | BIP | Easy | `models/02-assignment` |
| Transportation Problem | IP | Easy | `models/03-transportation` |
| Diet Problem | LP | Easy | `models/04-diet` |
| Blending Problem | LP | Medium | `models/05-blending` |
| Bin Packing Problem | MIP | Medium/Hard | `models/06-bin-packing` |
| Set Covering Problem | BIP | Medium | `models/07-set-covering` |
| Traveling Salesperson (TSP) | MIP | Hard | `models/08-tsp` |
| Job-Shop Scheduling Problem | CP | Hard | `models/09-job-shop` |
| Vehicle Routing Problem (CVRP) | MIP | Hard | `models/10-vrp` |
| Facility Location Problem | MIP | Medium | `models/14-facility-location` |
| Execute & Main Block Test | Scripting | Medium | `models/15-execute-block` |
| Advanced Tuples Test | MIP | Medium | `models/16-tuples` |
