# Image Generation Prompts — Aegis Health FYP Report

**How to use this file.** Each section below is one complete prompt. Copy the
whole fenced block (everything between the ``` markers) into ChatGPT / GPT
Image and generate. Then save the result into `docs/assets/` using the exact
filename given in the heading, and the report will pick it up.

---

## ⚠️ READ THIS FIRST — five of these should NOT be AI generated

Five figures in your report are **measurements of your own model**. A language
model cannot know your real ROC curve, your real confusion counts, or your real
calibration error — it will invent plausible-looking numbers, and an examiner
who asks "where did this curve come from?" will expose it immediately.

Those five are **already generated from your trained artifact** and are sitting
in `docs/assets/`:

| File | What it is | Why AI must not make it |
|---|---|---|
| `fig_roc_curves.png` | ROC, AUC 0.823 / 0.793 | Plotted from the held-out test split |
| `fig_pr_curves.png` | Precision-recall | Real prevalence baselines |
| `fig_confusion.png` | Confusion matrices | Real counts at your thresholds |
| `fig_calibration.png` | Reliability, before/after isotonic | Real calibration measurement |
| `fig_feature_importance.png` | Permutation importance | Computed by shuffling each feature |
| `fig_class_imbalance.png` | 13.9% / 3.7% prevalence | Real class balance |

**Use those files as they are.** The prompts below cover only the *conceptual*
diagrams, where an illustration is legitimate.

---

## Global rules — paste these at the top of every prompt

```
GLOBAL REQUIREMENTS FOR THIS IMAGE

Format and resolution
- Produce a single flat 2D vector-style technical diagram.
- Landscape orientation, 16:10 aspect ratio, minimum 2400 x 1500 pixels.
- Pure white background (#FFFFFF). No canvas texture, no paper grain.
- Generous margins: leave at least 4% empty on every edge.

Absolutely forbidden
- NO 3D, no isometric projection, no perspective, no extruded boxes.
- NO drop shadows, no glows, no bevels, no gradients of any kind.
- NO photographic elements, no stock-photo people, no hands, no laptops.
- NO decorative circuit-board patterns, no glowing blue "AI brain" cliches,
  no neon, no sci-fi styling, no holograms.
- NO watermark, no signature, no logo of any AI tool.
- NO lorem ipsum and NO invented placeholder text of any kind.
- NO emoji anywhere in the figure.

Text rules (this is the most important requirement)
- Every character of text must be spelled EXACTLY as written in this prompt.
- Do not paraphrase a label. Do not shorten a label. Do not translate it.
- Do not add any text that is not listed in this prompt.
- All text must be perfectly horizontal. No rotated or vertical text.
- All text must be fully inside its box, never clipped and never overflowing.
- Text must never overlap another text element or a connector line.
- Use a clean humanist sans-serif face throughout (Inter, Helvetica Neue,
  Source Sans, or similar). One family only.
- Minimum effective text size: readable when the image is printed at 16 cm
  wide on A4 paper. Nothing smaller than roughly 11 px at 2400 px wide.
- Sentence case for descriptions. Small caps or uppercase ONLY where the
  prompt explicitly says uppercase.

Colour palette (use these hex values exactly, nothing else)
- Ink / primary text:        #1B2733
- Muted text and thin rules: #5B6B7C
- Blue (presentation tier):  #2E6DB4    fill #E8F0F8
- Teal (application tier):   #1A9E8F    fill #E2F4F1
- Amber (data tier):         #D9902F    fill #FBF1E0
- Rose (external services):  #C2557A    fill #FAECF1
- Neutral fill:              #F1F4F7
- White:                     #FFFFFF

Line and shape rules
- Box corner radius: 6 px at 2400 px wide. Consistent on every box.
- Box border: 2 px solid, in that box's assigned colour.
- Connector lines: 2 px solid #5B6B7C with a small solid triangular arrowhead.
- Connectors must meet box edges cleanly at right angles where possible.
- Connectors must never pass through a box. Route around instead.
- Alignment: boxes in the same row share a top edge and a height exactly.
- Spacing between sibling boxes must be visually equal.

Quality bar
- This figure goes into a university final-year engineering report that will
  be defended in front of an examination panel. It must look like it was
  drawn in Figma by a careful engineer, not generated. Precision over
  decoration. Clarity over style.
```

---

# FIGURE 1 — Cover illustration

**Save as:** `docs/assets/fig_cover.png`

```
Create a restrained, professional cover illustration for the title page of a
university final-year engineering report. The report is about a preventive
health screening mobile application driven by a machine-learning model.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Overall concept
The illustration must communicate one idea and one idea only: a person's
future health risk is measured from everyday lifestyle answers, and that risk
can then be lowered. It is a preventive tool, not a diagnostic machine. The
mood is calm, clinical, trustworthy, and quiet. It is not exciting, not
futuristic, and not dramatic.

Composition
- Landscape, 16:10, white background.
- The illustration occupies the middle 80% of the canvas horizontally and the
  middle 70% vertically. Wide clean white margins all around.
- The composition reads left to right in three stages, evenly spaced, with a
  thin horizontal connector line running through all three at the vertical
  centre.

Stage 1, on the left, at roughly x = 20% of canvas width
- A simple outlined rectangle with rounded corners, drawn in #2E6DB4 with a
  2 px border and #E8F0F8 fill, in the proportions of a mobile phone held
  vertically (aspect ratio 1:2).
- Inside it, draw four short horizontal lines stacked vertically, each with a
  small circle to its left, representing questionnaire rows. Draw these in
  #5B6B7C at 2 px. Two of the circles are filled solid #2E6DB4, two are
  outlined only. Do not write any text inside these rows.
- Beneath the phone, centred, the single word in sentence case:
  Answer
- Below that, in smaller muted text:
  Nineteen everyday questions

Stage 2, in the centre, at roughly x = 50% of canvas width
- A simple neural network glyph: three vertical columns of small circles.
  Column one has 5 circles, column two has 4 circles, column three has 2
  circles. Circle diameter roughly 1.5% of canvas width, outlined 2 px in
  #1A9E8F, filled #FFFFFF.
- Thin connector lines at 1 px in #1A9E8F at 30% opacity link every circle in
  each column to every circle in the next column. These lines must be light
  enough to read as texture, never as clutter.
- The two circles in the third column are filled solid: the upper one
  #2E6DB4, the lower one #C2557A.
- Beneath the glyph, centred, the single word in sentence case:
  Estimate
- Below that, in smaller muted text:
  One shared network, two risks

Stage 3, on the right, at roughly x = 80% of canvas width
- A simple line chart inside an invisible square area. Draw two axes as thin
  #5B6B7C lines, an L shape, with no tick marks and no numbers.
- Draw one line that starts high on the left and descends to the right,
  drawn 3 px in #1A9E8F, with three small solid circular markers along it.
  The line should descend in clear steps, not a smooth curve, suggesting
  measured improvement over time.
- Beneath the chart, centred, the single word in sentence case:
  Lower it
- Below that, in smaller muted text:
  What to change, and by how much

Connector line
- A single horizontal line at 2 px in #5B6B7C runs behind all three stages at
  the vertical centre of the three glyphs, with small triangular arrowheads
  pointing right, positioned between stage 1 and stage 2, and between stage 2
  and stage 3.
- The connector must pass behind the glyphs, not through the text.

Text to include, and nothing else
- Answer
- Nineteen everyday questions
- Estimate
- One shared network, two risks
- Lower it
- What to change, and by how much

Explicitly do NOT include
- Do not draw a heart, a heartbeat line, a stethoscope, a red cross, a pill,
  a syringe, a DNA helix, a caduceus, or a doctor figure. These are medical
  cliches and this is a preventive screening tool, not a clinic.
- Do not draw a human body or silhouette.
- Do not write the words Aegis, Health, diabetes, kidney, AI, or machine
  learning anywhere in the image. The title page already carries the title.
- Do not add a border or frame around the whole image.

Verification checklist before you finish
- Exactly six text strings appear, matching the list above character for
  character.
- Every word is spelled correctly.
- No text touches or overlaps any line or shape.
- The three stages are the same size and sit on the same baseline.
- The image works in greyscale: the three stages remain distinguishable by
  shape alone, not only by colour.
```

---

# FIGURE 2 — System architecture

**Save as:** `docs/assets/fig_architecture.png`

```
Create a precise three-tier software architecture diagram for a university
final-year engineering report.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the very top of the canvas, in bold, dark ink #1B2733:
Aegis Health — System Architecture

Subtitle, directly beneath the title, centred, italic, muted #5B6B7C:
Three-tier modular monolith: presentation, application, data

STRUCTURE
The diagram has three horizontal bands stacked vertically, each band being a
large rounded rectangle with a 2 px DASHED border and a pale tinted fill. The
bands are separated by clear vertical space with connector arrows between
them. Each band has its own caption in the top-left corner INSIDE the band,
positioned so that it never overlaps any box inside that band. Leave a clear
horizontal strip below each caption before the first box begins.

BAND 1 — top band
- Dashed border #2E6DB4, fill #E8F0F8.
- Caption, top-left inside the band, bold, in #2E6DB4, uppercase for the
  first two words only:
  PRESENTATION TIER — Flutter (Dart), Android
- Inside this band, one row of six white boxes with 2 px #2E6DB4 borders.
  All six boxes share the same height and the same top edge. Spacing between
  them is equal. Each box contains two or three lines of centred text:

  Box 1, two lines:
  Auth
  sign in / sign up

  Box 2, two lines:
  Questionnaire
  19 questions

  Box 3, three lines:
  Result
  risk · factors
  advice

  Box 4, two lines:
  Assistant
  chat

  Box 5, two lines:
  History
  trend

  Box 6, two lines:
  Reminders
  on-device

- Beneath the row of six boxes, still inside band 1, one centred line of small
  muted #5B6B7C text:
  State: Provider · JWT in Android Keystore · offline reminders on device

BETWEEN BAND 1 AND BAND 2
- One vertical arrow pointing down, from the bottom edge of band 1 to the top
  edge of band 2, positioned at the horizontal centre of the canvas.
- Two lines of label text beside the arrow, in #2E6DB4:
  HTTPS / REST + JSON
  JWT Bearer token

BAND 2 — middle band
- Dashed border #1A9E8F, fill #E2F4F1.
- Caption, top-left inside the band, bold, in #1A9E8F:
  APPLICATION TIER — Django REST Framework (Python), hosted on Render
- Inside, an upper row of four white boxes with 2 px #1A9E8F borders, equal
  height, equal spacing, each with three lines of centred text:

  Box 1:
  accounts
  register · login
  refresh · password

  Box 2:
  predictions
  schema · predict
  history · model card

  Box 3:
  profiles
  get · update

  Box 4:
  chat
  send · history

- Below that upper row, inside the same band, a lower row of two wider white
  boxes with 2 px #1A9E8F borders, each with two lines of centred text:

  Left box:
  PredictionService  (singleton)
  predict · explain (occlusion) · advise (what-if)

  Right box:
  LLMProvider  (strategy)
  Gemini | Claude | Ollama — swapped by configuration

- Draw a short vertical arrow from the bottom of the predictions box down to
  the top of the PredictionService box.
- Draw a short arrow from the bottom of the chat box down to the top of the
  LLMProvider box.

BETWEEN BAND 2 AND BAND 3
- Three vertical arrows pointing down from band 2 to band 3, evenly spaced
  across the width, each with a short label in #1A9E8F:
  Left arrow label, two lines:
  loads once
  at start-up
  Middle arrow label, one line:
  ORM / SQL
  Right arrow label, one line:
  HTTPS

BAND 3 — bottom band
- Dashed border #D9902F, fill #FBF1E0.
- Caption, top-left inside the band, bold, in #D9902F, uppercase:
  DATA AND MODEL TIER
- Inside, one row of three white boxes with 2 px #D9902F borders, equal
  height and spacing, each with three lines of centred text:

  Box 1:
  multitask_model.joblib
  MLP 18-96-48-2 · 6,674 parameters
  scaler and isotonic calibrators

  Box 2:
  Supabase PostgreSQL
  users · profiles
  assessments · chat

  Box 3:
  Anthropic Messages API
  natural-language
  explanations

CRITICAL LAYOUT REQUIREMENTS
- The caption text inside each band must sit in clear empty space. It must not
  touch, overlap, or sit behind any box. If space is tight, make the band
  taller rather than moving the caption.
- Every box must be large enough that its longest line of text fits with at
  least 8 px of padding on the left and right.
- The longest single string in the diagram is:
  APPLICATION TIER — Django REST Framework (Python), hosted on Render
  Size the middle band so this caption fits on one line without wrapping.
- No arrow may cross another arrow.
- No arrow may pass through any box.

SPELLING CHECK — these exact strings must appear, spelled exactly:
Flutter, Dart, Android, Django REST Framework, Python, Render, Supabase,
PostgreSQL, Anthropic, Gemini, Claude, Ollama, PredictionService, LLMProvider,
singleton, strategy, occlusion, what-if, Keystore, multitask_model.joblib

Note carefully: it is "Supabase", not "Supbase" or "Superbase".
It is "Anthropic", not "Anthropics" or "Antropic".
It is "PostgreSQL", not "PostgresSQL" or "Postgre SQL".

Verification checklist before you finish
- Three bands, clearly separated, each with a visible dashed border.
- Band captions readable and not overlapping anything.
- Six boxes in band 1, six boxes in band 2 (four plus two), three in band 3.
- All arrows point downward, from presentation to application to data.
- Every technical term spelled exactly as listed in the spelling check.
```

---

# FIGURE 3 — Machine-learning pipeline

**Save as:** `docs/assets/fig_ml_pipeline.png`

```
Create a clean left-to-right process pipeline diagram showing how a raw public
health survey file becomes a deployed machine-learning artifact.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Machine-Learning Pipeline

Subtitle, beneath the title, centred, italic, #5B6B7C:
From raw CDC survey file to the artifact the API serves

MAIN STRUCTURE
A single horizontal row of eight rounded rectangles of identical size, evenly
spaced across the width of the canvas, connected left to right by short
horizontal arrows with triangular arrowheads pointing right.

Each box is taller than it is wide (portrait proportion, roughly 2:3) so that
three or four short lines of centred text fit comfortably. All eight boxes
share the same top edge and the same bottom edge.

The eight boxes, in order from left to right, with their fill colours and
their exact text content:

Box 1, fill #F1F4F7, border #5B6B7C, four lines:
Raw BRFSS 2015
LLCP2015.XPT
441 columns
approximately 99 MB

Box 2, fill #E8F0F8, border #2E6DB4, four lines:
Recode
survey codes to
0/1 and ordinals
drop don't-know

Box 3, fill #E8F0F8, border #2E6DB4, four lines:
Clean dataset
253,155 people
18 features
2 labels

Box 4, fill #E2F4F1, border #1A9E8F, four lines:
Split
fit 64%
validation 16%
test 20%

Box 5, fill #E2F4F1, border #1A9E8F, three lines:
Train
shared-backbone MLP
early stopping

Box 6, fill #FAECF1, border #C2557A, three lines:
Calibrate
isotonic regression
on the validation set

Box 7, fill #FAECF1, border #C2557A, three lines:
Tune threshold
lowest value that
holds recall above 0.85

Box 8, fill #FBF1E0, border #D9902F, four lines:
Artifact
model and scaler
calibrators
thresholds

FOOTER NOTE
Below the row of boxes, centred, inside a rounded rectangle with fill #F1F4F7
and a 1 px #5B6B7C border, two lines of text in #5B6B7C:
Validation: 5-fold stratified cross-validation on the joint (diabetes, kidney) label
Selection metric: recall and ROC-AUC, never accuracy, because both conditions are rare

LAYOUT REQUIREMENTS
- All eight boxes identical in width and height.
- Arrows between boxes are short, horizontal, and centred vertically on the
  boxes. Arrowheads point right.
- The numbers must be written exactly as given, including the comma in
  253,155 and the percent signs.
- Text must never overflow a box. If a line is too long, make all eight boxes
  wider rather than shrinking the font of one box.

SPELLING CHECK — exact strings required:
BRFSS, LLCP2015.XPT, isotonic regression, stratified, cross-validation,
ROC-AUC, shared-backbone, early stopping, calibrators, thresholds

Note: it is "BRFSS", all capitals. It is "ROC-AUC" with a hyphen.
The file name is "LLCP2015.XPT" exactly, capital letters, one dot.

Verification checklist
- Exactly eight boxes in one straight horizontal row.
- Exactly seven arrows between them.
- The colour progression runs grey, blue, blue, teal, teal, rose, rose, amber.
- The footer note sits below and does not touch the boxes.
- 253,155 and 18 and 2 and 0.85 all appear correctly.
```

---

# FIGURE 4 — Multi-task neural network

**Save as:** `docs/assets/fig_multitask_network.png`

```
Create a clear, accurate diagram of a small feed-forward neural network that
has one shared body and two separate output heads.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Multi-Task Neural Network

Subtitle, two lines, centred, italic, #5B6B7C:
One shared backbone learns what both diseases have in common; two heads specialise.
Diabetes is a leading cause of chronic kidney disease, so the tasks share structure.

NETWORK STRUCTURE
Draw four vertical columns of circles, plus two output boxes on the right.

Column 1, positioned at roughly x = 14% of canvas width
- 9 circles stacked vertically, evenly spaced.
- Each circle: diameter roughly 1.6% of canvas width, white fill, 2 px border
  in #2E6DB4.
- Below the column, two lines of centred text:
  Input layer
  18 features

Column 2, positioned at roughly x = 38% of canvas width
- 11 circles stacked vertically, evenly spaced, spanning slightly more
  vertical height than column 1.
- Each circle: white fill, 2 px border in #1A9E8F.
- Below the column, two lines of centred text:
  Hidden layer 1
  96 units, ReLU

Column 3, positioned at roughly x = 60% of canvas width
- 9 circles stacked vertically, evenly spaced.
- Each circle: white fill, 2 px border in #1A9E8F.
- Below the column, two lines of centred text:
  Hidden layer 2
  48 units, ReLU

Output boxes, positioned at roughly x = 82% of canvas width
- Two rounded rectangles, one in the upper half and one in the lower half,
  vertically separated so they clearly read as two distinct heads.
- Upper box: fill #E8F0F8, 2 px border #2E6DB4, two lines of centred text:
  Diabetes head
  sigmoid output
- Lower box: fill #FAECF1, 2 px border #C2557A, two lines of centred text:
  Kidney head
  sigmoid output

CONNECTIONS
- Draw thin connector lines between consecutive columns. Do NOT draw every
  possible connection, or the figure becomes an unreadable mesh. Draw roughly
  one in three, sampled evenly, so the impression is of dense connectivity
  while individual lines remain visible.
- Connection lines between column 1, 2 and 3: 1 px, #5B6B7C, 30% opacity.
- Connection lines from column 3 to the Diabetes head: 1 px, #2E6DB4, 35%
  opacity.
- Connection lines from column 3 to the Kidney head: 1 px, #C2557A, 35%
  opacity.
- Crucially: EVERY circle in column 3 must connect to BOTH heads. This is the
  entire point of the figure. The two heads share the same backbone.

ANNOTATION BAND
- Beneath the whole network, centred, a rounded rectangle with fill #F1F4F7
  and 1 px #5B6B7C border, containing one line of centred text:
  Shared backbone · 6,674 trainable parameters

LABEL FOR THE SHARED REGION
- Draw a thin horizontal bracket or a light dashed rounded rectangle that
  encloses columns 1, 2 and 3 but NOT the two head boxes.
- Label it above, in #5B6B7C italic:
  shared representation

Text to include, and nothing else
- Multi-Task Neural Network
- the two subtitle lines
- Input layer / 18 features
- Hidden layer 1 / 96 units, ReLU
- Hidden layer 2 / 48 units, ReLU
- Diabetes head / sigmoid output
- Kidney head / sigmoid output
- Shared backbone · 6,674 trainable parameters
- shared representation

Explicitly do NOT
- Do not label individual neurons with numbers or letters.
- Do not draw weights, biases, or mathematical formulas.
- Do not draw a brain, a lightbulb, a robot, or any AI iconography.
- Do not write the words "deep learning" or "artificial intelligence".

SPELLING CHECK
ReLU is written exactly as "ReLU": capital R, lowercase e, capital L, capital U.
The parameter count is exactly 6,674 with a comma.
The feature count is exactly 18.

Verification checklist
- Four columns: 9, 11, 9 circles then two boxes.
- Every circle in the third column links to both output boxes.
- The bracket encloses the three circle columns only.
- 18, 96, 48 and 6,674 all appear and are correct.
```

---

# FIGURE 5 — Use-case diagram

**Save as:** `docs/assets/fig_use_case.png`

```
Create a standard UML use-case diagram.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Use-Case Diagram

STRUCTURE
A classic UML use-case layout: one actor on the left, one actor on the right,
and a large system boundary rectangle in the middle containing oval use cases.

LEFT ACTOR
- A standard UML stick figure drawn in 2 px #1B2733 lines: a circle for the
  head, a vertical line for the body, a horizontal line for the arms, two
  diagonal lines for the legs. No face, no detail, no clothing.
- Positioned at roughly x = 9% of canvas width, vertically centred.
- Label beneath, two lines, centred, bold:
  Registered
  User

RIGHT ACTOR
- An identical stick figure at roughly x = 91% of canvas width.
- Label beneath, one line, centred, bold:
  Administrator

SYSTEM BOUNDARY
- A large rectangle with square corners (not rounded), 2 px border #5B6B7C,
  white fill, occupying the middle 56% of the canvas width and most of its
  height.
- At the top inside the rectangle, centred, italic #5B6B7C:
  Aegis Health System

USE CASES
Inside the boundary, nine ovals (ellipses) stacked vertically, evenly spaced,
all the same width and height. Each has a white fill and a 2 px border in the
colour noted, with centred single-line text in #1B2733:

1. border #2E6DB4:  Create account
2. border #2E6DB4:  Sign in
3. border #2E6DB4:  Change password
4. border #1A9E8F:  Complete questionnaire
5. border #1A9E8F:  View risk assessment
6. border #1A9E8F:  Run what-if simulation
7. border #C2557A:  Ask the assistant
8. border #C2557A:  Review history
9. border #D9902F:  Manage reminders

ONE ADMINISTRATOR USE CASE
- A tenth oval, same style, border #5B6B7C, positioned near the top-right
  INSIDE the boundary, offset to the right so it is clearly associated with
  the Administrator:
  Inspect model card

ASSOCIATION LINES
- Draw a thin 1.5 px solid #5B6B7C line from the Registered User stick figure
  to each of the nine ovals numbered 1 to 9. These lines fan out from the
  actor. They have NO arrowheads (UML associations are plain lines).
- Draw one thin line from the Administrator stick figure to the "Inspect model
  card" oval. No arrowhead.
- Association lines must never cross an oval. They may cross each other only
  where unavoidable.

FOOTER NOTE
- Below the system boundary, centred, small italic #5B6B7C, one line:
  Completing the questionnaire always triggers a prediction, an explanation and a what-if pass.

Text to include, and nothing else
- Use-Case Diagram
- Registered User
- Administrator
- Aegis Health System
- the ten use-case labels listed above
- the footer note

Explicitly do NOT
- Do not add <<include>> or <<extend>> stereotype arrows between ovals. Keep
  the diagram simple and readable.
- Do not add a database symbol, a server symbol, or any icon.
- Do not number the ovals in the image. The numbers above are only to tell you
  the order.

SPELLING CHECK
"what-if" is lowercase with a hyphen.
"Aegis Health System" has three capitalised words.
"model card" is lowercase in the administrator use case.

Verification checklist
- Two stick figures, one on each side.
- Exactly ten ovals inside the boundary.
- Nine lines from the left actor, one line from the right actor.
- No arrowheads on any association line.
- The system boundary has square corners, and the ovals are true ellipses.
```

---

# FIGURE 6 — Activity diagram

**Save as:** `docs/assets/fig_activity.png`

```
Create a standard UML activity diagram (a flowchart) for one complete risk
assessment, from opening the app to receiving a result.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE. Use PORTRAIT orientation for this
one, 10:14 aspect ratio, minimum 1800 x 2520 pixels.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Activity Diagram — Risk Assessment

FLOW, from top to bottom, vertically centred on the canvas

1. START NODE
   A solid filled black circle, diameter roughly 3% of canvas width.

2. ACTIVITY: rounded rectangle, fill #E8F0F8, border 2 px #2E6DB4, one line:
   Open app

3. ACTIVITY: rounded rectangle, fill #E8F0F8, border 2 px #2E6DB4, one line:
   Sign in, JWT issued

4. ACTIVITY: rounded rectangle, fill #E2F4F1, border 2 px #1A9E8F, two lines:
   Answer 19 questions
   profile pre-fills age, sex, height and weight

5. ACTIVITY: rounded rectangle, fill #E2F4F1, border 2 px #1A9E8F, two lines:
   App computes BMI from height and weight
   producing an 18-feature payload

6. ACTIVITY: rounded rectangle, fill #E2F4F1, border 2 px #1A9E8F, one line:
   POST /api/predict/ with Bearer token

7. ACTIVITY: rounded rectangle, fill #FBF1E0, border 2 px #D9902F, one line:
   Server validates every field against the schema

8. DECISION: a diamond (rotated square), white fill, 2 px #D9902F border,
   containing one word:
   Valid?

9. From the LEFT point of the diamond, a horizontal arrow pointing left,
   labelled in #C2557A:
   no
   leading to a rounded rectangle, fill #FAECF1, border 2 px #C2557A, two
   lines:
   Return 400
   with the field errors
   From that box, a line continues down and then right, rejoining the flow at
   the end node.

10. From the BOTTOM point of the diamond, a vertical arrow pointing down,
    labelled in #1A9E8F:
    yes
    leading to a rounded rectangle, fill #E2F4F1, border 2 px #1A9E8F, three
    lines:
    The model runs three times over the same vector
    predict, then explain with 18 occlusions,
    then advise with 6 what-if edits

11. ACTIVITY: rounded rectangle, fill #E8F0F8, border 2 px #2E6DB4, one line:
    Save to history and return risk, factors and advice

12. END NODE
    A black circle with a white ring around it: an outer circle with a 2 px
    black border and white fill, containing a smaller solid black circle.

CONNECTORS
- Every step is joined to the next by a straight vertical 2 px #5B6B7C line
  with a triangular arrowhead pointing down.
- The only horizontal movement is the "no" branch on the left.
- Arrows must connect box edge to box edge, never overlapping the box.

LAYOUT REQUIREMENTS
- All activity rectangles share the same width and the same horizontal centre.
- The diamond is centred on that same vertical axis.
- The "no" branch box sits clearly to the left, not overlapping the main
  column.
- Vertical spacing between steps is equal throughout.

Text to include, and nothing else
- the title
- the eleven step labels exactly as written above
- the word "Valid?" in the diamond
- the words "yes" and "no" on the two branches

SPELLING CHECK
"JWT" is three capital letters.
"BMI" is three capital letters.
The endpoint is written exactly: POST /api/predict/
including the leading slash and the trailing slash.
"18-feature" has a hyphen. "what-if" has a hyphen.
The numbers 19, 18 and 6 must appear correctly.

Verification checklist
- One solid start circle at the top, one ringed end circle at the bottom.
- Exactly one diamond, with exactly two outgoing branches labelled yes and no.
- Every arrow points downward except the single "no" branch.
- The three colour families are used consistently: blue for app steps, teal
  for user and model steps, amber for validation, rose for the error path.
```

---

# FIGURE 7 — Entity-relationship diagram

**Save as:** `docs/assets/fig_erd.png`

```
Create a precise entity-relationship diagram for a relational database, in the
common "table box" style used in engineering reports.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Entity-Relationship Diagram

Subtitle, centred, italic, #5B6B7C:
As implemented by the Django ORM on Supabase PostgreSQL

STRUCTURE
Four table boxes. Each table box is a rectangle with slightly rounded corners,
white fill, and a 2 px coloured border. Each has a coloured header strip at the
top containing the table name in bold, and beneath it a list of columns.

Each column row shows three things, laid out on one line:
- on the left, a key marker: the letters PK, FK, or U, or blank
- next to it, the column name, left aligned
- on the far right of the box, the data type, right aligned, in smaller
  italic muted #5B6B7C text

TABLE 1 — top left
Border and header fill: #1F3B5C header with #E8F0F8 tint
Header text: auth_user
Columns:
  PK   id                 bigint
  U    username           varchar(150)
       email              varchar(254)
       password           varchar(128)
       date_joined        timestamptz
       is_active          boolean

TABLE 2 — top centre
Border #1A9E8F, header fill #E2F4F1
Header text: profiles_userprofile
Columns:
  PK   id                 bigint
  FK   user_id            bigint
       avatar             text
       sex                integer
       age                integer
       height_cm          double
       weight_kg          double
       updated_at         timestamptz

TABLE 3 — top right
Border #2E6DB4, header fill #E8F0F8
Header text: predictions_assessment
Columns:
  PK   id                 bigint
  FK   user_id            bigint
       inputs             jsonb
       result             jsonb
       diabetes_risk      double
       kidney_risk        double
       created_at         timestamptz

TABLE 4 — bottom centre
Border #C2557A, header fill #FAECF1
Header text: chat_chatmessage
Columns:
  PK   id                 bigint
  FK   user_id            bigint
       role               varchar(10)
       text               text
       created_at         timestamptz

RELATIONSHIP LINES
Draw three plain 2 px #5B6B7C lines with NO arrowheads, each labelled at both
ends with its cardinality in small #5B6B7C text:

Line A: from the right edge of auth_user to the left edge of
profiles_userprofile. Label "1" at the auth_user end and "1" at the
profiles_userprofile end.

Line B: from auth_user to predictions_assessment, routed above or around
profiles_userprofile so it does not pass through it. Label "1" at the
auth_user end and "N" at the predictions_assessment end.

Line C: from the bottom of auth_user down to the left edge of
chat_chatmessage. Label "1" at the auth_user end and "N" at the
chat_chatmessage end.

FOOTER NOTE
Below everything, centred, inside a rounded rectangle with #F1F4F7 fill and a
1 px #5B6B7C border, three lines of #5B6B7C text:
One user has exactly one profile, and many assessments and chat messages.
The inputs and result columns are stored as JSONB, so a model change needs no migration.
Deleting a user cascades to every row that user owns.

LAYOUT REQUIREMENTS
- Column rows inside a table must be evenly spaced and left-aligned with each
  other. The data types must form a clean right-aligned column.
- All four tables use the same row height and the same font size.
- Relationship lines must not pass through any table box.
- Nothing may overlap.

SPELLING CHECK — these exact identifiers must appear character for character:
auth_user
profiles_userprofile
predictions_assessment
chat_chatmessage
user_id, height_cm, weight_kg, diabetes_risk, kidney_risk, created_at,
updated_at, date_joined, is_active
timestamptz, jsonb, bigint, varchar, boolean, double, integer, text

Note carefully: underscores, not spaces or hyphens.
"timestamptz" is one word, no spaces.
"jsonb" is lowercase.
It is "Supabase" in the subtitle, not "Supbase".

Verification checklist
- Four table boxes, each with a coloured header strip.
- PK appears once per table, FK appears in three tables, U appears once.
- Exactly three relationship lines, each labelled with 1 and 1, or 1 and N.
- No arrowheads on relationship lines.
- Every identifier spelled exactly as listed.
```

---

# FIGURE 8 — Sequence diagram

**Save as:** `docs/assets/fig_sequence.png`

```
Create a UML sequence diagram showing the messages exchanged during one risk
assessment request.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Sequence Diagram — One Risk Assessment

PARTICIPANTS
Five participant boxes across the top, evenly spaced, all the same size.
Each is a rounded rectangle, white fill, 2 px coloured border, with the
participant name in bold centred inside:

1. at x = 10%:  border #2E6DB4, text:  Flutter app
2. at x = 32%:  border #1A9E8F, text:  Django API
3. at x = 55%:  border #D9902F, text:  PredictionService
4. at x = 76%:  border #5B6B7C, text:  Model artifact
5. at x = 93%:  border #C2557A, text:  PostgreSQL

LIFELINES
From the bottom centre of each participant box, draw a vertical DASHED 1.5 px
line in #5B6B7C running down to near the bottom of the canvas. These are the
lifelines.

MESSAGES
Ten horizontal messages, stacked from top to bottom in this exact order.
Each message that travels between two different participants is a solid 2 px
horizontal arrow with a triangular arrowhead, drawn from one lifeline to
another, with its label written just above the arrow in small text on a white
background so it stays readable where it crosses a lifeline.

Each message that a participant sends to itself is drawn instead as a small
rounded rectangle sitting on that participant's lifeline, containing the text.

Message 1, from Flutter app to Django API:
POST /api/predict/ with 18 answers and a Bearer token

Message 2, Django API to itself (self-call box):
authenticate and validate against the schema

Message 3, from Django API to PredictionService:
assess(payload)

Message 4, from PredictionService to Model artifact:
predict, returning 2 calibrated probabilities

Message 5, from PredictionService to Model artifact:
explain, 18 occlusion passes

Message 6, from PredictionService to Model artifact:
advise, 6 what-if passes

Message 7, from PredictionService back to Django API (arrow points left):
risk, factors and recommendations

Message 8, from Django API to PostgreSQL:
INSERT assessment row

Message 9, from PostgreSQL back to Django API (arrow points left):
row id

Message 10, from Django API back to Flutter app (arrow points left):
200 OK with prediction, key_factors and recommendations

FOOTER NOTE
At the bottom, centred, italic #5B6B7C, one line:
The model is loaded once at start-up and held in memory, so a request costs 25 forward passes and a single insert.

LAYOUT REQUIREMENTS
- Messages are evenly spaced vertically.
- Arrows are perfectly horizontal.
- Return messages (7, 9, 10) point LEFT. All others point RIGHT.
- Message labels must never be obscured where they cross a lifeline: place a
  small white rectangle behind each label.
- The self-call box for message 2 must sit to the right of the Django API
  lifeline and must not overlap the PredictionService lifeline.

SPELLING CHECK
The endpoint is exactly: POST /api/predict/
"assess(payload)" includes the parentheses.
"key_factors" has an underscore.
"200 OK" has a space.
"PredictionService" is one word, two capitals.
"PostgreSQL" is spelled with capital P, capital SQL.

Verification checklist
- Five participants with five dashed lifelines.
- Exactly ten messages in the order given.
- Three arrows point left; six point right; one is a self-call box.
- No label is unreadable where it crosses a lifeline.
```

---

# FIGURE 9 — Deployment diagram

**Save as:** `docs/assets/fig_deployment.png`

```
Create a deployment diagram showing which software runs on which machine, and
how those machines communicate over the network.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Deployment Diagram

Subtitle, centred, italic, #5B6B7C:
What runs where, once the project is live

STRUCTURE
Four labelled "node" containers. Each is a large rounded rectangle with a
2 px DASHED border and a pale tinted fill, with its caption in the top-left
corner inside, in bold uppercase. Inside each container sits one or two white
boxes with solid 2 px borders describing the software deployed there.

Leave clear space below each caption so the caption never touches the inner
box.

NODE 1 — upper left
Dashed border #2E6DB4, fill #E8F0F8
Caption: USER DEVICE
Inner box, white with 2 px #2E6DB4 border, six lines of centred text:
Android phone
Aegis Health APK
signed release build
JWT stored in Keystore
reminders scheduled
on the device itself

NODE 2 — upper centre
Dashed border #1A9E8F, fill #E2F4F1
Caption: RENDER, SINGAPORE REGION
Inner box, white with 2 px #1A9E8F border, six lines of centred text:
Web service
gunicorn
1 worker, 4 threads
Django and DRF
model held in memory
automatic redeploy on push

NODE 3 — upper right
Dashed border #D9902F, fill #FBF1E0
Caption: SUPABASE, SYDNEY REGION
Inner box, white with 2 px #D9902F border, six lines of centred text:
PostgreSQL 15
session pooler
TLS required
users and profiles
assessments
chat messages

NODE 4 — lower centre, spanning a wide area
Dashed border #C2557A, fill #FAECF1
Caption: EXTERNAL SERVICES
Two inner boxes side by side, each white with a 2 px #C2557A border:
Left box, two lines:
Anthropic Messages API
natural-language replies
Right box, three lines:
GitHub Actions
keep-alive ping
every 10 minutes

CONNECTIONS
- From NODE 1 to NODE 2: a horizontal 2 px #2E6DB4 arrow pointing right,
  labelled on two lines:
  HTTPS
  REST and JWT
- From NODE 2 to NODE 3: a horizontal 2 px #1A9E8F arrow pointing right,
  labelled on two lines:
  TLS
  port 5432
- From NODE 2 down to the Anthropic box in NODE 4: a vertical 2 px #C2557A
  arrow, labelled:
  HTTPS
- From the GitHub Actions box up to NODE 2: a 2 px #C2557A arrow pointing up
  and left, labelled:
  GET /api/health/

FOOTER NOTE
At the very bottom, centred, inside a rounded rectangle with #F1F4F7 fill and
a 1 px #5B6B7C border, one line:
git push → GitHub → Render rebuilds and redeploys automatically

LAYOUT REQUIREMENTS
- The three upper nodes sit in one row, sharing a top edge and a height.
- The fourth node sits below, centred.
- Arrows must not cross each other.
- Captions must not overlap inner boxes.

SPELLING CHECK
"gunicorn" is all lowercase.
"Supabase" is spelled S-u-p-a-b-a-s-e.
"Anthropic" is spelled A-n-t-h-r-o-p-i-c.
"GitHub" has a capital G and a capital H, no space.
"PostgreSQL 15" with a space before the number.
The endpoint is exactly: GET /api/health/
The port number is exactly 5432.

Verification checklist
- Four dashed containers, three on top and one below.
- Five solid inner boxes in total.
- Four labelled connections.
- Every region name and port number correct.
```

---

# FIGURE 10 — Class diagram

**Save as:** `docs/assets/fig_class_diagram.png`

```
Create a UML class diagram of the backend domain model and service layer.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Class Diagram — Backend Domain and Services

CLASS BOX FORMAT
Every class is drawn as a rectangle divided into three horizontal compartments
by thin horizontal lines:
- top compartment: the class name in bold, centred, on a tinted background
- middle compartment: attributes, one per line, left aligned, each prefixed
  with a minus sign and a space
- bottom compartment: methods, one per line, left aligned, each prefixed with
  a plus sign and a space

THE CLASSES

Class 1 — top left. Border #1F3B5C, header tint #E8F0F8
Name: User
Attributes:
- username
- email
- password
Methods:
+ check_password()
+ set_password()

Class 2 — top centre. Border #2E6DB4, header tint #E8F0F8
Name: Assessment
Attributes:
- user : ForeignKey
- inputs : JSON
- result : JSON
- diabetes_risk : float
- kidney_risk : float
- created_at : datetime
Methods:
+ __str__()

Class 3 — top right. Border #1A9E8F, header tint #E2F4F1
Name: UserProfile
Attributes:
- user : OneToOneField
- sex : int
- age : int
- height_cm : float
- weight_kg : float
Methods:
+ __str__()

Class 4 — middle left, larger. Border #D9902F, header tint #FBF1E0
Above the class name, in small italic, write the stereotype:
«singleton»
Name: PredictionService
Attributes:
- model
- scaler
- features
- thresholds
- calibrators
Methods:
+ instance()
+ predict()
+ explain()
+ advise()
+ assess()
+ model_card()

Class 5 — middle right. Border #C2557A, header tint #FAECF1
Above the class name, in small italic, write the stereotype:
«interface»
Name: LLMProvider
Attributes:
- name
Methods:
+ reply(system, history)

THREE IMPLEMENTING CLASSES
Below LLMProvider, three small boxes in a row, each white with a 2 px #C2557A
border, containing only a class name, no compartments:
ClaudeProvider
GeminiProvider
OllamaProvider

RELATIONSHIPS
- From User to Assessment: a plain 2 px #5B6B7C line, no arrowhead, with the
  cardinality "1" written near the User end and "N" near the Assessment end.
- From UserProfile to User: a plain line, with "1" at each end.
- From each of the three implementing classes up to LLMProvider: a 2 px
  #C2557A line ending in a LARGE HOLLOW TRIANGLE arrowhead touching the
  LLMProvider box. This is the UML realisation symbol. The triangle must be
  unfilled, white inside, with a coloured outline.
- From PredictionService, a short arrow downward labelled in #D9902F:
  loads the trained artifact

FOOTER NOTE
At the bottom, centred, italic #5B6B7C, one line:
The provider interface is the Strategy pattern: the chat brain is chosen by configuration, never by an if-statement inside a view.

LAYOUT REQUIREMENTS
- The three top classes share a top edge.
- Compartment divider lines span the full width of the class box.
- Attribute and method text is left aligned with consistent indentation.
- The three implementing classes are evenly spaced and the same size.
- No line passes through a class box.

SPELLING CHECK
"ForeignKey" and "OneToOneField" are each one word with internal capitals.
"__str__()" has exactly two underscores on each side.
"check_password()" and "set_password()" use underscores.
"model_card()" uses an underscore.
"PredictionService", "LLMProvider", "ClaudeProvider", "GeminiProvider",
"OllamaProvider" are each one word with internal capitals.
The stereotype guillemets are « and », not << and >>.

Verification checklist
- Five full class boxes with three compartments each, plus three small boxes.
- Two stereotypes shown, on PredictionService and LLMProvider.
- Three hollow triangle arrowheads pointing at LLMProvider.
- Minus signs on all attributes, plus signs on all methods.
```

---

# FIGURE 11 — Sprint schedule (Gantt chart)

**Save as:** `docs/assets/fig_gantt.png`

```
Create a clean horizontal Gantt chart showing an eight-sprint agile schedule.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Title, centred at the top, bold, #1B2733:
Development Schedule — Agile Sprints

CHART STRUCTURE
- A horizontal bar chart. The vertical axis lists eight sprint names, reading
  top to bottom. The horizontal axis is project week, running from 0 to 22.
- Draw light vertical gridlines in #DCE3EA at every even week: 0, 2, 4, 6, 8,
  10, 12, 14, 16, 18, 20, 22. Label each gridline with its number beneath the
  axis.
- The horizontal axis is labelled beneath, centred:
  Project week
- No vertical axis line and no top or right border. Only a light baseline.

THE EIGHT BARS
Each bar is a plain rectangle with a 1.5 px #1B2733 outline and a solid fill.
To the right of each bar, outside it, write a short description in #5B6B7C.

Row 1, weeks 0 to 3, fill #2E6DB4
Label on the left axis: Sprint 1 — Research and data
Description to the right of the bar: BRFSS extraction, recoding, baseline model

Row 2, weeks 3 to 6, fill #2E6DB4
Label: Sprint 2 — Multi-task model
Description: Shared backbone, two heads, threshold tuning

Row 3, weeks 6 to 8, fill #1A9E8F
Label: Sprint 3 — Rigour
Description: Cross-validation, isotonic calibration

Row 4, weeks 8 to 11, fill #1A9E8F
Label: Sprint 4 — REST API
Description: JWT auth, predict, explain, what-if, history

Row 5, weeks 11 to 15, fill #D9902F
Label: Sprint 5 — Mobile app
Description: Flutter screens, state, offline reminders

Row 6, weeks 15 to 17, fill #D9902F
Label: Sprint 6 — Assistant
Description: Provider abstraction, grounded prompting

Row 7, weeks 17 to 19, fill #C2557A
Label: Sprint 7 — Deployment
Description: Render, Supabase, signed release build

Row 8, weeks 19 to 22, fill #C2557A
Label: Sprint 8 — Design and documentation
Description: Design system, accessibility, report

LAYOUT REQUIREMENTS
- All eight bars have the same height.
- Vertical spacing between bars is equal.
- Bar start and end positions must match the week numbers exactly. A bar that
  runs weeks 3 to 6 must begin precisely at gridline 3 and end precisely at
  gridline 6.
- The sprint names on the left must be fully visible, never truncated.
- The descriptions on the right must not run off the canvas. Leave enough
  room on the right-hand side.
- Do not add a legend. The colours simply group related sprints.

SPELLING CHECK
Each sprint label uses an em dash "—" with a space on each side, not a hyphen.
"BRFSS" is all capitals.
"Multi-task" has a hyphen and a capital M.
"what-if" is lowercase with a hyphen.
"REST API" is all capitals with a space.

Verification checklist
- Eight bars, eight labels, eight descriptions.
- Week axis runs 0 to 22 with even-numbered gridlines.
- Bars are colour grouped in pairs: blue, blue, teal, teal, amber, amber,
  rose, rose.
- No bar extends past week 22.
```

---

# FIGURE 12 — Mobile screen showcase

**Save as:** `docs/assets/fig_screens.png`

> **Better option:** real screenshots from the running app are already being
> captured into `docs/assets/screens/`. Use those in the report. Generate this
> figure only if you want an additional stylised showcase page.

```
Create a clean product showcase image presenting five mobile app screens side
by side, in the style used on a software portfolio page.

PASTE THE GLOBAL REQUIREMENTS BLOCK HERE.

SPECIFIC BRIEF FOR THIS IMAGE

Overall
- Five phone-shaped frames in one horizontal row, evenly spaced, all the same
  size, all perfectly upright and front-facing. No tilting, no perspective, no
  overlapping, no 3D.
- Each frame is a rounded rectangle with an aspect ratio of 1:2, a 3 px
  #1B2733 border, and a white interior. Do not draw a notch, a camera, a
  status bar, a battery icon, or a signal icon. Those belong to the operating
  system and must not be faked.
- Beneath each frame, centred, a caption in bold #1B2733.

SCREEN 1 — caption: Sign in
Contents, from top:
- A small solid square in #1A9E8F, roughly 12% of the frame width, top left.
- Below it, the word in large bold dark text: Welcome
- On the next line, same size: back.
- A thin horizontal rule in #DCE3EA spanning the frame width.
- Two input fields drawn as rounded rectangles with #DCE3EA borders and white
  fill. Above the first, in small uppercase letter-spaced muted text:
  USERNAME
  Above the second:
  PASSWORD
- Below them, a solid #1A9E8F rounded rectangle button containing centred
  white uppercase text:
  SIGN IN

SCREEN 2 — caption: Questionnaire
Contents, from top:
- A row of five short horizontal segments, the first two filled #1A9E8F and
  the rest #DCE3EA, representing step progress.
- On the right of that row, small monospace-looking text: 02/05
- Below, in small uppercase letter-spaced #1A9E8F text: YOUR BODY
- Below that, in large bold dark text on two lines:
  We will work out
  your BMI for you
- Two labelled input fields as in screen 1, labelled:
  HEIGHT
  WEIGHT
- At the bottom, a solid #1A9E8F button with white uppercase text:
  CONTINUE

SCREEN 3 — caption: Result
Contents, from top:
- A dark, nearly black band (#101613) filling the upper 45% of the frame,
  spanning the full frame width.
- Inside that dark band, in white:
  small uppercase letter-spaced text: ESTIMATED RISK
  then very large white numerals: 18.4
  followed by a smaller percent sign
  then small uppercase text in a warm colour: HIGH RISK
  then a horizontal bar: a thin grey track with the left third filled in a
  warm red (#EB5B49), and a short vertical white tick mark near the middle.
- Below the dark band, on white:
  small uppercase letter-spaced text: WHAT DRIVES IT
  then three rows, each with a short label on the left in dark text and a
  thin horizontal bar to the right filled in #FF7A63 to differing lengths.
  The three labels are:
  Self-rated general health
  High blood pressure
  Body mass index

SCREEN 4 — caption: What-if
Contents, from top:
- Small uppercase letter-spaced muted text: PROJECTED RISK
- Large dark numerals: 12.1
- A horizontal bar, mostly filled in #F2A03D.
- A thin horizontal rule.
- Small uppercase letter-spaced muted text: HABITS
- Four rows, each with a short dark label on the left and a small toggle
  switch on the right. Two toggles are ON, drawn as a filled #1A9E8F rounded
  pill with a white circle at the right end. Two are OFF, drawn as a #DCE3EA
  pill with a white circle at the left end. The four labels are:
  Physically active
  Not smoking
  Fruit most days
  Vegetables most days

SCREEN 5 — caption: Assistant
Contents, from top:
- Small uppercase letter-spaced dark text: ASSISTANT
- A thin horizontal rule.
- Three chat bubbles, alternating alignment:
  First, aligned right, filled #1A9E8F with white text:
  Why is my risk high?
  Second, aligned left, white fill with a #DCE3EA border and dark text on two
  lines:
  Three things stand out:
  your BMI, blood pressure and activity.
  Third, aligned right, filled #1A9E8F with white text:
  What should I change first?
- At the bottom, an input field with a rounded #DCE3EA border, and to its
  right a small solid #1A9E8F square button containing a white upward arrow.

CRITICAL REQUIREMENTS
- All text inside the phone frames must be real, legible, correctly spelled
  English exactly as specified. Do NOT render blurred grey placeholder lines
  in place of text.
- Do not invent extra screens, extra buttons, or extra labels.
- Do not draw a fake status bar or fake keyboard.
- Keep every frame perfectly vertical and identical in size.

Verification checklist
- Five frames, five captions.
- Screen 3 has a dark band; the other four are light.
- Every number shown (02/05, 18.4, 12.1) appears exactly as written.
- No fake status bar anywhere.
```

---

## Quick reference — filenames the report expects

| Figure | Filename | Source |
|---|---|---|
| 1 | `fig_cover.png` | generate with prompt |
| 2 | `fig_architecture.png` | generate, or use the one already in assets |
| 3 | `fig_ml_pipeline.png` | generate, or use the one already in assets |
| 4 | `fig_multitask_network.png` | generate, or use the one already in assets |
| 5 | `fig_use_case.png` | generate, or use the one already in assets |
| 6 | `fig_activity.png` | generate, or use the one already in assets |
| 7 | `fig_erd.png` | generate, or use the one already in assets |
| 8 | `fig_sequence.png` | generate, or use the one already in assets |
| 9 | `fig_deployment.png` | generate, or use the one already in assets |
| 10 | `fig_class_diagram.png` | generate, or use the one already in assets |
| 11 | `fig_gantt.png` | generate, or use the one already in assets |
| 12 | `fig_screens.png` | prefer real screenshots |
| — | `fig_roc_curves.png` | **do not generate — measured** |
| — | `fig_pr_curves.png` | **do not generate — measured** |
| — | `fig_confusion.png` | **do not generate — measured** |
| — | `fig_calibration.png` | **do not generate — measured** |
| — | `fig_feature_importance.png` | **do not generate — measured** |
| — | `fig_class_imbalance.png` | **do not generate — measured** |
