# Aegis Health — The Complete Guide (Simple English)

This file explains **everything** in your project from zero — like nobody
ever taught you any of this before. Every hard word is explained the first
time it's used. Colored boxes help you tell different KINDS of information
apart at a glance.

---

## 🎨 Color Key — what each box means

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 BLUE = WHAT IS IT</b> — a plain definition of a word or idea.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 GREEN = WHY WE USE IT</b> — the reason we made this choice.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 ORANGE = SIMPLE EXAMPLE</b> — real numbers, so it's not just theory.
</div>

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 RED = WATCH OUT</b> — a mistake people commonly make, or a trap question.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 PURPLE = SAY THIS IN THE VIVA</b> — a ready sentence you can say out loud.
</div>

---

# PART 1 — The Big Picture

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> Aegis Health is a mobile app. A person answers 19 easy
questions about their daily life (do you smoke, are you active, is your
blood pressure high, and so on). The app then tells them how likely they are
to get Diabetes or Kidney Disease IN THE FUTURE — even though they have no
symptoms yet, and without taking any blood test.
</div>

Three separate computer programs work together to make this happen:

| Part | What it is in one word | Language used |
|---|---|---|
| **Mobile App** | The screens you tap on your phone | Dart (using Flutter) |
| **Backend** | The "brain office" that receives requests and decides things | Python (using Django) |
| **The Model** | The actual trained AI that makes the prediction | Python (using scikit-learn) |

They all talk to each other over the internet using a common language called
**JSON** (a simple way of writing data like `{"age": 25, "smoker": 0}` that
every programming language can read).

---

# PART 2 — The Dataset (Where Our Data Came From)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> A dataset is just a big table of information, like a huge
Excel sheet. Our dataset is called <b>BRFSS 2015</b> (Behavioral Risk Factor
Surveillance System) — a real phone survey done every year in the USA by the
government's health department (the CDC). It asks ordinary people questions
about their health and habits.
</div>

- **253,155 rows** — that means data from 253,155 real people.
- Each row has answers to health questions PLUS whether that person actually
  has diabetes or kidney disease (this is called the **label** — the "correct
  answer" the model needs to learn to guess).

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE IT:</b> It's real government data (not something we made up),
it's huge (253,155 people is a LOT — that makes the model's learning much
more trustworthy than if we only had, say, 500 people), and it already
records both diseases we care about.
</div>

### Cleaning the raw data

The raw survey file doesn't use nice numbers like 0 and 1. It uses survey
codes, like:

- `1` = Yes
- `2` = No
- `7` = Don't know
- `9` = Refused to answer

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> The raw file might say a person's smoking answer is
"2". A computer reading that literally would think "2 cigarettes" or
something meaningless. So we WROTE CODE (a script) that turns every "2" for
that question into a clean "0" (meaning No), and every "1" into "1" (meaning
Yes). We also THROW AWAY any row that answered "don't know" or "refused,"
because we can't use an unclear answer to teach the model.
</div>

### Our final 18 questions (features)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A "FEATURE":</b> In machine learning, a "feature" is just one
piece of input information — one column in the table. "Are you a smoker?" is
one feature. "What is your age group?" is another feature.
</div>

We started with 19 features, then **removed one — `MentHlth`** (a question
asking how many days you felt mentally unwell). We didn't just guess it was
unimportant — we **measured** it first using a technique called **permutation
importance** (explained later in Part 8). It turned out to be the 15th most
useful feature out of 19, worth barely anything (0.001 out of the model's
total accuracy score). Asking that question also felt intrusive for a
diabetes/kidney screening app, so removing it was an easy win — simpler
questionnaire, no real loss in prediction quality.

**Our final 18 features:** High blood pressure, High cholesterol, Cholesterol
checked recently, BMI (Body Mass Index — a number that combines your height
and weight), Smoker, History of stroke, Heart disease, Physically active,
Eats fruit, Eats vegetables, Heavy alcohol use, Has healthcare coverage,
Skipped doctor due to cost, General health rating, Poor physical-health days,
Difficulty walking, Sex, Age group.

