import java.lang.management.ManagementFactory
import java.net.URI
import java.util.Properties
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

val siblingRepo1 = file("../../cplex-opl-jetbrains")
val siblingRepo2 = file("../cplex-opl-jetbrains")
val pluginRepoDir = when {
    siblingRepo1.exists() -> siblingRepo1
    siblingRepo2.exists() -> siblingRepo2
    else -> null
}

val effectivePluginVersion = run {
    val siblingPropsFile = pluginRepoDir?.resolve("gradle.properties")
    val localRepoVersion = if (siblingPropsFile?.exists() == true) {
        val props = Properties()
        siblingPropsFile.inputStream().use { stream -> props.load(stream) }
        props.getProperty("pluginVersion")
    } else null

    localRepoVersion ?: providers.gradleProperty("pluginVersion").orNull ?: "1.4.9.7"
}

val preparePluginArtifact by tasks.registering {
    group = "verification"
    description = "Ensures the plugin .zip artifact is ready before running tests (builds locally if repo exists, otherwise downloads from GitHub)"

    doLast {
        if (project.hasProperty("pluginZipPath")) {
            val customZip = file(project.property("pluginZipPath") as String)
            if (!customZip.exists()) {
                throw GradleException("Specified pluginZipPath does not exist: $customZip")
            }
            println("Using custom plugin zip: ${customZip.absolutePath}")
            return@doLast
        }

        if (pluginRepoDir != null) {
            println("Checking and building local plugin in: ${pluginRepoDir.absolutePath} (detected version: $effectivePluginVersion)")
            val osName = System.getProperty("os.name").lowercase()
            val gradlewCmd = if (osName.contains("windows")) "gradlew.bat" else "./gradlew"
            val pb = ProcessBuilder(gradlewCmd, "buildPlugin")
            pb.directory(pluginRepoDir)
            pb.inheritIO()
            val process = pb.start()
            val exitCode = process.waitFor()
            if (exitCode != 0) {
                throw GradleException("Failed to build local plugin, exit code $exitCode")
            }
            return@doLast
        }

        val downloadedFile = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile
        if (!downloadedFile.exists() || downloadedFile.length() < 1024) {
            downloadedFile.parentFile.mkdirs()
            println("Downloading plugin release v$effectivePluginVersion from GitHub...")
            val url = URI.create("https://github.com/JAANULO/cplex-opl-jetbrains/releases/download/$effectivePluginVersion/CPLEX-Plugin-$effectivePluginVersion.zip").toURL()
            url.openStream().use { input ->
                downloadedFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            println("Downloaded plugin to: ${downloadedFile.absolutePath}")
        }
    }
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity(providers.gradleProperty("platformVersion"))
        
        val pluginFile = run {
            val customProp = findProperty("pluginZipPath") as? String
            if (!customProp.isNullOrBlank()) {
                return@run file(customProp)
            }
            if (pluginRepoDir != null) {
                val distDir = pluginRepoDir.resolve("build/distributions")
                val exactDist = distDir.resolve("CPLEX-Plugin-$effectivePluginVersion.zip")
                if (exactDist.exists()) {
                    return@run exactDist
                }
                val anyDist = distDir.listFiles()?.firstOrNull { it.isFile && it.extension == "zip" && it.name.startsWith("CPLEX-Plugin-") }
                if (anyDist != null && anyDist.exists()) {
                    return@run anyDist
                }
            }
            layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile
        }
        
        localPlugin(pluginFile)
        testFramework(TestFrameworkType.Platform)
    }

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.opentest4j:opentest4j:1.3.0")
}

tasks.test {
    dependsOn(preparePluginArtifact)

    val isCi = providers.environmentVariable("CI").isPresent
    val availableCores = Runtime.getRuntime().availableProcessors()
    val osBean = ManagementFactory.getOperatingSystemMXBean() as? com.sun.management.OperatingSystemMXBean
    @Suppress("DEPRECATION")
    val totalRamBytes = osBean?.totalMemorySize ?: osBean?.totalPhysicalMemorySize ?: 0L
    val totalRamGb = totalRamBytes / (1024 * 1024 * 1024)

    maxParallelForks = 1
    maxHeapSize = if (totalRamGb >= 16) "2g" else "1g"

    systemProperty(
        "testData.dir",
        rootProject.layout.projectDirectory.dir("models").asFile.absolutePath
    )

    systemProperty(
        "report.output",
        layout.buildDirectory.file("test-results/plugin-report.json").get().asFile.absolutePath
    )

    systemProperty(
        "completionTestData.dir",
        project.layout.projectDirectory.dir("testData/completion").asFile.absolutePath
    )

    systemProperty(
        "completionReport.output",
        layout.buildDirectory.file("test-results/completion-report.json").get().asFile.absolutePath
    )

    systemProperty("plugin.version.under.test", effectivePluginVersion)

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
    jvmToolchain(21)
}

