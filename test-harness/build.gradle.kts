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

// fetchPlugin task removed, logic moved to dependencies block

dependencies {
    intellijPlatform {
        intellijIdeaCommunity(providers.gradleProperty("platformVersion"))
        
        val pluginVer = providers.gradleProperty("pluginVersion").get()
        val pluginFile = run {
            val localDist = file("../../cplex-opl-jetbrains/build/distributions/CPLEX-Plugin-$pluginVer.zip")
            if (localDist.exists()) {
                println("Using locally built plugin at: $localDist")
                return@run localDist
            }

            val downloadedFile = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile
            if (!downloadedFile.exists() || downloadedFile.length() < 1024) {
                downloadedFile.parentFile.mkdirs()
                println("Downloading plugin from GitHub ($pluginVer)...")
                try {
                    val url = URI.create("https://github.com/JAANULO/cplex-opl-jetbrains/releases/download/$pluginVer/CPLEX-Plugin-$pluginVer.zip").toURL()
                    url.openStream().use { input ->
                        downloadedFile.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    }
                } catch (e: java.io.FileNotFoundException) {
                    val pluginProjectDir = file("../../cplex-opl-jetbrains")
                    if (pluginProjectDir.exists()) {
                        println("Release not found. Building plugin locally...")
                        val osName = System.getProperty("os.name").lowercase()
                        val gradlewCmd = if (osName.contains("windows")) "gradlew.bat" else "./gradlew"
                        val pb = ProcessBuilder(gradlewCmd, "buildPlugin")
                        pb.directory(pluginProjectDir)
                        pb.inheritIO()
                        val process = pb.start()
                        val exitCode = process.waitFor()
                        if (exitCode != 0) {
                            throw GradleException("Failed to run buildPlugin, exit code $exitCode")
                        }
                        if (localDist.exists()) {
                            return@run localDist
                        }
                    }
                    throw GradleException("Plugin release $pluginVer not found on GitHub, and local source not available.", e)
                }
            }
            downloadedFile
        }
        
        localPlugin(pluginFile)
        testFramework(TestFrameworkType.Platform)
    }

    testImplementation("junit:junit:4.13.2")

    // Workaround for known bug IJPL-157292 (NoClassDefFoundError: opentest4j)
    // in some versions of IntelliJ Platform Gradle Plugin 2.x.
    // If it doesn't occur for you, you can remove it.
    testImplementation("org.opentest4j:opentest4j:1.3.0")
}

tasks.test {
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
