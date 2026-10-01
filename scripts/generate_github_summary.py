import json
import os
import sys
from datetime import datetime

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    reports_dir = os.path.join(base_dir, "reports")
    os.makedirs(reports_dir, exist_ok=True)

    now = datetime.now()
    file_timestamp = now.strftime('%Y-%m-%d_%H-%M-%S')
    display_timestamp = now.strftime('%Y-%m-%d %H:%M:%S')

    report_file = os.path.join(base_dir, "test-harness", "build", "test-results", "plugin-report.json")
    completion_file = os.path.join(base_dir, "test-harness", "build", "test-results", "completion-report.json")

    summary_env = os.environ.get("GITHUB_STEP_SUMMARY")
    local_md_file = os.path.join(reports_dir, f"models-report-{file_timestamp}.md")
    local_json_file = os.path.join(reports_dir, f"models-report-{file_timestamp}.json")

    lines = []
    unified_data = {
        "timestamp": f"{display_timestamp} (Europe/Warsaw)",
        "category": "models",
        "modelsAnalysis": None,
        "codeCompletion": None
    }

    generated_any = False

    if os.path.exists(report_file):
        try:
            with open(report_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            
            unified_data["modelsAnalysis"] = data

            lines.append("### 📊 OPL Models Analysis Report")
            lines.append(f"**Timestamp:** {display_timestamp}\n")
            lines.append("| File | Errors | Warnings |")
            lines.append("|---|---|---|")
            
            for result in data.get("results", []):
                rel_path = result.get("relativePath", "")
                err_count = result.get("errorCount", 0)
                warn_count = result.get("warningCount", 0)
                err_badge = f"❌ **{err_count}**" if err_count > 0 else f"✅ {err_count}"
                warn_badge = f"⚠️ {warn_count}" if warn_count > 0 else f"0"
                lines.append(f"| `{rel_path}` | {err_badge} | {warn_badge} |")
                
            generated_any = True
        except Exception as e:
            print(f"Error reading {report_file}: {e}", file=sys.stderr)

    if os.path.exists(completion_file):
        try:
            with open(completion_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                
            unified_data["codeCompletion"] = data

            lines.append("\n### ⚡ Code Completion Tests")
            lines.append(f"**Total files:** {data.get('totalFiles', 0)} | **Passed:** {data.get('passedCount', 0)} | **Failed:** {data.get('failedCount', 0)}\n")
            lines.append("| File | Status | Message |")
            lines.append("|---|---|---|")
            
            for result in data.get("results", []):
                rel_path = result.get("relativePath", "")
                passed = result.get("passed", False)
                status = "✅ Passed" if passed else "❌ Failed"
                msg = result.get("message", "") or ""
                msg = msg.replace('\n', ' ').strip()
                lines.append(f"| `{rel_path}` | {status} | {msg} |")
                
            generated_any = True
        except Exception as e:
            print(f"Error reading {completion_file}: {e}", file=sys.stderr)

    if not generated_any:
        lines.append("### ❌ Tests did not generate any report.\n")
        lines.append("The job crashed before the tests started (e.g., compile error, test initialization failure).\n")

    md_content = "\n".join(lines) + "\n"

    # Save timestamped MD report
    with open(local_md_file, "w", encoding="utf-8") as f:
        f.write(md_content)

    # Save timestamped JSON report if data was available
    if generated_any:
        with open(local_json_file, "w", encoding="utf-8") as f:
            json.dump(unified_data, f, indent=2)

    # Write to GitHub Actions step summary if available
    if summary_env:
        try:
            with open(summary_env, "a", encoding="utf-8") as f:
                f.write(md_content)
        except Exception as e:
            print(f"Warning: Could not write to GITHUB_STEP_SUMMARY: {e}", file=sys.stderr)

    print(f"Summary report generated successfully at: {local_md_file}")

if __name__ == "__main__":
    main()
