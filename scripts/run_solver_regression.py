import os
import sys
import subprocess
import concurrent.futures
import time
import tempfile
import argparse
import re
from datetime import datetime

# ANSI escape codes for colors
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    RESET = '\033[0m'

def print_color(text, color):
    print(f"{color}{text}{Colors.RESET}")

def sanity_check():
    try:
        subprocess.run(["oplrun", "-h"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except FileNotFoundError:
        print_color("Error: Command 'oplrun' not found in PATH. Ensure CPLEX Studio is installed.", Colors.RED)
        sys.exit(1)
    except subprocess.CalledProcessError:
        pass # -h might return non-zero in some versions, but the binary exists

def create_temp_ops():
    # Tworzymy tymczasowy plik .ops wymuszający użycie 1 wątku
    ops_content = """<?xml version="1.0" encoding="utf-8"?>
<settings>
  <category name="cplex">
    <setting name="threads" value="1"/>
  </category>
</settings>
"""
    temp_ops = tempfile.NamedTemporaryFile(mode='w', suffix='.ops', delete=False)
    temp_ops.write(ops_content)
    temp_ops.close()
    return temp_ops.name

def find_files(model_dir):
    mod_files = []
    dat_files = []
    ops_files = []
    
    for f in os.listdir(model_dir):
        if f.endswith('.mod'):
            mod_files.append(f)
        elif f.endswith('.dat'):
            dat_files.append(f)
        elif f.endswith('.ops'):
            ops_files.append(f)
            
    # Szukamy mod
    target_mod = None
    if 'model.mod' in mod_files:
        target_mod = 'model.mod'
    elif len(mod_files) == 1:
        target_mod = mod_files[0]
    elif len(mod_files) > 1:
        raise ValueError("Multiple .mod files found, but none is named model.mod")
    elif len(mod_files) == 0:
        raise ValueError("No .mod files found in directory")
        
    target_dat = dat_files[0] if dat_files else None
    target_ops = ops_files[0] if ops_files else None
    
    return target_mod, target_dat, target_ops

def run_model(model_dir, temp_ops_path, timeout, verbose):
    model_name = os.path.basename(model_dir)
    
    # Sprawdzenie pomijania
    if os.path.exists(os.path.join(model_dir, ".skip")):
        return {"name": model_name, "status": "SKIPPED", "time": 0.0, "warnings": 0, "error": None}
        
    try:
        target_mod, target_dat, target_ops = find_files(model_dir)
    except ValueError as e:
        return {"name": model_name, "status": "ERROR", "time": 0.0, "warnings": 0, "error": str(e)}

    # Przygotowanie komendy
    cmd = ["oplrun"]
    
    # Plik .mod musi byc pierwszym argumentem pozycyjnym
    cmd.append(target_mod)
    
    if target_dat:
        cmd.append(target_dat)
        
    start_time = time.time()
    log_path = os.path.join(model_dir, "cplex.log")
    
    cmd_str = " ".join(cmd)
    
    # Log header
    header = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Executed command:\n{cmd_str}\n{'-'*60}\n"
    
    try:
        result = subprocess.run(cmd, cwd=model_dir, capture_output=True, text=True, timeout=timeout)
        elapsed = time.time() - start_time
        
        output = result.stdout + result.stderr
        
        with open(log_path, 'w', encoding='utf-8') as f:
            f.write(header + output)
            
        if verbose:
            print(f"\n--- LOGS FROM MODEL {model_name} ---\n{output}\n---------------------------------")
            
        warnings = len(re.findall(r"warning", output, re.IGNORECASE))
        
        if result.returncode == 0:
            status = "SUCCESS"
            if "infeasible" in output.lower():
                status = "INFEASIBLE"
        else:
            status = "ERROR"
            
        return {"name": model_name, "status": status, "time": elapsed, "warnings": warnings, "error": None}
        
    except subprocess.TimeoutExpired as e:
        elapsed = time.time() - start_time
        output = e.stdout.decode('utf-8') if e.stdout else ""
        output += e.stderr.decode('utf-8') if e.stderr else ""
        
        with open(log_path, 'w', encoding='utf-8') as f:
            f.write(header + f"\nPROCESS KILLED DUE TO TIMEOUT ({timeout}s).\n" + output)
            
        if verbose:
            print(f"\n--- LOGS FROM MODEL {model_name} (TIMEOUT) ---\n{output}\n---------------------------------")
            
        return {"name": model_name, "status": "TIMEOUT", "time": elapsed, "warnings": 0, "error": "Timeout exceeded"}
    except Exception as e:
        return {"name": model_name, "status": "ERROR", "time": 0.0, "warnings": 0, "error": str(e)}

def main():
    parser = argparse.ArgumentParser(description="Runs regression tests for CPLEX OPL models.")
    parser.add_argument("model_name", nargs="?", help="Name of a specific model to test (directory in models/). If empty, tests all.")
    parser.add_argument("-t", "--timeout", type=int, default=60, help="Timeout for a single model in seconds (default: 60).")
    parser.add_argument("-v", "--verbose", action="store_true", help="Prints CPLEX logs directly to the console in real-time.")
    
    args = parser.parse_args()
    
    sanity_check()
    temp_ops = create_temp_ops()
    
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    models_dir = os.path.join(base_dir, "models")
    
    if not os.path.exists(models_dir):
        print_color("Error: Directory 'models/' not found.", Colors.RED)
        sys.exit(1)
        
    # Zbieranie modeli
    model_dirs = []
    if args.model_name:
        target = os.path.join(models_dir, args.model_name)
        if not os.path.isdir(target):
            print_color(f"Error: Model '{args.model_name}' not found.", Colors.RED)
            sys.exit(1)
        model_dirs.append(target)
    else:
        for d in os.listdir(models_dir):
            path = os.path.join(models_dir, d)
            if os.path.isdir(path):
                model_dirs.append(path)
                
    print(f"Starting tests for {len(model_dirs)} models... (Timeout: {args.timeout}s)")
    
    results = []
    
    # Przetwarzanie równoległe
    # Używamy ThreadPoolExecutor zamiast ProcessPoolExecutor dla łatwiejszego logowania stdout,
    # Ponieważ samo `subprocess.run` i tak ucieka poza GIL i tworzy proces.
    workers = min(32, os.cpu_count() + 4) if os.cpu_count() else 4
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {executor.submit(run_model, d, temp_ops, args.timeout, args.verbose): d for d in model_dirs}
        
        for future in concurrent.futures.as_completed(futures):
            res = future.result()
            results.append(res)
            
            # Kolorowy output na żywo
            name_padded = res['name'].ljust(30)
            if res['status'] == "SUCCESS":
                print_color(f"[{res['status'].center(10)}] {name_padded} ({res['time']:.2f}s, {res['warnings']} warnings)", Colors.GREEN)
            elif res['status'] == "INFEASIBLE":
                print_color(f"[{res['status'].center(10)}] {name_padded} ({res['time']:.2f}s, {res['warnings']} warnings)", Colors.YELLOW)
            elif res['status'] == "SKIPPED":
                print(f"[{res['status'].center(10)}] {name_padded} (Skipped by .skip file)")
            else:
                err_msg = res['error'] if res['error'] else "Execution error"
                print_color(f"[{res['status'].center(10)}] {name_padded} ({res['time']:.2f}s) - {err_msg}", Colors.RED)
                
    # Sprzątanie temp
    try:
        os.remove(temp_ops)
    except:
        pass
        
    # Sortowanie wyników
    results.sort(key=lambda x: x['name'])
    
    # Save to reports/solver_report.md
    reports_dir = os.path.join(base_dir, "reports")
    os.makedirs(reports_dir, exist_ok=True)
    report_path = os.path.join(reports_dir, "solver_report.md")
    
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("# Solver Test Execution Report\n\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("| Model | Status | Time (s) | Warnings | Notes |\n")
        f.write("|---|---|---|---|---|\n")
        for r in results:
            err = r['error'] if r['error'] else "-"
            f.write(f"| {r['name']} | {r['status']} | {r['time']:.2f} | {r['warnings']} | {err} |\n")
            
    # Końcowe podsumowanie
    successes = sum(1 for r in results if r['status'] in ["SUCCESS", "INFEASIBLE"])
    errors = sum(1 for r in results if r['status'] in ["ERROR", "TIMEOUT"])
    skipped = sum(1 for r in results if r['status'] == "SKIPPED")
    total_time = sum(r['time'] for r in results)
    
    print("\n" + "="*50)
    summary_msg = f"Tested {len(model_dirs)} models: {successes} Successes, {errors} Errors, {skipped} Skipped. Total time: {total_time:.2f}s"
    if errors > 0:
        print_color(summary_msg, Colors.RED)
    elif successes > 0:
        print_color(summary_msg, Colors.GREEN)
    else:
        print(summary_msg)
        
    if errors > 0:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
