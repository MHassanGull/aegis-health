# -*- coding: utf-8 -*-
"""Build the Aegis Health final-year project report as a .docx.

Every figure and every number is pulled from the repository or from the
training report, so rebuilding after a retrain keeps the document honest:

    python _build/build_report.py
"""
import json
from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "docs" / "assets"
OUT = ROOT / "docs" / "Aegis_Health_FYP_Report.docx"

INK = RGBColor(0x1B, 0x27, 0x33)
MUTED = RGBColor(0x5B, 0x6B, 0x7C)
ACCENT = RGBColor(0x1F, 0x3B, 0x5C)

# ---------------------------------------------------------------- live data
rep = json.loads((ROOT / "ml" / "reports" / "sprint3_report.json").read_text())
DIA = rep["final"]["Diabetes_binary"]
KID = rep["final"]["Kidney_binary"]
CV = rep["cv"]
PREV = rep["prevalence"]
N_RECORDS = f"{rep['records']:,}"
N_FEATS = len(rep["features"])

FIGS = []   # (number, caption)
TABLES = []  # (number, caption)


# ------------------------------------------------------------------ helpers
def style_doc(doc):
    n = doc.styles["Normal"]
    n.font.name = "Times New Roman"
    n.font.size = Pt(12)
    n.font.color.rgb = INK
    n.paragraph_format.space_after = Pt(6)
    n.paragraph_format.line_spacing = 1.15
    rpr = n.element.get_or_add_rPr()
    rf = OxmlElement("w:rFonts")
    for a in ("w:ascii", "w:hAnsi", "w:cs"):
        rf.set(qn(a), "Times New Roman")
    rpr.append(rf)


def para(doc, text="", size=12, bold=False, italic=False, align=None,
         color=None, space_before=0, space_after=6, line=1.15):
    p = doc.add_paragraph()
    if align is not None:
        p.alignment = align
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = line
    if text:
        r = p.add_run(text)
        r.font.size = Pt(size)
        r.bold = bold
        r.italic = italic
        r.font.color.rgb = color or INK
    return p


def heading(doc, text, level=1):
    sizes = {1: 16, 2: 13.5, 3: 12}
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(16 if level == 1 else 12)
    p.paragraph_format.space_after = Pt(8 if level == 1 else 6)
    p.paragraph_format.keep_with_next = True
    r = p.add_run(text)
    r.bold = True
    r.font.size = Pt(sizes[level])
    r.font.color.rgb = ACCENT if level == 1 else INK
    return p


def chapter(doc, number, title):
    doc.add_page_break()
    para(doc, f"CHAPTER {number}", size=11, bold=True, color=MUTED,
         space_after=2)
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(14)
    r = p.add_run(title)
    r.bold = True
    r.font.size = Pt(19)
    r.font.color.rgb = ACCENT
    rule(doc)


def rule(doc):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(10)
    pPr = p._p.get_or_add_pPr()
    bdr = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "8")
    bottom.set(qn("w:color"), "1F3B5C")
    bdr.append(bottom)
    pPr.append(bdr)


def figure(doc, filename, caption, width_cm=15.5):
    path = ASSETS / filename
    if not path.exists():
        para(doc, f"[missing figure: {filename}]", italic=True, color=MUTED,
             align=WD_ALIGN_PARAGRAPH.CENTER)
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(4)
    p.add_run().add_picture(str(path), width=Cm(width_cm))
    n = len(FIGS) + 1
    FIGS.append((n, caption))
    c = doc.add_paragraph()
    c.alignment = WD_ALIGN_PARAGRAPH.CENTER
    c.paragraph_format.space_after = Pt(12)
    r = c.add_run(f"Figure {n}: {caption}")
    r.font.size = Pt(10)
    r.italic = True
    r.font.color.rgb = MUTED