**Our 2 labels (what we're trying to predict):** Diabetes (yes/no), Kidney
disease (yes/no).

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — an important number:</b> Diabetes appears in about
<b>13.9%</b> of the 253,155 people. Kidney disease appears in about
<b>3.7%</b>. Both are RARE. Keep this number in your head — Part 9 explains
why it's the single most dangerous trap in this whole project if you don't
understand it.
</div>

---

# PART 3 — Preparing Data for the Model (Splitting and Scaling)

### Splitting into three groups — not two!

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> Before training, we cut our 253,155 people into THREE
separate piles:
</div>

| Pile | Share | What it's used for |
|---|---|---|
| **Fit set (training set)** | ~64% | The model actually STUDIES this data and learns from it |
| **Validation set** | ~16% | Used AFTER training, to fine-tune settings (like calibration and the decision cutoff) |
| **Test set** | ~20% | Locked away, NEVER touched until the very last step — used only to report the final, honest score |

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — why not just two piles (train + test)?</b> If you use the
SAME data to both tune your settings AND report your final score, your score
becomes fake-optimistic — you're grading yourself using the answer key you
already peeked at. Keeping a locked-away test set is what makes our reported
numbers (like "84.9% recall") trustworthy.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "We use a three-way split — fit, validation,
and test — so that no single piece of data is used for both learning AND
grading. This avoids an optimistic, fake result."
</div>

### Scaling the numbers (StandardScaler)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> Our 18 features have very different number ranges. Age
group is a small number like 1–13. BMI can be 12–70. Smoker is just 0 or 1.
"Scaling" means we mathematically stretch or shrink every column so they all
sit on roughly the same scale (centered around 0, with a similar spread).
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE IT:</b> Without scaling, a feature with naturally BIG numbers
(like BMI, up to 70) could accidentally "shout louder" than a feature with
naturally SMALL numbers (like Smoker, only 0 or 1) — not because it's truly
more important, just because its numbers are bigger. Scaling makes it a fair
contest between all 18 features.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> A BMI of 31.5 might get turned into a scaled number
like 0.8. A raw age-group value of 9 might get turned into 0.4. Neither looks
like the original number anymore, but now they're comparable in size.
</div>

We use scikit-learn's `StandardScaler` for this. Important: we `fit` (learn)
the scaling rules ONLY from the training set, then apply those same rules to
the validation and test sets. We never let the test set "peek" and influence
the scaling rules.

---

# PART 4 — Neural Networks From Zero

Before ReLU and Sigmoid make sense, you need the basic building blocks.

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A NEURON:</b> A single tiny calculator. It takes several input
numbers, multiplies each one by its own "importance number" (called a
<b>weight</b>), adds them all up, adds one more adjustment number (called a
<b>bias</b>), and passes the result through an "activation function" (ReLU or
Sigmoid — explained next). That's it. One neuron = one small calculation.
</div>

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A LAYER:</b> A group of neurons that all work at the same time,
side by side, all looking at the same inputs. Our network has 3 layers after
the input: a layer of 96 neurons, then a layer of 48 neurons, then a final
layer of 2 neurons (one output neuron per disease).
</div>

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A WEIGHT:</b> A number that says "how much attention should I pay
to this particular input." Big weight = pay a lot of attention. Weight near
zero = mostly ignore this input. <b>Training</b> is the process of finding
the best weights — nothing more mysterious than that.
</div>

**Our full architecture, in one line:**

```
18 numbers in  →  96 neurons  →  48 neurons  →  2 numbers out
   (features)     (ReLU)         (ReLU)         (Sigmoid, one per disease)
```

That's **6,674 total weights and biases** that get adjusted during training.

---

# PART 5 — Activation Functions: ReLU and Sigmoid

This is one of the most commonly asked "explain this" questions. Learn it well.

## ReLU (Rectified Linear Unit)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> A very simple rule applied after every neuron's
calculation in the HIDDEN layers (the 96-neuron and 48-neuron layers). The
rule is: <b>"If the number is negative, turn it into 0. If it's zero or
positive, leave it exactly as it is."</b> Written as math: ReLU(x) = max(0, x).
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> A neuron calculates -5 → ReLU turns it into 0 (this
neuron stays "off," it doesn't fire). Another neuron calculates +5 → ReLU
keeps it as 5 (this neuron "fires" with strength 5).
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE IT:</b> Two reasons.<br><br>
<b>1. It lets the network learn CURVES, not just straight lines.</b> Real
health risk doesn't rise in a perfectly straight line — a small rise in blood
pressure might barely matter, but a big rise matters a LOT more than double.
Without ReLU (or something like it), stacking layers on top of each other
would mathematically collapse into being just one big straight-line
calculation, no matter how many layers you added — completely pointless.
ReLU adds a "bend," which is what lets multiple layers actually learn more
complex patterns than a single layer could.<br><br>
<b>2. It's very fast and trains well.</b> It's just one comparison (is this
number below zero or not?) — much cheaper to compute than older activation
functions. It also avoids a classic old problem called the "vanishing
gradient," where signals get weaker and weaker as they pass through many
layers, making the network very slow or unable to learn. ReLU mostly avoids
this problem.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "ReLU turns any negative number into zero and
keeps positive numbers unchanged. We use it in both hidden layers because it
lets the network learn non-linear (curved) relationships between lifestyle
factors, and it's fast and stable to train."
</div>

## Sigmoid

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> A rule applied ONLY at the very last (output) layer —
the 2 final neurons. It takes ANY number, no matter how big, negative, or
positive, and squashes it into a value strictly between 0 and 1. Formula:
sigmoid(x) = 1 / (1 + e^-x). You do not need to memorize the formula — just
understand what it DOES.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> If the raw number coming into the output neuron is
2.5, sigmoid turns it into about 0.92 (meaning 92% predicted risk). If the
raw number is -3, sigmoid turns it into about 0.05 (5% predicted risk). No
matter how extreme the input number is, the output always stays between 0
and 1.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE IT:</b> We want our final answer to be a PROBABILITY — like
"44.5% risk of diabetes." A probability, by definition, must be between 0%
and 100%. Sigmoid guarantees this no matter what. We have TWO separate
sigmoid outputs (one for diabetes, one for kidney disease), each independent
of the other — so the app can say "high diabetes risk AND high kidney risk"
at the same time, or any other combination. This is different from
situations where you must pick exactly ONE category out of many (that uses a
different function called Softmax, which we do NOT use here, since our two
diseases are not mutually exclusive).
</div>

### ReLU vs Sigmoid — the difference in one table

| | ReLU | Sigmoid |
|---|---|---|
| Where used | Hidden layers (96, 48 neurons) | Output layer only (2 neurons) |
| What it does | Kills negative numbers to 0, keeps positive as-is | Squashes ANY number into 0–1 |
| Purpose | Helps the network learn complex patterns | Turns the final number into a valid probability |
| Output range | 0 to infinity | 0 to 1 (exclusive) |

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "ReLU and Sigmoid are both called 'activation
functions' — they both take a number and transform it — but they serve
different jobs. ReLU lives inside the network to help it think in
non-straight-line patterns. Sigmoid lives only at the very end, to convert
the network's raw output into a clean 0–100% probability."
</div>

---

# PART 6 — How Training Actually Works

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS "TRAINING":</b> Training means slowly adjusting all 6,674
weights and biases so the network's guesses get closer and closer to the
real answers, over many repeated rounds.
</div>

Here is the loop, step by step, in plain words:

1. **Forward pass:** Feed one batch of people's data (we use batches of 512
   people at a time, not all 253,155 at once — faster and more stable) through
   the network: input → 96 neurons (ReLU) → 48 neurons (ReLU) → 2 outputs
   (Sigmoid). Get a guess for each person.
2. **Measure the mistake (loss):** Compare the guess to the REAL answer
   (did this person actually have diabetes, yes or no?). Calculate a number
   that represents "how wrong was I" — called the **loss**. A perfect guess
   gives a low loss; a wildly wrong guess gives a high loss.
3. **Backpropagation:** A mathematical technique (built into scikit-learn, we
   don't write this ourselves) that figures out exactly which weights
   contributed most to the mistake, and in which direction to nudge each one
   to make the mistake smaller next time.
4. **Gradient descent (the adjustment step):** Nudge every weight a tiny bit
   in the direction that reduces the loss. We use a specific, well-known
   version of this called **Adam**, which is smart about how big each nudge
   should be.
5. **Repeat.** Do steps 1–4 again and again, batch after batch, for up to 120
   full passes through the training data (called **epochs**).

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — "overfitting":</b> If you train for TOO LONG, the network
can start memorizing the exact training people, quirks and all, instead of
learning general patterns. This is called <b>overfitting</b> — like a student
who memorizes the exact exam questions from last year instead of
understanding the subject, and then fails when the questions change slightly.
An overfit model looks amazing on training data and terrible on brand new
people.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 HOW WE PREVENT OVERFITTING — Early Stopping:</b> While training, we keep
a small slice of data aside and watch how the model performs on it after
EVERY few rounds. If it stops improving for 8 rounds in a row, we STOP
training immediately, even if we haven't reached 120 epochs. This locks in
the weights from before the model started memorizing instead of learning.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "Training repeatedly shows the model batches of
people, measures how wrong its guess was using a loss function, and nudges
every weight slightly to reduce that error — this is backpropagation plus
gradient descent, using the Adam optimiser. We use early stopping, halting
training once improvement stalls for 8 rounds, to prevent the model from
memorizing the training data instead of learning general patterns."
</div>

---

# PART 7 — Multi-Task Learning (Why ONE Model for TWO Diseases)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> Instead of training two completely separate models (one
just for diabetes, one just for kidney disease), we train ONE model that
SHARES its two hidden layers (96 and 48 neurons) between both diseases, and
only splits into two separate paths at the very last output layer.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE IT:</b> Diabetes is a well-known medical cause of kidney
disease — they share many of the same underlying risk factors (high blood
pressure, high BMI, older age). By sharing the hidden layers, the network is
forced to learn a general "health risk representation" that's useful for
BOTH diseases at once, instead of learning everything twice from scratch,
separately, and missing the connection between them.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> Imagine two students studying for two different
exams that actually share half their syllabus. If they study the shared
material TOGETHER, they save time and understand the connection between the
two subjects better than if they studied each exam in complete isolation.
</div>

How it's actually done in code: instead of giving the model ONE column of
correct answers (`Diabetes_binary`), we give it a table with **two columns**
(`Diabetes_binary` AND `Kidney_binary`) at once. Scikit-learn's `MLPClassifier`
automatically treats this as training one shared network with two output
heads.

---

# PART 8 — scikit-learn (The Toolbox We Used)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> scikit-learn (often written "sklearn") is a free,
extremely popular Python library — a big box of ready-made, already-tested
machine learning tools. You don't have to write the maths of a neural network
from scratch; smart people already wrote it, tested it for years, and gave it
away for free.
</div>

**What we specifically used from it:**

| Tool from scikit-learn | What we used it for |
|---|---|
| `MLPClassifier` | The actual neural network itself |
| `StandardScaler` | Scaling all 18 features to a fair, similar range |
| `train_test_split` | Splitting data into fit / validation / test piles |
| `StratifiedKFold` | Cross-validation that keeps the disease ratio fair in every split |
| `IsotonicRegression` | Calibrating raw scores into honest probabilities |
| `roc_auc_score`, `recall_score`, `precision_score`, `confusion_matrix`, `balanced_accuracy_score` | Measuring how good the model is, in different ways |

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY scikit-learn AND NOT TensorFlow / PyTorch / Keras:</b> Those bigger
frameworks are built for HUGE deep learning models — things with millions or
billions of parameters, like models that understand images or generate
paragraphs of text, and usually need a graphics card (GPU) to train in
reasonable time. Our entire model is tiny — only 6,674 parameters, and its
saved file is only 170 KB. scikit-learn trains something this size in minutes
on an ordinary laptop CPU, and it comes bundled with all the extra tools
(scaling, splitting, calibration, metrics) we needed anyway, all speaking the
same simple style of code.
</div>

### Permutation Importance (mentioned earlier — here's how it actually works)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> A way to measure how much the model actually RELIES on
one particular feature. Take one feature column (say, `MentHlth`) and
randomly shuffle/scramble its values among all the people — breaking any real
connection it had to the answer, on purpose. Then run the model again and see
how much WORSE its score gets.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> If shuffling `GenHlth` (general health rating)
badly hurts the model's score, it means the model was leaning on that feature
a lot — it's important. If shuffling `MentHlth` barely changes the score at
all (which is exactly what we found — only 0.001 drop), it means the model
almost wasn't using it — safe to remove.
</div>

---

# PART 9 — Testing and Metrics (How We Know the Model Is Good)

## The Accuracy Trap — the #1 thing to understand

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT:</b> "Accuracy" simply means "what percentage of guesses were
correct." Sounds like the obvious best measurement — but it is DANGEROUSLY
misleading when the disease is rare. Remember: only 3.7% of people in our
data actually have kidney disease. A lazy model that ALWAYS guesses "No
kidney disease," no matter what, would be correct 96.3% of the time — sounds
amazing, but it catches <b>ZERO</b> real cases. That's why we do NOT report
accuracy as our main measurement.
</div>

## The metrics we actually use, explained simply

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 CONFUSION MATRIX — the base of everything else:</b> A simple 2x2 table
that counts 4 things: people the model correctly flagged as sick (True
Positive), people it correctly flagged as healthy (True Negative), healthy
people it wrongly flagged as sick (False Positive), and sick people it
wrongly missed (False Negative). Every other metric below is just a different
way of combining these 4 numbers.
</div>

| Metric | Plain English meaning | Our score (diabetes / kidney) |
|---|---|---|
| **Recall** (a.k.a. Sensitivity) | Out of everyone who ACTUALLY has the disease, what % did we catch? | 84.9% / 87.5% |
| **Precision** | Out of everyone we FLAGGED as high risk, what % really have it? | Lower on purpose — see below |
| **ROC-AUC** | How good the model is at RANKING a sick person above a healthy one, across every possible cutoff point, from 0 (terrible) to 1 (perfect), with 0.5 being a random coin flip | 0.823 / 0.793 |
| **Balanced Accuracy** | Like normal accuracy, but corrected so it can't be gamed by a rare disease | Reported instead of plain accuracy |

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE ACCEPT LOWER PRECISION:</b> This is a SCREENING tool, not a final
diagnosis. We deliberately chose a cutoff point that favors catching almost
every real case (high Recall), even if that means some healthy people get
flagged too (lower Precision) and are told "maybe get checked." Missing a
real case is far more costly than one unnecessary follow-up appointment.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "We do not report accuracy as our headline
number, because with a rare disease it can look artificially high while
catching zero real cases. We instead report Recall and ROC-AUC, and we
deliberately tuned our decision threshold to prioritise catching real cases
over avoiding false alarms — the correct trade-off for a screening tool."
</div>

## Cross-Validation (double-checking our result wasn't just luck)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT (5-fold stratified cross-validation):</b> Instead of trusting
just ONE lucky (or unlucky) train/test split, we split all the data into 5
roughly equal chunks. We train on 4 chunks and test on the 5th, then repeat
this 5 times so that every chunk gets a turn being the "test" chunk. Finally
we average the 5 scores together, and also report how much they varied
(called the standard deviation).
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY:</b> If all 5 scores come out similar, we can trust the model's
performance is stable and real, not a fluke of one particular lucky split.
"Stratified" means each of the 5 chunks keeps the same disease ratio (13.9%
diabetes, 3.7% kidney) as the full dataset — so no chunk accidentally ends up
with almost no sick people in it.
</div>

## Calibration — making "30% risk" actually mean 30%

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> A neural network's raw output number, after sigmoid,
LOOKS like a probability (it's between 0 and 1), but it isn't automatically a
TRUSTWORTHY one. Calibration is an extra fixing step that adjusts these raw
numbers so that, in reality, among all the people the model said had "around
30% risk," roughly 30 out of 100 of them actually do have the disease.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE USE ISOTONIC REGRESSION SPECIFICALLY:</b> Isotonic regression is
a calibration method that doesn't assume any particular shape (like a
straight line) — it can bend and flex to fix ANY kind of miscalibration,
which makes it more flexible and accurate than simpler methods. We fit it
using ONLY the validation set (never the test set), so it doesn't cheat.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> Before calibration, the model might say "80% risk"
for a group of people where actually only 55% of them get sick — the raw
number was too extreme/overconfident. After calibration, that same group
would correctly show closer to "55% risk."
</div>

## Choosing the decision threshold (cutoff point)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> The model outputs a percentage (like 23%). Somewhere, we
need to decide: "above what percentage do we call this person HIGH RISK?"
That cutoff number is called the threshold. We did NOT just use the obvious
50% — we specifically searched for the highest threshold that still catches
at least 85% of real cases (our recall target), using the validation set.
</div>

**Our actual thresholds:** Diabetes ≈ 11.9%, Kidney ≈ 2.1%. Notice the kidney
threshold is much lower — because kidney disease is rarer, the model
naturally outputs lower percentages for it overall, so the cutoff has to be
lower too to still catch 85% of real cases.

---

# PART 10 — Explaining Predictions (Occlusion) and What-If Simulator

## Occlusion — "why did YOU get this score?"

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> For one specific person, we go through each of their 18
answers ONE AT A TIME. For each one, we temporarily replace just that single
answer with the "average" value across everyone, re-run the model, and see
how much the predicted risk DROPS. That drop tells us how much that one
answer was pushing this person's risk UP.
</div>

<div style="background:#FFF3E0; border-left:5px solid #EF6C00; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟠 SIMPLE EXAMPLE:</b> Say a person's real diabetes risk is 44.5%. We
temporarily pretend their BMI was just an average BMI instead of their real
(higher) one, and re-run the model — the risk drops to 40.7%. That 3.8%
difference is BMI's personal contribution to THIS person's score. We do this
for all 18 features and show the top few biggest contributors to the user.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY THIS METHOD (occlusion) AND NOT REAL SHAP:</b> SHAP (a more famous,
mathematically fancier explanation method based on game theory) would need to
test many different COMBINATIONS of features together, which becomes very
expensive to calculate. Occlusion just tests one feature at a time — 18
quick extra calculations, about 1 millisecond each — a fast, honest,
"good-enough" approximation, not a fake shortcut.
</div>

## What-If Simulator — "what should I actually change?"

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS IT:</b> We take the 6 habits a person can realistically change
(BMI, physical activity, smoking, eating fruit, eating vegetables, heavy
alcohol use). For each one, we swap the person's CURRENT answer for the
"healthy" target answer (e.g., Smoker: Yes → No), re-run the model, and
report how much their risk would go DOWN if they made exactly that one
change.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY IT MATTERS:</b> A risk percentage alone can just cause anxiety. This
turns the number into ACTION — "if you quit smoking, your diabetes risk would
drop by roughly 4%." It only ever shows genuine IMPROVEMENTS (never suggests
making a habit worse), and skips habits the person has already adopted.
</div>

