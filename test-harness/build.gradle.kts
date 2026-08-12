import java.lang.management.ManagementFactory
import java.net.URI
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
val fetchPlugin by tasks.registering {
    val pluginVer = providers.gradleProperty("pluginVersion").get()
    val localDist = file("../../cplex-opl-jetbrains/build/distributions/CPLEX-Plugin-$pluginVer.zip")
    val outputFile = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile

    outputs.file(outputFile)

    doLast {
        outputFile.parentFile.mkdirs()
        if (localDist.exists()) {
            localDist.copyTo(outputFile, overwrite = true)
        } else if (!outputFile.exists() || outputFile.length() < 1000) {
            val url = URI.create("https://github.com/JAANULO/cplex-opl-jetbrains/releases/download/$pluginVer/CPLEX-Plugin-$pluginVer.zip").toURL()
            url.openStream().use { input ->
                outputFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }
    }
}

tasks.matching { it.name.startsWith("initializeIntellijPlatform") }.configureEach {
    dependsOn(fetchPlugin)
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity(providers.gradleProperty("platformVersion"))
        val pluginVer = providers.gradleProperty("pluginVersion").get()
        val localDist = file("../../cplex-opl-jetbrains/build/distributions/CPLEX-Plugin-$pluginVer.zip")
        val downloadedDist = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile

        if (localDist.exists()) {
            localPlugin(localDist)
        } else {
            if (!downloadedDist.exists()) {
                downloadedDist.parentFile.mkdirs()
                downloadedDist.createNewFile()
            }
            localPlugin(downloadedDist)
        }
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

    val isCi = providers.environmentVariable("CI").isPresent
    val availableCores = Runtime.getRuntime().availableProcessors()
    val osBean = ManagementFactory.getOperatingSystemMXBean() as? com.sun.management.OperatingSystemMXBean
    @Suppress("DEPRECATION")
    val totalRamBytes = osBean?.totalMemorySize ?: osBean?.totalPhysicalMemorySize ?: 0L
    val totalRamGb = totalRamBytes / (1024 * 1024 * 1024)

    // Użycie 1 forka zapobiega konfliktom dostępu do bazy VFS (AccessDeniedException na Windowsie) w idea-sandbox
    maxParallelForks = 1
    maxHeapSize = if (totalRamGb >= 16) "2g" else "1g"

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
