---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 1/7)
---
# Workflow: Translation & Localization (GetX) (Part 3/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 2. Option A: GetX Built-in Translations (Recommended)

Pendekatan ini memanfaatkan class `Translations` bawaan GetX. Semua translation
string didefinisikan sebagai Dart Maps — type-safe, mudah di-refactor, dan tidak
butuh asset loading.

#### 2.1 Translation Maps per Bahasa

Setiap bahasa didefinisikan dalam file Dart terpisah yang meng-export sebuah
`Map<String, String>`. Gunakan **dot notation** untuk grouping keys supaya
terstruktur rapi.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/en_us.dart`

```dart
// lib/core/translations/en_us.dart

const Map<String, String> enUS = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'My Application',
  'app.description': 'A complete Flutter application with GetX',

  // Common actions
  'common.save': 'Save',
  'common.cancel': 'Cancel',
  'common.delete': 'Delete',
  'common.edit': 'Edit',
  'common.add': 'Add',
  'common.search': 'Search',
  'common.filter': 'Filter',
  'common.sort': 'Sort',
  'common.refresh': 'Refresh',
  'common.loading': 'Loading...',
  'common.retry': 'Retry',
  'common.confirm': 'Confirm',
  'common.back': 'Back',
  'common.next': 'Next',
  'common.done': 'Done',
  'common.close': 'Close',
  'common.yes': 'Yes',
  'common.no': 'No',
  'common.ok': 'OK',
  'common.submit': 'Submit',
  'common.continue': 'Continue',
  'common.skip': 'Skip',
  'common.select_all': 'Select All',
  'common.deselect_all': 'Deselect All',
  'common.no_data': 'No data available',
  'common.see_all': 'See All',
  'common.view_details': 'View Details',

  // Common labels
  'common.name': 'Name',
  'common.email': 'Email',
  'common.phone': 'Phone',
  'common.address': 'Address',
  'common.date': 'Date',
  'common.time': 'Time',
  'common.status': 'Status',
  'common.description': 'Description',
  'common.amount': 'Amount',
  'common.total': 'Total',
  'common.price': 'Price',
  'common.quantity': 'Quantity',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Login',
  'auth.logout': 'Logout',
  'auth.register': 'Register',
  'auth.forgot_password': 'Forgot Password?',
  'auth.reset_password': 'Reset Password',
  'auth.email_hint': 'Enter your email',
  'auth.password_hint': 'Enter your password',
  'auth.confirm_password': 'Confirm Password',
  'auth.login_success': 'Login successful',
  'auth.login_failed': 'Login failed. Please check your credentials.',
  'auth.register_success': 'Registration successful! Please log in.',
  'auth.logout_confirm': 'Are you sure you want to logout?',
  'auth.password_mismatch': 'Passwords do not match',
  'auth.welcome_back': 'Welcome back, @name!',
  'auth.new_user': 'New user? Create an account',
  'auth.existing_user': 'Already have an account? Login',
  'auth.or_continue_with': 'Or continue with',
  'auth.terms_agree': 'By continuing, you agree to our Terms of Service',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Home',
  'nav.profile': 'Profile',
  'nav.settings': 'Settings',
  'nav.notifications': 'Notifications',
  'nav.favorites': 'Favorites',
  'nav.history': 'History',
  'nav.help': 'Help & Support',
  'nav.about': 'About',
  'nav.dashboard': 'Dashboard',
  'nav.orders': 'Orders',
  'nav.products': 'Products',
  'nav.categories': 'Categories',
  'nav.cart': 'Cart',
  'nav.checkout': 'Checkout',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Settings',
  'settings.language': 'Language',
  'settings.language_subtitle': 'Choose your preferred language',
  'settings.theme': 'Theme',
  'settings.theme_subtitle': 'Choose light or dark theme',
  'settings.theme_light': 'Light',
  'settings.theme_dark': 'Dark',
  'settings.theme_system': 'System',
  'settings.notifications': 'Notifications',
  'settings.notifications_subtitle': 'Manage notification preferences',
  'settings.push_notifications': 'Push Notifications',
  'settings.email_notifications': 'Email Notifications',
  'settings.sound': 'Sound',
  'settings.vibration': 'Vibration',
  'settings.privacy': 'Privacy',
  'settings.privacy_subtitle': 'Manage your privacy settings',
  'settings.account': 'Account',
  'settings.account_subtitle': 'Manage your account details',
  'settings.about_app': 'About App',
  'settings.version': 'Version',
  'settings.terms': 'Terms of Service',
  'settings.privacy_policy': 'Privacy Policy',
  'settings.rate_app': 'Rate This App',
  'settings.share_app': 'Share App',
  'settings.delete_account': 'Delete Account',
  'settings.delete_account_confirm':
      'Are you sure? This action cannot be undone.',
  'settings.cache_cleared': 'Cache cleared successfully',
  'settings.clear_cache': 'Clear Cache',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'My Profile',
  'profile.edit': 'Edit Profile',
  'profile.update_success': 'Profile updated successfully',
  'profile.update_failed': 'Failed to update profile',
  'profile.change_photo': 'Change Photo',
  'profile.full_name': 'Full Name',
  'profile.bio': 'Bio',
  'profile.date_of_birth': 'Date of Birth',
  'profile.gender': 'Gender',
  'profile.gender_male': 'Male',
  'profile.gender_female': 'Female',
  'profile.gender_other': 'Other',
  'profile.member_since': 'Member since @date',
  'profile.orders_count': '@count Orders',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Good Morning',
  'home.greeting_afternoon': 'Good Afternoon',
  'home.greeting_evening': 'Good Evening',
  'home.featured': 'Featured',
  'home.popular': 'Popular',
  'home.recent': 'Recent',
  'home.recommended': 'Recommended for You',
  'home.whats_new': "What's New",
  'home.trending': 'Trending Now',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Product Details',
  'product.add_to_cart': 'Add to Cart',
  'product.buy_now': 'Buy Now',
  'product.out_of_stock': 'Out of Stock',
  'product.in_stock': 'In Stock',
  'product.reviews': 'Reviews (@count)',
  'product.no_reviews': 'No reviews yet',
  'product.write_review': 'Write a Review',
  'product.specifications': 'Specifications',
  'product.related': 'Related Products',
  'product.added_to_cart': 'Added to cart',
  'product.price_from': 'From @price',
  'product.discount': '@percent% OFF',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Shopping Cart',
  'cart.empty': 'Your cart is empty',
  'cart.subtotal': 'Subtotal',
  'cart.shipping': 'Shipping',
  'cart.tax': 'Tax',
  'cart.total': 'Total',
  'cart.checkout': 'Proceed to Checkout',
  'cart.remove_item': 'Remove item?',
  'cart.item_count': '@count items',
  'cart.free_shipping': 'Free Shipping',

  'checkout.title': 'Checkout',
  'checkout.shipping_address': 'Shipping Address',
  'checkout.payment_method': 'Payment Method',
  'checkout.order_summary': 'Order Summary',
  'checkout.place_order': 'Place Order',
  'checkout.order_success': 'Order placed successfully!',
  'checkout.order_id': 'Order ID: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'My Orders',
  'order.empty': 'No orders yet',
  'order.status_pending': 'Pending',
  'order.status_processing': 'Processing',
  'order.status_shipped': 'Shipped',
  'order.status_delivered': 'Delivered',
  'order.status_cancelled': 'Cancelled',
  'order.track': 'Track Order',
  'order.reorder': 'Reorder',
  'order.cancel': 'Cancel Order',
  'order.details': 'Order Details',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Notifications',
  'notification.empty': 'No notifications',
  'notification.mark_read': 'Mark as Read',
  'notification.mark_all_read': 'Mark All as Read',
  'notification.clear_all': 'Clear All',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Something went wrong. Please try again.',
  'error.network': 'No internet connection. Please check your network.',
  'error.server': 'Server error. Please try again later.',
  'error.timeout': 'Request timed out. Please try again.',
  'error.not_found': 'Not found',
  'error.unauthorized': 'Unauthorized. Please login again.',
  'error.forbidden': 'You do not have permission to access this.',
  'error.validation': 'Please check your input and try again.',
  'error.empty_field': 'This field cannot be empty',
  'error.invalid_email': 'Please enter a valid email address',
  'error.password_too_short': 'Password must be at least 8 characters',
  'error.unknown': 'An unknown error occurred',

  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'This field is required',
  'validation.email': 'Please enter a valid email',
  'validation.min_length': 'Must be at least @count characters',
  'validation.max_length': 'Must be at most @count characters',
  'validation.phone': 'Please enter a valid phone number',
  'validation.password_weak':
      'Password must contain uppercase, lowercase, and numbers',