---

# PART 11 — The Backend (Django) — Full API List

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A BACKEND:</b> The backend is a program that runs on a server
(a computer somewhere on the internet, not on your phone) and waits for
requests from the app. When your phone sends a request, the backend decides
what to do — maybe check your password, maybe run the AI model, maybe save
something to the database — and sends a reply back.
</div>

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS AN API:</b> "API" stands for Application Programming Interface.
Think of it as a menu at a restaurant: it lists the exact things you're
ALLOWED to ask the backend to do, what information you must provide (like
ordering "burger, no onions"), and what you'll get back. Each single item on
that menu is called an "endpoint."
</div>

**We built 13 endpoints (menu items) in total.** Here is every single one:

| # | Method | Endpoint (URL path) | Needs login? | What you send it | What it does | Talks to DB? |
|---|---|---|---|---|---|---|
| 1 | GET | `/api/health/` | No | nothing | Just checks the server is alive | No |
| 2 | POST | `/api/auth/register/` | No | username, email (optional), password | Creates a new account | **Writes** a new user row |
| 3 | POST | `/api/auth/login/` | No | username, password | Checks password, hands back login tokens | **Reads** to check password |
| 4 | POST | `/api/auth/refresh/` | No (needs refresh token) | refresh token | Gives you a brand-new access token, no need to log in again | No |
| 5 | GET | `/api/auth/me/` | Yes | nothing | Returns your own basic account info | **Reads** |
| 6 | POST | `/api/auth/password/` | Yes | current password, new password | Changes your password | **Writes** the updated password |
| 7 | GET | `/api/schema/` | No | nothing | Returns the list of all 18 questions and their rules | No (this list is fixed in code) |
| 8 | GET | `/api/model/card/` | No | nothing | Returns the REAL, live model's architecture and accuracy numbers | No (reads the model file, not the DB) |
| 9 | POST | `/api/predict/` | Yes | your 18 lifestyle answers | Runs the model, explains it, gives advice, saves the result | **Writes** a new assessment row |
| 10 | GET | `/api/history/` | Yes | nothing | Returns your past assessments, newest first | **Reads** your assessment rows |
| 11 | GET | `/api/profile/` | Yes | nothing | Returns your name, photo, sex, age, height, weight | **Reads** your profile row |
| 12 | PATCH | `/api/profile/` | Yes | any profile fields you want to change | Updates your profile | **Writes** the updated profile row |
| 13 | POST | `/api/chat/` | Yes | your message text | Sends your message to the AI and saves the reply | **Reads** your latest result, **writes** both chat messages |
| 14 | GET | `/api/chat/history/` | Yes | nothing | Returns your past chat messages | **Reads** your chat messages |

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — "GET" vs "POST" vs "PATCH":</b> These are called HTTP
methods — they describe the INTENTION of a request. <b>GET</b> means "just
give me information, don't change anything." <b>POST</b> means "here is new
information, please create/do something with it." <b>PATCH</b> means "update
just part of something that already exists." Notice `/api/profile/` appears
TWICE in the table — same address, but GET reads it while PATCH updates it.
The method is what tells the backend which one you mean.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "We built 13 REST API endpoints using Django
REST Framework. Most require a login token; a few — like the health check and
the questionnaire schema — are intentionally public so the app can work
before a user signs in."
</div>

