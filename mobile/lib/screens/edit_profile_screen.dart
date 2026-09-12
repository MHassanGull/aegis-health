import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _picker = ImagePicker();
  int _sex = 0;
  int _age = 6;
  String _avatarB64 = '';
  String _avatarColor = '#20A57A';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  static const _presetColors = [
    '#20A57A', '#FF7A63', '#F2A03D', '#3D8BF2',
    '#8A6DF0', '#12B3A6', '#EB5B8A', '#5B7CEB',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await ApiClient.instance.getProfile();
      _name.text = (p['full_name'] ?? '') as String;
      _email.text = (p['email'] ?? '') as String;
      _avatarB64 = (p['avatar'] ?? '') as String;
      _avatarColor = (p['avatar_color'] ?? '#20A57A') as String;
      if (p['sex'] != null) _sex = (p['sex'] as num).toInt();
      if (p['age'] != null) _age = (p['age'] as num).toInt();
      if (p['height_cm'] != null) _height.text = '${p['height_cm']}';
      if (p['weight_kg'] != null) _weight.text = '${p['weight_kg']}';
    } catch (_) {/* first time: empty form */}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
          source: source, maxWidth: 512, maxHeight: 512, imageQuality: 70);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() => _avatarB64 = base64Encode(bytes));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Couldn’t open that image.')));
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient.instance.updateProfile({
        'full_name': _name.text.trim(),
        'email': _email.text.trim(),
        'avatar': _avatarB64,
        'avatar_color': _avatarColor,
        'sex': _sex,
        'age': _age,
        'height_cm': double.tryParse(_height.text),
        'weight_kg': double.tryParse(_weight.text),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _avatarSection(p),
                const SizedBox(height: 22),
                _label('Full name', p),
                TextField(controller: _name,
                    decoration: const InputDecoration(hintText: 'Your name')),
                const SizedBox(height: 16),
                _label('Email', p),
                TextField(controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'you@email.com')),
                const SizedBox(height: 16),
                _label('Sex', p),
                Row(children: [
                  _seg('Female', 0, p), const SizedBox(width: 10), _seg('Male', 1, p),
                ]),
                const SizedBox(height: 16),
                _label('Age group', p),
                _ageDropdown(p),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Height (cm)', p),
                      TextField(controller: _height,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '170')),
                    ],
                  )),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Weight (kg)', p),
                      TextField(controller: _weight,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '70')),
                    ],
                  )),
                ]),
                const SizedBox(height: 8),
                Text('Saved here so your health check is faster next time.',
                    style: TextStyle(color: p.subtle, fontSize: 12.5)),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppTheme.high)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 22, width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : const Text('Save Profile'),
                ),
              ],
            ),
    );
  }

  // ---- avatar --------------------------------------------------------------
  Widget _avatarSection(Palette p) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _avatarPreview(p),
            GestureDetector(
              onTap: _chooseSource,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.bg, width: 3),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _miniBtn(Icons.photo_library_rounded, 'Gallery',
                () => _pick(ImageSource.gallery), p),
            const SizedBox(width: 10),
            _miniBtn(Icons.photo_camera_rounded, 'Camera',
                () => _pick(ImageSource.camera), p),
            if (_avatarB64.isNotEmpty) ...[
              const SizedBox(width: 10),
              _miniBtn(Icons.delete_outline_rounded, 'Remove',
                  () => setState(() => _avatarB64 = ''), p),
            ],
          ],
        ),
        if (_avatarB64.isEmpty) ...[
          const SizedBox(height: 16),
          Text('Or pick an avatar colour',
              style: TextStyle(color: p.subtle, fontSize: 12.5)),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in _presetColors) _swatch(c),
            ],
          ),
        ],
      ],
    );
  }

  Widget _avatarPreview(Palette p) {
    if (_avatarB64.isNotEmpty) {
      return CircleAvatar(
          radius: 52, backgroundImage: MemoryImage(base64Decode(_avatarB64)));
    }
    final color = UserAvatar.parseColor(_avatarColor);
    final name = ApiClient.instance.username;
    final letter = name.isEmpty ? '?' : name[0].toUpperCase();
    return CircleAvatar(
      radius: 52,
      backgroundColor: color.withValues(alpha: p.isDark ? 0.30 : 0.15),
      child: Text(letter,
          style: TextStyle(
              color: color, fontSize: 40, fontWeight: FontWeight.w800)),
    );
  }

  Widget _swatch(String hex) {
    final color = UserAvatar.parseColor(hex);
    final selected = _avatarColor.toUpperCase() == hex.toUpperCase();
    return GestureDetector(
      onTap: () => setState(() => _avatarColor = hex),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppTheme.green, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  void _chooseSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () { Navigator.pop(context); _pick(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap, Palette p) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
            color: p.tint(AppTheme.green),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppTheme.greenDark),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.greenDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ]),
      ),
    );
  }

  // ---- fields --------------------------------------------------------------
  Widget _label(String t, Palette p) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(t,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: p.ink, fontSize: 14)),
      );

  Widget _seg(String label, int val, Palette p) {
    final selected = _sex == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sex = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.green : p.tint(AppTheme.green),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppTheme.greenDark,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _ageDropdown(Palette p) {
    const labels = [
      '18-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59',
      '60-64','65-69','70-74','75-79','80+'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: p.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line)),
      child: DropdownButton<int>(
        value: _age,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: [
          for (var i = 0; i < labels.length; i++)
            DropdownMenuItem(value: i + 1, child: Text(labels[i])),
        ],
        onChanged: (v) => setState(() => _age = v ?? _age),
      ),
    );
  }
}
