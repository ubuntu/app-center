#!/usr/bin/env python3

import argparse
import json
import re
from pathlib import Path


# Parse command-line arguments
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description='Import localized app titles from ARB files into a .desktop file'
    )
    parser.add_argument(
        '--arb-dir',
        type=Path,
        required=True,
        help='Directory containing ARB localization files'
    )
    parser.add_argument(
        '--desktop-file',
        type=Path,
        required=True,
        help='Path to the .desktop file to update'
    )
    parser.add_argument(
        '--name-variable',
        type=str,
        required=True,
        help='JSON key for the app title in ARB files'
    )
    return parser.parse_args()


# Extract locale code from ARB file name
def extract_locale_from_arb_file_name(file_path) -> str | None:
    match = re.match(r'app_([a-z]{2,3}(?:_[A-Z]{2})?)\.arb$', file_path)
    return match.group(1) if match else None


# Get app titles from ARB files
def get_app_titles(arb_dir: Path, name_variable: str) -> dict[str, str] | None:

    if not arb_dir.exists() or not arb_dir.is_dir():
        print(f"Directory {arb_dir} does not exist.")
        return None

    # Load app titles from ARB files
    app_titles = {}

    for arb_file in sorted(arb_dir.glob('app_*.arb')):
        locale = extract_locale_from_arb_file_name(arb_file.name)
        if not locale:
            print(f"Could not extract locale from file name: {arb_file.name}")
            continue

        with arb_file.open('r', encoding='utf-8') as f:
            data = json.load(f)
            app_title = data.get(name_variable)
            if app_title:
                app_titles[locale] = app_title
                print(f' Found: {locale} = "{app_title}"')

    return app_titles


# Update desktop file with new app titles
def main():
    args = parse_args()
    arb_dir = args.arb_dir
    desktop_file = args.desktop_file
    name_variable = args.name_variable

    if not desktop_file.exists():
        print(f"Error: Desktop file {desktop_file} does not exist.")
        return 1

    lines = desktop_file.read_text(encoding='utf-8').splitlines()
    new_lines = []

    # Track if we are in the [Desktop Entry] section of the file
    in_desktop_entry = False

    # Track where in the [Desktop Entry] to insert the l10n Names
    insertion_index = None

    # Build new file based on old without any Name translations from [Desktop Entry]
    for line in lines:
        # See if we are in the [Desktop Entry] section
        if line.strip() == '[Desktop Entry]':
            in_desktop_entry = True
            new_lines.append(line)
            continue

        # See if we are leaving the [Desktop Entry] section
        if in_desktop_entry and line.strip().startswith('[') and line.strip().endswith(']'):
            # If we haven't found an insertion point yet, set it to the end of [Desktop Entry]
            if insertion_index is None:
                insertion_index = len(new_lines)
            in_desktop_entry = False

        # Skip existing Name[...] translations, they will be regenerated.
        if in_desktop_entry and line.startswith('Name['):
            continue

        # Anchor insertion point immediately after the Name= line for readability
        if in_desktop_entry and line.startswith('Name=') and insertion_index is None:
            new_lines.append(line)
            insertion_index = len(new_lines)
            continue

        new_lines.append(line)

    # If we're still in [Desktop Entry] at EOF (no other sections after it)
    # and haven't set insertion_index yet, set it to end of file
    if in_desktop_entry and insertion_index is None:
        insertion_index = len(new_lines)

    # We never found the [Desktop Entry], something is wrong with the file
    if insertion_index is None:
        print("Error: could not find [Desktop Entry] section in desktop file")
        return 1

    app_titles = get_app_titles(arb_dir, name_variable)

    if app_titles is None:
        print(f"Error: Failed to load app titles from {arb_dir}")
        return 1

    if not app_titles:
        print(f"Error: No app titles found in {arb_dir}")
        return 1

    # Add new Name translations at the insertion point
    for locale, title in app_titles.items():
        new_lines.insert(insertion_index, f'Name[{locale}]={title}')
        insertion_index += 1

    # Write updated desktop file
    desktop_file.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
    print(f"Updated desktop file written to {desktop_file}")

    return 0


if __name__ == "__main__":
    exit(main())
