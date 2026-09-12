import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../data/questions.dart';
import 'analyzing_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});
  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _controller = PageController();
  final Map<String, num> _answers = defaultAnswers();
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    try {
      final p = await ApiClient.instance.getProfile();
      setState(() {
        if (p['sex'] != null) _answers['Sex'] = (p['sex'] as num);
        if (p['age'] != null) _answers['Age'] = (p['age'] as num);
        if (p['height_cm'] != null) _answers['heightCm'] = (p['height_cm'] as num);
        if (p['weight_kg'] != null) _answers['weightKg'] = (p['weight_kg'] as num);
      });
    } catch (_) {/* not signed-in profile / offline: use defaults */}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < kSteps.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => AnalyzingScreen(payload: buildPayload(_answers))),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final step = kSteps[_step];
    final progress = (_step + 1) / kSteps.length;
    final last = _step == kSteps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  8, 4, AppTheme.gutter, 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: _back,
                      iconSize: 20,
                      icon: const Icon(Icons.arrow_back)),
                  Expanded(
                    child: Row(
                      children: List.generate(kSteps.length, (k) {
                        return Expanded(
                          child: Container(
                            height: 2,
                            margin: EdgeInsets.only(
                                right: k < kSteps.length - 1 ? 4 : 0),
                            color: k <= _step ? AppTheme.green : p.line,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                      '${(_step + 1).toString().padLeft(2, '0')}'
                      '/${kSteps.length.toString().padLeft(2, '0')}',
                      style: AppType.mono.copyWith(color: p.subtle)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.gutter, 26, AppTheme.gutter, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title.toUpperCase(),
                      style: AppType.label.copyWith(color: AppTheme.green)),
                  const SizedBox(height: 10),
                  Text(step.subtitle,
                      style: AppType.h1.copyWith(color: p.ink)),
                ],
              ).animate(key: ValueKey(_step)).fadeIn(duration: 220.ms),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                itemCount: kSteps.length,
                itemBuilder: (context, i) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    children: [
                      for (final q in kSteps[i].questions)
                        _QuestionCard(
                          question: q,
                          value: _answers[q.key]!,
                          onChanged: (v) => setState(() => _answers[q.key] = v),
                        ),
                      if (kSteps[i].title == 'Your Body') _BmiPreview(_answers),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: FilledButton(
                onPressed: _next,
                child: Text(last ? 'SEE RESULTS' : 'CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BmiPreview extends StatelessWidget {
  final Map<String, num> answers;
  const _BmiPreview(this.answers);
  @override
  Widget build(BuildContext context) {
    final bmi = bmiFrom(answers['heightCm'] ?? 170, answers['weightKg'] ?? 70);
    final cat = bmiCategory(bmi);
    final color = cat == 'Healthy'
        ? AppTheme.low
        : (cat == 'Overweight' ? AppTheme.moderate : AppTheme.high);
    final p = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Rule(margin: const EdgeInsets.only(bottom: 18)),
        Text('CALCULATED BMI',
            style: AppType.label.copyWith(color: p.subtle)),
        const SizedBox(height: 8),
        Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(bmi.toStringAsFixed(1),
                  style: AppType.metric.copyWith(color: p.ink, fontSize: 30)),
              const SizedBox(width: 12),
              Text(cat.toUpperCase(),
                  style: AppType.label.copyWith(color: color)),
            ]),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final num value;
  final ValueChanged<num> onChanged;
  const _QuestionCard(
      {required this.question, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.label,
              style: AppType.body
                  .copyWith(color: p.ink, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _input(p),
        ],
      ),
    );
  }

  Widget _input(Palette p) {
    switch (question.type) {
      case QType.toggle:
      case QType.segmented:
        return Row(
          children: question.choices.map((c) {
            final selected = value == c.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onChanged(c.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(
                          color: selected ? AppTheme.green : p.line,
                          width: AppTheme.hair),
                    ),
                    alignment: Alignment.center,
                    child: Text(c.label,
                        style: AppType.body.copyWith(
                            color: selected ? Colors.white : p.ink,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      case QType.dropdown:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: DropdownButton<num>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            items: question.choices
                .map((c) =>
                    DropdownMenuItem(value: c.value, child: Text(c.label)))
                .toList(),
            onChanged: (v) => onChanged(v ?? value),
          ),
        );
      case QType.slider:
        return Row(children: [
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: question.min.toDouble(),
              max: question.max.toDouble(),
              divisions: question.divisions,
              activeColor: AppTheme.green,
              label: value.round().toString(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 46,
            child: Text(value.round().toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppTheme.green)),
          ),
        ]);
      case QType.number:
        return _Stepper(
          value: value.toDouble(),
          min: question.min.toDouble(),
          max: question.max.toDouble(),
          unit: question.unit ?? '',
          onChanged: onChanged,
        );
    }
  }
}

class _Stepper extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<num> onChanged;
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        _circleBtn(p, Icons.remove_rounded,
            () => onChanged((value - 1).clamp(min, max))),
        Expanded(
          child: Center(
            child: RichText(
              text: TextSpan(
                text: value.round().toString(),
                style: TextStyle(
                    color: p.ink, fontSize: 30, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                      text: '  $unit',
                      style: TextStyle(
                          color: p.subtle,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        _circleBtn(p, Icons.add_rounded,
            () => onChanged((value + 1).clamp(min, max))),
      ],
    );
  }

  Widget _circleBtn(Palette p, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
            color: p.tint(AppTheme.green), shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.green),
      ),
    );
  }
}
