"""Generate crawlable HTML for every marketing route.

Flutter paints to a canvas, so none of the marketing copy exists in the DOM:
Google indexes nothing and a 3.4MB bundle has to load before a visitor on
Nigerian mobile data sees a word. These pages are ~10KB of real HTML served at
the same URLs, with the app one tap away.
"""
from __future__ import annotations

import html
import json
import os
import shutil

SITE = 'https://gabis.pages.dev'
OUT = 'web'
DATA = 'assets/content/marketing.json'

NAV = [
    ('Money', '/wallet'),
    ('Cards', '/virtual-cards'),
    ('Business', '/business'),
    ('Help', '/help'),
]

FOOTER = [
    ('Products', [('Multi-currency wallet', '/wallet'), ('Global USD account', '/usd-account'),
                  ('Virtual cards', '/virtual-cards'), ('Smart invoicing', '/invoicing'),
                  ('Instant FX swaps', '/fx'), ('Bills & airtime', '/bills')]),
    ('For business', [('gabis Business', '/business'), ('Tuition invoicing', '/tuition-invoicing'),
                      ('AI debt recovery', '/debt-recovery'),
                      ('Connected payments', '/connected-payments'),
                      ('Bulk payouts', '/bulk-payouts')]),
    ('Company', [('About gabis', '/about'), ('Careers', '/careers'),
                 ('Press & news', '/press'), ('Brand assets', '/brand')]),
    ('Legal', [('Terms of service', '/terms'), ('Privacy policy', '/privacy'),
               ('Security', '/security'), ('Tax compliance', '/tax-compliance')]),
    ('Support', [('Help centre', '/help'), ('Contact support', '/contact'),
                 ('System status', '/status')]),
]

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
:root{--ink:#101010;--cream:#F4F0E8;--white:#fff;--electric:#4C45FF;--lime:#D9FF43;
--sky:#BFE8FF;--coral:#FF7657;--lilac:#D9D0FF;--line:#E2DCD1;--soft:#6B6660}
html{-webkit-text-size-adjust:100%}
body{font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;background:var(--cream);
color:var(--ink);line-height:1.5;-webkit-font-smoothing:antialiased}
.wrap{max-width:1120px;margin:0 auto;padding:0 24px}
a{color:inherit}
header{border-bottom:1px solid var(--line)}
header .wrap{display:flex;align-items:center;gap:28px;height:72px}
.brand{font-size:22px;font-weight:800;letter-spacing:-.8px;text-decoration:none}
nav{display:flex;gap:20px;margin-left:12px;flex-wrap:wrap}
nav a{font-size:14px;font-weight:700;text-decoration:none}
.spacer{flex:1}
.btn{display:inline-block;background:var(--ink);color:var(--cream);text-decoration:none;
font-weight:800;font-size:14px;padding:14px 22px;border-radius:100px}
.btn.lime{background:var(--lime);color:var(--ink)}
.crumb{font-size:11.5px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase;
color:var(--soft);padding-top:44px}
h1{font-size:56px;line-height:.98;letter-spacing:-2.6px;font-weight:900;margin:18px 0 0}
.lede{font-size:18px;line-height:1.6;max-width:720px;margin-top:18px;color:#3a3733;font-weight:500}
.pills{display:flex;flex-wrap:wrap;gap:10px;margin-top:24px}
.pill{background:var(--lime);border:1.2px solid var(--ink);border-radius:100px;
padding:9px 13px;font-size:12.5px;font-weight:800}
.cta-row{margin:28px 0 8px}
.grid{display:grid;grid-template-columns:repeat(2,1fr);gap:14px;margin-top:40px}
.card{background:var(--white);border:1.3px solid var(--ink);border-radius:12px;padding:20px}
.card .dot{width:30px;height:30px;border:1.1px solid var(--ink);border-radius:8px;display:block}
.card h3{font-size:18px;font-weight:900;letter-spacing:-.6px;margin:14px 0 8px}
.card p{font-size:13.5px;line-height:1.5;color:#3a3733}
section.prose{max-width:860px;margin:56px auto 0}
section.prose h2{font-size:20px;font-weight:900;letter-spacing:-.7px;margin-bottom:9px}
section.prose p{font-size:15.5px;line-height:1.65;color:#3a3733;margin-bottom:26px}
.faq{max-width:860px;margin:56px auto 0}
.faq h2{font-size:10.5px;letter-spacing:1.6px;font-weight:900;color:var(--soft);margin-bottom:8px}
details{border-top:1px solid var(--line);padding:18px 0}
summary{font-size:16.5px;font-weight:800;letter-spacing:-.4px;cursor:pointer;list-style:none}
summary::-webkit-details-marker{display:none}
details p{margin-top:10px;font-size:15px;line-height:1.6;color:#3a3733}
.close{background:var(--ink);color:var(--cream);border-radius:20px;padding:40px;margin:64px 0}
.close h2{font-size:32px;font-weight:900;letter-spacing:-1.2px;color:var(--cream)}
.close p{margin:12px 0 22px;max-width:620px;color:rgba(244,240,232,.72);font-size:15.5px}
footer{background:var(--ink);color:var(--cream);padding:56px 0 40px}
footer .cols{display:grid;grid-template-columns:repeat(5,1fr);gap:28px}
footer h4{font-size:11.5px;letter-spacing:1.3px;font-weight:900;margin-bottom:14px}
footer a{display:block;font-size:13.5px;color:rgba(244,240,232,.58);text-decoration:none;margin-bottom:10px}
footer .legal{margin-top:40px;padding-top:22px;border-top:1px solid rgba(244,240,232,.14);
font-size:12.5px;color:rgba(244,240,232,.5);line-height:1.6}
@media(max-width:820px){h1{font-size:36px;letter-spacing:-1.4px}.grid{grid-template-columns:1fr}
footer .cols{grid-template-columns:repeat(2,1fr)}nav{display:none}}
"""

ACCENTS = ['var(--sky)', 'var(--lilac)', 'var(--lime)', 'var(--coral)']


def esc(text: str) -> str:
    return html.escape(text, quote=True)


def page_html(page: dict) -> str:
    route = page['route']
    title_plain = page['title'].replace('\n', ' ').strip().rstrip('.')
    meta_title = f"{title_plain} | gabis"
    desc = page['lede'].replace('\n', ' ')[:158]

    pills = ''.join(f'<span class="pill">{esc(h)}</span>' for h in page['highlights'])
    pills = f'<div class="pills">{pills}</div>' if pills else ''

    cards = ''
    for i, f in enumerate(page['features']):
        cards += (f'<article class="card"><span class="dot" style="background:'
                  f'{ACCENTS[i % len(ACCENTS)]}"></span><h3>{esc(f["title"])}</h3>'
                  f'<p>{esc(f["body"])}</p></article>')
    cards = f'<div class="grid">{cards}</div>' if cards else ''

    prose = ''.join(f'<h2>{esc(s["heading"])}</h2><p>{esc(s["body"])}</p>'
                    for s in page['sections'])
    prose = f'<section class="prose">{prose}</section>' if prose else ''

    faqs = ''.join(f'<details><summary>{esc(q["question"])}</summary>'
                   f'<p>{esc(q["answer"])}</p></details>' for q in page['faqs'])
    faqs = f'<section class="faq"><h2>FREQUENTLY ASKED</h2>{faqs}</section>' if faqs else ''

    nav = ''.join(f'<a href="{h}">{esc(t)}</a>' for t, h in NAV)

    cols = ''
    for heading, links in FOOTER:
        items = ''.join(f'<a href="{h}">{esc(t)}</a>' for t, h in links)
        cols += f'<div><h4>{esc(heading.upper())}</h4>{items}</div>'

    # Structured data: a real page a crawler can classify.
    ld = {
        '@context': 'https://schema.org',
        '@type': 'WebPage',
        'name': meta_title,
        'description': desc,
        'url': f'{SITE}{route}',
        'isPartOf': {'@type': 'WebSite', 'name': 'gabis', 'url': SITE},
        'publisher': {'@type': 'Organization', 'name': 'gabis', 'url': SITE},
    }
    if page['faqs']:
        ld = [ld, {
            '@context': 'https://schema.org',
            '@type': 'FAQPage',
            'mainEntity': [{
                '@type': 'Question',
                'name': q['question'],
                'acceptedAnswer': {'@type': 'Answer', 'text': q['answer']},
            } for q in page['faqs']],
        }]

    heading = esc(page['title']).replace('\n', '<br>')

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(meta_title)}</title>
<meta name="description" content="{esc(desc)}">
<link rel="canonical" href="{SITE}{route}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="gabis">
<meta property="og:title" content="{esc(meta_title)}">
<meta property="og:description" content="{esc(desc)}">
<meta property="og:url" content="{SITE}{route}">
<meta property="og:image" content="{SITE}/icons/Icon-512.png">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" type="image/png" href="/favicon.png">
<script type="application/ld+json">{json.dumps(ld)}</script>
<style>{CSS}</style>
</head>
<body>
<header><div class="wrap">
  <a class="brand" href="/">gabis</a>
  <nav>{nav}</nav>
  <span class="spacer"></span>
  <a class="btn" href="/login">Open your account</a>
</div></header>

<main class="wrap">
  <p class="crumb">{esc(page['eyebrow'])}</p>
  <h1>{heading}</h1>
  <p class="lede">{esc(page['lede'])}</p>
  {pills}
  <p class="cta-row"><a class="btn" href="{esc(page.get('ctaHref', '/login'))}">{esc(page.get('ctaLabel', 'Open your account'))}</a></p>
  {cards}
  {prose}
  {faqs}
  <section class="close">
    <h2>{esc(page['ctaTitle'])}</h2>
    <p>{esc(page['ctaBody'])}</p>
    <a class="btn lime" href="{esc(page.get('ctaHref', '/login'))}">{esc(page.get('ctaLabel', 'Open your account'))}</a>
  </section>
</main>

<footer><div class="wrap">
  <div class="cols">{cols}</div>
  <p class="legal">gabis is a financial technology company, not a bank. Money remittance
  and banking services are provided by our licensed financial institution partners.<br>
  &copy; 2026 gabis</p>
</div></footer>
</body>
</html>
"""


def main() -> None:
    data = json.load(open(DATA))

    # Written flat as <route>.html: Cloudflare Pages serves those at /<route>
    # with a 200, where a _redirects rewrite to a folder answered 308 and moved
    # the visitor to a different URL.
    routes = []
    for page in data['pages']:
        route = page['route']
        with open(os.path.join(OUT, route.strip('/') + '.html'), 'w') as fh:
            fh.write(page_html(page))
        routes.append(route)

    # Sitemap and robots, so the pages are discoverable rather than merely
    # crawlable.
    urls = ''.join(
        f'<url><loc>{SITE}{r}</loc><changefreq>monthly</changefreq></url>'
        for r in ['/'] + routes)
    with open('web/sitemap.xml', 'w') as fh:
        fh.write('<?xml version="1.0" encoding="UTF-8"?>'
                 '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
                 f'{urls}</urlset>')
    with open('web/robots.txt', 'w') as fh:
        fh.write(f'User-agent: *\nAllow: /\nSitemap: {SITE}/sitemap.xml\n')

    # The static pages win by existing; everything unmatched is the app.
    with open('web/_redirects', 'w') as fh:
        fh.write('# Marketing routes are real files (wallet.html, terms.html …).\n'
                 '# Anything else belongs to the Flutter app.\n'
                 '/*    /index.html    200\n')

    print(f'{len(routes)} static pages -> {OUT}')


if __name__ == '__main__':
    main()
