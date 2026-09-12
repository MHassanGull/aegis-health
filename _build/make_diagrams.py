# -*- coding: utf-8 -*-
"""Generate clean, professional diagrams for the AI Medical Assist documentation."""
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.lines import Line2D

OUT = os.path.dirname(os.path.abspath(__file__))

# ---- Palette ------------------------------------------------------------
NAVY   = "#1F3B5C"
BLUE   = "#2E6DB4"
TEAL   = "#1A9E8F"
AMBER  = "#E8A13A"
SLATE  = "#54657A"
LIGHT  = "#EAF1F8"
LIGHT2 = "#E5F4F1"
LIGHT3 = "#FBF1DD"
GREY   = "#F2F4F7"
INK    = "#1B2733"
WHITE  = "#FFFFFF"

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 11,
})


def box(ax, x, y, w, h, text, face, edge, tc=INK, fs=11, bold=False, rad=0.018):
    p = FancyBboxPatch((x, y), w, h,
                       boxstyle=f"round,pad=0.004,rounding_size={rad}",
                       linewidth=1.4, edgecolor=edge, facecolor=face, zorder=2)
    ax.add_patch(p)
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center",
            color=tc, fontsize=fs, fontweight="bold" if bold else "normal",
            zorder=3, wrap=True)


def arrow(ax, x1, y1, x2, y2, color=SLATE, style="-|>", lw=1.6, ls="-"):
    a = FancyArrowPatch((x1, y1), (x2, y2), arrowstyle=style,
                        mutation_scale=16, linewidth=lw, color=color,
                        linestyle=ls, zorder=1, shrinkA=2, shrinkB=2)
    ax.add_patch(a)


def base(figsize):
    fig, ax = plt.subplots(figsize=figsize)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis("off")
    return fig, ax


