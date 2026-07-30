import json
import os
import sys

summary_file = os.environ.get("GITHUB_STEP_SUMMARY", "local_summary.md")
report_file = "test-harness/build/test-results/plugin-report.json"
completion_file = "test-harness/build/test-results/completion-report.json"

generated_any = False

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
        generated_any = True
    except Exception as e:
        print(f"Error generating summary: {e}", file=sys.stderr)
        sys.exit(1)

if os.path.exists(completion_file):
    try:
        with open(completion_file, "r", encoding="utf-8") as f:
            data = json.load(f)
            
        lines = []
        lines.append("\n### ⚡ Code Completion Tests")
        lines.append(f"**Total files:** {data.get('totalFiles', 0)} | **Passed:** {data.get('passedCount', 0)} | **Failed:** {data.get('failedCount', 0)}\n")
        lines.append("| File | Status | Message |")
        lines.append("|---|---|---|")
        
        for result in data.get("results", []):
            rel_path = result.get("relativePath", "")
            passed = result.get("passed", False)
            status = "✅ Passed" if passed else "❌ Failed"
            msg = result.get("message", "")
            if msg is None:
                msg = ""
            msg = msg.replace('\n', ' ').strip()
            lines.append(f"| {rel_path} | {status} | {msg} |")
            
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print("Completion summary report appended successfully.")
        generated_any = True
    except Exception as e:
        print(f"Error generating completion summary: {e}", file=sys.stderr)

if not generated_any:
    try:
        with open(summary_file, "a", encoding="utf-8") as f:
            f.write("### ❌ Tests did not generate any report.\n")
            f.write("The job crashed before the tests started (e.g., compile error, test initialization failure).\n")
        print("No report files found. Summary generated with error.")
    except Exception as e:
        print(f"Error writing fallback summary: {e}", file=sys.stderr)
        sys.exit(1)

