"""Tier 3 — built to actually break the 26b.

Two families:
  codegen  - the model writes a function. It is graded by AST-checking the
             structural bans, then EXECUTING it against hidden test cases in a
             separate subprocess. Partial credit per check.
  longctx  - a ~140-record synthetic document requiring multi-hop chaining or
             aggregation across widely separated positions.

The "no imports" ban is enforced by AST *before* anything is executed, which
doubles as the safety guard on running model-written code.
"""
import ast
import json
import re
import subprocess
import sys
import tempfile

CODE_SUFFIX = ("\n\nReturn only a ```python code block containing the function. "
               "No explanation, no tests, no example usage.")


def _extract_code(text):
    text = re.sub(r"<think>.*?</think>", "", text or "", flags=re.S | re.I)
    m = re.findall(r"```(?:python)?\s*\n(.*?)```", text, flags=re.S)
    return (m[-1] if m else text).strip()


def _body_lines(src):
    return [l for l in src.splitlines()
            if l.strip() and not l.strip().startswith("#")]


def codegen(fn_name, tests, max_lines, banned_nodes=(), banned_names=()):
    """Grade on 4 checks: parses, structural bans, line budget, tests pass."""
    def grade(text):
        src = _extract_code(text)
        try:
            tree = ast.parse(src)
        except SyntaxError:
            return 0.0, "syntax error"

        has_import = any(isinstance(n, (ast.Import, ast.ImportFrom))
                         for n in ast.walk(tree))
        bad_node = any(isinstance(n, banned_nodes) for n in ast.walk(tree)) \
            if banned_nodes else False
        used = {n.id for n in ast.walk(tree) if isinstance(n, ast.Name)} | \
               {n.attr for n in ast.walk(tree) if isinstance(n, ast.Attribute)}
        bad_name = bool(used & set(banned_names))
        # recursion ban is implied whenever the function calls itself
        selfcall = any(isinstance(n, ast.Call) and isinstance(n.func, ast.Name)
                       and n.func.id == fn_name for n in ast.walk(tree))

        structural_ok = not (has_import or bad_node or bad_name or selfcall)
        lines_ok = len(_body_lines(src)) <= max_lines

        tests_ok = False
        detail = ""
        if not has_import:  # never execute anything that imports
            tests_ok, detail = _run_tests(src, fn_name, tests)
        else:
            detail = "import banned"

        checks = [True, structural_ok, lines_ok, tests_ok]
        why = []
        if not structural_ok:
            why.append("import" if has_import else
                       "banned-node" if bad_node else
                       "banned-name" if bad_name else "recursion")
        if not lines_ok:
            why.append(f"{len(_body_lines(src))}>{max_lines}ln")
        if not tests_ok:
            why.append(detail or "tests")
        return sum(checks) / 4.0, f"{sum(checks)}/4 " + ",".join(why)
    return grade


def _run_tests(src, fn_name, tests):
    harness = (src + "\n\nimport json,sys\n_f=" + fn_name + "\n_bad=[]\n"
               "for _a,_e in json.loads(sys.argv[1]):\n"
               "    try:\n        _g=_f(*_a)\n"
               "    except Exception as _x:\n        _bad.append([_a,'raised '+type(_x).__name__]); continue\n"
               "    if _g!=_e: _bad.append([_a,_g])\n"
               "print(json.dumps(_bad))\n")
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as f:
        f.write(harness)
        path = f.name
    try:
        r = subprocess.run([sys.executable, path, json.dumps(tests)],
                           capture_output=True, text=True, timeout=15)
        if r.returncode != 0:
            return False, "runtime error"
        bad = json.loads(r.stdout.strip().splitlines()[-1])
        return (not bad), ("" if not bad else f"{len(bad)}/{len(tests)} failed")
    except subprocess.TimeoutExpired:
        return False, "timeout"
    except Exception:
        return False, "harness error"


