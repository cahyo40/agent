---
description: Implementasi internationalization (i18n) untuk Flutter dengan multiple language support. (Part 4/4)
---
# Workflow: Translation & Localization (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Add Dependencies**
   - Tambahkan `easy_localization` dan `intl` ke pubspec.yaml
   - Update assets configuration
   - Run `flutter pub get`

2. **Create Translation Files**
   - Buat folder `assets/translations/`
   - Buat JSON file untuk setiap bahasa
   - Definisikan semua keys dan translations

3. **Initialize in Bootstrap**
   - Update `bootstrap.dart` dengan EasyLocalization wrapper
   - Define supported locales
   - Set fallback locale

4. **Configure MaterialApp**
   - Update `app.dart` dengan localization delegates
   - Use `.tr()` untuk app title

5. **Create Locale Controller**
   - Buat `locale_controller.dart` dengan Riverpod
   - Implement change locale functionality
   - Add helper methods untuk language names dan flags

6. **Create Language Selector Widget**
   - Buat popup menu atau bottom sheet selector
   - Display flags dan language names
   - Handle locale change

7. **Add to Screens**
   - Add LanguageSelector ke app bar atau settings
   - Replace all hardcoded strings dengan `.tr()`
   - Test semua translations

8. **Test Localization**
   - Test ganti bahasa
   - Verify all strings translated
   - Check RTL support (jika diperlukan)
   - Test persistence (locale tersimpan)


## Success Criteria

- [ ] Dependencies terinstall tanpa error
- [ ] Translation files created untuk semua languages
- [ ] Easy Localization initialized correctly
- [ ] Locale controller berfungsi
- [ ] Language selector widget berfungsi
- [ ] All screens menggunakan `.tr()` method
- [ ] Locale persist between app restarts
- [ ] Fallback locale berfungsi jika translation missing
- [ ] No hardcoded strings in UI
- [ ] Semua bahasa bisa diganti dengan lancar


## Best Practices

### ✅ DO:
- ✅ Organize translations by feature/module
- ✅ Use nested keys (e.g., `login.title`)
- ✅ Provide fallback locale
- ✅ Test all supported languages
- ✅ Use context-appropriate translations
- ✅ Support RTL languages if needed
- ✅ Save locale preference
- ✅ Use pluralization untuk count strings

### ❌ DON'T:
- ❌ Hardcode strings di UI
- ❌ Mix languages dalam satu translation file
- ❌ Forget to add new keys ke semua language files
- ❌ Use machine translation tanpa review
- ❌ Ignore text overflow dengan different languages
- ❌ Forget to test dengan longest translations


## Tools & Resources

- **easy_localization**: https://pub.dev/packages/easy_localization
- **intl**: https://pub.dev/packages/intl
- **Flutter Localization**: https://docs.flutter.dev/ui/accessibility-and-internationalization


## Next Steps

Setelah translation setup:
1. Add more languages sesuai kebutuhan
2. Implement RTL support jika diperlukan
3. Add date/number formatting dengan intl
4. Consider using translation management tools (e.g., Localizely, POEditor)

---

**Catatan**: Translation sebaiknya diimplementasikan sejak awal project untuk menghindari refactoring yang rumit di kemudian hari.
