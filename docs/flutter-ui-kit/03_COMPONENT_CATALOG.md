# Component Catalog & Priority
## Flutter UI Kit - Complete Component List

| Document Info | Details |
|---------------|---------|
| **Product** | Flutter UI Kit |
| **Version** | 1.0.0 |
| **Created** | February 24, 2026 |
| **Total Components** | 50+ |

---

## Component Priority Legend

| Priority | Description | Timeline |
|----------|-------------|----------|
| **P0** | Critical - MVP Required | Week 1-4 |
| **P1** | High - Core Features | Week 5-8 |
| **P2** | Medium - Enhanced UX | Month 3 |
| **P3** | Low - Nice to Have | Month 4+ |

---

## 1. Button Components (8 variants)

### P0 - Critical

| Component | Variants | Description | Complexity |
|-----------|----------|-------------|------------|
| **AppButton** | Primary, Secondary, Outline, Ghost, Destructive | Main button component with full customization | Medium |

```dart
// API Preview
AppButton(
  text: 'Submit',
  variant: ButtonVariant.primary,  // primary | secondary | outline | ghost | destructive
  size: ButtonSize.medium,         // small | medium | large
  isLoading: false,
  isDisabled: false,
  icon: Icons.arrow_forward,
  onPressed: () {},
)
```

### P1 - Enhanced

| Component | Variants | Description | Complexity |
|-----------|----------|-------------|------------|
| **AppIconButton** | Standard, Floating, Mini | Icon-only button | Low |
| **AppButtonGroup** | Horizontal, Vertical | Grouped buttons with shared borders | Medium |

### P2 - Specialized

| Component | Variants | Description | Complexity |
|-----------|----------|-------------|------------|
| **AppSocialButton** | Google, Facebook, Apple, GitHub | Pre-styled social auth buttons | Low |
| **AppPaymentButton** | Visa, Mastercard, PayPal, GPay | Payment method buttons | Low |

---

## 2. Input Components (12 variants)

### P0 - Critical

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppTextField** | Text input with label, hint, error states | Medium |
| **AppCheckbox** | Single checkbox with label | Low |
| **AppRadio** | Single radio button | Low |
| **AppSwitch** | Toggle switch | Low |
| **AppDropdown** | Dropdown select | Medium |

```dart
// API Preview - TextField
AppTextField(
  controller: controller,
  label: 'Email',
  hint: 'Enter your email',
  errorText: 'Invalid email format',
  prefixIcon: Icons.email,
  suffixIcon: Icons.check_circle,
  obscureText: false,
  keyboardType: TextInputType.emailAddress,
  enabled: true,
  onChanged: (value) {},
)

// API Preview - Checkbox
AppCheckbox(
  value: true,
  label: 'I agree to terms',
  onChanged: (value) {},
)

// API Preview - Switch
AppSwitch(
  value: true,
  label: 'Enable notifications',
  onChanged: (value) {},
)
```

### P1 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppSearchField** | Search input with clear button | Low |
| **AppPasswordField** | Password input with show/hide toggle | Low |
| **AppNumberField** | Numeric input with +/- buttons | Medium |
| **AppRadioGroup** | Vertical/Horizontal radio group | Low |
| **AppCheckboxGroup** | Multiple checkbox selection | Low |

### P2 - Specialized

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppPhoneNumberField** | Phone input with country code | High |
| **AppOtpField** | OTP input (4-6 digits) | Medium |
| **AppTagInput** | Input with tags/chips | High |

---

## 3. Card Components (6 variants)

### P0 - Critical

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppCard** | Basic card container | Low |
| **AppImageCard** | Card with image header | Low |

```dart
// API Preview
AppCard(
  elevation: 2,
  padding: EdgeInsets.all(16),
  borderRadius: 12,
  child: Column(
    children: [...],
  ),
)

AppImageCard(
  imageUrl: 'https://...',
  title: 'Card Title',
  subtitle: 'Card subtitle',
  actions: [IconButton(...)],
)
```

### P1 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppExpandableCard** | Expandable/collapsible card | Medium |
| **AppSwipeCard** | Swipeable card (Tinder-style) | High |

### P2 - Specialized

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppProductCard** | E-commerce product card | Medium |
| **AppProfileCard** | User profile card | Low |

---

## 4. Navigation Components (8 variants)

### P1 - High Priority

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppBar** | Custom app bar with actions | Medium |
| **AppBottomNavigationBar** | Bottom navigation (3-5 items) | Medium |
| **AppNavigationBar** | Rail navigation (tablet/desktop) | Medium |
| **AppDrawer** | Side navigation drawer | Medium |
| **AppTabBar** | Tab bar with indicators | Low |
| **AppBreadcrumb** | Breadcrumb navigation | Low |

```dart
// API Preview - Bottom Nav
AppBottomNavigationBar(
  items: [
    BottomNavItem(icon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.search, label: 'Search'),
    BottomNavItem(icon: Icons.person, label: 'Profile'),
  ],
  currentIndex: 0,
  onTap: (index) {},
)
```

### P2 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppStepper** | Step progress indicator | Medium |
| **AppPagination** | Page number pagination | Low |

---

## 5. Feedback Components (8 variants)

### P0 - Critical

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppSnackBar** | Snack bar messages | Low |
| **AppDialog** | Alert/Confirmation dialogs | Medium |
| **AppBottomSheet** | Modal bottom sheet | Medium |
| **AppLoadingIndicator** | Circular/Linear progress | Low |

