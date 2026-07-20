rootProject.name = "cplex-opl-examples-tests"

include(":test-harness")

// Set of Gradle plugin repositories - applies to all modules
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}
