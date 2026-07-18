package com.github.cplexopl.tests

import com.intellij.lang.annotation.HighlightSeverity
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import com.google.gson.GsonBuilder
import java.io.File

/**
 * Wynik testu dla jednego pliku .mod/.dat.
 * Zmień pola tutaj jeśli chcesz inny kształt JSON-a.
 */
data class FileTestResult(
    val fileName: String,
    val relativePath: String,
    val errorCount: Int,
    val warningCount: Int,
    val errorMessages: List<String>
)

data class RegressionReport(
    val pluginVersion: String,
    val totalFiles: Int,
    val totalErrors: Int,
    val results: List<FileTestResult>
)

/**
 * Testowa "sprawdzaczka" pluginu: dla każdego pliku .mod w models/
 * odpala highlighting silnika pluginu (headless, bez otwierania okna IDE)
 * i zbiera liczbę błędów/warningów do jednego raportu JSON.
 *
 * WAŻNE - to na razie tylko szkielet:
 *  - assercja na końcu jest bardzo prosta (pliki z "broken" w nazwie
 *    powinny mieć >0 błędów). Dostosuj to do realnej konwencji nazw
 *    Twoich przykładów w models/.
 *  - jeśli chcesz porównywać z dokładną, oczekiwaną liczbą błędów per plik,
 *    dodaj pliki *.expected.json obok modeli i wczytaj je tutaj do porównania.
 */
class PluginRegressionTest : BasePlatformTestCase() {

    private val modelsDir: File
        get() = File(System.getProperty("testData.dir") ?: "models")

    override fun getTestDataPath(): String = modelsDir.absolutePath

    fun `test all mod files produce expected diagnostics`() {
        val modFiles = modelsDir.walkTopDown()
            .filter { it.isFile && it.extension == "mod" }
            .toList()

        check(modFiles.isNotEmpty()) {
            "Nie znaleziono żadnych plików .mod w ${modelsDir.absolutePath} - " +
                "sprawdź systemProperty(testData.dir) w build.gradle.kts"
        }

        val results = modFiles.map { file -> analyzeFile(file) }

        val report = RegressionReport(
            pluginVersion = System.getProperty("plugin.version.under.test") ?: "unknown",
            totalFiles = results.size,
            totalErrors = results.sumOf { it.errorCount },
            results = results
        )

        writeReport(report)
        assertNoUnexpectedErrors(results)
    }

    private fun analyzeFile(file: File): FileTestResult {
        val relativePath = file.relativeTo(modelsDir).path
        myFixture.configureByFile(relativePath)

        val highlights = myFixture.doHighlighting()
        val errors = highlights.filter { it.severity == HighlightSeverity.ERROR }
        val warnings = highlights.filter { it.severity == HighlightSeverity.WARNING }

        return FileTestResult(
            fileName = file.name,
            relativePath = relativePath,
            errorCount = errors.size,
            warningCount = warnings.size,
            errorMessages = errors.mapNotNull { it.description }
        )
    }

    private fun writeReport(report: RegressionReport) {
        val outputPath = System.getProperty("report.output")
            ?: "build/test-results/plugin-report.json"
        val outputFile = File(outputPath)
        outputFile.parentFile?.mkdirs()

        val gson = GsonBuilder().setPrettyPrinting().create()
        outputFile.writeText(gson.toJson(report))

        println("Raport zapisany do: ${outputFile.absolutePath}")
    }

    private fun assertNoUnexpectedErrors(results: List<FileTestResult>) {
        // Konwencja: pliki z "broken" w nazwie MAJĄ mieć błędy (to są
        // celowo zepsute przykłady testujące wykrywanie błędów).
        // Wszystkie inne pliki NIE powinny mieć błędów.
        val shouldBeClean = results.filterNot { it.fileName.contains("broken", ignoreCase = true) }
        val unexpectedlyBroken = shouldBeClean.filter { it.errorCount > 0 }

        assertTrue(
            "Pliki, które powinny być poprawne, mają błędy: " +
                unexpectedlyBroken.joinToString { "${it.fileName} (${it.errorCount} błędów)" },
            unexpectedlyBroken.isEmpty()
        )
    }
}