def table(doc, caption, headers, rows, widths=None):
    n = len(TABLES) + 1
    TABLES.append((n, caption))
    c = doc.add_paragraph()
    c.paragraph_format.space_before = Pt(10)
    c.paragraph_format.space_after = Pt(4)
    r = c.add_run(f"Table {n}: {caption}")
    r.font.size = Pt(10)
    r.italic = True
    r.font.color.rgb = MUTED

    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Table Grid"
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr = t.rows[0].cells
    for i, h in enumerate(headers):
        hdr[i].text = ""
        pr = hdr[i].paragraphs[0]
        run = pr.add_run(h)
        run.bold = True
        run.font.size = Pt(10)
        run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        shd = OxmlElement("w:shd")
        shd.set(qn("w:fill"), "1F3B5C")
        hdr[i]._tc.get_or_add_tcPr().append(shd)
    for row in rows:
        cells = t.add_row().cells
        for i, v in enumerate(row):
            cells[i].text = ""
            run = cells[i].paragraphs[0].add_run(str(v))
            run.font.size = Pt(10)
    if widths:
        for r_ in t.rows:
            for i, w in enumerate(widths):
                r_.cells[i].width = Cm(w)
    doc.add_paragraph().paragraph_format.space_after = Pt(8)
    return t


def bullets(doc, items, size=12):
    for it in items:
        p = doc.add_paragraph(style="List Bullet")
        p.paragraph_format.space_after = Pt(4)
        r = p.add_run(it)
        r.font.size = Pt(size)
        r.font.color.rgb = INK


def page_footer(section, text):
    f = section.footer.paragraphs[0]
    f.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = f.add_run(text)
    r.font.size = Pt(9)
    r.font.color.rgb = MUTED
    r.font.name = "Times New Roman"


