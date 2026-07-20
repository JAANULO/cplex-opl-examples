package com.github.cplexopl.tests

import com.intellij.lang.annotation.HighlightSeverity
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import com.google.gson.GsonBuilder
import java.io.File

/**
* Test result for a single .mod/.dat file.
* Change the fields here if you want a different JSON structure.
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
* Plugin test harness: for each .mod file in models/
* runs the plugin engine highlighting (headless, without opening an IDE window)
* and collects the number of errors/warnings into a single JSON report.
* IMPORTANT - this is just a skeleton for now:
* * the assertion at the end is very simple (files with "broken" in the name
* should have >0 errors). Adjust this to the actual naming convention
* of your examples in models/.
* * if you want to compare against an exact, expected number of errors per file,

* add *.expected.json files next to the models and load them here for comparison.
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
        // Convention: files with "broken" in the name MUST have errors (these are
        // intentionally broken examples testing error detection).
        // All other files should NOT have errors.

        val shouldBeClean = results.filterNot { it.fileName.contains("broken", ignoreCase = true) }
        val unexpectedlyBroken = shouldBeClean.filter { it.errorCount > 0 }

        assertTrue(
            "Files that should be clean have errors: " +
                unexpectedlyBroken.joinToString { "${it.fileName} (${it.errorCount} błędów)" },
            unexpectedlyBroken.isEmpty()
        )
    }
}
