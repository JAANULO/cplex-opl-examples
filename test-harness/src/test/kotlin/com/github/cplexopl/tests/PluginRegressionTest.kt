package com.github.cplexopl.tests

import com.google.gson.GsonBuilder
import com.intellij.lang.annotation.HighlightSeverity
import com.intellij.testFramework.fixtures.CodeInsightTestFixture
import com.intellij.testFramework.fixtures.IdeaTestFixtureFactory
import org.junit.After
import org.junit.AfterClass
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import java.io.File
import kotlin.time.measureTimedValue

/**
 * Test result for a single .mod/.dat file.
 */
data class FileTestResult(
    val fileName: String,
    val relativePath: String,
    val errorCount: Int,
    val warningCount: Int,
    val errorMessages: List<String>,
    val highlightingTimeMs: Long
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
 */
@RunWith(Parameterized::class)
class PluginRegressionTest(private val testFile: File) {

    private lateinit var myFixture: CodeInsightTestFixture

    @Before
    fun setUp() {
        val factory = IdeaTestFixtureFactory.getFixtureFactory()
        val fixtureBuilder = factory.createLightFixtureBuilder(null, "PluginRegressionTest")
        myFixture = factory.createCodeInsightFixture(fixtureBuilder.fixture)
        myFixture.testDataPath = modelsDir.absolutePath
        myFixture.setUp()
    }

    @After
    fun tearDown() {
        myFixture.tearDown()
    }

    @Test
    fun checkDiagnostics() {
        val relativePath = testFile.relativeTo(modelsDir).path.replace("\\", "/")
        val parentDir = testFile.parentFile
        if (parentDir != null && parentDir.exists()) {
            myFixture.copyDirectoryToProject(parentDir.relativeTo(modelsDir).path.replace("\\", "/"), parentDir.relativeTo(modelsDir).path.replace("\\", "/"))
        }
        myFixture.configureByFile(relativePath)

        val (highlights, duration) = measureTimedValue {
            myFixture.doHighlighting()
        }
        val timeMs = duration.inWholeMilliseconds

        val errors = highlights.filter { it.severity == HighlightSeverity.ERROR }
        val warnings = highlights.filter { it.severity == HighlightSeverity.WARNING }

        val result = FileTestResult(
            fileName = testFile.name,
            relativePath = relativePath,
            errorCount = errors.size,
            warningCount = warnings.size,
            errorMessages = errors.mapNotNull { it.description },
            highlightingTimeMs = timeMs
        )

        synchronized(resultsLock) {
            allResults.add(result)
        }

        if (!testFile.name.contains("broken", ignoreCase = true)) {
            assertTrue(
                "Files that should be clean have errors: ${testFile.name} (${result.errorCount} błędów)",
                errors.isEmpty()
            )
        }
    }

    companion object {
        private val modelsDir: File
            get() {
                val prop = System.getProperty("testData.dir")
                if (prop != null) {
                    val f = File(prop)
                    if (f.exists()) return f
                }
                val candidates = listOf(
                    File("models"),
                    File("../models"),
                    File("../../models"),
                    File(System.getProperty("user.dir"), "models"),
                    File(System.getProperty("user.dir"), "../models")
                )
                return candidates.firstOrNull { it.exists() } ?: File("models")
            }

        private val allResults = mutableListOf<FileTestResult>()
        private val resultsLock = Any()

        @JvmStatic
        @Parameterized.Parameters(name = "{0}")
        fun data(): Collection<File> {
            val dir = modelsDir
            if (!dir.exists()) return emptyList()

            return dir.walkTopDown()
                .filter { it.isFile && (it.extension == "mod" || it.extension == "dat") }
                .toList()
        }

        @JvmStatic
        @AfterClass
        fun tearDownClass() {
            if (allResults.isEmpty()) return

            val report = RegressionReport(
                pluginVersion = System.getProperty("plugin.version.under.test") ?: "unknown",
                totalFiles = allResults.size,
                totalErrors = allResults.sumOf { it.errorCount },
                results = allResults
            )

            writeReport(report)
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
    }
}
