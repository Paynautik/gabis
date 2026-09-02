"""Pull the marketing pages out of the Dart source into JSON.

Run once: the JSON becomes the single source both the Flutter app and the
static HTML generator read, so the site and the app can never drift apart.
"""
from __future__ import annotations

import json
import re
import sys

SRC = 'lib/features/marketing/marketing_content.dart'
OUT = 'assets/content/marketing.json'

src = open(SRC).read()
start = src.index('const marketingPages = <String, MarketingPage>{')
body = src[start:]


def dart_string(raw):
    """Join Dart adjacent string literals and unescape."""
    parts = re.findall(r"'((?:\\.|[^'\\])*)'", raw, re.S)
    text = ''.join(parts)
    return (text.replace("\\'", "'")
                .replace('\\n', '\n')
                .replace('\\u2019', '’')
                .replace('\\$', '$')
                .replace('\\\\', '\\'))


def split_top_level(text, sep=','):
    out, depth, quote, buf = [], 0, None, ''
    i = 0
    while i < len(text):
        ch = text[i]
        if quote:
            buf += ch
            if ch == '\\':
                buf += text[i + 1] if i + 1 < len(text) else ''
                i += 2
                continue
            if ch == quote:
                quote = None
        else:
            if ch in "'\"":
                quote = ch
                buf += ch
            elif ch in '([{':
                depth += 1
                buf += ch
            elif ch in ')]}':
                depth -= 1
                buf += ch
            elif ch == sep and depth == 0:
                out.append(buf)
                buf = ''
            else:
                buf += ch
        i += 1
    if buf.strip():
        out.append(buf)
    return out


def field(block, name):
    m = re.search(rf'\b{name}:\s*', block)
    if not m:
        return None
    rest = block[m.end():]
    return split_top_level(rest)[0]


def list_of(block, name, kind):
    raw = field(block, name)
    if not raw:
        return []
    open_at = raw.index('[')
    close_at = raw.rindex(']')
    inner = raw[open_at + 1:close_at]
    items = []
    for chunk in split_top_level(inner):
        chunk = chunk.strip()
        if not chunk:
            continue
        if kind == 'string':
            items.append(dart_string(chunk))
        elif kind == 'feature':
            args = split_top_level(chunk[chunk.index('(') + 1:chunk.rindex(')')])
            items.append({
                'icon': args[0].strip().replace('Icons.', ''),
                'title': dart_string(args[1]),
                'body': dart_string(args[2]),
            })
        elif kind == 'faq':
            args = split_top_level(chunk[chunk.index('(') + 1:chunk.rindex(')')])
            items.append({'question': dart_string(args[0]), 'answer': dart_string(args[1])})
        elif kind == 'section':
            args = split_top_level(chunk[chunk.index('(') + 1:chunk.rindex(')')])
            items.append({'heading': dart_string(args[0]), 'body': dart_string(args[1])})
    return items


pages = []
for m in re.finditer(r"'(/[a-z0-9-]+)':\s*MarketingPage\(", body):
    route = m.group(1)
    i = body.index('(', m.end() - 1)
    depth, j = 0, i
    while j < len(body):
        if body[j] == '(':
            depth += 1
        elif body[j] == ')':
            depth -= 1
            if depth == 0:
                break
        j += 1
    block = body[i + 1:j]

    page = {
        'route': route,
        'eyebrow': dart_string(field(block, 'eyebrow') or "''"),
        'title': dart_string(field(block, 'title') or "''"),
        'lede': dart_string(field(block, 'lede') or "''"),
        'highlights': list_of(block, 'highlights', 'string'),
        'features': list_of(block, 'features', 'feature'),
        'faqs': list_of(block, 'faqs', 'faq'),
        'sections': list_of(block, 'sections', 'section'),
    }
    cta_title = field(block, 'ctaTitle')
    cta_body = field(block, 'ctaBody')
    page['ctaTitle'] = dart_string(cta_title) if cta_title else 'Open your account'
    page['ctaBody'] = dart_string(cta_body) if cta_body else (
        'It takes a few minutes. Hold the currencies you actually use and move '
        'your first payment the same day.')
    pages.append(page)

json.dump({'pages': pages}, open(OUT, 'w'), indent=2, ensure_ascii=False)
print(f'{len(pages)} pages -> {OUT}')
if len(pages) != 22:
    sys.exit(f'expected 22 routes, found {len(pages)}')
