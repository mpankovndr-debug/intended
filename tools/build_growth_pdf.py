#!/usr/bin/env python3
"""Build a phone-readable PDF from the Intended growth + store-copy docs.

The plan changes weekly, so this exists to reprint it rather than to be run
once. Needs `markdown` (and `pypdf` for the self-check); everything else is
headless Chrome, which is already on the machine.

    python3 -m venv /tmp/pdfvenv
    /tmp/pdfvenv/bin/pip install markdown pypdf
    /tmp/pdfvenv/bin/python tools/build_growth_pdf.py

Output is gitignored — it's derived from the markdown, which is the source.
"""
import subprocess, sys, pathlib, datetime, tempfile
import markdown

REPO = pathlib.Path(__file__).resolve().parent.parent
OUT = REPO / "Intended-Growth-Kit.pdf"
SCRATCH = pathlib.Path(tempfile.mkdtemp(prefix="growthkit-"))

DOCS = [
    ("INTENDED_GROWTH_PLAN_2026-08.md", "Growth Plan",
     "The distribution plan: the arithmetic, the App Store, the content engine."),
    ("APP_STORE_COPY_V2.md", "App Store Copy",
     "Description, promotional text and What's New — English and Russian."),
    ("APP_STORE_PANELS_RU.md", "Screenshot Panels — RU",
     "Russian for the six promo panels, with the layout notes."),
]

md = markdown.Markdown(extensions=["tables", "fenced_code", "toc", "sane_lists"])

CSS = """
@page { size: 6in 9in; margin: 14mm 13mm 15mm 13mm; }
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body {
  margin: 0;
  font: 10.5pt/1.55 "Helvetica Neue", -apple-system, Arial, sans-serif;
  color: #1b1a19; background: #fff;
  overflow-wrap: break-word; hyphens: auto;
}

/* ---- cover ---- */
.cover { height: calc(9in - 29mm); display: flex; flex-direction: column;
         justify-content: center; page-break-after: always; }
.cover .sq { display: flex; gap: 6px; margin-bottom: 22px; }
.cover .sq i { width: 15px; height: 15px; border-radius: 4px; display: block; }
.cover h1 { font: 600 30pt/1.1 Georgia, "Times New Roman", serif; margin: 0 0 10px; letter-spacing: -.5px; }
.cover .sub { font-size: 12pt; color: #5d5a56; margin: 0 0 34px; max-width: 30em; }
.cover .meta { font-size: 8.5pt; color: #8a857f; letter-spacing: .06em; text-transform: uppercase; }
.cover ol { margin: 0 0 34px; padding-left: 1.1em; font-size: 11pt; color: #33312e; }
.cover ol li { margin-bottom: 7px; }
.cover ol li span { color: #8a857f; font-size: 9.5pt; display: block; }

/* ---- document divider ---- */
.docstart { page-break-before: always; }
.docstart .eyebrow { font-size: 8pt; letter-spacing: .14em; text-transform: uppercase;
                     color: #b06a4f; margin-bottom: 8px; }

/* ---- typography ---- */
h1, h2, h3, h4 { font-family: Georgia, "Times New Roman", serif; font-weight: 600;
                 line-height: 1.2; margin: 0 0 8px; page-break-after: avoid; }
h1 { font-size: 20pt; margin-top: 0; letter-spacing: -.3px; }
h2 { font-size: 14pt; margin-top: 22px; padding-top: 9px; border-top: 1.5px solid #e6e1da; }
h3 { font-size: 11.5pt; margin-top: 16px; }
h4 { font-size: 10.5pt; margin-top: 13px; color: #4a4642; }
p, ul, ol, blockquote, table, pre { margin: 0 0 9px; }
ul, ol { padding-left: 1.15em; }
li { margin-bottom: 4px; }
strong { font-weight: 600; }
em { font-style: italic; }
a { color: #1b1a19; text-decoration: none; border-bottom: .5px solid #c9c2b8; }

hr { border: 0; border-top: 1px solid #e6e1da; margin: 16px 0; }

blockquote { border-left: 2.5px solid #b06a4f; padding: 2px 0 2px 12px;
             margin-left: 0; color: #3d3a36; page-break-inside: avoid; }
blockquote h3 { margin-top: 2px; font-size: 12pt; }
blockquote p { margin-bottom: 5px; }
blockquote > :last-child { margin-bottom: 0; }

code { font: 9pt/1.4 "SF Mono", Menlo, Consolas, monospace;
       background: #f2efea; padding: 1px 3.5px; border-radius: 3px; }
pre { background: #f7f5f1; border: .5px solid #e6e1da; border-radius: 5px;
      padding: 9px 11px; white-space: pre-wrap; word-break: break-word;
      page-break-inside: avoid; }
pre code { background: none; padding: 0; font-size: 8.6pt; line-height: 1.5; }

table { width: 100%; border-collapse: collapse; font-size: 8.8pt;
        page-break-inside: avoid; margin-bottom: 11px; }
th { text-align: left; font-weight: 600; background: #f2efea;
     border-bottom: 1px solid #ddd6cc; padding: 5px 7px; }
td { padding: 5px 7px; border-bottom: .5px solid #ebe6df; vertical-align: top; }
td code, th code { font-size: 8pt; }

/* keep short sections together where we can */
h2 + p, h3 + p, h2 + table, h3 + table { page-break-before: avoid; }
"""

