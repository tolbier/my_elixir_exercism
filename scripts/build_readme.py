#!/usr/bin/env python3
"""Regenerates the "Exercises" and "Concepts" tables in ../README.md.

Data sources:
  - Exercism's public track config (concepts, concept-exercise prerequisites,
    practice-exercise "practices" lists): fetched from GitHub, cached locally.
  - Local exercise folders (which ones exist, and in what order they were
    downloaded): read from each folder's .exercism/metadata.json mtime.
  - scripts/descriptions.json: hand-written one-line prose for each exercise
    and each concept. This is the only part that can't be derived from the
    two sources above — fill it in by hand when a new exercise is added.

Usage:
  python3 build_readme.py            # fetch config.json, then regenerate
  python3 build_readme.py --offline  # reuse the cached config.json instead

Only the regions between the HTML comment markers in README.md are touched;
everything else in the file (prose, other sections) is left untouched.
"""

import json
import os
import re
import sys
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EXERCISM_ROOT = os.path.dirname(SCRIPT_DIR)
README_PATH = os.path.join(EXERCISM_ROOT, "README.md")
DESCRIPTIONS_PATH = os.path.join(SCRIPT_DIR, "descriptions.json")
CONFIG_CACHE_PATH = os.path.join(SCRIPT_DIR, "config_cache.json")
CONFIG_URL = "https://raw.githubusercontent.com/exercism/elixir/main/config.json"

NON_EXERCISE_DIRS = {"scripts", "projectFilesBackup"}

EXERCISES_BEGIN = "<!-- BEGIN GENERATED: exercises-table (see scripts/build_readme.py) -->"
EXERCISES_END = "<!-- END GENERATED: exercises-table -->"
CONCEPTS_BEGIN = "<!-- BEGIN GENERATED: concepts-table (see scripts/build_readme.py) -->"
CONCEPTS_END = "<!-- END GENERATED: concepts-table -->"


def load_config(offline):
    if offline:
        with open(CONFIG_CACHE_PATH) as f:
            return json.load(f)
    with urllib.request.urlopen(CONFIG_URL) as resp:
        data = json.load(resp)
    with open(CONFIG_CACHE_PATH, "w") as f:
        json.dump(data, f, indent=2)
    return data


def load_descriptions():
    with open(DESCRIPTIONS_PATH) as f:
        return json.load(f)


def scan_local_exercises():
    """Returns (ordered list of local exercise slugs, {slug: mtime})."""
    entries = []
    for name in sorted(os.listdir(EXERCISM_ROOT)):
        if name in NON_EXERCISE_DIRS or name.startswith("."):
            continue
        path = os.path.join(EXERCISM_ROOT, name)
        metadata = os.path.join(path, ".exercism", "metadata.json")
        if os.path.isdir(path) and os.path.isfile(metadata):
            entries.append((name, os.path.getmtime(metadata)))
    entries.sort(key=lambda e: e[1])
    order = [slug for slug, _ in entries]
    return order, {slug: mtime for slug, mtime in entries}


def build_concept_graph(config):
    concept_meta = {c["slug"]: c["name"] for c in config["concepts"]}
    concept_exercises = {
        e["slug"]: e
        for e in config["exercises"]["concept"]
        if e.get("status") != "deprecated" and e.get("concepts")
    }

    concept_to_exercise = {}
    concept_prereqs = {}
    for ex in concept_exercises.values():
        for concept in ex["concepts"]:
            concept_to_exercise[concept] = ex["slug"]
            concept_prereqs[concept] = ex.get("prerequisites", [])

    all_concepts = set(concept_meta)
    prereqs_within = {
        c: set(concept_prereqs.get(c, [])) & all_concepts for c in all_concepts
    }

    order, remaining = [], set(all_concepts)
    while remaining:
        ready = sorted(c for c in remaining if prereqs_within[c] <= set(order))
        if not ready:
            raise RuntimeError(f"Unresolved concept prerequisites: {remaining}")
        order.extend(ready)
        remaining -= set(ready)

    concept_num = {slug: i + 1 for i, slug in enumerate(order)}

    unlocks = {c: [] for c in all_concepts}
    for c, prereqs in prereqs_within.items():
        for p in prereqs:
            unlocks[p].append(c)
    for c in unlocks:
        unlocks[c].sort(key=lambda s: concept_num[s])

    return {
        "order": order,
        "concept_meta": concept_meta,
        "concept_num": concept_num,
        "concept_exercises": concept_exercises,
        "concept_to_exercise": concept_to_exercise,
        "unlocks": unlocks,
    }


def practice_exercise_map(config):
    return {e["slug"]: e for e in config["exercises"]["practice"]}


def concept_link(slug, name, graph):
    n = graph["concept_num"][slug]
    return f"[{n}. {name}](https://exercism.org/tracks/elixir/concepts/{slug})"


