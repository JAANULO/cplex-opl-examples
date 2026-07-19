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

// Pobiera zbudowany plugin z ostatniego GitHub Release repo cplex-opl-jetbrains.
// Uruchamiane raz - jeśli plik już jest w build/, nie pobiera ponownie.
val fetchPlugin by tasks.registering(Exec::class) {
    val pluginVersion = providers.gradleProperty("pluginVersion").get()
    val outputFile = layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip")

    outputs.file(outputFile)
    onlyIf { !outputFile.get().asFile.exists() }

    doFirst {
        outputFile.get().asFile.parentFile.mkdirs()
    }

    // UWAGA: dopasuj dokładny wzorzec URL-a do nazwy pliku,
    // jaką faktycznie mają Twoje release assets na GitHubie.
    commandLine(
        "curl", "-L", "-f",
        "-o", outputFile.get().asFile.absolutePath,
        "https://github.com/JAANULO/cplex-opl-jetbrains/releases/download/$pluginVersion/CPLEX-Plugin-$pluginVersion.zip"
    )
}

dependencies {
    intellijPlatform {
        intellijIdeaCommunity(providers.gradleProperty("platformVersion"))
        localPlugin(layout.buildDirectory.file("downloaded/cplex-opl-jetbrains.zip").get().asFile)
        testFramework(TestFrameworkType.Platform)
    }

    testImplementation("junit:junit:4.13.2")

    // Workaround na znany bug IJPL-157292 (NoClassDefFoundError: opentest4j)
    // w niektórych wersjach IntelliJ Platform Gradle Plugin 2.x.
    // Jeśli u Ciebie nie występuje, można usunąć.
    testImplementation("org.opentest4j:opentest4j:1.3.0")
}

tasks.test {
    dependsOn(fetchPlugin)

    // Ścieżka do przykładów - folder models/ w korzeniu repo,
    // czyli jeden poziom wyżej niż moduł test-harness.
    systemProperty(
        "testData.dir",
        rootProject.layout.projectDirectory.dir("models").asFile.absolutePath
    )

    // Raport JSON ma trafić do tego pliku - odczytywane w PluginRegressionTest.kt
    systemProperty(
        "report.output",
        layout.buildDirectory.file("test-results/plugin-report.json").get().asFile.absolutePath
    )

    // Przekazanie wersji testowanego pluginu do raportu
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
    jvmToolchain(21) // dopasuj do wersji JDK używanej w cplex-opl-jetbrains
}
