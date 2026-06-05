---
description: Tambah dukungan bahasa baru ke Flutter UI Kit. ARB translation, locale registration, gen-l10n, RTL support, dan testing.
---
# 04 — Add Locale: Flutter UI Kit

## Overview
Tambah dukungan bahasa baru ke package.

**Recommended Skills:** `senior-flutter-developer`, `internationalization-specialist`

## Agent Behavior

### i18n Rules
- Semua keys dari `app_en.arb` WAJIB di-translate — tidak boleh ada yang tertinggal
- Default labels komponen (button text, hints, validation) = localized via ARB
- User-passed strings (label, title) = override, TIDAK perlu di-localize
- Format date/number/currency menggunakan `intl` package
- Min. 2 bahasa: English (default) + Bahasa Indonesia (sudah ada dari init)

### Input Interpretation
```
/add-locale ja   → Japanese
/add-locale zh   → Chinese Simplified
/add-locale ko   → Korean
/add-locale es   → Spanish
/add-locale ar   → Arabic (RTL!)
/add-locale de   → German
```

### ARB Keys (Template — English)
Semua keys ini WAJIB ada di setiap locale:
```
buttonLoading, buttonRetry, buttonCancel, buttonConfirm,
buttonSave, buttonDelete, buttonEdit, buttonClose, buttonBack, buttonNext,
dialogAlertTitle, dialogConfirmTitle, dialogDeleteMessage,
searchHint, searchNoResults, searchClear,
emptyStateTitle, emptyStateDescription,
validationRequired, validationEmail, validationMinLength
```

---

## Steps

### Step 1: Check Existing Locales
```
1. Baca lib/src/l10n/arb/ → list existing ARB files
2. Baca lib/src/l10n/l10n.dart → list supported locales
3. Baca app_en.arb → extract ALL keys (template)
4. Check: apakah locale = RTL language (ar, he, fa, ur)?
```

### Step 2: Create ARB File
Copy template dan translate SEMUA keys:
```bash
cp lib/src/l10n/arb/app_en.arb lib/src/l10n/arb/app_<locale>.arb
```

**Japanese (ja):**
```json
{
  "@@locale": "ja",
  "buttonLoading": "読み込み中...",
  "buttonRetry": "再試行",
  "buttonCancel": "キャンセル",
  "buttonConfirm": "確認",
  "buttonSave": "保存",
  "buttonDelete": "削除",
  "buttonEdit": "編集",
  "buttonClose": "閉じる",
  "buttonBack": "戻る",
  "buttonNext": "次へ",
  "dialogAlertTitle": "警告",
  "dialogConfirmTitle": "よろしいですか？",
  "dialogDeleteMessage": "この操作は元に戻せません。",
  "searchHint": "検索...",
  "searchNoResults": "結果が見つかりません",
  "searchClear": "クリア",
  "emptyStateTitle": "まだ何もありません",
  "emptyStateDescription": "最初のアイテムを追加してください",
  "validationRequired": "この項目は必須です",
  "validationEmail": "有効なメールアドレスを入力してください",
  "validationMinLength": "{length}文字以上で入力してください",
  "@validationMinLength": {
    "placeholders": { "length": { "type": "int" } }
  }
}
```

**Arabic (ar) — RTL:**
```json
{
  "@@locale": "ar",
  "buttonLoading": "جاري التحميل...",
  "buttonCancel": "إلغاء",
  "buttonConfirm": "تأكيد",
  "dialogAlertTitle": "تنبيه",
  "dialogConfirmTitle": "هل أنت متأكد؟",
  "searchHint": "بحث...",
  "emptyStateTitle": "لا يوجد شيء هنا بعد"
}
```

### Step 3: Update Supported Locales
`lib/src/l10n/l10n.dart`:
```dart
static const supportedLocales = [
  Locale('en'),
  Locale('id'),
  Locale('ja'),    // ← added
];
```

### Step 4: Regenerate Localizations
```bash
flutter gen-l10n
```

### Step 5: RTL Support (Arabic/Hebrew only)
Jika locale = `ar`, `he`, `fa`, `ur`:
- Verify komponen menggunakan `EdgeInsetsDirectional` (bukan `EdgeInsets`)
- Verify `TextDirection.rtl` di-support
- Test layout mirroring

```dart
testWidgets('AppButton supports RTL', (tester) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('ar'),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: AppButton(text: 'إرسال', onPressed: () {}),
    ),
  ));
});
```

### Step 6: Write Tests
```dart
group('Japanese Locale', () {
  test('all keys present', () { /* compare key sets with English */ });
  test('no English leftover', () { /* check no English in ja values */ });
  test('placeholders preserved', () { /* {length} exists */ });
  testWidgets('components render', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(body: AppDialog(/* ... */)),
    ));
    expect(find.text('キャンセル'), findsOneWidget);
  });
});
```

### Step 7: Commit
```bash
dart format lib/src/l10n/
dart analyze
flutter test test/l10n/
git add .
git commit -m "feat(i18n): add Japanese (ja) locale support"
```

## Quality Gate
- [ ] ARB file — all keys from template present
- [ ] `@@locale` tag correct
- [ ] No English text leftover
- [ ] Placeholder variables preserved
- [ ] `supportedLocales` updated
- [ ] `flutter gen-l10n` succeeds
- [ ] RTL verified (if Arabic/Hebrew)
- [ ] Tests pass
- [ ] Git committed

## Next Step
→ `05_run_quality_check.md` atau → `02_add_component.md`