def render_exercises_table(order, exercise_num, graph, practice_map, descriptions):
    concept_meta = graph["concept_meta"]
    concept_exercises = graph["concept_exercises"]
    lines = ["| # | Exercise | Concepts it covers | Concepts (exercism.org) |", "|---|---|---|---|"]

    for slug in order:
        n = exercise_num[slug]
        ex_cell = f"[`{slug}`]({slug}) [(+)](https://exercism.org/tracks/elixir/exercises/{slug})"
        desc = descriptions["exercise_descriptions"].get(
            slug, "*(missing description — add it to scripts/descriptions.json)*"
        )

        if slug in concept_exercises:
            concepts = concept_exercises[slug]["concepts"]
            concepts_cell = ", ".join(
                concept_link(c, concept_meta[c], graph) for c in concepts
            )
        elif slug in practice_map and practice_map[slug].get("practices"):
            concepts = practice_map[slug]["practices"]
            concepts_cell = ", ".join(
                concept_link(c, concept_meta[c], graph)
                for c in concepts
                if c in concept_meta
            )
        else:
            concepts_cell = "— (no concept mapping in track config)"

        lines.append(f"| {n} | {ex_cell} | {desc} | {concepts_cell} |")

    return "\n".join(lines)


def render_concepts_table(graph, exercise_num, descriptions):
    concept_meta = graph["concept_meta"]
    concept_to_exercise = graph["concept_to_exercise"]
    concept_exercises = graph["concept_exercises"]
    unlocks = graph["unlocks"]
    lines = ["| # | Concept | Description | Taught by | Unlocks |", "|---|---|---|---|---|"]

    for slug in graph["order"]:
        n = graph["concept_num"][slug]
        name = concept_meta[slug]
        desc = descriptions["concept_descriptions"].get(
            slug, "*(missing description — add it to scripts/descriptions.json)*"
        )

        ex_slug = concept_to_exercise.get(slug)
        if ex_slug and ex_slug in exercise_num:
            taught_by = (
                f"[{exercise_num[ex_slug]}. `{ex_slug}`]({ex_slug}) "
                f"[(+)](https://exercism.org/tracks/elixir/exercises/{ex_slug})"
            )
        elif ex_slug:
            status = concept_exercises.get(ex_slug, {}).get("status", "unknown")
            taught_by = f"*not present locally (`{ex_slug}`, {status} in track config)*"
        else:
            taught_by = "*(no concept exercise found in config.json)*"

        unlocked = unlocks.get(slug, [])
        unlocks_cell = (
            ", ".join(concept_link(u, concept_meta[u], graph) for u in unlocked)
            if unlocked
            else "—"
        )

        lines.append(
            f"| {n} | [{name}](https://exercism.org/tracks/elixir/concepts/{slug}) "
            f"| {desc} | {taught_by} | {unlocks_cell} |"
        )

    return "\n".join(lines)


def splice(readme_text, begin_marker, end_marker, new_table):
    pattern = re.compile(
        re.escape(begin_marker) + r".*?" + re.escape(end_marker), re.S
    )
    replacement = f"{begin_marker}\n{new_table}\n{end_marker}"
    # Pass a callable, not a plain string: re.sub/subn treat backslashes in a
    # string replacement as escape sequences (e.g. "\\" -> "\"), which silently
    # corrupts table cells containing Elixir's `\\` default-argument syntax.
    # A callable's return value is inserted verbatim, with no such processing.
    new_text, count = pattern.subn(lambda _m: replacement, readme_text)
    if count != 1:
        raise RuntimeError(f"Expected exactly one {begin_marker!r} block, found {count}")
    return new_text


def main():
    offline = "--offline" in sys.argv
    config = load_config(offline)
    descriptions = load_descriptions()

    order, mtimes = scan_local_exercises()
    exercise_num = {slug: i + 1 for i, slug in enumerate(order)}

    graph = build_concept_graph(config)
    practice_map = practice_exercise_map(config)

    missing_ex_desc = [s for s in order if s not in descriptions["exercise_descriptions"]]
    missing_concept_desc = [
        s for s in graph["order"] if s not in descriptions["concept_descriptions"]
    ]
    if missing_ex_desc:
        print(f"WARNING: no description for exercises: {missing_ex_desc}", file=sys.stderr)
    if missing_concept_desc:
        print(f"WARNING: no description for concepts: {missing_concept_desc}", file=sys.stderr)

    exercises_table = render_exercises_table(order, exercise_num, graph, practice_map, descriptions)
    concepts_table = render_concepts_table(graph, exercise_num, descriptions)

    with open(README_PATH) as f:
        readme = f.read()

    readme = splice(readme, EXERCISES_BEGIN, EXERCISES_END, exercises_table)
    readme = splice(readme, CONCEPTS_BEGIN, CONCEPTS_END, concepts_table)

    with open(README_PATH, "w") as f:
        f.write(readme)

    print(f"Regenerated {len(order)} exercise rows and {len(graph['order'])} concept rows.")


if __name__ == "__main__":
    main()
