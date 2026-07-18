rootProject.name = "cplex-opl-examples-tests"

include(":test-harness")

// Zbiór repozytoriów pluginów Gradle - dotyczy wszystkich modułów
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}
