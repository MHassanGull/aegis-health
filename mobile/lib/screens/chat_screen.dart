import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

class _Msg {
  final String role; // user | assistant
  final String text;
  _Msg(this.role, this.text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _sending = false;
  bool _loading = true;

  static const _suggestions = [
    'How can I lower my diabetes risk?',
    'Explain my results simply',
    'What foods are good for my kidneys?',
    'Make me a simple weekly plan',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final h = await ApiClient.instance.chatHistory();
      for (final m in h) {
        _messages.add(_Msg(m['role'] as String, m['text'] as String));
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    text = text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Msg('user', text));
      _sending = true;
      _input.clear();
    });
    _scrollToEnd();
    try {
      final reply = await ApiClient.instance.sendChat(text);
      _messages.add(_Msg('assistant', reply['text'] as String));
    } catch (e) {
      _messages.add(_Msg('assistant',
          'Sorry, I couldn’t reach the assistant. Is the backend running?'));
    }
    if (mounted) setState(() => _sending = false);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter, 14, AppTheme.gutter, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      color: AppTheme.green,
                      borderRadius:
                          BorderRadius.all(Radius.circular(AppTheme.radius)),
                    ),
                    child: const Icon(Icons.forum_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text('ASSISTANT',
                      style: AppType.label
                          .copyWith(color: p.ink, letterSpacing: 1.6)),
                  const Spacer(),
                  Text('CLAUDE',
                      style: AppType.label
                          .copyWith(color: p.subtle, fontSize: 9)),
                ]),
                const SizedBox(height: 12),
                Rule(),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_messages.isEmpty ? _empty(p) : _list(p)),
          ),
          _composer(p),
        ],
      ),
    );
  }

  Widget _empty(Palette p) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTheme.gutter, 24, AppTheme.gutter, 20),
      children: [
        Text('Ask about\nyour results.',
            style: AppType.display.copyWith(color: p.ink, fontSize: 28)),
        const SizedBox(height: 12),
        Text(
            'The assistant can see your most recent screening and will '
            'explain it in plain language.',
            style: AppType.body.copyWith(color: p.subtle)),
        const SizedBox(height: 32),
        const SectionLabel('Try asking'),
        ..._suggestions.map((s) => Column(
              children: [
                InkWell(
                  onTap: () => _send(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(children: [
                      Expanded(
                          child: Text(s,
                              style: AppType.body.copyWith(color: p.ink))),
                      const SizedBox(width: 12),
                      Icon(Icons.north_east, size: 15, color: p.subtle),
                    ]),
                  ),
                ),
                Rule(),
              ],
            )),
      ],
    );
  }

  Widget _list(Palette p) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length) return _typing(p);
        final m = _messages[i];
        final isUser = m.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.green : p.card,
              borderRadius:
                  const BorderRadius.all(Radius.circular(AppTheme.radius)),
              border: isUser
                  ? null
                  : Border.all(color: p.line, width: AppTheme.hair),
            ),
            child: Text(m.text,
                style: AppType.body.copyWith(
                    color: isUser ? Colors.white : p.ink, height: 1.5)),
          ),
        ).animate().fadeIn(duration: 180.ms);
      },
    );
  }

  Widget _typing(Palette p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: p.card,
            borderRadius:
                const BorderRadius.all(Radius.circular(AppTheme.radius)),
            border: Border.all(color: p.line, width: AppTheme.hair)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var d = 0; d < 3; d++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(width: 6, height: 6, color: AppTheme.green)
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(duration: 400.ms, delay: (d * 150).ms)
                  .then()
                  .fadeOut(duration: 400.ms),
            ),
        ]),
      ),
    );
  }

  Widget _composer(Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
          color: p.bg,
          border:
              Border(top: BorderSide(color: p.line, width: AppTheme.hair))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _input,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Type a message…',
              fillColor: p.bg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: _send,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _send(_input.text),
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppTheme.green,
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius)),
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
