# -*- coding: utf-8 -*-
"""Chapter bodies for the Aegis Health report. Imported by build_report.py."""
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Cm, Pt

J = WD_ALIGN_PARAGRAPH.JUSTIFY
C = WD_ALIGN_PARAGRAPH.CENTER


def build(doc, H, P, B, T, F, CH, RULE, D):
    """H=heading P=para B=bullets T=table F=figure CH=chapter RULE=rule D=data."""
    DIA, KID, CV, PREV, N_RECORDS, N_FEATS, REP = (
        D["DIA"], D["KID"], D["CV"], D["PREV"], D["N_RECORDS"], D["N_FEATS"], D["REP"])

    # ===================================================== CHAPTER 1
    CH(doc, 1, "Introduction")

    H(doc, "1.1  Background", 2)
    P(doc, "Pakistan has one of the highest rates of diabetes in the world. The "
      "International Diabetes Federation places the country among the leading "
      "nations by number of adults living with the condition, and a substantial "
      "share of those people do not know they have it. Chronic kidney disease "
      "follows closely behind, and the two are linked: sustained high blood "
      "glucose damages the small vessels of the kidney, which is why diabetic "
      "nephropathy is the largest single cause of kidney failure worldwide.", align=J)
    P(doc, "What makes both conditions tractable for software is that neither "
      "appears suddenly. Each develops over years, driven mainly by factors a "
      "person can influence: body mass, physical activity, diet, blood pressure, "
      "smoking and alcohol. Someone who learns at thirty-five that their risk is "
      "elevated has a decade in which to act. The same person learning at "
      "fifty-five, after symptoms appear, has far fewer options and a permanent "
      "loss of kidney function.", align=J)
    P(doc, "Screening already exists in clinical practice, but it depends on blood "
      "work: fasting glucose, HbA1c, serum creatinine. Each requires money, travel "
      "and time away from work. The practical consequence is that the people most "
      "likely to be tested are those who already suspect something is wrong, which "
      "is precisely the population for whom prevention has come too late.", align=J)

    H(doc, "1.2  Problem Statement", 2)
    P(doc, "There is no accessible way for an ordinary person in Pakistan to find "
      "out whether they are on a path toward diabetes or kidney disease before "
      "symptoms begin. Existing risk calculators either require laboratory values "
      "the user does not have, or reduce the question to a handful of generic "
      "questions with no stated accuracy, no explanation of the reasoning, and no "
      "indication of what the person should do next.", align=J)
    P(doc, "The problem this project addresses is therefore narrow and concrete: "
      "estimate the future risk of two specific chronic conditions using only "
      "information a person already knows about themselves; report that estimate "
      "honestly, including its limitations; explain which of their answers drove "
      "it; and quantify how much specific, realistic changes would reduce it.", align=J)

    H(doc, "1.3  Objectives", 2)
    B(doc, [
        "Build a dataset of behavioural risk factors and disease outcomes from a "
        "large, credible, publicly available population survey.",
        "Train a single multi-task neural network that predicts the risk of type 2 "
        "diabetes and chronic kidney disease from the same input vector, "
        "exploiting the clinical relationship between them.",
        "Evaluate the model with metrics appropriate to rare conditions, namely "
        "recall and ROC-AUC, and validate by stratified cross-validation rather "
        "than a single split.",
        "Calibrate the output probabilities so that a stated risk percentage "
        "carries its ordinary meaning.",
        "Explain every individual prediction by attributing it to the specific "
        "answers that produced it.",
        "Simulate realistic habit changes and report the projected reduction for "
        "each, so the output is actionable rather than merely informative.",
        "Deliver the system as a deployed mobile application with secure "
        "authentication, persistent history and offline reminders.",
    ])

    H(doc, "1.4  Scope and Delimitations", 2)
    P(doc, "Within scope:", bold=True, space_after=4)
    B(doc, [
        "Two conditions only: type 2 diabetes and chronic kidney disease.",
        f"{N_FEATS} behavioural and demographic features, all self-reported.",
        "Android as the target mobile platform.",
        "A hosted REST backend with a managed PostgreSQL database.",
        "Risk estimation, factor attribution, what-if simulation, history, "
        "reminders, and a conversational assistant grounded in the user's result.",
    ])
    P(doc, "Explicitly out of scope:", bold=True, space_after=4)
    B(doc, [
        "Diagnosis. The system estimates risk and states plainly that it does not "
        "diagnose disease.",
        "Laboratory values. No glucose, HbA1c or creatinine input is accepted, "
        "because requiring them would defeat the purpose of the project.",
        "Prescription, dosage or treatment advice of any kind.",
        "Clinical trial validation. The model is validated statistically against "
        "survey data, not prospectively against patients.",
        "iOS. The architecture supports it, but no iOS build was produced.",
    ])

    H(doc, "1.5  Significance", 2)
    P(doc, "The contribution of this project is not that it applies machine "
      "learning to health data, which is common. It is the combination of four "
      "decisions that are individually unremarkable and collectively uncommon in "
      "student work: predicting the future rather than detecting the present; "
      "sharing one network between two clinically related tasks; reporting "
      "rare-disease metrics honestly instead of hiding behind accuracy; and making "
      "every prediction explain itself and propose a remedy.", align=J)

    # ===================================================== CHAPTER 2
    CH(doc, 2, "Literature Review")

    H(doc, "2.1  Existing Systems", 2)
    P(doc, "Risk estimation for diabetes has a long clinical history. The Finnish "
      "Diabetes Risk Score (FINDRISC) is the most widely used questionnaire "
      "instrument: eight questions, a points total, and a risk band. It is well "
      "validated and requires no laboratory work, which makes it the closest "
      "precedent for this project. Its limitations are that the scoring is a fixed "
      "additive table derived from a Finnish cohort, it addresses diabetes alone, "
      "and it offers no personalised explanation.", align=J)
    P(doc, "For kidney disease, the Kidney Failure Risk Equation is the established "
      "tool, but it is built for patients already diagnosed with reduced kidney "
      "function and depends on serum creatinine and urine albumin. It answers a "
      "different question from ours: how quickly an existing condition will "
      "progress, rather than whether a healthy person will develop one.", align=J)
    P(doc, "In the research literature, machine-learning models trained on the same "
      "BRFSS dataset used here are numerous. Most report accuracy figures in the "
      "mid-eighties for diabetes, which sounds strong until one notices that the "
      f"prevalence in the dataset is {PREV['Diabetes_binary']*100:.1f} per cent, "
      "meaning a model that predicts no unconditionally already achieves "
      f"{(1-PREV['Diabetes_binary'])*100:.1f} per cent. Papers that report recall "
      "alongside accuracy are markedly less common.", align=J)

    H(doc, "2.2  Comparative Analysis", 2)
    T(doc, "Comparison of existing approaches with the proposed system",
      ["System", "Inputs required", "Conditions", "Explains", "Actionable"],
      [["FINDRISC questionnaire", "8 questions", "Diabetes only", "No", "Generic"],
       ["Kidney Failure Risk Equation", "Laboratory values", "CKD progression", "No", "No"],
       ["Typical BRFSS ML study", f"{N_FEATS} to 21 features", "One at a time", "Rarely", "No"],
       ["Commercial wellness apps", "Varies, undisclosed", "Varies", "No", "Generic tips"],
       ["Aegis Health (this work)", f"{N_FEATS} questions", "Both, jointly", "Per factor", "Quantified"]],
      widths=[4.6, 3.4, 3.0, 2.2, 2.6])

    H(doc, "2.3  Research Gap", 2)
    P(doc, "Three gaps follow from the comparison. First, no accessible tool "
      "estimates both conditions together, despite their shared causation. Second, "
      "published models on this dataset seldom report the metric that actually "
      "matters for screening, which is the proportion of true cases identified. "
      "Third, almost nothing in this space closes the loop: a user is given a "
      "number and left to interpret it, without being told which of their own "
      "answers produced it or what would change it.", align=J)

    H(doc, "2.4  The Flaw We Corrected", 2)
    P(doc, "This section records a design error made early in the project, because "
      "correcting it produced the work described in the rest of this report.", align=J)
    P(doc, "The original proposal was to predict the stage of chronic kidney disease "
      "from laboratory values. A dataset of measurements would be obtained, the "
      "stage label would be assigned by applying the standard clinical formula for "
      "estimated glomerular filtration rate, and a classifier would then be trained "
      "to predict that label from the same measurements.", align=J)
    P(doc, "The flaw is circularity, a form of label leakage. The label was computed "
      "from the features by a deterministic rule that we supplied ourselves, so any "
      "competent model would simply rediscover our own arithmetic and report "
      "near-perfect accuracy. The result would have been an impressive number with "
      "no predictive value whatsoever, because a calculator already does that job "
      "exactly and for free.", align=J)
    P(doc, "The correction was to change the question. Instead of inferring a "
      "present clinical state from clinical measurements, the system predicts a "
      "future outcome from behaviour, where the label comes from what the survey "
      "respondent actually reported and not from anything we calculated. That "
      "single change is what gives the project its value, and it is the reason "
      "accuracy is treated with suspicion throughout this report.", align=J)

    # ===================================================== CHAPTER 3
    CH(doc, 3, "System Analysis and Design")

    H(doc, "3.1  Requirement Analysis", 2)
    P(doc, "Requirements were gathered from three sources: the clinical literature "
      "on modifiable risk factors, which determined what the model could "
      "legitimately ask about; the structure of the BRFSS questionnaire, which "
      "determined what data existed to learn from; and informal testing with "
      "fellow students, which determined how many questions a person will answer "
      "before abandoning the form. That last constraint proved the binding one: "
      "early drafts asked twenty-one questions including household income and "
      "education, and testers objected to both as intrusive and irrelevant. They "
      "were removed, along with a question asking how many days the respondent had "
      "felt mentally unwell, which measurement later confirmed contributed "
      "approximately 0.001 to ROC-AUC.", align=J)

    H(doc, "3.2  Functional Requirements", 2)
    T(doc, "Functional requirements",
      ["ID", "Requirement", "Description", "Priority"],
      [["FR-1", "Account creation", "Register with a username and password; email optional.", "High"],
       ["FR-2", "Authentication", "Sign in and receive a JSON Web Token.", "High"],
       ["FR-3", "Password change", "Change password after confirming the current one.", "Medium"],
       ["FR-4", "Questionnaire", "Collect 19 answers across five grouped steps.", "High"],
       ["FR-5", "Risk prediction", "Return calibrated risk for both conditions.", "High"],
       ["FR-6", "Factor attribution", "Rank the answers that raised the risk.", "High"],
       ["FR-7", "What-if simulation", "Report projected reduction per habit change.", "High"],
       ["FR-8", "Interactive what-if", "Let the user alter answers and re-run live.", "Medium"],
       ["FR-9", "History", "Persist assessments and display the trend.", "Medium"],
       ["FR-10", "Assistant", "Answer questions grounded in the latest result.", "Medium"],
       ["FR-11", "Reminders", "Schedule repeating on-device notifications.", "Medium"],
       ["FR-12", "Model transparency", "Expose architecture and real metrics in-app.", "Medium"]],
      widths=[1.6, 3.6, 8.0, 2.2])

    H(doc, "3.3  Non-Functional Requirements", 2)
    T(doc, "Non-functional requirements",
      ["Category", "Requirement", "Target", "Achieved"],
      [["Performance", "Inference latency, server-side", "Under 100 ms", "About 1 ms"],
       ["Performance", "End-to-end request, warm server", "Under 3 s", "1.8 to 2.2 s"],
       ["Reliability", "Model must load or fail loudly", "No silent fallback", "Yes, 503 returned"],
       ["Accuracy", "Recall, diabetes", "At least 0.85", f"{DIA['recall']:.3f}"],
       ["Accuracy", "Recall, kidney", "At least 0.85", f"{KID['recall']:.3f}"],
       ["Accuracy", "ROC-AUC, both heads", "Above 0.75", f"{DIA['roc_auc']:.3f} / {KID['roc_auc']:.3f}"],
       ["Security", "Credential storage on device", "Encrypted", "Android Keystore"],
       ["Security", "Brute-force resistance", "Rate limited", "8 attempts per minute"],
       ["Security", "Transport", "Encrypted in transit", "HTTPS and TLS"],
       ["Usability", "Questionnaire completion", "Under 3 minutes", "About 2 minutes"],
       ["Accessibility", "Touch target size", "At least 48 dp", "Met"],
       ["Accessibility", "Reduced motion", "Respected", "Implemented"],
       ["Portability", "Offline reminders", "No network needed", "On-device alarms"]],
      widths=[2.8, 5.4, 3.6, 3.6])

    H(doc, "3.4  Use-Case Model", 2)
    P(doc, "The system has two actors. The registered user performs every "
      "health-related use case. The administrator inspects the deployed model card "
      "to confirm which artifact is live and what its measured performance is.", align=J)
    F(doc, "fig_use_case.png", "Use-case diagram showing both actors and the ten use cases", 13.5)

    H(doc, "3.5  Activity Model", 2)
    P(doc, "The activity diagram traces one complete assessment. Two details are "
      "worth noting. Body mass index is computed on the device from height and "
      "weight, so the user is never asked for a figure they are unlikely to know. "
      "And validation happens server-side against the same schema the model was "
      "trained on, so a malformed or incomplete payload is rejected with field-level "
      "errors rather than silently producing a meaningless prediction.", align=J)
    F(doc, "fig_activity.png", "Activity diagram for a single risk assessment", 11.5)

    H(doc, "3.6  System Architecture", 2)
    P(doc, "The system is a three-tier modular monolith. Microservices were "
      "considered and rejected: with two developers and a single deployable unit of "
      "work, the operational overhead of service discovery, distributed tracing and "
      "independent deployment would have bought nothing. The monolith is modular "
      "internally, with each Django application owning its own models, serializers, "
      "views and routes, so extraction into services later would be mechanical.", align=J)
    F(doc, "fig_architecture.png", "Three-tier system architecture", 16.0)
    P(doc, "Two design patterns carry most of the weight. PredictionService is a "
      "singleton: the model artifact is deserialised once at process start and held "
      "in memory, because loading it per request would dominate response time. "
      "LLMProvider is a strategy: the conversational assistant is defined by an "
      "interface with interchangeable implementations, so the underlying language "
      "model is selected by configuration and can be replaced without touching a "
      "single view.", align=J)

    H(doc, "3.7  Class Design", 2)
    F(doc, "fig_class_diagram.png", "Class diagram of the backend domain and service layer", 15.5)

    H(doc, "3.8  Database Design", 2)
    P(doc, "Four tables hold all persistent state. The design decision worth "
      "defending is the use of JSONB columns for the questionnaire inputs and the "
      "full result. A fully normalised alternative would give each feature its own "
      "column, which would be tidier on paper but would require a schema migration "
      "every time the feature set changed. During this project the feature set "
      f"changed twice, most recently from 19 to {N_FEATS} features. With JSONB "
      "those changes cost nothing, and historical rows remain readable because each "
      "one records exactly the inputs that produced it.", align=J)
    F(doc, "fig_erd.png", "Entity-relationship diagram as implemented on PostgreSQL", 15.5)
    T(doc, "Assessment table schema",
      ["Column", "Type", "Constraint", "Description"],
      [["id", "bigint", "Primary key", "Surrogate identifier"],
       ["user_id", "bigint", "Foreign key, cascade", "Owner of the assessment"],
       ["inputs", "jsonb", "Not null", f"The {N_FEATS} answers submitted"],
       ["result", "jsonb", "Not null", "Prediction, factors and advice"],
       ["diabetes_risk", "double", "Not null", "Denormalised for fast trend queries"],
       ["kidney_risk", "double", "Not null", "Denormalised for fast trend queries"],
       ["created_at", "timestamptz", "Auto, indexed", "Ordering key for history"]],
      widths=[3.4, 2.6, 3.6, 5.8])

    # ===================================================== CHAPTER 4
    CH(doc, 4, "Implementation")

    H(doc, "4.1  Development Methodology", 2)
    P(doc, "Work proceeded in eight two-to-four week sprints. The sequence was "
      "deliberately model-first: no interface work began until the model produced "
      "trustworthy numbers, because a beautiful application wrapped around an "
      "untrustworthy model would have been worse than useless in a health context.", align=J)
    F(doc, "fig_gantt.png", "Development schedule by sprint", 16.0)

    H(doc, "4.2  Technologies and Justification", 2)
    T(doc, "Technology stack, with the reason for each choice",
      ["Layer", "Technology", "Why this and not the alternative"],
      [["Mobile", "Flutter 3 (Dart)", "One codebase for both platforms; native compilation; no JavaScript bridge."],
       ["Backend", "Django REST Framework", "Batteries-included auth and ORM; the team already knew Python from the ML work."],
       ["Model", "scikit-learn MLPClassifier", "A 6,674-parameter network does not need a GPU framework; deploys as a 170 KB file."],
       ["Calibration", "Isotonic regression", "Non-parametric, so it corrects any monotonic distortion, unlike Platt scaling."],
       ["Database", "Supabase PostgreSQL", "Managed, free tier, JSONB support, connection pooling."],
       ["Hosting", "Render", "Persistent process, so the model stays in memory; serverless would reload it per request."],
       ["Auth", "Simple JWT", "Stateless tokens suit a mobile client with intermittent connectivity."],
       ["Assistant", "Provider interface", "Vendor-independent by construction; swapped by one configuration value."],
       ["Notifications", "flutter_local_notifications", "Alarms scheduled by the operating system, so reminders fire offline."]],
      widths=[2.6, 4.4, 8.4])

    H(doc, "4.3  The Machine-Learning Core", 2)
    P(doc, "The raw BRFSS 2015 file contains 441 columns of survey responses "
      "encoded with values such as 7 for do not know and 9 for refused. The "
      "extraction stage recodes the two disease labels and the behavioural "
      "features into clean binary and ordinal values, discarding rows where a "
      f"needed answer is missing. This yields {N_RECORDS} complete records with "
      f"{N_FEATS} features and two labels.", align=J)
    F(doc, "fig_ml_pipeline.png", "Machine-learning pipeline from raw survey to deployed artifact", 16.0)
    P(doc, "The model itself is a multilayer perceptron trained on a two-column "
      "label matrix. Because both outputs share every hidden layer, the network is "
      "structurally a multi-task model: the hidden layers form a representation "
      "that must serve both predictions at once, and the two output units are the "
      "task-specific heads.", align=J)
    F(doc, "fig_multitask_network.png", "Multi-task architecture: one shared backbone, two heads", 13.5)
    T(doc, "Model hyperparameters",
      ["Parameter", "Value", "Reason"],
      [["Hidden layers", "96, then 48", "Wide enough to represent interactions, narrow enough to avoid overfitting."],
       ["Activation", "ReLU", "Standard, non-saturating, inexpensive."],
       ["Solver", "Adam", "Robust default for small tabular networks."],
       ["Batch size", "512", "Large batches stabilise gradients on 200,000 rows."],
       ["Learning rate", "0.0008", "Tuned for stable convergence within the iteration budget."],
       ["Early stopping", "Enabled, patience 8", "Halts when validation loss stops improving."],
       ["Trainable parameters", "6,674", "Small by design; the constraint is data quality, not capacity."]],
      widths=[3.8, 3.4, 8.2])

    H(doc, "4.4  Explanation and What-If Engines", 2)
    P(doc, "A risk number on its own is not useful, and in a health setting it can "
      "be actively harmful, because a person told they are at high risk with no "
      "explanation has been given anxiety without agency. Two mechanisms address "
      "this.", align=J)
    P(doc, "Factor attribution uses occlusion. For each feature in turn, the value "
      "is replaced by the population mean and the model is re-run; the drop in "
      "predicted risk is that feature's contribution for this individual. With "
      f"{N_FEATS} features this costs {N_FEATS} additional forward passes, which at "
      "roughly one millisecond each is negligible. The approach is a faithful "
      "local attribution and is honest about being an approximation to a full "
      "Shapley decomposition rather than claiming to be one.", align=J)
    P(doc, "The what-if engine takes the six habits a person can realistically "
      "change, applies the healthier value to each in turn, re-runs the model, and "
      "reports the projected reduction. Only improvements are shown, and only for "
      "habits the user has not already adopted, so nobody is advised to stop "
      "smoking when they have said they do not smoke.", align=J)

    H(doc, "4.5  REST API", 2)
    T(doc, "REST endpoints",
      ["Method", "Path", "Auth", "Purpose"],
      [["GET", "/api/health/", "No", "Liveness probe"],
       ["POST", "/api/auth/register/", "No", "Create an account"],
       ["POST", "/api/auth/login/", "No", "Obtain access and refresh tokens"],
       ["POST", "/api/auth/refresh/", "No", "Exchange a refresh token"],
       ["POST", "/api/auth/password/", "Yes", "Change password"],
       ["GET", "/api/schema/", "No", "Questionnaire field schema"],
       ["GET", "/api/model/card/", "No", "Live architecture and metrics"],
       ["POST", "/api/predict/", "Yes", "Assess risk and store the result"],
       ["GET", "/api/history/", "Yes", "List past assessments"],
       ["GET", "/api/profile/", "Yes", "Read profile"],
       ["PATCH", "/api/profile/", "Yes", "Update profile"],
       ["POST", "/api/chat/", "Yes", "Send a message to the assistant"],
       ["GET", "/api/chat/history/", "Yes", "Retrieve conversation history"]],
      widths=[2.2, 5.4, 1.8, 6.8])
    F(doc, "fig_sequence.png", "Sequence of messages during one prediction request", 16.0)

    H(doc, "4.6  Mobile Application", 2)
    P(doc, "The application is built around a design system rather than ad-hoc "
      "styling: one typeface pairing, a fixed type scale, a single corner radius, "
      "and hairline rules in place of drop shadows. Data is set in a monospaced "
      "face so that figures align in columns, which matters on the history screen "
      "where percentages are compared down the page.", align=J)
    F(doc, "screens/screen_home.png", "Home screen: the primary action and the most recent reading", 6.6)
    F(doc, "screens/screen_questionnaire.png", "Questionnaire: grouped into five short steps", 6.6)
    P(doc, "Reminders are scheduled through the operating system's alarm service "
      "rather than by a background process, which is why they continue to fire when "
      "the application is closed and the device has no network connection.", align=J)

    H(doc, "4.7  Deployment", 2)
    F(doc, "fig_deployment.png", "Deployment topology across device, Render and Supabase", 16.0)
    P(doc, "The backend is deployed on Render as a persistent web service running "
      "gunicorn. A serverless platform was rejected for a specific technical reason: "
      "the model artifact must be deserialised into memory before the first "
      "prediction, and a platform that starts a fresh process per request would pay "
      "that cost every time. The database is a managed PostgreSQL instance on "
      "Supabase reached over TLS through a session pooler. Pushing to the main "
      "branch triggers an automatic rebuild and redeploy.", align=J)

    # ===================================================== CHAPTER 5
    CH(doc, 5, "Testing and Results")

    H(doc, "5.1  Testing Methodology", 2)
    P(doc, "Testing operated at three levels. The model was evaluated statistically "
      f"on a held-out test split never seen during training, and separately by "
      f"{REP['n_folds']}-fold stratified cross-validation. The API was exercised "
      "end-to-end against the deployed service over the public internet. The "
      "application was tested manually on a physical Android device.", align=J)

    H(doc, "5.2  Test Cases", 2)
    T(doc, "API test cases executed against the live deployment",
      ["ID", "Scenario", "Expected", "Result"],
      [["T-1", "Health endpoint", "HTTP 200 with status ok", "Pass"],
       ["T-2", "Model card returns live architecture", f"{N_FEATS} inputs reported", "Pass"],
       ["T-3", "Register a new account", "HTTP 201", "Pass"],
       ["T-4", "Sign in with correct credentials", "Access token issued", "Pass"],
       ["T-5", "Predict with a valid payload", "Risk, factors and advice", "Pass"],
       ["T-6", "Predict without a token", "HTTP 401", "Pass"],
       ["T-7", "Predict with a field missing", "HTTP 400, field named", "Pass"],
       ["T-8", "Assistant grounded in latest result", "Cites the user's own risk", "Pass"],
       ["T-9", "History persists across sessions", "Assessment returned", "Pass"],
       ["T-10", "Password change without current password", "Rejected", "Pass"],
       ["T-11", "Repeated failed sign-in attempts", "Throttled after 8", "Pass"]],
      widths=[1.6, 6.4, 5.4, 2.0])

    H(doc, "5.3  Model Results", 2)
    T(doc, "Model performance on the held-out test set",
      ["Metric", "Diabetes", "Kidney disease", "Interpretation"],
      [["ROC-AUC", f"{DIA['roc_auc']:.3f}", f"{KID['roc_auc']:.3f}",
        "Ability to rank a case above a non-case"],
       ["ROC-AUC, cross-validated",
        f"{CV['Diabetes_binary']['roc_auc']['mean']:.3f} ± {CV['Diabetes_binary']['roc_auc']['std']:.3f}",
        f"{CV['Kidney_binary']['roc_auc']['mean']:.3f} ± {CV['Kidney_binary']['roc_auc']['std']:.3f}",
        "Stable across folds, so not a lucky split"],
       ["Recall at screening threshold", f"{DIA['recall']:.3f}", f"{KID['recall']:.3f}",
        "Share of true cases identified"],
       ["Precision at that threshold", f"{DIA['precision']:.3f}", f"{KID['precision']:.3f}",
        "Share of flagged people who truly have it"],
       ["PR-AUC", f"{DIA['pr_auc']:.3f}", f"{KID['pr_auc']:.3f}",
        "Area under precision-recall, imbalance aware"],
       ["Prevalence in the data", f"{PREV['Diabetes_binary']*100:.1f}%", f"{PREV['Kidney_binary']*100:.1f}%",
        "The no-skill baseline for precision"],
       ["Screening threshold", f"{DIA['threshold']:.3f}", f"{KID['threshold']:.3f}",
        "Chosen to hold recall above 0.85"]],
      widths=[5.0, 3.0, 3.2, 4.2])
    F(doc, "fig_roc_curves.png", "ROC curves for both heads on the held-out test set", 12.5)
    F(doc, "fig_pr_curves.png", "Precision-recall curves with prevalence baselines", 12.5)
    F(doc, "fig_feature_importance.png",
      "Permutation importance: the drop in ROC-AUC when each answer is shuffled", 13.5)

    H(doc, "5.4  Why Accuracy Is Not Reported", 2)
    P(doc, "This section exists because accuracy is the metric an examiner is most "
      "likely to ask for, and reporting it without this explanation would be "
      "misleading.", align=J)
    P(doc, f"Chronic kidney disease appears in {PREV['Kidney_binary']*100:.1f} per "
      "cent of the dataset. A model that ignores its input entirely and answers no "
      f"to every person is therefore {(1-PREV['Kidney_binary'])*100:.1f} per cent "
      "accurate while identifying not one single case. Our own model, evaluated at "
      "the conventional 0.5 decision threshold, reports an accuracy of "
      f"{KID['accuracy']*100:.1f} per cent and a balanced accuracy of "
      f"{KID['balanced_accuracy']*100:.1f} per cent, which is the signature of "
      "exactly that degenerate behaviour.", align=J)
    F(doc, "fig_class_imbalance.png",
      "Class imbalance in the dataset, which is what makes accuracy misleading", 12.0)
    P(doc, "The response is not to hide the number but to change the operating "
      "point and report the metrics that cannot be gamed this way. ROC-AUC measures "
      "ranking ability independently of any threshold. Recall measures the "
      "proportion of real cases caught. Balanced accuracy corrects for prevalence. "
      "All three are reported above, for both heads.", align=J)

    H(doc, "5.5  Calibration and Threshold Selection", 2)
    P(doc, "A screening tool that tells a user their risk is thirty per cent has "
      "made a claim about the world, and that claim should be true: roughly thirty "
      "in a hundred such people should go on to have the condition. Raw neural "
      "network outputs do not have this property. Isotonic regression, fitted on "
      "the validation split only, maps raw scores onto calibrated probabilities.", align=J)
    F(doc, "fig_calibration.png",
      "Reliability curves before and after isotonic calibration", 15.0)
    P(doc, "The threshold for each head is then chosen as the highest value that "
      "still achieves the target recall of 0.85 on the validation split. This is a "
      "deliberate trade: precision falls, meaning some healthy people are flagged. "
      "In a screening context that is the correct direction to err, because the "
      "cost of an unnecessary check is inconvenience whereas the cost of a missed "
      "case is years of untreated disease.", align=J)
    F(doc, "fig_threshold_tradeoff.png",
      "Recall and precision as the decision threshold moves, with the chosen point marked", 15.0)
    F(doc, "fig_confusion.png",
      "Confusion matrices at the chosen screening thresholds", 15.0)

    H(doc, "5.6  Performance Evaluation", 2)
    T(doc, "Measured system performance",
      ["Measurement", "Result", "Note"],
      [["Model inference, server-side", "About 1 ms", "Model held in memory"],
       ["Full assessment, server-side", "About 25 forward passes", "Predict, explain, advise"],
       ["End-to-end request, warm", "1.8 to 2.2 s", "Includes network and database write"],
       ["Cold start after idle", "Up to 50 s", "Free hosting tier spins down"],
       ["Model artifact size", "170 KB", "Deploys with the source"],
       ["Release APK size", "19 to 53 MB", "Per architecture, or universal"]],
      widths=[5.4, 4.4, 6.0])
    P(doc, "The variance in end-to-end timing is attributable to the hosting tier "
      "rather than to the application: the same variance appears on an endpoint "
      "that performs neither database access nor inference. A paid instance would "
      "remove it.", align=J)

    # ===================================================== CHAPTER 6
    CH(doc, 6, "Conclusion and Future Work")

    H(doc, "6.1  Conclusion", 2)
    P(doc, "This project set out to make preventive screening for two chronic "
      "diseases available to anyone with an Android phone, without a blood test, "
      "and to do so honestly. The delivered system meets that aim. A single "
      f"multi-task network trained on {N_RECORDS} real survey responses estimates "
      "risk for both conditions from nineteen everyday questions, reaching a "
      f"ROC-AUC of {DIA['roc_auc']:.3f} and {KID['roc_auc']:.3f} and catching "
      f"{DIA['recall']*100:.0f} and {KID['recall']*100:.0f} per cent of true cases "
      "at its screening thresholds.", align=J)
    P(doc, "The work we consider most valuable is not the model but the correction "
      "described in Section 2.4. Recognising that our original design would have "
      "produced a model that merely re-learned our own formula, and abandoning it, "
      "is the difference between a project that reports a meaningless 99 per cent "
      "and one that reports a meaningful 0.82.", align=J)

    H(doc, "6.2  Limitations", 2)
    B(doc, [
        "All inputs are self-reported, and self-reported height, weight and "
        "activity are known to be optimistic. The model inherits that bias.",
        "The training data describes a United States population surveyed in 2015. "
        "Risk factors transfer across populations, but base rates do not, so "
        "absolute percentages should be read as indicative for Pakistani users.",
        "The dataset is cross-sectional. It records who has a condition now, not "
        "who developed one later, so the model learns the risk profile of people "
        "who already have the disease.",
        "Precision at the screening threshold is low by construction, particularly "
        "for kidney disease. This is an accepted trade, not an oversight.",
        "The free hosting tier introduces latency variance and a cold-start delay.",
    ])

    H(doc, "6.3  Future Work", 2)
    B(doc, [
        "Validate prospectively against a local cohort to establish whether the "
        "thresholds transfer to a Pakistani population.",
        "Replace occlusion attribution with exact Shapley values, now that the "
        "smaller feature set makes the computation affordable.",
        "Add Urdu localisation, which would substantially widen reach.",
        "Publish an iOS build; the Flutter codebase requires no change.",
        "Move the model to a paid instance or a dedicated inference container to "
        "eliminate cold starts before any real-world deployment.",
        "Retrain on a longitudinal dataset if one becomes available, which would "
        "let the model predict incidence rather than prevalence.",
    ])

    # ===================================================== REFERENCES
    doc.add_page_break()
    H(doc, "References")
    RULE(doc)
    refs = [
        "Centers for Disease Control and Prevention. Behavioral Risk Factor "
        "Surveillance System Survey Data. Atlanta, Georgia: U.S. Department of "
        "Health and Human Services, 2015.",
        "International Diabetes Federation. IDF Diabetes Atlas, 10th edition. "
        "Brussels: International Diabetes Federation, 2021.",
        "Lindström, J. and Tuomilehto, J. The Diabetes Risk Score: a practical "
        "tool to predict type 2 diabetes risk. Diabetes Care, 26(3), 725–731, 2003.",
        "Tangri, N. et al. A predictive model for progression of chronic kidney "
        "disease to kidney failure. JAMA, 305(15), 1553–1559, 2011.",
        "Caruana, R. Multitask Learning. Machine Learning, 28(1), 41–75, 1997.",
        "Ruder, S. An Overview of Multi-Task Learning in Deep Neural Networks. "
        "arXiv:1706.05098, 2017.",
        "Niculescu-Mizil, A. and Caruana, R. Predicting good probabilities with "
        "supervised learning. Proceedings of the 22nd International Conference on "
        "Machine Learning, 625–632, 2005.",
        "Zadrozny, B. and Elkan, C. Transforming classifier scores into accurate "
        "multiclass probability estimates. Proceedings of KDD, 694–699, 2002.",
        "Saito, T. and Rehmsmeier, M. The precision-recall plot is more "
        "informative than the ROC plot when evaluating binary classifiers on "
        "imbalanced datasets. PLOS ONE, 10(3), 2015.",
        "Lundberg, S. M. and Lee, S.-I. A Unified Approach to Interpreting Model "
        "Predictions. Advances in Neural Information Processing Systems 30, 2017.",
        "Pedregosa, F. et al. Scikit-learn: Machine Learning in Python. Journal of "
        "Machine Learning Research, 12, 2825–2830, 2011.",
        "Django Software Foundation. Django Documentation, version 5. 2024.",
        "Google. Flutter Documentation. flutter.dev, 2024.",
        "Jones, M., Bradley, J. and Sakimura, N. JSON Web Token (JWT). RFC 7519, "
        "Internet Engineering Task Force, 2015.",
        "Fielding, R. T. Architectural Styles and the Design of Network-based "
        "Software Architectures. Doctoral dissertation, University of California, "
        "Irvine, 2000.",
    ]
    for i, r in enumerate(refs, 1):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.left_indent = Cm(0.9)
        p.paragraph_format.first_line_indent = Cm(-0.9)
        run = p.add_run(f"[{i}]  {r}")
        run.font.size = Pt(11)

    # ===================================================== APPENDICES
    doc.add_page_break()
    H(doc, "Appendix A — API Reference")
    RULE(doc)
    P(doc, "Base URL: https://aegis-health-jc2o.onrender.com", size=11)
    P(doc, "All authenticated endpoints expect an Authorization header of the form "
      "Bearer followed by the access token issued at sign-in.", size=11, align=J)
    P(doc, "Example request to POST /api/predict/", bold=True, size=11, space_before=8)
    P(doc, '{ "HighBP": 1, "HighChol": 1, "CholCheck": 1, "BMI": 31.5, "Smoker": 1, '
      '"Stroke": 0, "HeartDiseaseorAttack": 0, "PhysActivity": 0, "Fruits": 0, '
      '"Veggies": 0, "HvyAlcoholConsump": 0, "AnyHealthcare": 1, "NoDocbcCost": 0, '
      '"GenHlth": 4, "PhysHlth": 10, "DiffWalk": 1, "Sex": 1, "Age": 9 }',
      size=9.5, color=D["MUTED"])
    P(doc, "Example response", bold=True, size=11, space_before=8)
    P(doc, '{ "prediction": { "diabetes": { "risk_percent": 47.6, "tier": "High", '
      '"threshold": 0.119 }, "kidney": { "risk_percent": 9.7, "tier": "High", '
      '"threshold": 0.021 } }, "key_factors": { ... }, "recommendations": [ ... ] }',
      size=9.5, color=D["MUTED"])

    doc.add_page_break()
    H(doc, "Appendix B — User Manual")
    RULE(doc)
    steps = [
        ("Install", "Open the supplied APK file. Android will ask permission to "
         "install from this source; allow it, then tap Install."),
        ("Create an account", "Choose a username and a password of at least six "
         "characters. Email is optional."),
        ("Complete the health check", "Tap Begin Check on the home screen and "
         "answer nineteen questions across five short steps. Height and weight are "
         "used to compute body mass index automatically."),
        ("Read the result", "Each condition is shown as a percentage with a marked "
         "screening threshold. Sitting above the mark means the tool would refer "
         "you for a real test; it does not mean you have the condition."),
        ("Understand the drivers", "The What drives it section ranks your own "
         "answers by how much each raised your estimate."),
        ("Try changes", "Open the what-if simulator, toggle a habit or move the "
         "body-mass slider, and watch the estimate update."),
        ("Ask the assistant", "The Assistant tab can explain your result in plain "
         "language. It can see your most recent assessment."),
        ("Set reminders", "Reminders run on the phone itself and work without a "
         "network. On some devices you must allow unrestricted battery use, "
         "otherwise Android may delay them."),
    ]
    for i, (title, body) in enumerate(steps, 1):
        P(doc, f"{i}.  {title}", bold=True, size=11.5, space_after=2, space_before=8)
        P(doc, body, size=11, align=J)
    P(doc, "Aegis Health is an educational screening aid. It does not diagnose "
      "disease and it does not replace a clinician.",
      italic=True, size=11, space_before=12)
