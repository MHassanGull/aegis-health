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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Row(children: [
              Container(
                height: 42, width: 42,
                decoration: const BoxDecoration(
                    gradient: AppTheme.heroGradient, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aegis Assistant',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: p.ink)),
                  Text('AI health guide',
                      style: TextStyle(color: p.subtle, fontSize: 12.5)),
                ],
              ),
            ]),
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
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Icon(Icons.forum_rounded, size: 64, color: p.tint(AppTheme.green)),
        const SizedBox(height: 14),
        Text('Ask me anything about your health',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: p.ink)),
        const SizedBox(height: 8),
        Text('I know your latest risk results and can explain them or coach you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.subtle)),
        const SizedBox(height: 24),
        ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                onTap: () => _send(s),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  const Icon(Icons.bolt_rounded, color: AppTheme.coral, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s, style: TextStyle(color: p.ink))),
                ]),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.green : p.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: isUser ? null : p.shadow,
            ),
            child: Text(m.text,
                style: TextStyle(
                    color: isUser ? Colors.white : p.ink, height: 1.4)),
          ),
        ).animate().fadeIn(duration: 250.ms).moveY(begin: 6, end: 0);
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: p.shadow),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var d = 0; d < 3; d++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: AppTheme.green, shape: BoxShape.circle),
              )
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
      decoration: BoxDecoration(color: p.card, boxShadow: p.shadow),
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
            height: 50, width: 50,
            decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