### Following ONE request all the way through (memorize this flow)

> A user finishes the questionnaire and taps "See Results." Here's what
> actually happens, step by step:
>
> 1. The **app** (Flutter) collects all 19 answers and computes BMI itself
>    from height and weight (so the model gets 18 clean numeric features).
> 2. The app sends `POST /api/predict/` with those 18 numbers as JSON, plus
>    your login token attached in the request header.
> 3. The **backend** (Django) checks your login token is valid, then checks
>    every single field against the rules in `schema.py` (Is BMI between 12
>    and 70? Is Smoker exactly 0 or 1?). If anything is wrong, it replies
>    immediately with an error — it never even touches the model with bad
>    data.
> 4. The backend hands the clean data to `PredictionService` — a single
>    copy of the trained model that was loaded into memory ONE TIME when the
>    server started (so it doesn't have to reload the model file from disk on
>    every single request — that would be very slow).
> 5. The model scales the input, runs it through the network, applies
>    calibration, compares to the two thresholds → gets the risk %.
> 6. The backend ALSO runs the occlusion explainer (18 extra quick
>    calculations) and the what-if simulator (6 more) — all using the very
>    same trained model, just re-run with small tweaks.
> 7. The backend **saves** one new row into the `Assessment` database
>    table: your answers, the full result, and the two risk numbers.
> 8. The backend replies to the app with the prediction, the factors, and
>    the recommendations, all as JSON.
> 9. The **app** draws the risk gauges, the factor bars, and the
>    recommendation cards from that JSON.

