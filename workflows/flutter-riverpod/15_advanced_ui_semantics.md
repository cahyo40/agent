---
description: Implementasi animasi kompleks, slivers untuk custom scrolling, dan memastikan aksesibilitas (semantics) aplikasi.
---
# Workflow: Advanced UI & Semantics

// turbo-all

## Overview

Mengimplementasikan pola UI tingkat lanjut yang sering digunakan di aplikasi production: CustomScrollView (Slivers) untuk layout scrolling kompleks, animasi (implicit & explicit), dan aksesibilitas (A11y/Semantics) agar aplikasi ramah untuk semua pengguna.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- UI Components dari `03_ui_components.md` tersedia


## Agent Behavior

- **Gunakan Slivers** untuk efek scroll yang kompleks (SliverAppBar, parallax).
- **Semantics widget** wajib digunakan untuk screen read capability.
- **Hindari re-render** besar saat animasi berjalan (gunakan `RepaintBoundary` jika perlu).
- **Gunakan Implicit Animations** (AnimatedContainer, AnimatedOpacity) jika memungkinkan.


## Recommended Skills

- `senior-ui-ux-designer` — Accessibility & animation guidelines
- `web-animation-specialist` — Micro-interactions & animations


## Workflow Steps

### Step 1: Accessibility (Semantics)

Pastikan semua UI widget custom dibungkus dengan `Semantics` agar bisa terbaca oleh TalkBack (Android) atau VoiceOver (iOS).

```dart
// lib/core/widgets/accessible_button.dart
import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.hint,
  });

  final String label;
  final VoidCallback onPressed;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: label,
      hint: hint ?? 'Ketuk untuk mengeksekusi',
      excludeSemantics: true, // Hide children from screen reader
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
```

### Step 2: CustomScrollView & Slivers

Membangun Collapsing App Bar dengan CustomScrollView. Sangat berguna untuk profile page atau product detail.

```dart
// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('John Doe'),
              background: Image.network(
                'https://picsum.photos/seed/picsum/500/300',
                fit: BoxFit.cover,
                semanticsLabel: 'Profile background image',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Semantics(
                header: true,
                child: Text(
                  'About Me',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text('Activity Item $index'),
                  subtitle: Text('Details of activity $index'),
                  onTap: () {},
                );
              },
              childCount: 20, // Simulasi list item
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Implicit Animations

Gunakan `Animated...` widgets untuk state changes sederhana (size, color, opactiy).

```dart
// lib/features/home/presentation/widgets/favorite_button.dart
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(_isFavorite),
            color: _isFavorite ? Colors.red : Colors.grey,
          ),
        ),
      ),
    );
  }
}
```

### Step 4: Pagination dengan Slivers

Riverpod + ListView/SliverList untuk Infinite Scroll Pagination.

```dart
// lib/features/feed/presentation/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Asumsi ada feedProvider yang menghasilkan AsyncValue<List<Post>>

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger fetch next page
      // ref.read(feedProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // val feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: RefreshIndicator(
        onRefresh: () async {
          // await ref.read(feedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverPadding( ... list builder )
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(), // Loading indicator di bawah
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: RepaintBoundary (Performance Optimization)

Gunakan RepaintBoundary pada elemen statis dengan paint kompleks agar framework tidak melakukan render ulang (repaint) pada widget tree parent saat scroll.

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: ComplexPainter(),
    child: const SizedBox(width: 200, height: 200),
  ),
)
```


## Success Criteria

- [ ] CustomScrollView berjalan smooth tanpa janking (60fps).
- [ ] Tombol dan konten penting terbaca oleh Screen Reader (Aksesibilitas).
- [ ] Transisi `favorite` menggunakan animasi smooth (Implicit Animations).
- [ ] Pull-to-refresh dan infinite scrolling ter-handle secara baik.
- [ ] Layer animasi/paint kompleks terisolasi di dalam `RepaintBoundary`.


## Next Steps

Setelah setup UI lanjutan:
1. Pastikan performance metrics baik menggunakan DevTools Profiler (Lihat `12_performance_monitoring.md`).
2. Terapkan Isolate untuk handling API response besar agar main thread UI tidak tersendat (`16_background_processing.md`).
