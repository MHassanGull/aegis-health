# -*- coding: utf-8 -*-
"""Generate the system diagrams for the Aegis Health FYP report.

Drawn in code rather than by hand so every box matches the repository it
describes: rename a Django model or move an endpoint and this file is the one
place to update. Run:

    python _build/make_diagrams2.py
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Polygon, Ellipse

OUT = Path(__file__).resolve().parent.parent / "docs" / "assets"
OUT.mkdir(parents=True, exist_ok=True)

# ---- Palette -------------------------------------------------------------
INK = "#1B2733"
NAVY = "#1F3B5C"
BLUE = "#2E6DB4"
TEAL = "#1A9E8F"
ROSE = "#C2557A"
AMBER = "#D9902F"
SLATE = "#5B6B7C"
L_BLUE = "#E8F0F8"
L_TEAL = "#E2F4F1"
L_ROSE = "#FAECF1"
L_AMBER = "#FBF1E0"
L_GREY = "#F1F4F7"
WHITE = "#FFFFFF"

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "DejaVu Serif"],
    "figure.dpi": 200,
    "savefig.dpi": 200,
    "savefig.bbox": "tight",
})


def canvas(w, h):
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis("off")
    return fig, ax


def box(ax, x, y, w, h, text, fc=WHITE, ec=INK, fs=9.5, bold=False, lw=1.3,
        radius=1.6, tc=None, align="center"):
    ax.add_patch(FancyBboxPatch(
        (x, y), w, h, boxstyle=f"round,pad=0,rounding_size={radius}",
        facecolor=fc, edgecolor=ec, linewidth=lw, zorder=2))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center",
            fontsize=fs, color=tc or INK, zorder=3,
            fontweight="bold" if bold else "normal", linespacing=1.5)


def band(ax, x, y, w, h, title, fc, ec):
    """A labelled container used for architectural layers."""
    ax.add_patch(FancyBboxPatch(
        (x, y), w, h, boxstyle="round,pad=0,rounding_size=2",
        facecolor=fc, edgecolor=ec, linewidth=1.1, linestyle="--",
        alpha=0.55, zorder=1))
    ax.text(x + 1.5, y + h - 2.4, title, ha="left", va="top",
            fontsize=8.5, color=ec, fontweight="bold", zorder=3)


def arrow(ax, p1, p2, text=None, color=SLATE, style="-|>", rad=0.0, fs=8,
          dashed=False, offset=(0, 1.6)):
    ax.add_patch(FancyArrowPatch(
        p1, p2, arrowstyle=style, mutation_scale=13, color=color,
        linewidth=1.25, linestyle="--" if dashed else "-",
        connectionstyle=f"arc3,rad={rad}", zorder=4,
        shrinkA=2, shrinkB=2))
    if text:
        mx, my = (p1[0] + p2[0]) / 2 + offset[0], (p1[1] + p2[1]) / 2 + offset[1]
        ax.text(mx, my, text, ha="center", va="center", fontsize=fs,
                color=color, zorder=5,
                bbox=dict(boxstyle="round,pad=0.22", fc=WHITE, ec="none", alpha=0.92))


# ==========================================================  1. ARCHITECTURE
def architecture():
    fig, ax = canvas(11, 7.6)
    ax.text(50, 97, "Aegis Health — System Architecture", ha="center",
            fontsize=13.5, fontweight="bold", color=INK)
    ax.text(50, 93.2, "Three-tier modular monolith: presentation, application, data",
            ha="center", fontsize=9, color=SLATE, style="italic")

    band(ax, 2, 64, 96, 24, "PRESENTATION TIER — Flutter (Dart), Android", L_BLUE, BLUE)
    for i, (t, x) in enumerate([
        ("Auth\nsign in / sign up", 5), ("Questionnaire\n19 questions", 24),
        ("Result\nrisk · factors · advice", 43), ("Assistant\nchat", 62),
        ("History\ntrend", 76.5), ("Reminders\non-device", 88)]):
        w = 17.5 if i < 4 else 10.5
        box(ax, x, 69, w, 11, t, WHITE, BLUE, 8.2)
    ax.text(50, 66.0, "State: Provider · JWT in Android Keystore · offline reminders via flutter_local_notifications",
            ha="center", fontsize=7.6, color=SLATE)

    arrow(ax, (50, 64), (50, 56.5), "HTTPS / REST + JSON\nJWT Bearer token", BLUE, fs=8.2)

    band(ax, 2, 26, 96, 30, "APPLICATION TIER — Django REST Framework (Python), hosted on Render", L_TEAL, TEAL)
    for t, x, w in [
        ("accounts\nregister · login\nrefresh · password", 5, 21),
        ("predictions\nschema · predict\nhistory · model card", 28, 21),
        ("profiles\nget · update", 51, 19),
        ("chat\nsend · history", 72, 21)]:
        box(ax, x, 43.5, w, 10.5, t, WHITE, TEAL, 8.2)

    box(ax, 5, 29.5, 44, 11, "PredictionService  (singleton)\n"
        "predict  ·  explain (occlusion)  ·  advise (what-if)",
        L_GREY, TEAL, 8.4)
    box(ax, 53, 29.5, 40, 11, "LLMProvider  (strategy)\n"
        "Gemini  |  Claude  |  Ollama — swapped by config",
        L_GREY, TEAL, 8.4)
    arrow(ax, (27, 43.5), (27, 40.5), color=TEAL)
    arrow(ax, (82, 43.5), (73, 40.5), color=TEAL)

    arrow(ax, (27, 29.5), (27, 20), "loads once\nat start-up", TEAL, fs=8)
    arrow(ax, (73, 29.5), (73, 20), "HTTPS", TEAL, fs=8)
    arrow(ax, (50, 26), (50, 20), "ORM / SQL", TEAL, fs=8)

    band(ax, 2, 4, 96, 15, "DATA & MODEL TIER", L_AMBER, AMBER)
    box(ax, 5, 7, 26, 9, "multitask_model.joblib\nMLP 18-96-48-2  ·  6.6 k params\n+ scaler + isotonic calibrators",
        WHITE, AMBER, 7.8)
    box(ax, 36, 7, 28, 9, "Supabase PostgreSQL\nusers · profiles\nassessments · chat",
        WHITE, AMBER, 8.2)
    box(ax, 69, 7, 26, 9, "Anthropic Messages API\nnatural-language\nexplanations", WHITE, AMBER, 8.2)

    fig.savefig(OUT / "fig_architecture.png"); plt.close(fig)
    print("  fig_architecture.png")


# ==========================================================  2. ML PIPELINE
def ml_pipeline():
    fig, ax = canvas(12, 4.4)
    ax.text(50, 95, "Machine-Learning Pipeline", ha="center",
            fontsize=13, fontweight="bold", color=INK)
    ax.text(50, 88, "From raw CDC survey file to the artifact the API serves",
            ha="center", fontsize=9, color=SLATE, style="italic")

    steps = [
        ("Raw BRFSS 2015\nLLCP2015.XPT\n~99 MB, 441 cols", L_GREY),
        ("Recode\nsurvey codes to\n0/1 and ordinals\ndrop don't-know", L_BLUE),
        ("Clean dataset\n253,155 people\n18 features\n2 labels", L_BLUE),
        ("Split\nfit 64% · val 16%\ntest 20%\nstratified", L_TEAL),
        ("Train\nshared-backbone\nMLP, early stop", L_TEAL),
        ("Calibrate\nisotonic on val\nper head", L_ROSE),
        ("Tune threshold\nlowest that holds\nrecall ≥ 0.85", L_ROSE),
        ("Artifact\nmodel + scaler\n+ calibrators\n+ thresholds", L_AMBER),
    ]
    w, gap = 10.4, 1.7
    x = 1.5
    for label, fc in steps:
        box(ax, x, 36, w, 30, label, fc, INK, 7.4)
        if x + w + gap < 100:
            arrow(ax, (x + w, 51), (x + w + gap, 51), color=SLATE)
        x += w + gap

    ax.text(50, 25, "Validation: 5-fold stratified cross-validation on the joint (diabetes, kidney) label\n"
                    "Selection metric: Recall and ROC-AUC — never accuracy, because both conditions are rare",
            ha="center", fontsize=8.4, color=SLATE,
            bbox=dict(boxstyle="round,pad=0.5", fc=L_GREY, ec=SLATE, lw=0.8))
    fig.savefig(OUT / "fig_ml_pipeline.png"); plt.close(fig)
    print("  fig_ml_pipeline.png")


# ======================================================  3. MULTI-TASK NET
def multitask_net():
    fig, ax = canvas(10, 6.6)
    ax.text(50, 96, "Multi-Task Neural Network", ha="center",
            fontsize=13, fontweight="bold", color=INK)
    ax.text(50, 91, "One shared backbone learns the biology both diseases have in common;\n"
                    "two heads specialise. Diabetes is a leading cause of kidney disease.",
            ha="center", fontsize=8.6, color=SLATE, style="italic")

    layers = [(14, 18, "Input\n18 features", BLUE, 9),
              (36, 96, "Hidden 1\n96 · ReLU", TEAL, 11),
              (58, 48, "Hidden 2\n48 · ReLU", TEAL, 9)]
    for x, n, label, col, shown in layers:
        ys = [78 - i * (54 / max(shown - 1, 1)) for i in range(shown)]
        for y in ys:
            ax.add_patch(Circle((x, y), 1.5, facecolor=WHITE, edgecolor=col,
                                linewidth=1.2, zorder=3))
        ax.text(x, 16, label, ha="center", fontsize=8.6, color=col, fontweight="bold")
        ax.text(x, 11.5, f"({n} units)", ha="center", fontsize=7.6, color=SLATE)

    # Connections, sampled so the figure stays readable.
    for (x1, _, _, _, s1), (x2, _, _, _, s2) in zip(layers, layers[1:]):
        y1s = [78 - i * (54 / max(s1 - 1, 1)) for i in range(s1)]
        y2s = [78 - i * (54 / max(s2 - 1, 1)) for i in range(s2)]
        for i, y1 in enumerate(y1s):
            for j, y2 in enumerate(y2s):
                if (i + j) % 3 == 0:
                    ax.plot([x1 + 1.5, x2 - 1.5], [y1, y2], color=SLATE,
                            lw=0.28, alpha=0.35, zorder=1)

    for y, label, col, fc in [(64, "Diabetes head\nsigmoid", BLUE, L_BLUE),
                              (30, "Kidney head\nsigmoid", ROSE, L_ROSE)]:
        box(ax, 76, y - 7, 20, 14, label, fc, col, 8.6, bold=True)
        for i in range(9):
            yy = 78 - i * (54 / 8)
            ax.plot([59.5, 76], [yy, y], color=col, lw=0.3, alpha=0.3, zorder=1)

    ax.add_patch(FancyBboxPatch((30, 6), 36, 7, boxstyle="round,pad=0,rounding_size=1.4",
                                facecolor=L_GREY, edgecolor=SLATE, lw=0.9, zorder=2))
    ax.text(48, 9.5, "Shared backbone · 6,674 trainable parameters",
            ha="center", va="center", fontsize=8.4, color=INK, zorder=3)
    fig.savefig(OUT / "fig_multitask_network.png"); plt.close(fig)
    print("  fig_multitask_network.png")


# =========================================================  4. USE CASE
def use_case():
    fig, ax = canvas(9.6, 7.4)
    ax.text(50, 96.5, "Use-Case Diagram", ha="center", fontsize=13,
            fontweight="bold", color=INK)

    def stick(x, y, label):
        ax.add_patch(Circle((x, y + 7), 2.0, fill=False, ec=INK, lw=1.3))
        ax.plot([x, x], [y + 5, y], color=INK, lw=1.3)
        ax.plot([x - 3, x + 3], [y + 3.6, y + 3.6], color=INK, lw=1.3)
        ax.plot([x, x - 2.6], [y, y - 4], color=INK, lw=1.3)
        ax.plot([x, x + 2.6], [y, y - 4], color=INK, lw=1.3)
        ax.text(x, y - 7.5, label, ha="center", fontsize=8.8, fontweight="bold", color=INK)

    stick(9, 56, "Registered\nUser")
    stick(91, 44, "Administrator")

    ax.add_patch(FancyBboxPatch((22, 8), 56, 82, boxstyle="round,pad=0,rounding_size=2",
                                facecolor="#FBFCFD", edgecolor=SLATE, lw=1.2, zorder=1))
    ax.text(50, 86, "Aegis Health System", ha="center", fontsize=9.5,
            color=SLATE, fontweight="bold", style="italic")

    cases = [
        ("Create account", 50, 78, BLUE), ("Sign in", 50, 70, BLUE),
        ("Change password", 50, 62, BLUE),
        ("Complete questionnaire", 50, 53, TEAL),
        ("View risk assessment", 50, 45, TEAL),
        ("Run what-if simulation", 50, 37, TEAL),
        ("Ask the assistant", 50, 29, ROSE),
        ("Review history", 50, 21, ROSE),
        ("Manage reminders", 50, 13, AMBER),
    ]
    for label, x, y, col in cases:
        ax.add_patch(Ellipse((x, y), 44, 6.6, facecolor=WHITE, edgecolor=col,
                             lw=1.25, zorder=3))
        ax.text(x, y, label, ha="center", va="center", fontsize=8.5, color=INK, zorder=4)
        ax.plot([13.5, 28], [55, y], color=SLATE, lw=0.75, alpha=0.6, zorder=2)

    box(ax, 62, 84, 30, 7, "Inspect model card", L_GREY, SLATE, 8.2)
    ax.plot([86, 78], [46, 87], color=SLATE, lw=0.75, alpha=0.6)

    ax.text(50, 3.5,
            "<<include>>  Completing the questionnaire always triggers a prediction, an explanation and a what-if pass.",
            ha="center", fontsize=7.6, color=SLATE, style="italic")
    fig.savefig(OUT / "fig_use_case.png"); plt.close(fig)
    print("  fig_use_case.png")


# =========================================================  5. ACTIVITY
def activity():
    fig, ax = canvas(8.4, 9.4)
    ax.text(50, 97.5, "Activity Diagram — Risk Assessment", ha="center",
            fontsize=12.5, fontweight="bold", color=INK)

    ax.add_patch(Circle((50, 92), 2.1, facecolor=INK, edgecolor=INK, zorder=3))

    steps = [
        (84, "Open app", L_BLUE, BLUE),
        (75, "Sign in  (JWT issued)", L_BLUE, BLUE),
        (66, "Answer 19 questions\n(profile pre-fills age, sex, height, weight)", L_TEAL, TEAL),
        (56, "App computes BMI from height and weight\n→ 18-feature payload", L_TEAL, TEAL),
        (47, "POST /api/predict/  with Bearer token", L_TEAL, TEAL),
        (38, "Server validates every field against the schema", L_AMBER, AMBER),
    ]
    for y, t, fc, ec in steps:
        box(ax, 14, y, 72, 6.6, t, fc, ec, 8.2)

    arrow(ax, (50, 89.9), (50, 90.6 - 0.1), color=SLATE)
    ys = [92] + [s[0] + 6.6 for s in steps]
    for i, (y, *_rest) in enumerate(steps):
        top = 92 if i == 0 else steps[i - 1][0]
        arrow(ax, (50, top), (50, y + 6.6), color=SLATE)

    # Decision diamond
    ax.add_patch(Polygon([(50, 34), (64, 28), (50, 22), (36, 28)],
                         closed=True, facecolor=WHITE, edgecolor=AMBER, lw=1.3, zorder=3))
    ax.text(50, 28, "Valid?", ha="center", va="center", fontsize=8.6, zorder=4)
    arrow(ax, (50, 38), (50, 34), color=SLATE)

    box(ax, 2, 24, 30, 7.5, "Return 400\nwith the field errors", L_ROSE, ROSE, 8)
    arrow(ax, (36, 28), (32, 28), "no", ROSE, fs=8, offset=(0, 1.4))

    box(ax, 14, 12, 72, 7.5,
        "Model runs three times over the same vector:\n"
        "predict  →  explain (18 occlusions)  →  advise (6 what-if edits)",
        L_TEAL, TEAL, 8.2)
    arrow(ax, (50, 22), (50, 19.5), "yes", TEAL, fs=8, offset=(3, 0))

    box(ax, 14, 3.5, 72, 6.2, "Save to history · return risk, factors and advice",
        L_BLUE, BLUE, 8.2)
    arrow(ax, (50, 12), (50, 9.7), color=SLATE)

    ax.add_patch(Circle((92, 6.6), 2.3, fill=False, ec=INK, lw=1.3, zorder=3))
    ax.add_patch(Circle((92, 6.6), 1.3, facecolor=INK, edgecolor=INK, zorder=4))
    arrow(ax, (86, 6.6), (89.6, 6.6), color=SLATE)
    fig.savefig(OUT / "fig_activity.png"); plt.close(fig)
    print("  fig_activity.png")


# ==============================================================  6. ERD
def erd():
    fig, ax = canvas(10.4, 7.2)
    ax.text(50, 97, "Entity-Relationship Diagram", ha="center", fontsize=13,
            fontweight="bold", color=INK)
    ax.text(50, 93, "As implemented by the Django ORM on Supabase PostgreSQL",
            ha="center", fontsize=8.6, color=SLATE, style="italic")

    def table(x, y, w, title, rows, col, lcol):
        h = 6.2 + len(rows) * 4.3
        ax.add_patch(FancyBboxPatch((x, y - h), w, h,
                                    boxstyle="round,pad=0,rounding_size=1.2",
                                    facecolor=WHITE, edgecolor=col, lw=1.3, zorder=2))
        ax.add_patch(FancyBboxPatch((x, y - 6.2), w, 6.2,
                                    boxstyle="round,pad=0,rounding_size=1.2",
                                    facecolor=lcol, edgecolor=col, lw=1.3, zorder=2))
        ax.text(x + w / 2, y - 3.1, title, ha="center", va="center",
                fontsize=9, fontweight="bold", color=INK, zorder=3)
        for i, (name, typ, key) in enumerate(rows):
            yy = y - 6.2 - 2.2 - i * 4.3
            mark = {"PK": "PK ", "FK": "FK ", "U": "U  ", "": "   "}[key]
            ax.text(x + 1.8, yy, f"{mark}{name}", ha="left", va="center",
                    fontsize=7.4, color=INK,
                    fontweight="bold" if key in ("PK", "FK") else "normal", zorder=3)
            ax.text(x + w - 1.8, yy, typ, ha="right", va="center",
                    fontsize=6.9, color=SLATE, style="italic", zorder=3)
        return h

    table(3, 88, 27, "auth_user", [
        ("id", "bigint", "PK"), ("username", "varchar(150)", "U"),
        ("email", "varchar(254)", ""), ("password", "varchar(128)", ""),
        ("date_joined", "timestamptz", ""), ("is_active", "boolean", ""),
    ], NAVY, L_BLUE)

    table(37, 88, 28, "profiles_userprofile", [
        ("id", "bigint", "PK"), ("user_id", "bigint", "FK"),
        ("avatar", "text", ""), ("sex", "integer", ""),
        ("age", "integer", ""), ("height_cm", "double", ""),
        ("weight_kg", "double", ""), ("updated_at", "timestamptz", ""),
    ], TEAL, L_TEAL)

    table(71, 88, 27, "predictions_assessment", [
        ("id", "bigint", "PK"), ("user_id", "bigint", "FK"),
        ("inputs", "jsonb", ""), ("result", "jsonb", ""),
        ("diabetes_risk", "double", ""), ("kidney_risk", "double", ""),
        ("created_at", "timestamptz", ""),
    ], BLUE, L_BLUE)

    table(37, 36, 28, "chat_chatmessage", [
        ("id", "bigint", "PK"), ("user_id", "bigint", "FK"),
        ("role", "varchar(10)", ""), ("text", "text", ""),
        ("created_at", "timestamptz", ""),
    ], ROSE, L_ROSE)

    def rel(p1, p2, left, right, rad=0.0):
        arrow(ax, p1, p2, None, SLATE, style="-", rad=rad)
        ax.text(p1[0], p1[1] + 1.8, left, fontsize=7.4, color=SLATE, ha="center")
        ax.text(p2[0], p2[1] + 1.8, right, fontsize=7.4, color=SLATE, ha="center")

    rel((30, 70), (37, 70), "1", "1")
    rel((30, 62), (71, 62), "1", "N", rad=-0.18)
    rel((16.5, 52.5), (48, 36), "1", "N", rad=0.2)

    ax.text(50, 8,
            "One user has exactly one profile, and many assessments and chat messages.\n"
            "inputs and result are stored as JSONB so a model change does not require a migration.\n"
            "Deleting a user cascades to every row they own.",
            ha="center", fontsize=8, color=SLATE,
            bbox=dict(boxstyle="round,pad=0.5", fc=L_GREY, ec=SLATE, lw=0.8))
    fig.savefig(OUT / "fig_erd.png"); plt.close(fig)
    print("  fig_erd.png")


# ==========================================================  7. SEQUENCE
def sequence():
    fig, ax = canvas(10.6, 6.8)
    ax.text(50, 97, "Sequence Diagram — One Risk Assessment", ha="center",
            fontsize=12.5, fontweight="bold", color=INK)

    actors = [("Flutter app", 10, BLUE), ("Django API", 32, TEAL),
              ("PredictionService", 55, AMBER), ("Model artifact", 76, SLATE),
              ("PostgreSQL", 93, ROSE)]
    for name, x, col in actors:
        box(ax, x - 8.5, 86, 17, 6.6, name, WHITE, col, 8.2, bold=True)
        ax.plot([x, x], [86, 12], color=SLATE, lw=0.9, ls="--", alpha=0.65, zorder=1)

    msgs = [
        (10, 32, 79, "POST /api/predict/  { 18 answers }  + Bearer JWT", BLUE),
        (32, 32, 72, "authenticate + validate against schema", TEAL),
        (32, 55, 65, "assess(payload)", TEAL),
        (55, 76, 58, "predict → 2 calibrated probabilities", AMBER),
        (55, 76, 51, "explain → 18 occlusion passes", AMBER),
        (55, 76, 44, "advise → 6 what-if passes", AMBER),
        (55, 32, 37, "risk + factors + recommendations", AMBER),
        (32, 93, 30, "INSERT assessment row", TEAL),
        (93, 32, 23, "row id", ROSE),
        (32, 10, 16, "200 OK  { prediction, key_factors, recommendations }", TEAL),
    ]
    for x1, x2, y, label, col in msgs:
        if x1 == x2:
            ax.add_patch(FancyBboxPatch((x1 + 1, y - 1.6), 15, 3.4,
                                        boxstyle="round,pad=0,rounding_size=0.8",
                                        facecolor=WHITE, edgecolor=col, lw=0.9, zorder=3))
            ax.text(x1 + 8.5, y + 0.1, label, ha="center", va="center",
                    fontsize=6.8, color=INK, zorder=4)
        else:
            arrow(ax, (x1, y), (x2, y), None, col)
            ax.text((x1 + x2) / 2, y + 1.7, label, ha="center", fontsize=7.2,
                    color=INK, zorder=5,
                    bbox=dict(boxstyle="round,pad=0.2", fc=WHITE, ec="none", alpha=0.94))

    ax.text(50, 6, "The model is loaded once at start-up and held in memory, so a request costs "
                   "25 forward passes and a single INSERT.",
            ha="center", fontsize=7.8, color=SLATE, style="italic")
    fig.savefig(OUT / "fig_sequence.png"); plt.close(fig)
    print("  fig_sequence.png")


# ========================================================  8. DEPLOYMENT
def deployment():
    fig, ax = canvas(10.2, 5.6)
    ax.text(50, 95, "Deployment Diagram", ha="center", fontsize=13,
            fontweight="bold", color=INK)
    ax.text(50, 89.5, "What runs where, once the project is live",
            ha="center", fontsize=8.6, color=SLATE, style="italic")

    band(ax, 2, 52, 30, 30, "USER DEVICE", L_BLUE, BLUE)
    box(ax, 5, 57, 24, 18, "Android phone\n\nAegis Health APK\nsigned release build\n\nJWT in Keystore\nreminders scheduled\non-device", WHITE, BLUE, 7.8)

    band(ax, 36, 52, 30, 30, "RENDER  (Singapore)", L_TEAL, TEAL)
    box(ax, 39, 57, 24, 18, "Web service\n\ngunicorn\n1 worker · 4 threads\n\nDjango + DRF\nmodel in memory", WHITE, TEAL, 7.8)

    band(ax, 70, 52, 28, 30, "SUPABASE  (Sydney)", L_AMBER, AMBER)
    box(ax, 73, 57, 22, 18, "PostgreSQL 15\n\nsession pooler\nSSL required\n\nusers · profiles\nassessments · chat", WHITE, AMBER, 7.8)

    band(ax, 36, 18, 62, 24, "EXTERNAL SERVICES", L_ROSE, ROSE)
    box(ax, 40, 23, 26, 13, "Anthropic Messages API\nnatural-language replies", WHITE, ROSE, 7.8)
    box(ax, 70, 23, 24, 13, "GitHub Actions\nkeep-alive ping\nevery 10 minutes", WHITE, ROSE, 7.8)

    arrow(ax, (29, 66), (39, 66), "HTTPS\nREST + JWT", BLUE, fs=7.4)
    arrow(ax, (63, 66), (73, 66), "TLS\nport 5432", TEAL, fs=7.4)
    arrow(ax, (51, 57), (51, 36), "HTTPS", ROSE, fs=7.4)
    arrow(ax, (82, 36), (57, 57), "GET /api/health/", ROSE, fs=7.2, rad=0.18)

    ax.text(50, 12, "git push  →  GitHub  →  Render rebuilds and redeploys automatically",
            ha="center", fontsize=8.2, color=INK,
            bbox=dict(boxstyle="round,pad=0.45", fc=L_GREY, ec=SLATE, lw=0.8))
    fig.savefig(OUT / "fig_deployment.png"); plt.close(fig)
    print("  fig_deployment.png")


# ==============================================================  9. GANTT
def gantt():
    fig, ax = plt.subplots(figsize=(10.4, 4.4))
    sprints = [
        ("Sprint 1 — Research and data", 0, 3, BLUE,
         "BRFSS extraction, recoding, baseline model"),
        ("Sprint 2 — Multi-task model", 3, 3, BLUE,
         "Shared backbone, two heads, threshold tuning"),
        ("Sprint 3 — Rigour", 6, 2, TEAL,
         "Cross-validation, isotonic calibration"),
        ("Sprint 4 — REST API", 8, 3, TEAL,
         "JWT auth, predict, explain, what-if, history"),
        ("Sprint 5 — Mobile app", 11, 4, AMBER,
         "Flutter screens, state, offline reminders"),
        ("Sprint 6 — Assistant", 15, 2, AMBER,
         "Provider abstraction, grounded prompting"),
        ("Sprint 7 — Deployment", 17, 2, ROSE,
         "Render, Supabase, signed release build"),
        ("Sprint 8 — Design and docs", 19, 3, ROSE,
         "Design system, accessibility, report"),
    ]
    for i, (name, start, dur, col, detail) in enumerate(sprints):
        y = len(sprints) - i - 1
        ax.barh(y, dur, left=start, height=0.58, color=col, edgecolor=INK, linewidth=0.8)
        ax.text(start + dur + 0.25, y, detail, va="center", fontsize=7.6, color=SLATE)

    ax.set_yticks(range(len(sprints)))
    ax.set_yticklabels([s[0] for s in reversed(sprints)], fontsize=8.6)
    ax.set_xlabel("Project week", fontsize=9)
    ax.set_xlim(0, 32)
    ax.set_xticks(range(0, 23, 2))
    ax.set_title("Development Schedule — Agile Sprints", fontsize=12,
                 fontweight="bold", pad=12)
    ax.grid(axis="x", color="#DCE3EA", lw=0.7)
    ax.set_axisbelow(True)
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    fig.tight_layout()
    fig.savefig(OUT / "fig_gantt.png"); plt.close(fig)
    print("  fig_gantt.png")


# =========================================================  10. CLASS
def class_diagram():
    fig, ax = canvas(10.6, 7.0)
    ax.text(50, 97, "Class Diagram — Backend Domain and Services", ha="center",
            fontsize=12.5, fontweight="bold", color=INK)

    def cls(x, y, w, name, attrs, methods, col, lcol, stereo=None):
        ah, mh = len(attrs) * 3.5, len(methods) * 3.5
        h = 6 + ah + mh + 1.5
        ax.add_patch(FancyBboxPatch((x, y - h), w, h,
                                    boxstyle="round,pad=0,rounding_size=1",
                                    facecolor=WHITE, edgecolor=col, lw=1.3, zorder=2))
        ax.add_patch(FancyBboxPatch((x, y - 6), w, 6,
                                    boxstyle="round,pad=0,rounding_size=1",
                                    facecolor=lcol, edgecolor=col, lw=1.3, zorder=2))
        label = f"«{stereo}»\n{name}" if stereo else name
        ax.text(x + w / 2, y - 3, label, ha="center", va="center",
                fontsize=8.4, fontweight="bold", color=INK, zorder=3)
        yy = y - 6 - 2.4
        for a in attrs:
            ax.text(x + 1.6, yy, f"− {a}", ha="left", va="center",
                    fontsize=6.9, color=INK, zorder=3)
            yy -= 3.5
        ax.plot([x, x + w], [yy + 1.4, yy + 1.4], color=col, lw=0.9, zorder=3)
        yy -= 1.2
        for m in methods:
            ax.text(x + 1.6, yy, f"+ {m}", ha="left", va="center",
                    fontsize=6.9, color=INK, zorder=3)
            yy -= 3.5
        return h

    cls(2, 92, 27, "User", ["username", "email", "password"],
        ["check_password()", "set_password()"], NAVY, L_BLUE)
    cls(36, 92, 28, "Assessment",
        ["user : FK", "inputs : JSON", "result : JSON",
         "diabetes_risk", "kidney_risk", "created_at"],
        ["__str__()"], BLUE, L_BLUE)
    cls(71, 92, 27, "UserProfile",
        ["user : OneToOne", "sex", "age", "height_cm", "weight_kg"],
        ["__str__()"], TEAL, L_TEAL)

    cls(2, 44, 34, "PredictionService",
        ["model", "scaler", "features", "thresholds", "calibrators"],
        ["instance()", "predict()", "explain()", "advise()",
         "assess()", "model_card()"], AMBER, L_AMBER, stereo="singleton")

    cls(44, 44, 24, "LLMProvider",
        ["name"], ["reply(system, history)"], ROSE, L_ROSE, stereo="interface")

    for i, (nm, x) in enumerate([("ClaudeProvider", 41), ("GeminiProvider", 60),
                                 ("OllamaProvider", 79)]):
        box(ax, x, 6, 18, 7, nm, WHITE, ROSE, 7.4)
        arrow(ax, (x + 9, 13), (56, 22), None, ROSE, style="-|>", rad=0.1)

    arrow(ax, (29, 86), (36, 86), "1      N", NAVY, style="-")
    arrow(ax, (64, 86), (71, 86), "1      1", TEAL, style="-")
    arrow(ax, (19, 63), (19, 56), "loads artifact", AMBER, fs=7.4)
    arrow(ax, (36, 30), (44, 30), "used by ChatView", SLATE, fs=7.2, style="-", dashed=True)

    ax.text(50, 2.5, "The provider interface is the Strategy pattern: the chat brain is chosen by "
                     "configuration, never by an if-statement in a view.",
            ha="center", fontsize=7.6, color=SLATE, style="italic")
    fig.savefig(OUT / "fig_class_diagram.png"); plt.close(fig)
    print("  fig_class_diagram.png")


if __name__ == "__main__":
    print("Generating system diagrams:")
    architecture()
    ml_pipeline()
    multitask_net()
    use_case()
    activity()
    erd()
    sequence()
    deployment()
    gantt()
    class_diagram()
    print("Done.")
