# YoUI Navigation Components

## YoAppbar

```dart
YoAppbar(
  title: 'Page Title',
  actions: [
    YoIconButton(icon: Icons.search, onPressed: () {}),
    YoIconButton(icon: Icons.more_vert, onPressed: () {}),
  ],
)

YoAppbar.transparent(title: 'Overlay Title')
```

## YoBottomNav

```dart
YoBottomNav(
  currentIndex: selectedIndex,
  onTap: (index) => setState(() => selectedIndex = index),
  items: [
    YoBottomNavItem(icon: Icons.home, label: 'Home'),
    YoBottomNavItem(icon: Icons.search, label: 'Search'),
    YoBottomNavItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

## YoDrawer

```dart
YoDrawer(
  header: YoDrawerHeader(
    avatar: 'https://...',
    name: 'John Doe',
    email: 'john@example.com',
  ),
  items: [
    YoDrawerItem(icon: Icons.home, title: 'Home', onTap: () {}),
    YoDrawerItem(icon: Icons.settings, title: 'Settings', onTap: () {}),
  ],
)
```

## YoStepper

```dart
YoStepper(
  currentStep: currentStep,
  type: YoStepperType.vertical, // atau horizontal
  steps: [
    YoStep(title: 'Account', content: AccountForm()),
    YoStep(title: 'Address', content: AddressForm()),
    YoStep(title: 'Payment', content: PaymentForm()),
  ],
  onStepContinue: () => nextStep(),
  onStepCancel: () => prevStep(),
)
```

## YoPagination

```dart
YoPagination(
  currentPage: currentPage,
  totalPages: totalPages,
  onPageChanged: (page) => loadPage(page),
)
```

## YoBreadcrumb

```dart
YoBreadcrumb(
  items: [
    YoBreadcrumbItem(label: 'Home', onTap: () => goHome()),
    YoBreadcrumbItem(label: 'Products', onTap: () => goProducts()),
    YoBreadcrumbItem(label: 'Detail'),  // current (no onTap)
  ],
)
```

## YoTabbar

```dart
YoTabbar(
  tabs: ['Overview', 'Reviews', 'Related'],
  onChanged: (index) => switchTab(index),
)
```

## YoSidebar

```dart
YoSidebar(
  items: [
    YoSidebarItem(icon: Icons.dashboard, label: 'Dashboard'),
    YoSidebarItem(icon: Icons.people, label: 'Users'),
    YoSidebarItem(icon: Icons.settings, label: 'Settings'),
  ],
  selectedIndex: currentIndex,
  onItemTap: (index) => navigate(index),
)
```

## YoInfiniteScroll (Utility)

```dart
YoInfiniteScroll(
  onLoadMore: () => loadMoreItems(),
  hasMore: hasNextPage,
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => ItemCard(items[i]),
  ),
)
```
