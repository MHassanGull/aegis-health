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
              padding: const EdgeInsets.fromLTRB(8, 6, 20, 4),
              child: Row(
                children: [
                  IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 350),
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          backgroundColor: p.line,
                          color: AppTheme.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('${_step + 1}/${kSteps.length}',
                      style: TextStyle(
                          color: p.subtle, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 26,
                      backgroundColor: p.tint(AppTheme.green),
                      child: Icon(step.icon, color: AppTheme.green)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: p.ink)),
                        Text(step.subtitle,
                            style: TextStyle(color: p.subtle)),
                      ],
                    ),
                  ),
                ],
              ).animate(key: ValueKey(_step)).fadeIn(duration: 300.ms),
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
                child: Text(last ? 'See My Results' : 'Continue'),
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
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(Icons.monitor_weight_rounded, color: color, size: 30),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your BMI (we calculated it)',
                  style: TextStyle(
                      color: Palette.of(context).subtle, fontSize: 12.5)),
              Text('${bmi.toStringAsFixed(1)}  ·  $cat',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
        ),
      ]),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: p.ink, fontSize: 15.5)),
          const SizedBox(height: 14),
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
                    duration: const Duration(milliseconds: 180),
                    height: 50,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.green : p.tint(AppTheme.green),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(c.label,
                        style: TextStyle(
                            color: selected ? Colors.white : AppTheme.greenDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButton<num>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(14),
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
                    fontWeight: FontWeight.w800, color: AppTheme.green)),
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
                    color: p.ink, fontSize: 30, fontWeight: FontWeight.w800),
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
