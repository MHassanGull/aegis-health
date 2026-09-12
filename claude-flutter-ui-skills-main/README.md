# flutter-ui — Claude Code Skill

> **Pixel-perfect Flutter UI, smooth animations, GoRouter navigation, and enforced state management rules.**
> Prepared by [DevCenter](https://devcenter.dev)

---

## What This Skill Does

When activated, this skill transforms Claude Code into a Flutter UI expert that:

- Builds **pixel-perfect UI** using Material 3, ThemeExtension, and proper ColorScheme roles — never hardcoded colors or font sizes
- Implements **smooth animations** (implicit, explicit, Hero, page transitions, physics-based) on GPU-safe properties only
- Enforces **GoRouter navigation** with correct back-stack logic, PopScope (not deprecated WillPopScope), deep linking, and persistent tab state
- Applies **Riverpod or Provider rules** automatically by scanning your imports — correct widget types, provider placement, rebuild prevention
- Prevents **60+ common Flutter anti-patterns** before they reach your codebase
- Runs a **static audit script** against your project to find missing `const`, disposed animation controllers, deprecated APIs, and state management violations

---

## Installation

### macOS / Linux

```bash
git clone https://github.com/YOUR_USERNAME/claude-flutter-ui-skills.git
cd claude-flutter-ui-skills
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/YOUR_USERNAME/claude-flutter-ui-skills.git
cd claude-flutter-ui-skills
.\install.ps1
```

> **First time on Windows?** Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once to allow local scripts.

### One-liner (macOS / Linux — no git required)

```bash
curl -L https://github.com/YOUR_USERNAME/claude-flutter-ui-skills/archive/refs/heads/main.tar.gz \
  | tar -xz && cd claude-flutter-ui-skills-main && bash install.sh
```

### One-liner (Windows PowerShell — no git required)

```powershell
Invoke-WebRequest -Uri "https://github.com/YOUR_USERNAME/claude-flutter-ui-skills/archive/refs/heads/main.zip" `
  -OutFile skill.zip; Expand-Archive skill.zip .; cd claude-flutter-ui-skills-main; .\install.ps1
```

### Project-only install (scope to one repo)

```bash
# macOS / Linux — from your Flutter project root
mkdir -p .claude/skills
cp -r /path/to/claude-flutter-ui-skills/flutter-ui .claude/skills/flutter-ui

# Windows
New-Item -ItemType Directory -Force .claude\skills
Copy-Item -Recurse flutter-ui .claude\skills\flutter-ui
```

### Verify Installation

After installing, start a Claude Code session in any Flutter project and type:

```
/flutter-ui
```

Claude confirms the skill is loaded and fills the mandatory checkpoint before any UI work.

---

## Requirements

| Requirement | Minimum |
|------------|---------|
| Claude Code | Latest |
| Flutter | 3.12+ (uses `PopScope`, not `WillPopScope`) |
| Dart | 3.0+ |
| State management | Riverpod 2.x **or** Provider 6.x |
| Navigation | GoRouter 13.x (recommended) |

> Works with any Flutter project — the skill auto-detects your state manager and navigation package from imports.

---

## What's Included

```
flutter-ui/
├── SKILL.md                      Main skill — anti-patterns, checkpoints, checklists
├── flutter-design-thinking.md    Anti-memorization protocol, widget selection trees
├── flutter-animations.md         Implicit, explicit, Hero, page transitions, physics
├── flutter-navigation.md         GoRouter setup, PopScope, back logic, deep links, tabs
├── flutter-state-ui.md           Riverpod + Provider enforced rules and patterns
├── flutter-theme-system.md       Material 3, ColorScheme, TextTheme, ThemeExtension
├── flutter-layout-system.md      Responsive layouts, Slivers, LayoutBuilder, MediaQuery
├── flutter-performance.md        const, RepaintBoundary, 60fps, shader warmup
├── flutter-custom-paint.md       Canvas, CustomPainter, animation integration
└── scripts/
    └── flutter_ui_audit.py       Static auditor — finds issues before they ship
```

---

## How to Use

### Activate for any Flutter task

Just open Claude Code in your Flutter project. The skill activates automatically when relevant — or explicitly with:

```
/flutter-ui
```

### Run the audit script

```bash
python ~/.claude/skills/flutter-ui/scripts/flutter_ui_audit.py .
python ~/.claude/skills/flutter-ui/scripts/flutter_ui_audit.py . --only red
python ~/.claude/skills/flutter-ui/scripts/flutter_ui_audit.py . --all
```

The auditor outputs `🔴 Critical` / `🟡 Warning` / `🟢 Info` findings with file:line locations and exact fixes. Exit code `1` if critical issues found — CI-friendly.

**What it detects:**

| Category | Checks |
|----------|--------|
| Performance | Missing `const`, `ListView` without builder, `Opacity` hiding, `IntrinsicHeight` in lists |
| Animations | `AnimationController` without `dispose()`, `setState` in animation loop |
| Navigation | `WillPopScope` (deprecated), `Navigator.push` in GoRouter app |
| Riverpod | `ref.read()` in `build()`, provider inside class, missing `.when(error:)` |
| Provider | `context.read()` in `build()`, `BuildContext` in `ChangeNotifier` |
| Theming | Hardcoded `Color(0xFF...)`, hardcoded `fontSize` |

---

## Enforced Rules (Auto-Applied)

### State Management

Claude auto-detects your state manager from imports and applies the correct rule set:

**Riverpod** → `ConsumerWidget`, `ref.watch()` in build, `ref.read()` in callbacks, `AsyncNotifierProvider`, always handle `.when(data:, loading:, error:)`

**Provider** → `context.watch<T>()` in build, `Selector<T,R>` not full `Consumer<T>`, `notifyListeners()` after mutation, no `BuildContext` in `ChangeNotifier`

### Navigation

- `context.go()` vs `context.push()` vs `context.replace()` used correctly
- `PopScope` (not `WillPopScope`) with `canPop` and `onPopInvokedWithResult`
- `StatefulShellRoute` for persistent tab navigation
- Route guards via GoRouter `redirect` callback

### Animations

- Only animates `transform` and `opacity` (GPU-safe) — never `width`, `height`, `margin`
- `RepaintBoundary` on all complex painters and isolated animations
- `AnimationController` always disposed
- Easing curves always applied — no linear or zero-duration animations

### Performance

- `const` constructors on all `StatelessWidget`s
- `ListView.builder` for any list
- `select()` / `Selector` to prevent over-rebuilding
- No heavy work in `build()`

---

## Mandatory Checkpoint

Before writing any Flutter UI code, Claude fills this checkpoint:

```
🧠 FLUTTER CHECKPOINT:

State:      [ Riverpod / Provider / BLoC / Vanilla ]
Navigation: [ GoRouter / auto_route / Navigator 1.0 ]
Design:     [ Material 3 / Cupertino / Custom ]
Platforms:  [ Mobile / Tablet / Desktop / Web ]
Files Read: [ flutter-design-thinking.md, flutter-state-ui.md, ... ]

3 Rules I Will Apply:
1. ConsumerWidget + ref.watch() in build
2. Transform.scale not width animation
3. PopScope at root with canPop: false

Anti-Patterns I Will Avoid:
1. WillPopScope → PopScope
2. Hardcoded Color() → colorScheme.*
```

---

## Troubleshooting

**Skill not loading?**
- Confirm the folder is at `~/.claude/skills/flutter-ui/` (not nested deeper)
- Confirm `SKILL.md` exists inside it
- Restart Claude Code

**Audit script finds nothing?**
- Make sure you point it at a directory containing `lib/` (Flutter project root)
- Run with `--all` to see info-level findings

**Wrong state manager rules applied?**
- Check that your `pubspec.yaml` dependencies and `import` statements are present
- Tell Claude explicitly: "use Riverpod" or "use Provider"

---

## Pre-Release Checklist

Before shipping any screen built with this skill:

- [ ] `flutter analyze` — zero missing `const` warnings
- [ ] Audit script — zero 🔴 findings
- [ ] Android back button tested — no stuck screens
- [ ] iOS swipe-back tested — no gesture conflicts
- [ ] Dark mode tested — no hardcoded colors
- [ ] Tablet layout tested — no overflow
- [ ] All `AsyncValue.when()` handle error state with retry
- [ ] All `AnimationController`s disposed
- [ ] All `ChangeNotifier`s dispose resources

---

## License

MIT — free to use, modify, and distribute.

---

## About DevCenter

Prepared by **[DevCenter](https://devcenter.dev)** — tools, skills, and resources for modern software development.

If this skill saved you time, share it with your team or star the repo.
