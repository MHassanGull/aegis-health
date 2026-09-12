import 'package:flutter/material.dart';

/// Multi-step questionnaire definition for Aegis Health.
///
/// Friendly wording, height+weight instead of raw BMI, and no education/income.
/// The model needs 18 features; BMI is computed from height and weight in
/// [buildPayload] before sending to the backend.
enum QType { toggle, segmented, dropdown, slider, number }

class Choice {
  final String label;
  final num value;
  const Choice(this.label, this.value);
}

class Question {
  final String key;
  final String label;
  final QType type;
  final List<Choice> choices;
  final num min;
  final num max;
  final int? divisions;
  final num defaultValue;
  final String? unit;
  const Question({
    required this.key,
    required this.label,
    required this.type,
    this.choices = const [],
    this.min = 0,
    this.max = 1,
    this.divisions,
    required this.defaultValue,
    this.unit,
  });
}

class QStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Question> questions;
  const QStep(this.title, this.subtitle, this.icon, this.questions);
}

const _yesNo = [Choice('No', 0), Choice('Yes', 1)];

const List<QStep> kSteps = [
  QStep('About You', "Let's start with the basics", Icons.person_rounded, [
    Question(key: 'Sex', label: 'Your sex', type: QType.segmented,
        choices: [Choice('Female', 0), Choice('Male', 1)], defaultValue: 0),
    Question(key: 'Age', label: 'Your age group', type: QType.dropdown,
        defaultValue: 6, choices: [
      Choice('18 - 24', 1), Choice('25 - 29', 2), Choice('30 - 34', 3),
      Choice('35 - 39', 4), Choice('40 - 44', 5), Choice('45 - 49', 6),
      Choice('50 - 54', 7), Choice('55 - 59', 8), Choice('60 - 64', 9),
      Choice('65 - 69', 10), Choice('70 - 74', 11), Choice('75 - 79', 12),
      Choice('80 or older', 13),
    ]),
  ]),
  QStep('Your Body', "We'll work out your BMI for you", Icons.straighten_rounded, [
    Question(key: 'heightCm', label: 'Height', type: QType.number,
        min: 120, max: 220, defaultValue: 170, unit: 'cm'),
    Question(key: 'weightKg', label: 'Weight', type: QType.number,
        min: 30, max: 200, defaultValue: 70, unit: 'kg'),
  ]),
  QStep('Your Lifestyle', 'Your everyday habits', Icons.directions_run_rounded, [
    Question(key: 'PhysActivity', label: 'Active in the last 30 days?',
        type: QType.toggle, choices: _yesNo, defaultValue: 1),
    Question(key: 'Fruits', label: 'Eat fruit most days?',
        type: QType.toggle, choices: _yesNo, defaultValue: 1),
    Question(key: 'Veggies', label: 'Eat vegetables most days?',
        type: QType.toggle, choices: _yesNo, defaultValue: 1),
    Question(key: 'Smoker', label: 'Smoked 100+ cigarettes in your life?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
    Question(key: 'HvyAlcoholConsump', label: 'Drink heavily?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
  ]),
  QStep('Your Health', 'A few health questions', Icons.favorite_rounded, [
    Question(key: 'HighBP', label: 'Told you have high blood pressure?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
    Question(key: 'HighChol', label: 'Told you have high cholesterol?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
    Question(key: 'CholCheck', label: 'Cholesterol checked in last 5 years?',
        type: QType.toggle, choices: _yesNo, defaultValue: 1),
    Question(key: 'Stroke', label: 'Ever had a stroke?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
    Question(key: 'HeartDiseaseorAttack', label: 'Heart disease or heart attack?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
    Question(key: 'DiffWalk', label: 'Difficulty walking or climbing stairs?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
  ]),
  QStep('Wellbeing', 'How you have been feeling', Icons.spa_rounded, [
    Question(key: 'GenHlth', label: 'Your general health', type: QType.dropdown,
        defaultValue: 3, choices: [
      Choice('Excellent', 1), Choice('Very good', 2), Choice('Good', 3),
      Choice('Fair', 4), Choice('Poor', 5),
    ]),
    Question(key: 'PhysHlth', label: 'Poor physical-health days (last 30)',
        type: QType.slider, min: 0, max: 30, divisions: 30, defaultValue: 0),
    Question(key: 'AnyHealthcare', label: 'Do you have health-care coverage?',
        type: QType.toggle, choices: _yesNo, defaultValue: 1),
    Question(key: 'NoDocbcCost', label: 'Skipped a doctor due to cost?',
        type: QType.toggle, choices: _yesNo, defaultValue: 0),
  ]),
];

Map<String, num> defaultAnswers() {
  final m = <String, num>{};
  for (final s in kSteps) {
    for (final q in s.questions) {
      m[q.key] = q.defaultValue;
    }
  }
  return m;
}

/// Compute BMI from height(cm) & weight(kg).
double bmiFrom(num heightCm, num weightKg) {
  final h = heightCm / 100.0;
  if (h <= 0) return 0;
  return weightKg / (h * h);
}

String bmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Healthy';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

/// Convert questionnaire answers into the 18-feature payload the model expects.
Map<String, num> buildPayload(Map<String, num> answers) {
  final out = Map<String, num>.from(answers);
  final bmi = bmiFrom(answers['heightCm'] ?? 170, answers['weightKg'] ?? 70);
  out.remove('heightCm');
  out.remove('weightKg');
  out['BMI'] = double.parse(bmi.toStringAsFixed(1));
  return out;
}
