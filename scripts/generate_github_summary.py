import json
import os
import sys

report_file = "test-harness/build/test-results/plugin-report.json"
summary_file = os.environ.get("GITHUB_STEP_SUMMARY", "local_summary.md")

if os.path.exists(report_file):
    try:
        with open(report_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        lines = []
        lines.append("### 📊 OPL Models Analysis Report")
        lines.append("| File | Errors | Warnings |")
        lines.append("|---|---|---|")
        
        for result in data.get("results", []):
            rel_path = result.get("relativePath", "")
            err_count = result.get("errorCount", 0)
            warn_count = result.get("warningCount", 0)
            lines.append(f"| {rel_path} | {err_count} | {warn_count} |")
            
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print("Summary report generated successfully.")
    except Exception as e:
        print(f"Error generating summary: {e}", file=sys.stderr)
        sys.exit(1)
else:
    try:
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("### ❌ Tests did not generate a report.\n")
            f.write("The job crashed before the tests started (e.g., 404 error when downloading the plugin from GitHub, Draft instead of Release, wrong tag, or a JVM fatal error).\n")
        print("Report file not found. Summary generated with error.")
    except Exception as e:
        print(f"Error writing fallback summary: {e}", file=sys.stderr)
        sys.exit(1)
