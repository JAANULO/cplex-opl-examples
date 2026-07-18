# CPLEX OPL Examples & Portfolio

A collection of optimization models written in IBM ILOG CPLEX Optimization Programming Language (OPL). 
This repository serves as a learning portfolio and a source of test cases for the [CPLEX OPL JetBrains Plugin](https://github.com/JAANULO/CPLEX-Plugin).

## Struktura repo

To repo pełni dwie role:

- **`models/`** — przykładowe modele OPL (`.mod`/`.dat`) do przeglądania
  i nauki. To jest ta część, po którą warto tu wejść, jeśli szukasz
  przykładów kodu OPL.
- **`test-harness/`** — automatyczny "testownik" pluginu
  [cplex-opl-jetbrains](https://github.com/JAANULO/cplex-opl-jetbrains):
  pobiera ostatnie wydanie pluginu, odpala go headless (bez okna IDE) na
  wszystkich plikach z `models/` i generuje raport JSON z liczbą błędów/
  warningów wykrytych przez plugin. Zobacz `PLAN.md` po szczegóły.

Testy odpalają się automatycznie po każdym release'ie pluginu (przez
`repository_dispatch`) albo ręcznie: zakładka *Actions* → *Plugin regression
tests* → *Run workflow*.

## Prerequisites

To run these models, you need a local installation of **IBM ILOG CPLEX Studio**.

```bash
oplrun model.mod data.dat
```

## Models Status

| Model Name | Type | Difficulty | Status |
|---|---|---|---|
| Knapsack Problem | MIP | Easy | ✅ |
| Assignment Problem | BIP | Easy | 🚧 |
| Traveling Salesperson (TSP) | MIP | Medium | 🚧 |
