# Animation Mastery

## Animation Types Overview

```
FLUTTER ANIMATION TYPES
├── IMPLICIT ANIMATIONS (Easy)
│   ├── AnimatedContainer
│   ├── AnimatedOpacity
│   ├── AnimatedPositioned
│   └── AnimatedSwitcher
│
├── EXPLICIT ANIMATIONS (More Control)
│   ├── AnimationController
│   ├── Tween + AnimatedBuilder
│   ├── AnimatedWidget
│   └── TweenAnimationBuilder
│
├── PHYSICS-BASED
│   ├── SpringSimulation
│   ├── GravitySimulation
│   └── FrictionSimulation
│
└── HERO & PAGE TRANSITIONS
    ├── Hero widget
    ├── PageRouteBuilder
    └── CustomTransitionPage
```

## Implicit Animations

### AnimatedContainer

```dart
class AnimatedCard extends StatefulWidget {
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: _isExpanded ? 300 : 200,
        height: _isExpanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _isExpanded ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(_isExpanded ? 16 : 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isExpanded ? 0.3 : 0.1),
              blurRadius: _isExpanded ? 20 : 5,
              offset: Offset(0, _isExpanded ? 10 : 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
```

### AnimatedSwitcher

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
  child: _showFirst
      ? const Text('First', key: ValueKey('first'))
      : const Text('Second', key: ValueKey('second')),
)
```

## Explicit Animations

### AnimationController with Tween

```dart
class PulsingButton extends StatefulWidget {
  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Tap Me'),
      ),
    );
  }
}
```

### Staggered Animation

```dart
class StaggeredList extends StatefulWidget {
  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  Animation<double> _getDelayedAnimation(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.2).clamp(0.0, 1.0);
    
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final animation = _getDelayedAnimation(index);
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: child,
              ),
            );
          },
          child: ListTile(title: Text('Item $index')),
        );
      },
    );
  }
}
```

## Custom Painter Animation

```dart
class AnimatedProgressRing extends StatefulWidget {
  const AnimatedProgressRing({required this.progress});
  final double progress;

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(100, 100),
          painter: ProgressRingPainter(
            progress: widget.progress * _controller.value,
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  ProgressRingPainter({required this.progress, required this.color});
  
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

## Page Transitions

```dart
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

  final Widget page;
}

// With GoRouter
GoRoute(
  path: '/detail',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: DetailScreen(),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeIn).animate(animation),
        child: child,
      );
    },
  ),
)
```
