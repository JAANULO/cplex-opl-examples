import org.jetbrains.intellij.platform.gradle.TestFrameworkType

plugins {
    id("org.jetbrains.kotlin.jvm") version "1.9.25"
    id("org.jetbrains.intellij.platform") version "2.11.0"
}

group = "com.github.cplexopl.tests"
version = "1.0"

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

// Downloads the built plugin from the latest GitHub Release of the cplex-opl-jetbrains repo.
// Runs once - if the file already exists in build/, it won't download again.
val fetchPlugin by tasks.registering(Exec::class) {
    val pluginVersion = providers.gradleProperty("pluginVersion").get()
    val outputFile = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip")

    outputs.file(outputFile)
    onlyIf { !outputFile.get().asFile.exists() }

    doFirst {
        outputFile.get().asFile.parentFile.mkdirs()
    }

    // NOTE: adapt the exact URL pattern to the file name
    // that your release assets actually have on GitHub.
    commandLine(
        "curl", "-L", "-f",
        "-o", outputFile.get().asFile.absolutePath,
        "https://github.com/JAANULO/cplex-opl-jetbrains/releases/download/$pluginVersion/CPLEX-Plugin-$pluginVersion.zip"
    )
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity(providers.gradleProperty("platformVersion"))
        localPlugin(file("../../cplex-opl-jetbrains/build/distributions/CPLEX-Plugin-${providers.gradleProperty("pluginVersion").get()}.zip"))
        testFramework(TestFrameworkType.Platform)
    }

    testImplementation("junit:junit:4.13.2")

    // Workaround for known bug IJPL-157292 (NoClassDefFoundError: opentest4j)
    // in some versions of IntelliJ Platform Gradle Plugin 2.x.
    // If it doesn't occur for you, you can remove it.
    testImplementation("org.opentest4j:opentest4j:1.3.0")
}

tasks.test {
    dependsOn(fetchPlugin)

    // Path to examples - the models/ folder at the root of the repo,
    // i.e., one level above the test-harness module.
    systemProperty(
        "testData.dir",
        rootProject.layout.projectDirectory.dir("models").asFile.absolutePath
    )

    // JSON report should go to this file - read by PluginRegressionTest.kt
    systemProperty(
        "report.output",
        layout.buildDirectory.file("test-results/plugin-report.json").get().asFile.absolutePath
    )

    // Pass the version of the tested plugin to the report
    val pluginVersion = providers.gradleProperty("pluginVersion").get()
    systemProperty("plugin.version.under.test", pluginVersion)

    useJUnit()
    testLogging {
        events("passed", "skipped", "failed")
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        freeCompilerArgs += listOf("-Xskip-metadata-version-check")
    }
}

kotlin {
    jvmToolchain(21) // adjust to the JDK version used in cplex-opl-jetbrains
}
