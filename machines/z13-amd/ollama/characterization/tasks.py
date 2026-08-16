"""Prompt set + programmatic graders for the 26b-MoE vs 31b-dense comparison.

Every task is objectively checkable, so no LLM judge is involved.

Two grading modes:
  exact       - extract "ANSWER: x", normalise, compare to expected.
                best-of-N selects by majority vote (no ground truth needed).
  constraints - score = fraction of programmatic checks passed.
                best-of-N selects the highest-scoring sample, which is
                legitimate because the constraints are self-verifiable at
                inference time without knowing any answer.
"""
import json
import re

SUFFIX = "\n\nThink briefly, then end your reply with a final line of exactly: ANSWER: <value>"


def _norm(s):
    return re.sub(r"[\s,$\"'<>*`]+", "", (s or "").strip().lower().rstrip("."))


def exact(expected):
    def grade(text):
        got = extract_answer(text)
        return (1.0 if _norm(got) == _norm(expected) else 0.0), got
    return grade


def extract_answer(text):
    text = re.sub(r"<think>.*?</think>", "", text or "", flags=re.S | re.I)
    hits = re.findall(r"ANSWER\s*:\s*(.+)", text, flags=re.I)
    return hits[-1].strip() if hits else ""


# ---------------------------------------------------------------- reasoning
REASONING = [
    ("r1", "A train departs at 09:15 and travels for 3h40m. It then waits 25 minutes, "
           "then travels a further 1h50m. At what time does it arrive? Use 24h HH:MM." + SUFFIX,
     exact("15:10")),
    ("r2", "Widgets cost $12 each. Orders of 10 or more get 15% off the whole order. "
           "Sam buys 14 widgets, then returns 3 of them for a refund at the discounted "
           "unit price. What did Sam pay in total? Give dollars and cents." + SUFFIX,
     exact("112.20")),
    ("r3", "In a room every person shook hands with every other person exactly once, "
           "totalling 66 handshakes. Then 3 more people arrive; each newcomer shakes "
           "hands with everyone already there and with each other, no repeats. "
           "How many handshakes have occurred in total now?" + SUFFIX,
     exact("105")),
    ("r4", "A tank is 3/8 full. After adding 45 litres it is 3/4 full. Give the tank's "
           "total capacity in litres, then the litres still needed to fill it from 3/4. "
           "Give the answer as two digits-only numbers separated by a comma, "
           "for example: 5,7" + SUFFIX,
     exact("120,30")),
    ("r5", "Alice is twice as old as Bob was when Alice was as old as Bob is now. "
           "Their ages now sum to 63. How old is Bob now?" + SUFFIX,
     exact("27")),
    ("r6", "A cube is painted red on all six faces, then cut into 27 identical smaller "
           "cubes. How many small cubes have exactly two red faces, and how many have "
           "no red faces? Give the answer as two digits-only numbers separated by a "
           "comma, for example: 5,7" + SUFFIX,
     exact("12,1")),
]

# ------------------------------------------------------------- mixed domain
MIXED = [
    ("m1", "What does this Python print?\n\n"
           "d = {}\nfor i in range(5):\n    d[i % 3] = d.get(i % 3, 0) + i\n"
           "print(sorted(d.items()))" + SUFFIX,
     exact("[(0, 3), (1, 5), (2, 2)]")),
    ("m2", "What is the value of x after this JavaScript runs?\n\n"
           "let x = [1,2,3].reduce((a,b)=>a+b, 0);\nx = x * 2;\n"
           "x = x.toString().split('').reverse().join('');" + SUFFIX,
     exact("21")),
    ("m3", "Table t(id INT, v INT) holds rows (1,10),(2,20),(3,20),(4,30). "
           "What does `SELECT COUNT(DISTINCT v) FROM t WHERE v > 10;` return?" + SUFFIX,
     exact("2")),
    ("m4", "Compute (0b1011 XOR 0b0110) AND 0b1110 and give the result in decimal." + SUFFIX,
     exact("12")),
]


