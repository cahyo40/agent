# yo.dart Generator Commands

## Quick Reference

### Project Init

```bash
dart run yo.dart init --state=riverpod    # Riverpod (recommended)
dart run yo.dart init --state=getx        # GetX
dart run yo.dart init --state=bloc        # BLoC
```

### Page (Full Clean Architecture)

```bash
dart run yo.dart page:home                     # Simple page
dart run yo.dart page:auth.login               # Sub-feature (dot notation)
dart run yo.dart page:splash --presentation-only  # UI layer only
dart run yo.dart page:cart --dry-run            # Preview tanpa menulis
dart run yo.dart page:home --force              # Overwrite existing
```

### Model & Entity

```bash
dart run yo.dart model:user                    # Basic model
dart run yo.dart model:user --freezed          # With freezed
dart run yo.dart model:user --feature=auth     # In specific feature
dart run yo.dart entity:user --feature=auth    # Entity class
```

### Controller / Provider / BLoC

```bash
dart run yo.dart controller:auth               # Sesuai yo.yaml
dart run yo.dart controller:auth --cubit        # Cubit (bloc only)
dart run yo.dart controller:auth --feature=user # In specific feature
```

### Data Layer

```bash
dart run yo.dart datasource:auth --remote      # Remote only
dart run yo.dart datasource:auth --local        # Local only
dart run yo.dart datasource:auth --both         # Both
dart run yo.dart datasource:auth --feature=auth

dart run yo.dart repository:auth --feature=auth
dart run yo.dart usecase:login --feature=auth
```

### Infrastructure

```bash
dart run yo.dart network                       # Dio client + interceptors
dart run yo.dart network --force

dart run yo.dart di                             # Dependency injection
dart run yo.dart di --force
```

### UI Components

```bash
dart run yo.dart screen:profile --feature=user
dart run yo.dart dialog:confirm --feature=common
dart run yo.dart widget:avatar --feature=user
dart run yo.dart widget:avatar --global         # Global widget
dart run yo.dart service:auth
```

### Testing

```bash
dart run yo.dart test:auth --feature=auth       # All tests
dart run yo.dart test:auth --unit               # Unit only
dart run yo.dart test:auth --widget             # Widget only
dart run yo.dart test:auth --provider           # Provider/controller
dart run yo.dart test:auth --force
```

### Utilities

```bash
dart run yo.dart barrel feature:auth            # Barrel files
dart run yo.dart translation --key=welcome --en="Welcome" --id="Selamat Datang"
dart run yo.dart package-name:com.company.app
dart run yo.dart app-name:"My App"
dart run yo.dart delete:auth --delete-feature
```

### Interactive Mode

```bash
dart run yo.dart --interactive                  # Wizard mode
dart run yo.dart -i
```

## Global Flags

| Flag | Description |
|------|-------------|
| `--force` | Overwrite existing files |
| `--dry-run` | Preview tanpa menulis file |
| `--presentation-only` | UI layer saja |
| `--freezed` | Gunakan freezed untuk model |
| `--feature=<name>` | Tentukan feature target |
| `--global` | Generate di folder global |
| `--interactive` / `-i` | Mode interaktif |
| `--cubit` | Generate cubit (bloc only) |
| `--remote` / `--local` / `--both` | Tipe datasource |

## Naming Convention

| Input | Class | File | Feature Folder |
|-------|-------|------|----------------|
| `home` | `Home` | `home.dart` | `features/home/` |
| `setting.profile` | `SettingProfile` | `setting_profile.dart` | `features/setting/` |
| `user.auth.login` | `UserAuthLogin` | `user_auth_login.dart` | `features/user/` |

## yo.yaml

```yaml
# Created by yo init
project_name: my_app
state_management: riverpod  # riverpod | bloc | getx
use_freezed: true
use_go_router: true
localization:
  - en
  - id
```
