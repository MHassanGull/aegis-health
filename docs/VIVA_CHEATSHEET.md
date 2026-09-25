# Aegis Health — Viva Cheat Sheet

One page per topic. Each fact has **What / Why / Say this** — so you can answer
in your own words instead of reciting. Read once, then rehearse out loud.

---

## 0. The 30-second pitch (say this first if asked "explain your project")

> "Aegis Health predicts a person's **future** risk of type 2 diabetes and
> chronic kidney disease from 19 lifestyle questions — no blood test. One
> neural network with a shared backbone and two output heads handles both
> diseases together, because diabetes is a known cause of kidney disease. Every
> prediction comes with an explanation of what drove it and a what-if
> simulator showing how much each habit change would lower it. It's a Flutter
> app talking to a Django REST API, backed by a real trained model on 253,155
> real people from a CDC health survey."

---

## 1. THE ONE STORY THAT WINS THE VIVA — the label-leakage correction

**What happened:** The original plan was to predict CKD *stage* from lab
values, using the clinical eGFR formula to generate the label.

**Why that was wrong:** The label would have been *computed from* the input
features by a formula you wrote yourself. Any model would just re-learn your
own arithmetic and score ~100% — meaningless, because a calculator already
does that job for free. This is called **label leakage / data leakage**.

**The fix:** Predict *future* risk from *lifestyle behaviour* instead. The
label (does this survey respondent actually have the disease) is independent
of the inputs (their habits) — no circularity.

**Say this if asked "what was the hardest problem you solved":**
> "Our original design had a label-leakage flaw — we were about to train a
> model that would just re-derive a formula we wrote ourselves. Catching that
> and switching to predicting future risk from lifestyle, where the label is
> genuinely independent of the inputs, is the single most important decision
> in this project."

---

## 2. Dataset

| Fact | Value |
|---|---|
| Source | CDC BRFSS 2015 (Behavioral Risk Factor Surveillance System) |
| What it is | A real annual US government health phone survey |
| Records | **253,155** real people |
| Raw file | 441 survey columns, values like 1=yes, 2=no, 7=don't know, 9=refused |
| Our features | **18** (originally 19 — see below) |
| Labels | 2 binary: `Diabetes_binary`, `Kidney_binary` |
| Prevalence | Diabetes 13.9%, Kidney disease 3.7% — **both rare** |

**Why BRFSS and not a smaller/synthetic dataset:** Real, large, publicly
credible, government-collected — a panel can verify it exists.

**Why 18 not 19 features:** We removed `MentHlth` (days of poor mental health)
— it's intrusive to ask in a diabetes/kidney screening, and we *measured*
its value first: permutation importance ranked it 15th of 19, worth about
0.001 AUC. Removing it cost nothing and made the questionnaire kinder.

**Say this if asked "why this dataset":**
> "It's real government survey data, not synthetic, large enough to train a
> reliable model, and it already contains both disease labels plus 18
> lifestyle features — exactly what a lifestyle-based screening tool needs."

---

## 3. Machine Learning / Deep Learning / Model

**Architecture:** `18 inputs → 96 hidden (ReLU) → 48 hidden (ReLU) → 2 outputs (sigmoid)`

- **6,674 trainable parameters**
- Library: `scikit-learn`, class `MLPClassifier` (Multi-Layer Perceptron)
- This IS a neural network — multiple layers, non-linear activation — but a
  **shallow** one. Be honest if pushed: *"It's a small MLP, not a deep CNN or
  Transformer. Tabular survey data with 18 features doesn't need or benefit
  from a deep architecture the way images or text do."*

**Why sklearn and not PyTorch/TensorFlow/Keras:**
> "The model is tiny — 170 KB, 6,674 parameters. A GPU deep-learning framework
> would be overkill and complicate deployment on a free-tier server. Sklearn
> trains this in minutes on a CPU and deploys as a single file."

**Multi-task learning — the key ML concept:**
- ONE shared backbone (both hidden layers), TWO output heads (one per disease)
- Trained by giving the model a **2-column label matrix**, not two separate
  models