# --------------------------------------------------------------- constraints
def _sentences(t):
    t = re.sub(r"<think>.*?</think>", "", t or "", flags=re.S | re.I).strip()
    return [s.strip() for s in re.split(r"(?<=[.!?])\s+", t) if s.strip()]


def _lines(t):
    t = re.sub(r"<think>.*?</think>", "", t or "", flags=re.S | re.I).strip()
    return [l.strip() for l in t.splitlines() if l.strip()]


def c_coffee(text):
    s = _sentences(text)
    body = " ".join(s).lower()
    checks = [
        len(s) == 3,
        all("bean" in x.lower() for x in s),
        all(len(x.split()) <= 12 for x in s),
        "z" not in body,
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} sents={len(s)}"


def c_birds(text):
    ls = [l for l in _lines(text) if l.startswith("- ")]
    names = [l[2:].strip() for l in ls]
    checks = [
        len(ls) == 5,
        len(names) == 5 and all(len(n) == 5 and n.isalpha() for n in names),
        len({n[0].lower() for n in names}) == len(names) if names else False,
        all("a" not in n.lower() for n in names) if names else False,
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} {names}"


def c_poem(text):
    ls = _lines(text)
    rhyme = re.compile(r"(ay|ey|eigh|ae)[\W]*$", re.I)
    checks = [
        len(ls) == 4,
        all(len(l.split()) == 6 for l in ls) if ls else False,
        all("rain" not in l.lower() for l in ls),
        all(rhyme.search(l.rstrip(".,!?")) for l in ls) if ls else False,
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} lines={len(ls)}"


def c_json(text):
    raw = re.sub(r"<think>.*?</think>", "", text or "", flags=re.S | re.I)
    raw = re.sub(r"^```(?:json)?|```$", "", raw.strip(), flags=re.M).strip()
    try:
        o = json.loads(raw)
    except Exception:
        return 0.0, "unparseable"
    tags = o.get("tags")
    checks = [
        set(o.keys()) == {"name", "year", "tags"},
        isinstance(o.get("name"), str) and len(o.get("name", "")) == 7,
        isinstance(o.get("year"), int) and 1990 <= o.get("year", 0) <= 1999,
        isinstance(tags, list) and len(tags) == 3
        and all(isinstance(t, str) and t.islower() and len(t) == 4 for t in tags),
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)}"


def c_lipogram(text):
    s = _sentences(text)
    checks = [
        len(s) == 2,
        len(s) > 0 and len(s[0].split()) == 10,
        len(s) > 1 and len(s[1].split()) == 15,
        "e" not in " ".join(s).lower(),
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} sents={len(s)}"


CONSTRAINTS = [
    ("c1", "Write exactly 3 sentences about coffee. Every sentence must contain the word "
           "'bean'. No sentence may exceed 12 words. Do not use the letter 'z' anywhere. "
           "Output only the sentences, nothing else.", c_coffee),
    ("c2", "List exactly 5 birds, one per line, each line starting with '- '. Each bird "
           "name must be exactly 5 letters long. No two may start with the same letter. "
           "None may contain the letter 'a'. Output only the list.", c_birds),
    ("c3", "Write a 4-line poem about weather. Each line must be exactly 6 words. The last "
           "word of every line must rhyme with 'day'. Do not use the word 'rain'. "
           "Output only the poem.", c_poem),
    ("c4", "Output a JSON object with exactly the keys: name, year, tags. 'name' must be a "
           "string of exactly 7 characters. 'year' must be an integer between 1990 and "
           "1999. 'tags' must be an array of exactly 3 strings, each lowercase and exactly "
           "4 letters. Output only raw JSON, no markdown fences.", c_json),
    ("c5", "Write exactly 2 sentences describing a forest. The first must be exactly 10 "
           "words, the second exactly 15 words. Neither may contain the letter 'e'. "
           "Output only the sentences.", c_lipogram),
]