# ==========================================================  FRONT MATTER
def front_matter(doc):
    # --- Cover -----------------------------------------------------------
    if (ASSETS / "bismillah.png").exists():
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(30)
        p.add_run().add_picture(str(ASSETS / "bismillah.png"), width=Cm(9))

    para(doc, "", space_after=20)
    para(doc, "FINAL YEAR DESIGN PROJECT REPORT", size=13, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, color=MUTED, space_after=18)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("Aegis Health")
    r.bold = True
    r.font.size = Pt(30)
    r.font.color.rgb = ACCENT

    para(doc, "A Preventive Risk-Screening System for Type 2 Diabetes\n"
              "and Chronic Kidney Disease",
         size=14, align=WD_ALIGN_PARAGRAPH.CENTER, color=INK, space_after=24)

    # The title page carries the degree-awarding university's crest alone. The
    # college crest appears on the approval certificate instead, where it sits
    # with the signatures it belongs to.
    if (ASSETS / "logo_university.png").exists():
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(20)
        p.add_run().add_picture(str(ASSETS / "logo_university.png"), width=Cm(5.2))

    para(doc, "Submitted by", size=11, italic=True, color=MUTED,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    para(doc, "Muhammad Hassan            2716", size=13, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    para(doc, "Muhammad Rohan Ashraf            2720", size=13, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)

    para(doc, "Supervised by", size=11, italic=True, color=MUTED,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    para(doc, "Prof. Hafiz Shahzad", size=13, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_after=18)

    para(doc, "Bachelor of Science in Information Technology (2022 – 2026)",
         size=12, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=4)
    para(doc, "Department of Information Technology",
         size=12, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    para(doc, "Govt. Graduate College Gulberg (Boys), Lahore",
         size=12, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    para(doc, "University of the Punjab, Lahore, Pakistan",
         size=12, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=2)
    para(doc, "2026", size=12, bold=True,
         align=WD_ALIGN_PARAGRAPH.CENTER, space_before=10)

    # --- Declaration ------------------------------------------------------
    doc.add_page_break()
    heading(doc, "Declaration")
    rule(doc)
    para(doc,
         "We hereby declare that this software, neither as a whole nor in part, "
         "has been copied from any source. It is further declared that we have "
         "developed this software and the accompanying report entirely on the "
         "basis of our own efforts. If any part of this project is proved to "
         "have been copied, or found to be a reproduction of some other work, "
         "we shall stand by the consequences.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "No portion of the work presented here has been submitted in support "
         "of any other application for any degree or qualification at this or "
         "any other university or institute of learning.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=36)

    t = doc.add_table(rows=2, cols=2)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, name in enumerate(["Muhammad Hassan  (2716)",
                              "Muhammad Rohan Ashraf  (2720)"]):
        t.cell(0, i).text = "Signature: ______________________"
        t.cell(1, i).text = name
        for row in (0, 1):
            for r_ in t.cell(row, i).paragraphs[0].runs:
                r_.font.size = Pt(11)

    # --- Certificate of approval -----------------------------------------
    doc.add_page_break()
    # The college crest sits here rather than on the title page, small and
    # centred above the heading, the way a crest sits on institutional
    # letterhead. This is the page that carries the signatures, so it is the
    # page where the awarding college belongs.
    if (ASSETS / "logo_college.png").exists():
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(2)
        p.add_run().add_picture(str(ASSETS / "logo_college.png"), height=Cm(2.2))
        para(doc, "Govt. Graduate College Gulberg (Boys), Lahore",
             size=9, italic=True, color=MUTED,
             align=WD_ALIGN_PARAGRAPH.CENTER, space_after=4)
        para(doc, "Affiliated with the University of the Punjab",
             size=9, italic=True, color=MUTED,
             align=WD_ALIGN_PARAGRAPH.CENTER, space_after=10)

    heading(doc, "Certificate of Approval")
    rule(doc)
    para(doc,
         "It is certified that the Final Year Design Project titled "
         "“Aegis Health: A Preventive Risk-Screening System for Type 2 "
         "Diabetes and Chronic Kidney Disease” was developed by "
         "Muhammad Hassan (2716) and Muhammad Rohan Ashraf (2720) under the "
         "supervision of Prof. Hafiz Shahzad.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "In our opinion it is fully adequate, in scope and in quality, for "
         "the award of the degree of Bachelor of Science in Information "
         "Technology.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=40)

    para(doc, "Signature: ______________________________", space_after=2)
    para(doc, "Prof. Hafiz Shahzad — FYDP Supervisor", size=11, bold=True,
         space_after=28)

    para(doc, "Faculty Advisory Committee", size=11, bold=True, color=MUTED,
         space_after=10)
    t = doc.add_table(rows=2, cols=2)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.cell(0, 0).text = "Signature: ____________________"
    t.cell(0, 1).text = "Signature: ____________________"
    t.cell(1, 0).text = "Prof. Hafiz Shahzad  (FAC 1)"
    t.cell(1, 1).text = "Prof. Muhammad Fahim  (FAC 2)"
    for row in t.rows:
        for c in row.cells:
            for r_ in c.paragraphs[0].runs:
                r_.font.size = Pt(11)

    para(doc, "", space_after=28)
    para(doc, "Signature: ______________________________", space_after=2)
    para(doc, "Head of FYDP Coordination Office", size=11, bold=True,
         space_after=24)
    para(doc, "Signature: ______________________________", space_after=2)
    para(doc, "Chairperson, Department of Information Technology",
         size=11, bold=True, space_after=20)
    para(doc, "Dated: ______________________", size=11, color=MUTED)

    # --- Acknowledgement --------------------------------------------------
    doc.add_page_break()
    heading(doc, "Acknowledgement")
    rule(doc)
    para(doc,
         "All praise is due to Allah Almighty, the Most Gracious and the Most "
         "Merciful, who granted us the health, patience and clarity of mind "
         "needed to see this project through.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "We are deeply grateful to our supervisor, Prof. Hafiz Shahzad. His "
         "guidance changed the direction of this project at a decisive moment: "
         "an early design of ours would have predicted disease stage from "
         "laboratory values using a formula we had written ourselves, which "
         "would have taught the model nothing except our own rule. Being "
         "pushed to question that assumption is the reason this project "
         "predicts future risk from lifestyle instead, and it is the single "
         "most valuable lesson we take from the year.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "We thank Prof. Muhammad Fahim and the faculty of the Department of "
         "Information Technology for their feedback during evaluations, and "
         "our families for their patience over many long evenings.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "Finally we acknowledge the open-source communities behind Python, "
         "Django, scikit-learn, Flutter and PostgreSQL, and the United States "
         "Centers for Disease Control and Prevention, whose Behavioral Risk "
         "Factor Surveillance System made this work possible by publishing "
         f"{N_RECORDS} anonymised survey responses for public research.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY, space_after=30)

    para(doc, "Muhammad Hassan  (2716)", size=11, bold=True, space_after=2)
    para(doc, "Muhammad Rohan Ashraf  (2720)", size=11, bold=True, space_after=2)
    para(doc, "BSIT, 8th Semester — 2026", size=11, italic=True, color=MUTED)

    # --- Abstract ---------------------------------------------------------
    doc.add_page_break()
    heading(doc, "Abstract")
    rule(doc)
    para(doc,
         "Type 2 diabetes and chronic kidney disease are among the most costly "
         "chronic conditions in Pakistan, and both share a property that makes "
         "them unusually suitable for software intervention: they develop "
         "silently over years, and the risk factors that drive them are "
         "behavioural rather than genetic. By the time a patient presents with "
         "symptoms, irreversible damage has often already occurred. Screening "
         "exists, but it depends on laboratory tests that cost money, require "
         "travel, and are therefore taken mainly by people who already suspect "
         "they are unwell.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "This report presents Aegis Health, a mobile screening system that "
         "estimates a person's future risk of both conditions from nineteen "
         "questions about how they live, with no blood test and no clinical "
         "measurement. A single multi-task neural network with one shared "
         f"backbone and two output heads was trained on {N_RECORDS} anonymised "
         "responses from the CDC Behavioral Risk Factor Surveillance System. "
         "Sharing a backbone is a deliberate modelling decision rather than an "
         "optimisation: diabetes is a leading cause of chronic kidney disease, "
         "so the two tasks genuinely share structure, and one model learns "
         "that relationship where two separate models could not.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         f"On a held-out test set the model reaches a ROC-AUC of "
         f"{DIA['roc_auc']:.3f} for diabetes and {KID['roc_auc']:.3f} for "
         f"kidney disease, catching {DIA['recall']*100:.0f}% and "
         f"{KID['recall']*100:.0f}% of true cases respectively at its screening "
         "thresholds. Accuracy is deliberately not reported as a headline "
         "figure. Both conditions are rare in the population, so a model that "
         "answered “no” to every person would score above ninety per cent "
         "while identifying nobody. Probabilities are calibrated by isotonic "
         "regression, so a predicted thirty per cent risk corresponds to an "
         "observed frequency near thirty per cent, and results are validated "
         f"by {rep['n_folds']}-fold stratified cross-validation rather than a "
         "single fortunate split.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "Every prediction is accompanied by an explanation and by advice. An "
         "occlusion analysis re-runs the model with each answer neutralised in "
         "turn to rank the factors driving that individual's risk, and a "
         "what-if engine simulates realistic habit changes and reports the "
         "projected reduction for each. The system is delivered as a Flutter "
         "application on Android talking to a Django REST Framework service "
         "deployed on Render over PostgreSQL, with JSON Web Token "
         "authentication, on-device reminders that work without a network, and "
         "a conversational assistant that grounds its replies in the user's "
         "most recent result.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY)
    para(doc,
         "Aegis Health is an educational screening aid. It does not diagnose "
         "disease and it does not replace a clinician.",
         align=WD_ALIGN_PARAGRAPH.JUSTIFY, italic=True)
    para(doc, "", space_after=8)
    para(doc,
         "Keywords: preventive screening, multi-task learning, neural network, "
         "probability calibration, explainable artificial intelligence, "
         "class imbalance, mobile health, Flutter, Django REST Framework.",
         size=11, italic=True, color=MUTED, align=WD_ALIGN_PARAGRAPH.JUSTIFY)


def contents(doc):
    # ===================================================== CONTENTS
    doc.add_page_break()
    heading(doc, "Table of Contents")
    rule(doc)
    toc = [
        ("Declaration", "ii"), ("Certificate of Approval", "iii"),
        ("Acknowledgement", "iv"), ("Abstract", "v"),
        ("List of Figures", "vii"), ("List of Tables", "viii"), ("", ""),
        ("Chapter 1 — Introduction", "1"),
        ("    1.1  Background", "1"),
        ("    1.2  Problem Statement", "2"),
        ("    1.3  Objectives", "2"),
        ("    1.4  Scope and Delimitations", "3"),
        ("    1.5  Significance", "3"), ("", ""),
        ("Chapter 2 — Literature Review", "4"),
        ("    2.1  Existing Systems", "4"),
        ("    2.2  Comparative Analysis", "5"),
        ("    2.3  Research Gap", "5"),
        ("    2.4  The Flaw We Corrected", "6"), ("", ""),
        ("Chapter 3 — System Analysis and Design", "7"),
        ("    3.1  Requirement Analysis", "7"),
        ("    3.2  Functional Requirements", "8"),
        ("    3.3  Non-Functional Requirements", "9"),
        ("    3.4  Use-Case Model", "10"),
        ("    3.5  Activity Model", "11"),
        ("    3.6  System Architecture", "12"),
        ("    3.7  Class Design", "13"),
        ("    3.8  Database Design", "14"), ("", ""),
        ("Chapter 4 — Implementation", "16"),
        ("    4.1  Development Methodology", "16"),
        ("    4.2  Technologies and Justification", "17"),
        ("    4.3  The Machine-Learning Core", "18"),
        ("    4.4  Explanation and What-If Engines", "20"),
        ("    4.5  REST API", "21"),
        ("    4.6  Mobile Application", "22"),
        ("    4.7  Deployment", "24"), ("", ""),
        ("Chapter 5 — Testing and Results", "25"),
        ("    5.1  Testing Methodology", "25"),
        ("    5.2  Test Cases", "25"),
        ("    5.3  Model Results", "27"),
        ("    5.4  Why Accuracy Is Not Reported", "28"),
        ("    5.5  Calibration and Threshold Selection", "29"),
        ("    5.6  Performance Evaluation", "30"), ("", ""),
        ("Chapter 6 — Conclusion and Future Work", "31"),
        ("References", "32"),
        ("Appendix A — API Reference", "33"),
        ("Appendix B — User Manual", "34"),
    ]
    for label, page in toc:
        if not label:
            para(doc, "", space_after=4)
            continue
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.tab_stops.add_tab_stop(Cm(15.2))
        r = p.add_run(label + "\t" + page)
        r.font.size = Pt(11)
        r.bold = not label.startswith(" ")



def lists_of(doc, figs, tabs):
    """The figure and table indexes, emitted last so the counters are final."""
    doc.add_page_break()
    heading(doc, "List of Figures")
    rule(doc)
    for n, cap in figs:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.tab_stops.add_tab_stop(Cm(15.2))
        r = p.add_run(f"Figure {n}	{cap}")
        r.font.size = Pt(11)

    doc.add_page_break()
    heading(doc, "List of Tables")
    rule(doc)
    for n, cap in tabs:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.tab_stops.add_tab_stop(Cm(15.2))
        r = p.add_run(f"Table {n}	{cap}")
        r.font.size = Pt(11)


# ==============================================================  ASSEMBLE
def _new_doc():
    doc = Document()
    style_doc(doc)
    sec = doc.sections[0]
    sec.top_margin = Cm(2.4)
    sec.bottom_margin = Cm(2.2)
    sec.left_margin = Cm(2.6)
    sec.right_margin = Cm(2.2)
    page_footer(sec, "Aegis Health  |  BSIT Final Year Design Project  |  2026")
    return doc


def main():
    import report_chapters
    data = {"DIA": DIA, "KID": KID, "CV": CV, "PREV": PREV,
            "N_RECORDS": N_RECORDS, "N_FEATS": N_FEATS, "REP": rep,
            "MUTED": MUTED}

    # Pass one is thrown away. Its only job is to number every figure and
    # table, so that pass two can print the indexes in the front matter where
    # a reader expects them rather than orphaned at the back.
    report_chapters.build(_new_doc(), heading, para, bullets, table, figure,
                          chapter, rule, data)
    figs, tabs = list(FIGS), list(TABLES)
    FIGS.clear(); TABLES.clear()

    doc = _new_doc()
    front_matter(doc)
    contents(doc)
    lists_of(doc, figs, tabs)
    report_chapters.build(doc, heading, para, bullets, table, figure,
                          chapter, rule, data)

    assert [c for _, c in FIGS] == [c for _, c in figs], "figure numbering drifted"
    assert [c for _, c in TABLES] == [c for _, c in tabs], "table numbering drifted"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUT)
    print(f"Wrote {OUT}")
    print(f"  figures: {len(FIGS)}   tables: {len(TABLES)}")


if __name__ == "__main__":
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    main()