- **Why:** Diabetes is a leading cause of kidney disease — they share
  underlying risk factors (blood pressure, BMI, age). A shared representation
  lets the network learn that relationship; two separate models couldn't.
- Reference concept: Caruana's Multi-Task Learning (1997) — "tasks that share
  structure should share a representation."

**Validation — how you know it's not overfit:**
- Held-out test set the model never saw during training
- **5-fold stratified cross-validation** on the joint (diabetes, kidney) label
  → reports mean ± std, not one lucky number
- Metrics reported: **ROC-AUC 0.823 (diabetes) / 0.793 (kidney)**, **Recall
  84.9% / 87.5%** at the tuned screening threshold

**Calibration — "does 30% really mean 30%?":**
- **Isotonic regression**, fitted only on the validation split (never test)
- Non-parametric — corrects any shape of miscalibration, not just a straight
  line (that's the difference vs. Platt scaling)
- Verified with a reliability curve (predicted vs. observed frequency)

**Threshold tuning:**
- Chose the highest decision threshold that still holds **recall ≥ 0.85** on
  validation — found via the precision-recall curve, not guessed
- **Why prioritise recall over precision:** it's a *screening* tool. Missing
  a real case costs far more than one unnecessary follow-up test. Better to
  over-flag than under-flag.

---

## 4. THE ACCURACY TRAP — know this cold, it's the hardest likely question

**The trap:** At the standard 0.5 threshold, the kidney model shows 96.3%
"accuracy." That sounds great. It is **not** — kidney disease only affects
3.7% of people, so a model that always says "no" scores 96.3% while catching
**zero** real cases. Balanced accuracy at that point is exactly **50%** — a
coin flip.

**Say this if an examiner corners you on accuracy:**
> "We deliberately do not report accuracy as the headline metric, because with
> a rare condition it can be gamed by never predicting positive. We report
> ROC-AUC and recall instead, because those can't be won that way. Our kidney
> model's balanced accuracy at the default threshold is 50% — literally
> useless — which is exactly why we moved the operating threshold and report
> recall at that new point instead."

This answer, delivered confidently, actually **impresses** examiners — it
shows you understand the pitfall rather than hid from it.

---

## 5. Explainability — why a prediction happened

**Method: Occlusion-based attribution** (not full SHAP)
- For each of the 18 features, replace its value with the population average,
  re-run the model, measure how much the predicted risk **drops**
- That drop = how much that feature was pushing risk **up** for this person
- Cost: 18 extra forward passes, ~1ms each — cheap
- **Why not real SHAP:** SHAP (Shapley values) is combinatorially expensive
  (2^18 subsets in theory); occlusion is a fast, honest approximation that
  gets 90% of the value at a fraction of the cost.

**What-if simulator:**
- Takes 6 habits a person can realistically change (BMI, activity, smoking,
  fruit, veg, alcohol)
- Swaps each to its "healthy" target value, re-runs the model, reports the
  risk reduction
- This is a simple counterfactual — "if you changed X, your risk would move
  by Y" — not full causal inference, but genuinely useful and honestly framed

---

## 6. Backend / API

| Layer | Choice | Why |
|---|---|---|
| Framework | Django + Django REST Framework | Batteries-included auth/ORM; same language (Python) as the ML side |
| Auth | JWT (JSON Web Tokens), via `simplejwt` | Stateless — no server-side session storage; access + refresh pair |
| Database | PostgreSQL on Supabase (managed) | Relational data fits users/profiles/assessments naturally; JSONB columns give flexibility where needed |
| Model serving | `PredictionService` — a **singleton**, loaded once at startup | Reloading a model per-request would be catastrophically slow |
| Rate limiting | DRF throttling: 30/min anon, 300/min user, 8/min login, 5/min register | Blunts brute-force attacks |

**Key endpoints** (know these, an examiner may ask you to trace one):
```
POST /api/auth/register/     create account
POST /api/auth/login/        JWT access + refresh tokens
POST /api/auth/refresh/      renew an expired access token
GET  /api/schema/            public — questionnaire field definitions
GET  /api/model/card/        public — LIVE architecture + real metrics
POST /api/predict/           auth — runs predict+explain+advise, saves to DB
GET  /api/history/           auth — past assessments
POST /api/chat/              auth — AI assistant
```

**One request, end to end** (rehearse saying this out loud):
> "App collects 19 answers → computes BMI from height/weight on-device → sends
> 18 features as JSON with a Bearer token → Django validates every field
> against the schema → PredictionService (already in memory) scales the input,
> runs predict_proba, applies the isotonic calibrators, compares to each
> disease's tuned threshold → also runs the occlusion explainer and the
> what-if engine on the same input → saves one row to Postgres → returns JSON
> → app renders the risk gauges, factors and recommendations."

---

## 7. AI Assistant — no LangChain, and that's a strength

- **155 lines of plain Python.** Direct HTTPS POST to Anthropic's Messages API
  using the built-in `urllib` — no SDK, no framework.
- **Design pattern: Strategy.** `LLMProvider` is an interface; `ClaudeProvider`,
  `GeminiProvider`, `OllamaProvider` are interchangeable implementations.
  Switching the AI brain is **one config value**, zero code changes.
- **Grounded**: the system prompt includes the user's most recent risk
  assessment, so the assistant can say "your diabetes risk is 44.5%" for real.

**Say this if asked "why not LangChain":**
> "LangChain would add a large dependency to do what a 40-line HTTP call
> already does. We used the Strategy pattern instead — an interface with
> three swappable providers — which is simpler and just as flexible."

---

## 8. Mobile App

| Fact | Value |
|---|---|
| Framework | Flutter (Dart) |
| State management | Provider |
| Token storage | `flutter_secure_storage` → Android Keystore (encrypted) |
| Local reminders | `flutter_local_notifications` — real Android alarms, work fully offline, survive reboot |
| Design | Custom typographic system — one type scale, one corner radius, hairline rules instead of shadows |

**Why Flutter over native Android or React Native:**
> "One codebase, compiled to native ARM code — not a JavaScript bridge like
> React Native — so performance is close to native, and one team can
> maintain both Android and iOS from the same source."

---

## 9. Deployment

| Piece | Where |
|---|---|
| Backend | Render (free tier), gunicorn, 1 worker / 4 threads |
| Database | Supabase-managed PostgreSQL, Sydney region, TLS |
| Auto-deploy | Push to `main` → Render rebuilds automatically |
| Keep-alive | GitHub Actions ping the health endpoint so the free tier doesn't cold-sleep during a demo |
| Release APK | Signed with a real keystore (not debug), R8-minified |

---

## 10. Rapid-fire likely questions — one-line answers

- **"Is this a diagnosis tool?"** → No. Screening only. States this explicitly
  in the app. Does not replace a doctor or a blood test.
- **"Why not resample the imbalanced classes (SMOTE etc.)?"** → We tuned the
  decision threshold instead and reported imbalance-aware metrics (recall,
  ROC-AUC, balanced accuracy) — simpler, and avoids inventing synthetic
  patients.
- **"Why not logistic regression — simpler, more interpretable?"** → Fair
  point; it's a reasonable baseline we didn't formally compare against — a
  good honest answer, don't fake false confidence here. The MLP can capture
  non-linear interactions between lifestyle factors that a linear model can't.
- **"What's JWT?"** → A signed token proving who you are, without the server
  storing session state. Access token (short-lived) does the work daily;
  refresh token (longer-lived) silently gets you a new one without logging in
  again.
- **"Why microservices weren't used?"** → Two-person team, one deployable
  unit — the operational overhead of separate services would buy nothing at
  this scale. The Django app is still internally modular (separate apps:
  accounts, predictions, profiles, chat).
- **"What happens if the model file is missing?"** → The service raises a
  clear error and the API returns HTTP 503, rather than silently failing or
  crashing.
- **"Two people give identical answers — same result?"** → Yes. Deterministic
  at inference (frozen weights); no randomness once trained.

---

## Tonight's plan

1. Read this once, out loud if you can (15–20 min).
2. Say the 30-second pitch (Section 0) from memory, twice.
3. Tell me "start" and I'll fire questions at you like the panel would —
   that's the single most useful thing left to do tonight.
4. Sleep. Seriously — a rested, confident answer beats a memorized, shaky one.
