# YoUI Display Components

## YoText

```dart
// Variants
YoText('Regular text')
YoText.heading('Page Title')              // headline
YoText.headlineLarge('Large Title')
YoText.headlineMedium('Medium Title')
YoText.bodyMedium('Body text')
YoText.bodySmall('Caption text')
YoText.label('Label')

// With style
YoText('Custom',
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

## YoProductCard

```dart
YoProductCard(
  imageUrl: 'https://...',
  title: 'Product Name',
  price: 99.99,
  originalPrice: 129.99,      // optional, shows strikethrough
  stock: 15,
  onTap: () {},
)
```

## YoProfileCard

```dart
YoProfileCard.cover(
  avatarUrl: 'https://...',
  name: 'John Doe',
  subtitle: 'Flutter Developer',
  stats: [
    YoProfileStat(value: '1.2K', label: 'Followers'),
    YoProfileStat(value: '340', label: 'Posts'),
  ],
  onTap: () {},
)
```

## YoArticleCard

```dart
YoArticleCard.featured(
  imageUrl: 'https://...',
  title: 'Article Title',
  excerpt: 'Short description...',
  category: 'Tech',
  author: 'John',
  readTime: 5,
  onTap: () {},
)
```

## YoDestinationCard

```dart
YoDestinationCard.featured(
  imageUrl: 'https://...',
  title: 'Bali',
  location: 'Indonesia',
  rating: 4.8,
  price: 1200,
  onTap: () {},
)
```

## YoCarousel

```dart
YoCarousel(
  images: ['url1', 'url2', 'url3'],
  autoPlay: true,
  height: 200,
  onPageChanged: (index) {},
)
```

## YoDataTable

```dart
YoDataTable(
  columns: [
    YoDataColumn(label: 'Name', sortable: true),
    YoDataColumn(label: 'Email'),
    YoDataColumn(label: 'Role'),
  ],
  rows: data.map((item) => YoDataRow(
    cells: [
      YoDataCell(text: item.name),
      YoDataCell(text: item.email),
      YoDataCell(text: item.role),
    ],
  )).toList(),
  onSort: (column, ascending) {},
)
```

## YoAvatar

```dart
YoAvatar(url: 'https://...', radius: 24)
YoAvatar.initials('JD', radius: 24)
```

## YoAvatarOverlap

```dart
YoAvatarOverlap(
  avatars: ['url1', 'url2', 'url3'],
  maxDisplay: 3,
  size: 36,
)
```

## YoBadge

```dart
YoBadge(count: 5, child: Icon(Icons.notifications))
YoBadge.dot(child: Icon(Icons.mail))
```

## YoChip

```dart
YoChip(label: 'Flutter', onDeleted: () {})
YoChip.action(label: 'Filter', onTap: () {})
```

## YoRating

```dart
YoRating(
  value: 4.5,
  onChanged: (rating) {},
  maxRating: 5,
)
```

## YoTimeline

```dart
YoTimeline(
  items: [
    YoTimelineItem(title: 'Order Placed', subtitle: '10:00 AM'),
    YoTimelineItem(title: 'Processing', subtitle: '10:30 AM'),
    YoTimelineItem(title: 'Shipped', subtitle: '2:00 PM'),
  ],
)
```

## YoAccordion

```dart
YoAccordion(
  title: 'FAQ Question',
  content: YoText('Answer text here'),
)
```

## YoExpandableText

```dart
YoExpandableText(
  text: 'Very long text content...',
  maxLines: 3,
)
```

## YoChatBubble

```dart
YoChatBubble(
  message: 'Hello!',
  isMe: true,
  time: DateTime.now(),
)
```

## YoCalendar

```dart
YoCalendar(
  selectedDate: DateTime.now(),
  onDateSelected: (date) {},
)
```

## YoComment

```dart
YoComment(
  avatar: 'https://...',
  name: 'User',
  text: 'Great post!',
  time: DateTime.now(),
)
```

## YoKanbanBoard

```dart
YoKanbanBoard(
  columns: [
    YoKanbanColumn(title: 'To Do', items: [...]),
    YoKanbanColumn(title: 'In Progress', items: [...]),
    YoKanbanColumn(title: 'Done', items: [...]),
  ],
)
```

## YoListTile

```dart
YoListTile(
  title: 'Item Title',
  subtitle: 'Description',
  leading: YoAvatar(url: '...'),
  trailing: YoIconButton(icon: Icons.more_vert),
  onTap: () {},
)
```