```dart
// API Preview
AppSnackBar.show(
  context,
  message: 'Success!',
  type: SnackBarType.success,  // success | error | warning | info
  duration: Duration(seconds: 3),
)

AppDialog.show(
  context,
  title: 'Confirm',
  content: 'Are you sure?',
  confirmText: 'Yes',
  cancelText: 'No',
  onConfirm: () {},
  onCancel: () {},
)
```

### P1 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppBanner** | Inline banner messages | Low |
| **AppBadge** | Status badge/ribbon | Low |
| **AppProgressBar** | Determinate progress bar | Low |
| **AppSkeleton** | Loading skeleton | Medium |

### P2 - Specialized

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppToast** | Toast notifications | Medium |
| **AppNotification** | In-app notification | Medium |

---

## 6. Data Display Components (10 variants)

### P1 - High Priority

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppDataTable** | Data table with sorting | High |
| **AppListTile** | List item tile | Low |
| **AppChip** | Chip/tag component | Low |
| **AppAvatar** | User avatar with fallback | Low |
| **AppBadge** | Count badge | Low |
| **AppEmptyState** | Empty state illustration | Low |

```dart
// API Preview
AppListTile(
  title: 'Title',
  subtitle: 'Subtitle',
  leading: Avatar(...),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)

AppChip(
  label: 'Flutter',
  onDelete: () {},
  variant: ChipVariant.filled,  // filled | outlined
)

AppAvatar(
  imageUrl: 'https://...',
  name: 'John Doe',
  size: AvatarSize.medium,  // small | medium | large
  onTap: () {},
)
```

### P2 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppTimeline** | Timeline/Activity feed | High |
| **AppStatisticCard** | Stats/metrics display | Low |
| **AppRatingBar** | Star rating display | Low |
| **AppProgressRing** | Circular progress | Low |

---

## 7. Layout Components (6 variants)

### P1 - High Priority

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppContainer** | Styled container | Low |
| **AppSpacer** | Flexible spacer | Low |
| **AppDivider** | Horizontal/vertical divider | Low |
| **AppGrid** | Responsive grid | Medium |

### P2 - Enhanced

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppResponsiveLayout** | Adaptive layout | High |
| **AppAspectRatio** | Constrained aspect ratio | Low |

---

## 8. Specialized Components (8 variants)

### P2 - Medium Priority

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppDatePicker** | Date picker dialog | Medium |
| **AppTimePicker** | Time picker dialog | Medium |
| **AppRatingInput** | Star rating input | Low |
| **AppSlider** | Range slider | Medium |
| **AppSegmentedControl** | iOS-style segmented control | Low |

### P3 - Future

| Component | Description | Complexity |
|-----------|-------------|------------|
| **AppSignaturePad** | Signature input | High |
| **AppImagePicker** | Image selection/upload | Medium |
| **AppMapPicker** | Location picker | High |
| **AppFileUploader** | File upload with progress | High |

---

## Component Development Checklist

### For Each Component

```markdown
## Pre-Development
- [ ] API design finalized
- [ ] Variants defined
- [ ] Edge cases identified

## Development
- [ ] Component implemented
- [ ] All variants working
- [ ] States handled (loading, disabled, error, empty)
- [ ] Responsive tested
- [ ] Dark mode tested

## Quality
- [ ] Widget tests written (>80% coverage)
- [ ] Accessibility checked (semantics, contrast)
- [ ] Performance profiled
- [ ] dartdoc comments complete

## Documentation
- [ ] Example in demo app
- [ ] README section updated
- [ ] Code snippets prepared
- [ ] Screenshot captured
```

---

## Component Complexity Matrix

| Complexity | Count | Estimated Time |
|------------|-------|----------------|
| **Low** | 25 | 2-4 hours each |
| **Medium** | 18 | 4-8 hours each |
| **High** | 7 | 8-16 hours each |
| **Total** | 50 | ~200-300 hours |

---

## MVP Component List (Week 1-8)

### Phase 1: Core (Week 1-4)
- [ ] AppButton (5 variants)
- [ ] AppTextField
- [ ] AppCheckbox, AppRadio, AppSwitch
- [ ] AppCard (2 variants)
- [ ] AppSnackBar
- [ ] AppDialog
- [ ] AppLoadingIndicator
- [ ] AppAvatar
- [ ] AppChip

### Phase 2: Enhanced (Week 5-8)
- [ ] AppDropdown
- [ ] AppSearchField, AppPasswordField
- [ ] AppBottomNavigationBar
- [ ] AppTabBar
- [ ] AppBottomSheet
- [ ] AppListTile
- [ ] AppEmptyState
- [ ] AppSkeleton
- [ ] AppBanner, AppBadge

**Total MVP: 20+ components**

---

## Future Roadmap (Month 3+)

### Month 3: Advanced
- AppDataTable
- AppStepper
- AppTimeline
- AppDatePicker, AppTimePicker
- AppSlider

### Month 4+: Specialized
- AppPhoneNumberField
- AppOtpField
- AppProductCard
- AppProfileCard
- AppSignaturePad

---

## Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Owner | TBD | Draft | Feb 24, 2026 |
| Technical Lead | TBD | Pending | - |

---

**Document Version History**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1.0 | Feb 24, 2026 | TBD | Initial draft |