SQUARES = ["#E07A5F", "#8B7BB8", "#7A9A6D"]  # coral / violet / sage


def build_cover():
    today = datetime.date.today().strftime("%d %B %Y")
    sq = "".join(f'<i style="background:{c}"></i>' for c in SQUARES)
    items = "".join(
        f"<li>{t}<span>{d}</span></li>" for _, t, d in DOCS)
    return f"""
<div class="cover">
  <div class="sq">{sq}</div>
  <h1>Intended — Growth Kit</h1>
  <p class="sub">Everything decided so far about getting Intended in front of
     people, and the App Store copy that goes with the v2 submission.</p>
  <ol>{items}</ol>
  <p class="meta">Compiled {today} &nbsp;·&nbsp; read on the repo at
     INTENDED_GROWTH_PLAN_2026-08.md</p>
</div>"""


def convert(path, title):
    raw = (REPO / path).read_text(encoding="utf-8")
    # the repo files open with an H1; keep it but tag the section start
    md.reset()
    body = md.convert(raw)
    return f'<div class="docstart"><p class="eyebrow">{title}</p>{body}</div>'


def main():
    parts = [build_cover()] + [convert(p, t) for p, t, _ in DOCS]
    html = ("<!doctype html><html><head><meta charset='utf-8'>"
            f"<title>Intended — Growth Kit</title><style>{CSS}</style></head>"
            f"<body>{''.join(parts)}</body></html>")
    htmlfile = SCRATCH / "growth-kit.html"
    htmlfile.write_text(html, encoding="utf-8")

    chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    subprocess.run([
        chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer",
        f"--print-to-pdf={OUT}", "--virtual-time-budget=8000",
        htmlfile.as_uri(),
    ], check=True, capture_output=True)

    from pypdf import PdfReader
    r = PdfReader(str(OUT))
    txt = "".join((p.extract_text() or "") for p in r.pages)
    print(f"pages: {len(r.pages)}   size: {OUT.stat().st_size/1024:.0f} KB")
    print(f"chars extracted: {len(txt)}")
    for probe in ["Intended — Growth Kit", "No streaks to protect",
                  "Никаких серий", "Затихать", "tracker,journal,ritual",
                  "Intended: No Streaks Habits", "blahblah"]:
        print(("  ok  " if probe in txt else "  MISSING  ") + repr(probe))


if __name__ == "__main__":
    sys.exit(main())
