tasks.register<Exec>("runSolverTests") {
    group = "verification"
    description = "Uruchamia regresyjne testy lokalne solvera CPLEX za pomoca lokalnego skryptu Python"
    
    val osName = System.getProperty("os.name").lowercase()
    val pythonCmd = if (osName.contains("windows")) "python" else "python3"
    
    workingDir = rootDir
    commandLine(pythonCmd, "scripts/run_solver_regression.py")
}
