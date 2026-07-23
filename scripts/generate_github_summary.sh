#!/bin/bash

# Script called by GitHub Actions in the "if: always()" step
# Used to generate a nice Markdown table based on the plugin-report.json file

REPORT_FILE="test-harness/build/test-results/plugin-report.json"
SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-local_summary.md}"

if [ -f "$REPORT_FILE" ]; then
echo "### 📊 OPL Models Analysis Report" >> "$SUMMARY_FILE"
echo "| File | Errors | Warnings |" >> "$SUMMARY_FILE"
echo "|---|---|---|" >> "$SUMMARY_FILE"
# jq parses the JSON file and extracts per-file results, formatting them directly into Markdown table rows
jq -r '.results[] | "| \(.relativePath) | \(.errorCount) | \(.warningCount) |"' "$REPORT_FILE" >> "$SUMMARY_FILE"
else
echo "### ❌ Tests did not generate a report." >> "$SUMMARY_FILE"
echo "The job crashed before the tests started (e.g., 404 error when downloading the plugin from GitHub, Draft instead of Release, wrong tag, or a JVM fatal error)." >> "$SUMMARY_FILE"
fi
