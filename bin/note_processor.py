#!/usr/bin/env python3
# Renames and processes .svgz handwritten note files into dated .svg files.
# Intended to run before logseq sync so that processed SVGs are available.
#
# Usage: note_processor.py <assets_base_dir>
#   <assets_base_dir>  Parent of the svgz/ and svg/ directories.
#                      Defaults to ~/Documents/LogSeq/assets
#
# Paths used:
#   <assets_base_dir>/svgz/  — input: raw .svgz files from handwriting app
#   <assets_base_dir>/svg/   — output: processed .svg files in YYYY/MM/DD/ layout

import os
import sys
import gzip
import re
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

def get_base_dir():
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).expanduser().resolve()
    return Path("~/Documents/LogSeq/assets").expanduser()

BASE_DIR = get_base_dir()
SVGZ_DIR = BASE_DIR / "svgz"
SVG_BASE = BASE_DIR / "svg"
SCHEMA_RE = re.compile(r"^(\d{4})-(\d{2})-(\d{2})_(\d+)\.svgz$")

# SVG namespace
SVG_NS = "http://www.w3.org/2000/svg"
XLINK_NS = "http://www.w3.org/1999/xlink"
ET.register_namespace('', SVG_NS)
ET.register_namespace('xlink', XLINK_NS)


def parse_dimension(value):
    """Extract numeric value from dimension string like '1086px' or '1086'."""
    if value is None:
        return None
    match = re.match(r'([\d.]+)', str(value))
    return float(match.group(1)) if match else None


def sanitize_svg(content):
    try:
        content_str = content.decode('utf-8', errors='ignore')

        root = ET.fromstring(content_str)

        # Find the write-page svg element (contains actual content)
        write_page = None
        for elem in root.iter():
            if elem.tag == f'{{{SVG_NS}}}svg' or elem.tag == 'svg':
                if elem.get('class') == 'write-page':
                    write_page = elem
                    break

        if write_page is None:
            print("Warning: Could not find write-page element")
            return content

        x = parse_dimension(write_page.get('x')) or 0
        y = parse_dimension(write_page.get('y')) or 0
        width = parse_dimension(write_page.get('width'))
        height = parse_dimension(write_page.get('height'))

        if width is None or height is None:
            print("Warning: Could not extract dimensions from write-page")
            return content

        root.set('viewBox', f'{int(x)} {int(y)} {int(width)} {int(height)}')
        root.set('width', '100%')
        if 'height' in root.attrib:
            del root.attrib['height']
        root.set('preserveAspectRatio', 'xMinYMin meet')

        for elem in root.iter():
            if elem.get('id') == 'write-doc-background':
                elem.set('style', 'display:none')
                break

        result = ET.tostring(root, encoding='unicode')
        result = '<?xml version="1.0" encoding="UTF-8"?>\n' + result
        return result.encode('utf-8')

    except ET.ParseError as e:
        print(f"XML parsing failed: {e}")
        return sanitize_svg_fallback(content)
    except Exception as e:
        print(f"Sanitization failed: {e}")
        return content


def sanitize_svg_fallback(content):
    """Fallback regex-based sanitization for malformed XML."""
    try:
        content_str = content.decode('utf-8', errors='ignore')

        dim_match = re.search(
            r'<svg[^>]+class="write-page"[^>]*'
            r'x="([\d.]+)"[^>]*'
            r'width="([\d.]+)p?x?"[^>]*'
            r'height="([\d.]+)p?x?"',
            content_str, re.DOTALL
        )

        if not dim_match:
            dim_match = re.search(
                r'<svg[^>]+class="write-page"[^>]*'
                r'width="([\d.]+)p?x?"[^>]*'
                r'height="([\d.]+)p?x?"',
                content_str, re.DOTALL
            )
            if dim_match:
                x, w, h = 10, dim_match.group(1), dim_match.group(2)
            else:
                return content
        else:
            x, w, h = dim_match.group(1), dim_match.group(2), dim_match.group(3)

        root_attrs = f'viewBox="{x} 0 {w} {h}" width="100%" preserveAspectRatio="xMinYMin meet"'
        content_str = re.sub(r'<svg\s', f'<svg {root_attrs} ', content_str, count=1)

        content_str = re.sub(
            r'(<rect[^>]*id="write-doc-background")',
            r'\1 style="display:none"',
            content_str
        )

        return content_str.encode('utf-8')
    except Exception as e:
        print(f"Fallback sanitization failed: {e}")
        return content


def get_next_num(date_str):
    if not SVGZ_DIR.exists():
        return 1
    existing = [f.name for f in SVGZ_DIR.glob(f"{date_str}_*.svgz")]
    nums = [int(SCHEMA_RE.match(f).group(4)) for f in existing if SCHEMA_RE.match(f)]
    return max(nums, default=0) + 1


def process():
    if not SVGZ_DIR.exists():
        print(f"svgz directory does not exist: {SVGZ_DIR}")
        return
    for item in SVGZ_DIR.glob("*.svgz"):
        filename = item.name
        match = SCHEMA_RE.match(filename)
        if not match:
            date_str = datetime.now().strftime("%Y-%m-%d")
            num = get_next_num(date_str)
            new_name = f"{date_str}_{num}.svgz"
            os.rename(item, SVGZ_DIR / new_name)
            item = SVGZ_DIR / new_name
            filename = new_name
            match = SCHEMA_RE.match(filename)

        y, m, d, num = match.groups()
        dest_dir = SVG_BASE / y / m / d
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest_file = dest_dir / f"{num}.svg"

        try:
            with gzip.open(item, 'rb') as f_in:
                processed = sanitize_svg(f_in.read())
                with open(dest_file, 'wb') as f_out:
                    f_out.write(processed)
            print(f"Processed: {dest_file}")
        except Exception as e:
            print(f"Failed {item}: {e}")


if __name__ == "__main__":
    process()