---

# PART 12 — Authentication (JWT) — How the App Knows Who You Are

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS JWT:</b> JWT stands for JSON Web Token. It's a specially signed
piece of text the server hands you right after you log in successfully. It
proves "yes, this person really did log in as [username]" without the server
needing to remember you separately in its own memory (this is called being
"stateless").
</div>

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 ACCESS TOKEN vs REFRESH TOKEN:</b> We actually get TWO tokens at login.
The <b>access token</b> is what you attach to every regular request (like a
day-pass) — it expires after 7 days. The <b>refresh token</b> lasts much
longer (30 days) and has exactly ONE job: trade it in at `/api/auth/refresh/`
for a brand-new access token, without having to type your password again.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY TWO TOKENS INSTEAD OF ONE:</b> If we only had one long-lasting
token and it ever leaked (got stolen), it would be dangerous for a long time.
By keeping the access token short-lived, a stolen one becomes useless
quickly. The refresh token lets you stay logged in comfortably in the
background without constantly re-typing your password.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "We use JWT — JSON Web Tokens — for stateless
authentication. Each login gives an access token for daily use and a
longer-lived refresh token, so a user's session can silently renew itself
without the server storing session data or the user having to log in again
every week."
</div>

We also protect against password-guessing attacks using **rate limiting** —
the login endpoint only allows 8 attempts per minute per person, and
registration only 5 per minute — so a computer trying thousands of password
guesses per second gets blocked almost immediately.

