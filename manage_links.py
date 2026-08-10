#!/usr/bin/env python3
"""
Interactive link manager for theklif.github.io's links.json.
Run it, pick a number from the menu, follow the prompts.
"""

import json
import sys
import time
import traceback
from pathlib import Path

try:
    import msvcrt
except ImportError:
    msvcrt = None

SCRIPT_DIR = Path(__file__).parent
LINKS_PATH = SCRIPT_DIR / "links.json"


def load_links():
    """Load links.json. Missing or malformed file is a fatal setup error."""
    if not LINKS_PATH.exists():
        sys.exit(f"links.json not found at {LINKS_PATH}")
    with open(LINKS_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_links(data):
    """Write the current link data back to links.json."""
    with open(LINKS_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def column_label(index):
    names = {0: "left", 1: "right"}
    return f"Column {index + 1} ({names.get(index, 'extra')})"


def print_column(data, index):
    column = data["columns"][index]
    print(f"\n{column_label(index)}:")
    if not column:
        print("  (empty)")
        return
    for i, entry in enumerate(column, 1):
        if entry.get("divider"):
            print(f"  {i}. --- divider ---")
        else:
            tab_note = "" if entry.get("new_tab", True) else "  (same tab)"
            print(f"  {i}. {entry['label']} -> {entry['url']}{tab_note}")


def print_all(data):
    for i in range(len(data["columns"])):
        print_column(data, i)


def choose_column(data):
    print()
    for i in range(len(data["columns"])):
        print(f"  {i + 1}. {column_label(i)}")
    raw = input("Which column? ").strip()
    try:
        idx = int(raw) - 1
        if 0 <= idx < len(data["columns"]):
            return idx
    except ValueError:
        pass
    print("Not a valid column.")
    return None


def choose_entry_index(data, column_idx, prompt):
    print_column(data, column_idx)
    column = data["columns"][column_idx]
    if not column:
        return None
    raw = input(f"{prompt} ").strip()
    try:
        idx = int(raw) - 1
        if 0 <= idx < len(column):
            return idx
    except ValueError:
        pass
    print("Not a valid entry number.")
    return None


def action_list(data):
    print_all(data)


def action_add(data):
    col = choose_column(data)
    if col is None:
        return
    label = input("Label: ").strip()
    if not label:
        print("Label can't be empty. Cancelled.")
        return
    url = input("URL: ").strip()
    if not url:
        print("URL can't be empty. Cancelled.")
        return
    same_tab = input("Open in the same tab instead of a new one? (y/N): ").strip().lower() == "y"
    entry = {"label": label, "url": url, "new_tab": not same_tab}
    data["columns"][col].append(entry)
    save_links(data)
    print(f"Added '{label}'.")


def action_add_divider(data):
    col = choose_column(data)
    if col is None:
        return
    data["columns"][col].append({"divider": True})
    save_links(data)
    print("Divider added.")


def action_remove(data):
    col = choose_column(data)
    if col is None:
        return
    idx = choose_entry_index(data, col, "Which entry to remove?")
    if idx is None:
        return
    removed = data["columns"][col].pop(idx)
    save_links(data)
    label = removed.get("label", "divider")
    print(f"Removed '{label}'.")


def action_edit(data):
    col = choose_column(data)
    if col is None:
        return
    idx = choose_entry_index(data, col, "Which entry to edit?")
    if idx is None:
        return
    entry = data["columns"][col][idx]
    if entry.get("divider"):
        print("Can't edit a divider. Remove and re-add instead.")
        return
    print(f"Editing '{entry['label']}'. Leave blank to keep the current value.")
    new_label = input(f"Label [{entry['label']}]: ").strip()
    if new_label:
        entry["label"] = new_label
    new_url = input(f"URL [{entry['url']}]: ").strip()
    if new_url:
        entry["url"] = new_url
    tab_now = "same tab" if entry.get("new_tab", True) is False else "new tab"
    change_tab = input(f"Currently opens in a {tab_now}. Switch? (y/N): ").strip().lower() == "y"
    if change_tab:
        entry["new_tab"] = not entry.get("new_tab", True)
    save_links(data)
    print("Updated.")


def wait_before_exit(timeout=5):
    """
    Manual-run convenience only. If there's no console attached (e.g. run
    hidden/logged-off) or msvcrt isn't available, this quietly does nothing
    instead of throwing.
    """
    try:
        if not sys.stdout.isatty() or msvcrt is None:
            return
        print(f"\nDone. Press any key within {timeout} seconds to keep this window open...")
        start = time.time()
        while time.time() - start < timeout:
            if msvcrt.kbhit():
                msvcrt.getch()
                print("Staying open. Press Enter to close.")
                input()
                return
            time.sleep(0.1)
        print("No key pressed, closing...")
    except Exception:
        pass


MENU = {
    "1": ("List all links", action_list),
    "2": ("Add a link", action_add),
    "3": ("Add a divider", action_add_divider),
    "4": ("Remove a link or divider", action_remove),
    "5": ("Edit a link", action_edit),
}


def main():
    data = load_links()
    print("=== theklif.github.io link manager ===")
    while True:
        print("\nWhat would you like to do?")
        for key, (desc, _) in MENU.items():
            print(f"  {key}. {desc}")
        print("  6. Quit")
        choice = input("> ").strip()
        if choice == "6" or choice.lower() in ("q", "quit", "exit"):
            break
        action = MENU.get(choice)
        if action:
            action[1](data)
        else:
            print("Not a valid option.")


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, EOFError):
        print("\nInterrupted.")
    except Exception:
        print("\nUnexpected error:")
        traceback.print_exc()
    wait_before_exit()