def save(fig, name):
    path = os.path.join(OUT, name)
    fig.savefig(path, dpi=200, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("wrote", path)


# =========================================================================
# FIG 1 — High-Level System Architecture (layered)
# =========================================================================
def fig_architecture():
    fig, ax = base((9.2, 6.6))

    # Presentation layer
    box(ax, 6, 80, 88, 13, "", LIGHT, BLUE)
    ax.text(9, 90.5, "PRESENTATION LAYER", color=BLUE, fontsize=10.5, fontweight="bold")
    box(ax, 12, 81.5, 33, 7, "Flutter Mobile App\n(Clean Architecture UI)", WHITE, BLUE, fs=10)
    box(ax, 55, 81.5, 33, 7, "Lifestyle Questionnaire\n& Risk Dashboard", WHITE, BLUE, fs=10)

    # Application / API layer
    box(ax, 6, 58, 88, 17, "", GREY, NAVY)
    ax.text(9, 72.5, "APPLICATION LAYER  -  Django REST Framework (Modular Monolith)", color=NAVY, fontsize=10.5, fontweight="bold")
    box(ax, 10, 60, 18, 9, "JWT Auth &\nUser Service", WHITE, NAVY, fs=9.5)
    box(ax, 31, 60, 18, 9, "Prediction\nService", WHITE, NAVY, fs=9.5)
    box(ax, 52, 60, 18, 9, "Explainability\nService", WHITE, NAVY, fs=9.5)
    box(ax, 73, 60, 17, 9, "Advisory\nService", WHITE, NAVY, fs=9.5)

    # Intelligence layer
    box(ax, 6, 35, 88, 19, "", LIGHT2, TEAL)
    ax.text(9, 51.5, "INTELLIGENCE LAYER", color=TEAL, fontsize=10.5, fontweight="bold")
    box(ax, 10, 37.5, 24, 11, "Multi-Task ML Engine\nDiabetes + Kidney\nRisk Prediction", WHITE, TEAL, fs=9.5)
    box(ax, 37, 37.5, 22, 11, "SHAP\nExplainability\n(Top Risk Factors)", WHITE, TEAL, fs=9.5)
    box(ax, 62, 37.5, 28, 11, "What-If Engine\n(Counterfactual\nRecommendations)", WHITE, TEAL, fs=9.5)

    # Data + external
    box(ax, 6, 12, 42, 18, "", LIGHT3, AMBER)
    ax.text(9, 27.5, "DATA LAYER", color="#B8801F", fontsize=10.5, fontweight="bold")
    box(ax, 10, 14, 16, 10, "PostgreSQL\n(Users, History)", WHITE, AMBER, fs=9.5)
    box(ax, 29, 14, 16, 10, "Trained Model\nArtifacts", WHITE, AMBER, fs=9.5)

    box(ax, 52, 12, 42, 18, "", "#F4EEF6", "#7E57A6")
    ax.text(55, 27.5, "EXTERNAL SERVICES", color="#7E57A6", fontsize=10.5, fontweight="bold")
    box(ax, 56, 14, 16, 10, "Gemini API\n(Health Chat)", WHITE, "#7E57A6", fs=9.5)
    box(ax, 75, 14, 16, 10, "Google Maps\n(Doctor Lookup)", WHITE, "#7E57A6", fs=9.5)

    # connecting arrows
    arrow(ax, 50, 80, 50, 75.2, color=SLATE, style="<|-|>")
    arrow(ax, 50, 58, 50, 54.3, color=SLATE, style="<|-|>")
    arrow(ax, 27, 35, 18, 30.2, color=SLATE, style="<|-|>")
    arrow(ax, 70, 35, 78, 30.2, color=SLATE, style="<|-|>")
    save(fig, "fig1_architecture.png")


# =========================================================================
# FIG 2 — Predictive ML Pipeline (Health Time Machine)
# =========================================================================
def fig_ml_pipeline():
    fig, ax = base((9.4, 4.5))
    y = 56
    h = 22
    xs = [2, 21.5, 41, 60.5, 80]
    w = 17.5
    steps = [
        ("1. Lifestyle Input\n\nAge, BMI, activity,\ndiet, sleep, smoking,\nfamily history", LIGHT, BLUE),
        ("2. Preprocessing\n\nClean, encode,\nbalance classes\n(SMOTE / weights)", GREY, NAVY),
        ("3. Multi-Task Model\n\nShared backbone\n+ two risk heads", LIGHT2, TEAL),
        ("4. Risk Scores\n\nFuture Diabetes %\nFuture Kidney %\n+ risk tier", LIGHT3, AMBER),
        ("5. Explain & Advise\n\nSHAP factors +\nWhat-If actions", "#F4EEF6", "#7E57A6"),
    ]
    for (x, (t, f, e)) in zip(xs, steps):
        box(ax, x, y, w, h, t, f, e, fs=8.6)
    for i in range(4):
        arrow(ax, xs[i] + w, y + h / 2, xs[i + 1], y + h / 2, color=SLATE)

    # training data note
    box(ax, 2, 30, 36, 12, "Training Data:\nCDC BRFSS  -  ~250,000 real health records\n(behavioural + lifestyle indicators)", "#EFF7EF", "#3A8C4E", fs=9)
    arrow(ax, 12, 42, 12, 60, color="#3A8C4E", ls=(0, (4, 3)))

    box(ax, 50, 30, 44, 12, "Evaluation Metrics:\nRecall / Sensitivity, AUC-ROC, F1\n(NOT accuracy  -  rare-disease aware)", "#FBEFEF", "#B5413B", fs=9)
    arrow(ax, 72, 42, 68, 60, color="#B5413B", ls=(0, (4, 3)))
    save(fig, "fig2_ml_pipeline.png")


# =========================================================================
# FIG 3 — Multi-Task Model Architecture
# =========================================================================
def fig_multitask():
    fig, ax = base((8.6, 5.4))
    # inputs
    feats = ["Age", "BMI", "Physical Activity", "Diet Quality",
             "Smoking / Alcohol", "Sleep & Stress", "Blood Pressure Hx", "Family History"]
    fy = list(range(0, len(feats)))
    top, bot = 92, 16
    n = len(feats)
    for i, f in enumerate(feats):
        yy = bot + (top - bot) * (i / (n - 1))
        box(ax, 2, yy - 3.2, 22, 6.4, f, LIGHT, BLUE, fs=9)
        arrow(ax, 24, yy, 33, 54, color="#9FB4C9", lw=1.0)

    # shared backbone
    box(ax, 32, 38, 28, 32, "SHARED\nREPRESENTATION\nBACKBONE\n\n(learns the common\nphysiology linking\nthe two diseases)", LIGHT2, TEAL, fs=9.5, bold=False)

    # heads
    box(ax, 68, 64, 28, 14, "Diabetes Risk Head\n\nFuture risk of\nDiabetes Mellitus", WHITE, AMBER, fs=9.5)
    box(ax, 68, 30, 28, 14, "Kidney Risk Head\n\nFuture risk of\nChronic Kidney Disease", WHITE, "#7E57A6", fs=9.5)
    arrow(ax, 59, 58, 68, 71, color=AMBER, lw=2)
    arrow(ax, 59, 50, 68, 37, color="#7E57A6", lw=2)

    ax.text(50, 6, "Figure: one model, shared learning  -  diabetes is a leading cause of kidney disease",
            ha="center", color=SLATE, fontsize=9, style="italic")
    save(fig, "fig3_multitask.png")


# =========================================================================
# FIG 4 — Application Architecture (request flow / component)
# =========================================================================
def fig_app_arch():
    fig, ax = base((9.2, 5.2))
    box(ax, 3, 42, 20, 16, "User\n(Mobile App)", LIGHT, BLUE, fs=10, bold=True)
    box(ax, 30, 42, 22, 16, "Django REST API\nGateway\n(JWT secured)", GREY, NAVY, fs=10, bold=True)
    box(ax, 59, 64, 18, 14, "ML Engine\n(Risk)", LIGHT2, TEAL, fs=9.5)
    box(ax, 59, 42, 18, 14, "SHAP +\nWhat-If", LIGHT2, TEAL, fs=9.5)
    box(ax, 59, 20, 18, 14, "PostgreSQL", LIGHT3, AMBER, fs=9.5)
    box(ax, 82, 64, 16, 14, "Gemini\nAPI", "#F4EEF6", "#7E57A6", fs=9.5)
    box(ax, 82, 42, 16, 14, "Google\nMaps API", "#F4EEF6", "#7E57A6", fs=9.5)

    arrow(ax, 23, 50, 30, 50, color=SLATE, style="<|-|>")
    arrow(ax, 52, 52, 59, 60, color=SLATE, style="<|-|>")
    arrow(ax, 52, 50, 59, 49, color=SLATE, style="<|-|>")
    arrow(ax, 52, 48, 59, 30, color=SLATE, style="<|-|>")
    arrow(ax, 77, 71, 82, 71, color=SLATE, style="<|-|>")
    arrow(ax, 77, 49, 82, 49, color=SLATE, style="<|-|>")
    ax.text(13, 36, "HTTPS / REST", ha="center", color=SLATE, fontsize=8.5, style="italic")
    save(fig, "fig4_app_arch.png")


# =========================================================================
# FIG 5 — Gantt chart
# =========================================================================
def fig_gantt():
    tasks = [
        ("Requirements & Dataset Preparation", 1, 2, BLUE),
        ("ML Model Development (multi-task)", 3, 5, TEAL),
        ("Explainability & What-If Engine", 5, 3, TEAL),
        ("Backend Development (Django REST)", 6, 3, NAVY),
        ("Mobile App Development (Flutter)", 8, 3, BLUE),
        ("Gemini Chat & Maps Integration", 10, 3, "#7E57A6"),
        ("Testing & Evaluation", 13, 2, AMBER),
        ("Documentation & Deployment", 15, 2, SLATE),
    ]
    fig, ax = plt.subplots(figsize=(10.2, 4.7))
    names = []
    for i, (name, start, dur, color) in enumerate(tasks):
        y = len(tasks) - i - 1
        names.append((y, name))
        ax.barh(y, dur, left=start, height=0.55, color=color, edgecolor="white", zorder=3)
        ax.text(start + dur / 2, y, f"W{start}-{start+dur-1}", ha="center", va="center",
                color="white", fontsize=8.5, fontweight="bold", zorder=4)
    ax.set_xlim(0.5, 17)
    ax.set_ylim(-0.6, len(tasks) - 0.4)
    ax.set_yticks([y for y, _ in names])
    ax.set_yticklabels([n for _, n in names], fontsize=9.5, color=INK)
    ax.set_xticks(range(1, 17))
    ax.set_xlabel("Project Timeline (Weeks)", fontsize=10)
    ax.set_axisbelow(True)
    ax.grid(axis="x", color="#D9DEE5", linewidth=0.8)
    for s in ["top", "right", "left"]:
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color("#B8C2CE")
    ax.tick_params(axis="y", length=0)
    fig.tight_layout()
    save(fig, "fig5_gantt.png")


if __name__ == "__main__":
    fig_architecture()
    fig_ml_pipeline()
    fig_multitask()
    fig_app_arch()
    fig_gantt()
    print("ALL DIAGRAMS DONE")