---

# PART 13 — The Database (Where Information Is Permanently Stored)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS A DATABASE:</b> A very organized, permanent storage system —
like a set of linked spreadsheets — that keeps information safe even after
the app is closed or the server restarts. We use <b>PostgreSQL</b> (a very
popular, free, powerful type of database), hosted for us by a service called
<b>Supabase</b> (so we don't have to manage our own physical server for it).
</div>

**Our 4 tables:**

| Table name | What it stores | Connected to |
|---|---|---|
| `auth_user` | Username, email, (safely scrambled) password | The base for everything else |
| `profiles_userprofile` | Name, avatar photo, sex, age, height, weight | ONE row per user |
| `predictions_assessment` | Every health check ever run: the 18 answers, the full result, both risk numbers, the date | MANY rows per user |
| `chat_chatmessage` | Every message sent to/from the AI assistant | MANY rows per user |

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE STORE THE ANSWERS AND RESULT AS "JSONB" INSTEAD OF SEPARATE
COLUMNS:</b> A JSONB column can hold a whole flexible mini-document inside
ONE database cell, instead of needing one rigid column per question. This
meant that when we later removed the `MentHlth` question (going from 19 to
18 features), we did NOT need to redesign the database at all — old
assessment rows just keep their old 19 answers exactly as they were recorded,
and new rows simply have 18. Flexible, with zero extra work.
</div>

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — passwords are never stored as plain readable text.</b> They
go through a one-way scrambling process called <b>hashing</b> before being
saved. Even we, looking directly at the database, cannot see anyone's actual
password — only its scrambled version. When you log in, the backend
scrambles what you TYPED the same way and checks if the two scrambled
versions match.
</div>

---

# PART 14 — The AI Assistant (Which LLM, and How It "Knows" Your Info)

## What is an LLM?

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS AN LLM:</b> LLM stands for Large Language Model. It's a huge AI
program trained on enormous amounts of text from books and the internet, so
it learned the patterns of human language extremely well. In simple terms, it
works by repeatedly predicting "what is the most likely next word," extremely
fast, which lets it write full, coherent, helpful sentences and answers.
</div>

## Which model we use

We use **Claude** (made by Anthropic) — specifically a fast, low-cost version
called `claude-haiku-4-5`. But here's the important design detail:

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY WE MADE IT SWAPPABLE (the "Strategy" design pattern):</b> Our chat
code doesn't hard-wire itself to Claude specifically. We wrote one shared
"shape" (called an interface) that any AI provider can plug into, then wrote
three separate small plug-ins: one for Claude, one for Google's Gemini, and
one for a local model called Ollama. Switching which AI powers the assistant
is a single line of settings — no code changes needed. This is good software
engineering practice, not just a technical detail — it means we're not
permanently locked into one company's AI.
</div>

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — we do NOT use LangChain</b> (a very popular AI framework many
student projects use). Our entire AI-calling code is about 155 lines of
plain Python, making a direct internet request to Claude's API. We chose this
because our needs are simple (send a message, get a reply) — a big framework
would just add extra complexity for no real benefit at our scale.
</div>

## How does the AI "know" your risk results? (the most important AI question)

<div style="background:#FFEBEE; border-left:5px solid #C62828; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔴 WATCH OUT — the AI does NOT have its own permanent memory of you.</b>
Claude itself never "logs in" to our database and never remembers anything
between separate conversations by itself. If we did nothing special, it would
know absolutely nothing about your specific risk numbers.
</div>

Here's exactly what actually happens, step by step, EVERY single time you
send a chat message:

1. Our backend looks up YOUR most recent assessment from the database
   (the one saved by `/api/predict/`).
2. It builds a hidden instruction (called a **system prompt**) that says
   something like: *"You are Aegis, a warm health assistant... this user's
   most recent screening showed diabetes risk 44.5% (High) and kidney risk
   11.9% (High). Refer to this when relevant."*
3. It sends THREE things to Claude, all together, in one single request:
   the hidden system prompt (with your real numbers baked in), your last
   several chat messages (for conversation memory), and your brand new
   message.
4. Claude reads all of this **fresh, for this one request only**, and
   writes a reply using those real facts.
5. The reply gets saved to the database and sent back to your phone.

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT THIS TECHNIQUE IS CALLED:</b> This is called <b>grounding</b> (or
"in-context grounding," or sometimes "prompt injection of context" —
not to be confused with the *security* meaning of "prompt injection"). We are
literally handing the AI the facts it needs, freshly, inside every single
message, rather than expecting it to somehow already know them.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY NOT USE A FANCIER TECHNIQUE (like RAG / a vector database):</b> RAG
(Retrieval-Augmented Generation) is designed for searching through THOUSANDS
of documents to find relevant snippets. We only ever need to hand over ONE
simple fact per user (their latest risk numbers) — directly inserting it into
the prompt is far simpler, cheaper, and just as effective at this small
scale. Using RAG here would be over-engineering.
</div>

<div style="background:#F3E5F5; border-left:5px solid #7B1FA2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟣 SAY THIS IN THE VIVA:</b> "The AI itself has no memory of the user. Our
backend fetches the user's latest risk assessment from our own database and
inserts it into a hidden system prompt on every request, alongside the recent
chat history. This is called grounding — we hand the model the facts it
needs fresh each time, rather than relying on it to somehow already know
them."
</div>

---

# PART 15 — The Mobile App (Flutter)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS FLUTTER:</b> A toolkit made by Google for building mobile apps.
You write your code once in a language called <b>Dart</b>, and Flutter
compiles it into a real, fast, native app for both Android and iPhone —
without needing to write two separate apps in two separate languages.
</div>

<div style="background:#E8F5E9; border-left:5px solid #2E7D32; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🟢 WHY FLUTTER OVER OTHER OPTIONS:</b> Compared to React Native (another
popular cross-platform tool), Flutter compiles directly to native machine
code instead of running through a JavaScript "bridge" at all times — so it
tends to run smoother. Compared to writing separate native Android
(Kotlin/Java) and iOS (Swift) apps, one Flutter codebase means one team,
one language, half the work.
</div>

