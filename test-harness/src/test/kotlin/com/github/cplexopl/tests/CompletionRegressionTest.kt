package com.github.cplexopl.tests

import com.intellij.codeInsight.CodeInsightSettings
import com.intellij.codeInsight.completion.CompletionType
import com.intellij.rt.execution.junit.FileComparisonFailure
import com.intellij.testFramework.fixtures.CodeInsightTestFixture
import com.intellij.testFramework.fixtures.IdeaTestFixtureFactory
import org.junit.After
import org.junit.Assert.fail
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import java.io.File
import com.google.gson.GsonBuilder
import org.junit.AfterClass

data class CompletionResult(
    val fileName: String,
    val relativePath: String,
    val passed: Boolean,
    val message: String?
)

data class CompletionReport(
    val totalFiles: Int,
    val passedCount: Int,
    val failedCount: Int,
    val results: List<CompletionResult>
)

@RunWith(Parameterized::class)
class CompletionRegressionTest(private val testFile: File) {

    private lateinit var myFixture: CodeInsightTestFixture
    private var oldAutoInsertSetting: Boolean = false

    @Before
    fun setUp() {
        val factory = IdeaTestFixtureFactory.getFixtureFactory()
        val fixtureBuilder = factory.createLightFixtureBuilder(null, "CompletionRegressionTest")
        myFixture = factory.createCodeInsightFixture(fixtureBuilder.fixture)
        myFixture.testDataPath = completionDir.absolutePath
        myFixture.setUp()

        // Wylaczenie auto-insert dla testow, zeby zawsze otrzymywac liste
        val settings = CodeInsightSettings.getInstance()
        oldAutoInsertSetting = settings.AUTOCOMPLETE_ON_CODE_COMPLETION
        settings.AUTOCOMPLETE_ON_CODE_COMPLETION = false
    }

    @After
    fun tearDown() {
        val settings = CodeInsightSettings.getInstance()
        settings.AUTOCOMPLETE_ON_CODE_COMPLETION = oldAutoInsertSetting
        myFixture.tearDown()
    }

    @Test
    fun testCompletion() {
        val relativePath = testFile.relativeTo(completionDir).path
        var passed = true
        var errorMessage: String? = null

        try {
            myFixture.configureByFile(relativePath)

            val lookups = myFixture.complete(CompletionType.BASIC)
            val lookupStrings = lookups?.map { it.lookupString } ?: emptyList()
            val actualText = lookupStrings.joinToString("\n")

            val expectedFile = File(testFile.parentFile, testFile.nameWithoutExtension + ".txt")

            if (!expectedFile.exists()) {
                expectedFile.writeText(actualText)
                fail("Plik snapshot zostal wygenerowany automatycznie: ${expectedFile.name}. Zweryfikuj i zatwierdz jego zawartosc.")
            }

            val expectedLines = expectedFile.readLines()
            val expectedText = expectedLines.joinToString("\n")

            val missing = mutableListOf<String>()
            val unexpected = mutableListOf<String>()

            for (line in expectedLines) {
                if (line.isBlank()) continue
                if (line.startsWith("!")) {
                    val word = line.substring(1)
                    if (lookupStrings.contains(word)) {
                        unexpected.add(word)
                    }
                } else {
                    if (!lookupStrings.contains(line)) {
                        missing.add(line)
                    }
                }
            }

            if (missing.isNotEmpty() || unexpected.isNotEmpty()) {
                val msg = buildString {
                    if (missing.isNotEmpty()) append("Brakujace slowa: $missing. ")
                    if (unexpected.isNotEmpty()) append("Nieoczekiwane slowa: $unexpected.")
                }
                throw FileComparisonFailure(msg.trim(), expectedText, actualText, expectedFile.absolutePath)
            }
        } catch (e: Throwable) {
            passed = false
            errorMessage = e.message
            throw e
        } finally {
            synchronized(resultsLock) {
                allResults.add(CompletionResult(testFile.name, relativePath, passed, errorMessage))
            }
        }
    }

    companion object {
        private val allResults = mutableListOf<CompletionResult>()
        private val resultsLock = Any()

        private val completionDir: File
            get() {
                val baseDir = System.getProperty("user.dir")
                return File(baseDir, "testData/completion")
            }

        @JvmStatic
        @AfterClass
        fun tearDownClass() {
            if (allResults.isEmpty()) return

            val passedCount = allResults.count { it.passed }
            val failedCount = allResults.count { !it.passed }

            val report = CompletionReport(
                totalFiles = allResults.size,
                passedCount = passedCount,
                failedCount = failedCount,
                results = allResults
            )

            val outputPath = "build/test-results/completion-report.json"
            val outputFile = File(outputPath)
            outputFile.parentFile?.mkdirs()

            val gson = GsonBuilder().setPrettyPrinting().create()
            outputFile.writeText(gson.toJson(report))
        }

        @JvmStatic
        @Parameterized.Parameters(name = "{0}")
        fun data(): Collection<File> {
            val dir = completionDir
            if (!dir.exists()) return emptyList()

            return dir.walkTopDown()
                .filter { it.isFile && it.extension == "mod" }
                .toList()
        }
    }
}
