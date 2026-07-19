#!/bin/bash

# Skrypt wywoływany przez GitHub Actions w kroku "if: always()"
# Służy do generowania ładnej tabelki Markdown na podstawie pliku plugin-report.json

REPORT_FILE="test-harness/build/test-results/plugin-report.json"
SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-local_summary.md}"

if [ -f "$REPORT_FILE" ]; then
  echo "### 📊 Raport Analizy Modeli OPL" >> "$SUMMARY_FILE"
  echo "| Plik | Błędy | Ostrzeżenia |" >> "$SUMMARY_FILE"
  echo "|---|---|---|" >> "$SUMMARY_FILE"
  
  # jq parsuje plik JSON i wyciąga wyniki per plik formatując je bezpośrednio do wierszy tabeli Markdown
  jq -r '.results[] | "| \(.relativePath) | \(.errorCount) | \(.warningCount) |"' "$REPORT_FILE" >> "$SUMMARY_FILE"
else
  echo "### ❌ Testy nie wygenerowały raportu." >> "$SUMMARY_FILE"
  echo "Zadanie wywaliło się przed rozpoczęciem testów (np. błąd 404 przy pobieraniu wtyczki z GitHuba, szkic Draft zamiast Release, zły tag lub błąd krytyczny JVM)." >> "$SUMMARY_FILE"
fi