TASKS = ([("reasoning", *t) for t in REASONING]
         + [("mixed", *t) for t in MIXED]
         + [("constraints", *t) for t in CONSTRAINTS])


# ------------------------------------------------------------- hard tier
# The first tier saturated at 1.00 for both models; these are built to bite.
def h_words(text):
    ls = _lines(text)
    words = [w for l in ls for w in l.split()]
    clean = [w.strip(".,!?;:").lower() for w in words]
    vowels = set("aeiou")
    checks = [
        len(ls) == 3,
        [len(l.split()) for l in ls] == [5, 7, 5],
        all(c and c[0] not in vowels and c[0].isalpha() for c in clean) if clean else False,
        len(set(clean)) == len(clean) if clean else False,
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} lines={len(ls)}"


def h_kv(text):
    ls = [l for l in _lines(text) if "=" in l]
    keys, vals, ok = [], [], True
    for l in ls:
        k, _, v = l.partition("=")
        keys.append(k.strip())
        try:
            vals.append(int(v.strip()))
        except ValueError:
            ok = False
    checks = [
        len(ls) == 4,
        all(len(k) == 3 and k.isalpha() and k.isupper() for k in keys) if keys else False,
        keys == sorted(keys) and len(set(keys)) == len(keys) if keys else False,
        ok and bool(vals) and all(sum(int(c) for c in str(abs(v))) == 7 for v in vals)
        and len(set(vals)) == len(vals),
    ]
    return sum(checks) / len(checks), f"{sum(checks)}/{len(checks)} {keys} {vals}"


HARD_REASON = [
    ("h1", "Three friends split a bill. Ann pays 40% more than Ben. Cal pays 25% less "
           "than Ann. The total is $310.50. How much did Ben pay? Give dollars and "
           "cents." + SUFFIX, exact("90.00")),
    ("h2", "Five houses stand in a row at positions 1 to 5. The red house is immediately "
           "left of the blue house. The green house is at position 1. The blue house is "
           "not at position 3. There is exactly one house between the green and red "
           "houses. What position is the blue house?" + SUFFIX, exact("4")),
    ("h3", "What is 7^100 mod 13?" + SUFFIX, exact("9")),
    ("h4", "What does this Python print?\n\n"
           "def f(n, memo={}):\n    if n in memo: return memo[n]\n"
           "    r = 1 if n < 2 else f(n-1) + f(n-2)\n    memo[n] = r\n    return r\n"
           "print(f(10))" + SUFFIX, exact("89")),
]

HARD_CONSTRAINTS = [
    ("h5", "Write exactly 3 lines. Line 1 must be exactly 5 words, line 2 exactly 7 "
           "words, line 3 exactly 5 words. Every single word must begin with a "
           "consonant. No word may repeat anywhere. Output only the 3 lines.", h_words),
    ("h6", "Output exactly 4 lines, each of the form KEY=VALUE. Each KEY must be exactly "
           "3 uppercase letters, and the keys must be in alphabetical order. Each VALUE "
           "must be a positive integer whose digits sum to exactly 7. No two values may "
           "be equal. Output only the 4 lines.", h_kv),
]

TASKS_HARD = ([("hard-reasoning", *t) for t in HARD_REASON]
              + [("hard-constraints", *t) for t in HARD_CONSTRAINTS])

import tasks_tier3 as T3  # noqa: E402  (imported late: needs exact() defined)

TASKS_TIER3 = ([("codegen", tid, p, fn) for tid, p, fn in T3.CODEGEN]
               + [("longctx", tid, p, exact(e)) for tid, p, e in T3.LONGCTX])

ALL_TASKS = TASKS + TASKS_HARD + TASKS_TIER3

VOTE_MODE = {"reasoning": "majority", "mixed": "majority", "constraints": "best",
             "hard-reasoning": "majority", "hard-constraints": "best",
             "codegen": "best", "longctx": "majority"}