**A few important technical pieces inside the app:**

- **Provider** — a simple way of sharing information (like "is the user
  logged in?") across many different screens without messy manual wiring.
- **flutter_secure_storage** — stores your JWT tokens inside the phone's
  Android Keystore, a hardware-backed encrypted vault, instead of plain
  unprotected storage.
- **flutter_local_notifications** — schedules real Android alarms for
  reminders (drink water, take medicine) that work completely offline and
  survive the phone restarting.
- **permission_handler** — proactively asks the phone for notification
  access and an exemption from aggressive battery-saving settings, the two
  things Android needs a real human tap for on every brand of phone,
  Samsung included.

---

# PART 16 — Deployment (Putting It Live on the Internet)

<div style="background:#E3F2FD; border-left:5px solid #1976D2; padding:10px 15px; margin:8px 0; border-radius:6px;">
<b>🔵 WHAT IS "DEPLOYMENT":</b> Taking code that only ran on your own laptop
and putting it on a real server somewhere on the internet, so anyone with the
app, anywhere, can reach it — 24 hours a day, without your laptop needing to
be turned on.
</div>

| Piece | Service used | Plain-English role |
|---|---|---|
| Backend server | **Render** (free tier) | Runs our Django code permanently, 24/7 |
| Database | **Supabase** | Hosts our PostgreSQL database, managed for us |
| Web server software | **gunicorn** | The actual program on Render that receives web requests and hands them to Django |
| Static files | **WhiteNoise** | Serves small extra files (like the admin panel's styling) without needing a separate service |
| Auto-deploy | **GitHub → Render** | Every time we push new code to GitHub, Render automatically rebuilds and updates the live server |
| Keep-alive | **GitHub Actions** | A small robot that pings our server every few minutes so the free tier doesn't fall asleep during a demo |

---

# PART 17 — Glossary (Quick Lookup — Every Hard Word, A-Z)

| Word | Simple meaning |
|---|---|
| **API** | A defined menu of requests a program allows other programs to make to it |
| **Backend** | The server-side program that handles requests, logic, and the database |
| **Balanced Accuracy** | Accuracy that's fairly adjusted so a rare disease can't fake a high score |
| **Batch** | A small group of examples processed together during one training step |
| **Bias (in a neuron)** | An extra adjustment number added after multiplying inputs by weights |
| **Calibration** | Fixing a model's probabilities so they match real-world frequency |
| **Confusion Matrix** | A 2×2 table counting correct/incorrect predictions by type |
| **Cross-Validation** | Testing a model on several different data splits and averaging the results |
| **Dataset** | A structured collection of data, like a big table |
| **Early Stopping** | Halting training once the model stops improving, to avoid overfitting |
| **Endpoint** | One single specific address/action an API offers |
| **Epoch** | One full pass through all the training data |
| **Feature** | One column of input information used to make a prediction |
| **Grounding (AI)** | Giving an AI model real facts inside its prompt so its answer is accurate |
| **Hidden Layer** | A layer of neurons between the input and the final output |
| **JSON** | A simple, universal text format for representing data |
| **JWT** | JSON Web Token — a signed proof of identity used for logins |
| **Label** | The correct answer a model is trying to learn to predict |
| **Label Leakage** | When the answer is accidentally computable from the input, making the model meaningless |
| **Layer** | A group of neurons operating side by side |
| **LLM** | Large Language Model — a big AI trained to understand/generate text |
| **Loss** | A number representing how wrong a model's prediction was |
| **Multi-Task Learning** | One model sharing layers to learn several related tasks at once |
| **Neuron** | The smallest calculating unit inside a neural network |
| **Occlusion** | An explanation method: hide one feature, measure how much the prediction changes |
| **Overfitting** | A model memorizing training data instead of learning general patterns |
| **Permutation Importance** | Shuffling a feature's values to measure how much the model relies on it |
| **Precision** | Out of everyone flagged positive, what share truly are positive |
| **Rate Limiting** | Restricting how many requests someone can make per minute, to block abuse |
| **Recall** | Out of everyone truly positive, what share did the model catch |
| **ReLU** | An activation function: negative numbers become 0, positive stay the same |
| **REST API** | A common style of building web APIs using standard HTTP methods |
| **ROC-AUC** | A 0–1 score measuring how well a model ranks positive cases above negative ones |
| **Scaling** | Adjusting all features to a similar numeric range before training |
| **scikit-learn** | A free Python library of ready-made machine learning tools |
| **Sigmoid** | An activation function that squashes any number into a range between 0 and 1 |
| **Singleton** | A design pattern ensuring only one shared copy of something (like the loaded model) exists |
| **Strategy Pattern** | A design pattern letting you swap one interchangeable component for another (e.g., Claude ↔ Gemini) |
| **Threshold** | The cutoff percentage above which a prediction is called "high risk" |
| **Training** | The process of adjusting a model's weights to reduce its mistakes |
| **Weight** | A number representing how much importance a neuron gives to one input |

---

# Final Reminder

Reading this once is step one. Saying the answers **out loud, in your own
words**, is what actually makes them stick under pressure tomorrow morning.
Go back to `VIVA_CHEATSHEET.md` for the fast recap, and tell me **"start"**
whenever you want me to fire real viva-style questions at you.