CODEGEN = [
    ("x1", "Write a Python function `solve(n)` that returns the sum of the decimal "
           "digits of a non-negative integer n. You may not use any import, any "
           "`for` or `while` loop, and no recursion. The whole thing must be at "
           "most 3 lines." + CODE_SUFFIX,
     codegen("solve", [[[0], 0], [[123], 6], [[999999], 54], [[7], 7]], 3,
             banned_nodes=(ast.For, ast.While))),

    ("x2", "Write a Python function `solve(lst)` returning the second-largest "
           "DISTINCT value in a list of integers, or None if there are fewer than "
           "two distinct values. You may not use sorted, sort, max, min, or any "
           "import. At most 12 lines." + CODE_SUFFIX,
     codegen("solve", [[[[1, 2, 3]], 2], [[[5, 5, 5]], None], [[[3, 1]], 1],
                       [[[10, 10, 9]], 9], [[[]], None], [[[-1, -2]], -2]], 12,
             banned_names=("sorted", "sort", "max", "min"))),

    ("x3", "Write a Python function `solve(s)` returning True if the string s is a "
           "correctly nested sequence of the brackets ()[]{} and False otherwise. "
           "The empty string is True. No imports. At most 10 lines." + CODE_SUFFIX,
     codegen("solve", [[["()[]{}"], True], [["([)]"], False], [[""], True],
                       [["("], False], [["{[()]}"], True], [[")("], False]], 10)),

    ("x4", "Write a Python function `solve(m)` that rotates an N x N matrix 90 "
           "degrees clockwise and returns the rotated matrix. You may not use zip, "
           "reversed, or any import. At most 8 lines." + CODE_SUFFIX,
     codegen("solve", [[[[[1, 2], [3, 4]]], [[3, 1], [4, 2]]],
                       [[[[1]]], [[1]]],
                       [[[[1, 2, 3], [4, 5, 6], [7, 8, 9]]],
                        [[7, 4, 1], [8, 5, 2], [9, 6, 3]]]], 8,
             banned_names=("zip", "reversed"))),

    ("x5", "Write a Python function `solve(n)` returning the n-th prime number, "
           "1-indexed, so solve(1) == 2. No imports. At most 10 lines."
           + CODE_SUFFIX,
     codegen("solve", [[[1], 2], [[10], 29], [[100], 541], [[25], 97]], 10)),
]


# ------------------------------------------------------------- long context
DEPOTS = ["ALDER", "BIRCH", "CEDAR", "DAMSON", "ELDER", "FIRTH"]
MANAGERS = ["Okonjo", "Lindqvist", "Ferreira", "Nakamura", "Haddad", "Whitlock"]
BUDGETS = ["BX-11", "BX-27", "BX-38", "BX-42", "BX-55", "BX-63"]


def _build_doc():
    """Deterministic ~140-record log. Facts needed for the queries are
    deliberately far apart."""
    recs, x = [], 7
    for i in range(1, 141):
        x = (x * 31 + 17) % 1000
        d = DEPOTS[(i * 7) % len(DEPOTS)]
        units = 50 + (x % 450)
        recs.append(f"Record {i:03d}: shipment SH-{i:03d}, depot {d}, units {units}")
    table = "\n".join(f"Depot {d} is managed by {m}, budget code {b}"
                      for d, m, b in zip(DEPOTS, MANAGERS, BUDGETS))
    return "\n".join(recs), table, recs


DOC, TABLE, RECS = _build_doc()


def _units(i):
    return int(RECS[i - 1].split("units ")[1])


def _depot(i):
    return RECS[i - 1].split("depot ")[1].split(",")[0]


# chain: SH-093 -> its depot -> that depot's budget code
_CHAIN_ANS = BUDGETS[DEPOTS.index(_depot(93))]
# aggregation: total units for depot CEDAR across the whole log
_AGG_ANS = sum(_units(i) for i in range(1, 141) if _depot(i) == "CEDAR")
# comparison across distant records
_CMP_ANS = str(_units(12) + _units(128))

_TAIL = "\n\nEnd your reply with a final line of exactly: ANSWER: <value>"

# (id, prompt, expected) — tasks.py wraps these with its exact() grader.
LONGCTX = [
    ("L1", f"{DOC}\n\n{TABLE}\n\nUsing the log and the depot table above, what "
           f"budget code applies to shipment SH-093?" + _TAIL, _CHAIN_ANS),
    ("L2", f"{DOC}\n\nUsing the log above, what is the total number of units "
           f"across every record whose depot is CEDAR?" + _TAIL, str(_AGG_ANS)),
    ("L3", f"{DOC}\n\nUsing the log above, what is the sum of the units in "
           f"Record 012 and Record 128?" + _TAIL, _CMP_ANS),
]
