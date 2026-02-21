---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 5/7)
---
  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'จำเป็นต้องกรอกช่องนี้',
  'validation.email': 'กรุณากรอกอีเมลที่ถูกต้อง',
  'validation.min_length': 'ต้องมีอย่างน้อย @count ตัวอักษร',
  'validation.max_length': 'ต้องไม่เกิน @count ตัวอักษร',
  'validation.phone': 'กรุณากรอกหมายเลขโทรศัพท์ที่ถูกต้อง',
  'validation.password_weak':
      'รหัสผ่านต้องประกอบด้วยตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก และตัวเลข',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'วันนี้',
  'date.yesterday': 'เมื่อวาน',
  'date.tomorrow': 'พรุ่งนี้',
  'date.days_ago': '@count วันที่แล้ว',
  'date.hours_ago': '@count ชั่วโมงที่แล้ว',
  'date.minutes_ago': '@count นาทีที่แล้ว',
  'date.just_now': 'เมื่อสักครู่',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

**File:** `sdlc/flutter-youi/07-translation/option_a_getx_builtin/translations/vn_vn.dart`

```dart
// lib/core/translations/vn_vn.dart

const Map<String, String> viVN = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'Ứng dụng của tôi',
  'app.description': 'Ứng dụng Flutter hoàn chỉnh với GetX',

  'common.save': 'Lưu',
  'common.cancel': 'Hủy',
  'common.delete': 'Xóa',
  'common.edit': 'Sửa',
  'common.add': 'Thêm',
  'common.search': 'Tìm kiếm',
  'common.filter': 'Lọc',
  'common.sort': 'Sắp xếp',
  'common.refresh': 'Làm mới',
  'common.loading': 'Đang tải...',
  'common.retry': 'Thử lại',
  'common.confirm': 'Xác nhận',
  'common.back': 'Quay lại',
  'common.next': 'Tiếp theo',
  'common.done': 'Hoàn thành',
  'common.close': 'Đóng',
  'common.yes': 'Có',
  'common.no': 'Không',
  'common.ok': 'OK',
  'common.submit': 'Gửi',
  'common.continue': 'Tiếp tục',
  'common.skip': 'Bỏ qua',
  'common.select_all': 'Chọn tất cả',
  'common.deselect_all': 'Bỏ chọn tất cả',
  'common.no_data': 'Không có dữ liệu',
  'common.see_all': 'Xem tất cả',
  'common.view_details': 'Xem chi tiết',

  'common.name': 'Tên',
  'common.email': 'Email',
  'common.phone': 'Điện thoại',
  'common.address': 'Địa chỉ',
  'common.date': 'Ngày',
  'common.time': 'Thời gian',
  'common.status': 'Trạng thái',
  'common.description': 'Mô tả',
  'common.amount': 'Số lượng',
  'common.total': 'Tổng cộng',
  'common.price': 'Giá',
  'common.quantity': 'Số lượng',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'Đăng nhập',
  'auth.logout': 'Đăng xuất',
  'auth.register': 'Đăng ký',
  'auth.forgot_password': 'Quên mật khẩu?',
  'auth.reset_password': 'Đặt lại mật khẩu',
  'auth.email_hint': 'Nhập email của bạn',
  'auth.password_hint': 'Nhập mật khẩu của bạn',
  'auth.confirm_password': 'Xác nhận mật khẩu',
  'auth.login_success': 'Đăng nhập thành công',
  'auth.login_failed': 'Đăng nhập thất bại. Vui lòng kiểm tra lại.',
  'auth.register_success': 'Đăng ký thành công! Vui lòng đăng nhập.',
  'auth.logout_confirm': 'Bạn có chắc muốn đăng xuất?',
  'auth.password_mismatch': 'Mật khẩu không khớp',
  'auth.welcome_back': 'Chào mừng trở lại, @name!',
  'auth.new_user': 'Người dùng mới? Tạo tài khoản',
  'auth.existing_user': 'Đã có tài khoản? Đăng nhập',
  'auth.or_continue_with': 'Hoặc tiếp tục với',
  'auth.terms_agree': 'Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'Trang chủ',
  'nav.profile': 'Hồ sơ',
  'nav.settings': 'Cài đặt',
  'nav.notifications': 'Thông báo',
  'nav.favorites': 'Yêu thích',
  'nav.history': 'Lịch sử',
  'nav.help': 'Trợ giúp & Hỗ trợ',
  'nav.about': 'Giới thiệu',
  'nav.dashboard': 'Bảng điều khiển',
  'nav.orders': 'Đơn hàng',
  'nav.products': 'Sản phẩm',
  'nav.categories': 'Danh mục',
  'nav.cart': 'Giỏ hàng',
  'nav.checkout': 'Thanh toán',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'Cài đặt',
  'settings.language': 'Ngôn ngữ',
  'settings.language_subtitle': 'Chọn ngôn ngữ bạn muốn',
  'settings.theme': 'Giao diện',
  'settings.theme_subtitle': 'Chọn giao diện sáng hoặc tối',
  'settings.theme_light': 'Sáng',
  'settings.theme_dark': 'Tối',
  'settings.theme_system': 'Hệ thống',
  'settings.notifications': 'Thông báo',
  'settings.notifications_subtitle': 'Quản lý cài đặt thông báo',
  'settings.push_notifications': 'Thông báo đẩy',
  'settings.email_notifications': 'Thông báo qua email',
  'settings.sound': 'Âm thanh',
  'settings.vibration': 'Rung',
  'settings.privacy': 'Quyền riêng tư',
  'settings.privacy_subtitle': 'Quản lý cài đặt quyền riêng tư',
  'settings.account': 'Tài khoản',
  'settings.account_subtitle': 'Quản lý chi tiết tài khoản',
  'settings.about_app': 'Về ứng dụng',
  'settings.version': 'Phiên bản',
  'settings.terms': 'Điều khoản dịch vụ',
  'settings.privacy_policy': 'Chính sách bảo mật',
  'settings.rate_app': 'Đánh giá ứng dụng',
  'settings.share_app': 'Chia sẻ ứng dụng',
  'settings.delete_account': 'Xóa tài khoản',
  'settings.delete_account_confirm':
      'Bạn có chắc không? Hành động này không thể hoàn tác.',
  'settings.cache_cleared': 'Đã xóa bộ nhớ đệm thành công',
  'settings.clear_cache': 'Xóa bộ nhớ đệm',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'Hồ sơ của tôi',
  'profile.edit': 'Chỉnh sửa hồ sơ',
  'profile.update_success': 'Cập nhật hồ sơ thành công',
  'profile.update_failed': 'Cập nhật hồ sơ thất bại',
  'profile.change_photo': 'Đổi ảnh',
  'profile.full_name': 'Họ và tên',
  'profile.bio': 'Tiểu sử',
  'profile.date_of_birth': 'Ngày sinh',
  'profile.gender': 'Giới tính',
  'profile.gender_male': 'Nam',
  'profile.gender_female': 'Nữ',
  'profile.gender_other': 'Khác',
  'profile.member_since': 'Thành viên từ @date',
  'profile.orders_count': '@count Đơn hàng',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'Chào buổi sáng',
  'home.greeting_afternoon': 'Chào buổi chiều',
  'home.greeting_evening': 'Chào buổi tối',
  'home.featured': 'Nổi bật',
  'home.popular': 'Phổ biến',
  'home.recent': 'Gần đây',
  'home.recommended': 'Đề xuất cho bạn',
  'home.whats_new': 'Có gì mới',
  'home.trending': 'Xu hướng',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'Chi tiết sản phẩm',
  'product.add_to_cart': 'Thêm vào giỏ',
  'product.buy_now': 'Mua ngay',
  'product.out_of_stock': 'Hết hàng',
  'product.in_stock': 'Còn hàng',
  'product.reviews': 'Đánh giá (@count)',
  'product.no_reviews': 'Chưa có đánh giá',
  'product.write_review': 'Viết đánh giá',
  'product.specifications': 'Thông số kỹ thuật',
  'product.related': 'Sản phẩm liên quan',
  'product.added_to_cart': 'Đã thêm vào giỏ hàng',
  'product.price_from': 'Từ @price',
  'product.discount': 'Giảm @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'Giỏ hàng',
  'cart.empty': 'Giỏ hàng trống',
  'cart.subtotal': 'Tạm tính',
  'cart.shipping': 'Phí vận chuyển',
  'cart.tax': 'Thuế',
  'cart.total': 'Tổng cộng',
  'cart.checkout': 'Tiến hành thanh toán',
  'cart.remove_item': 'Xóa sản phẩm?',
  'cart.item_count': '@count sản phẩm',
  'cart.free_shipping': 'Miễn phí vận chuyển',

  'checkout.title': 'Thanh toán',
  'checkout.shipping_address': 'Địa chỉ giao hàng',
  'checkout.payment_method': 'Phương thức thanh toán',
  'checkout.order_summary': 'Tóm tắt đơn hàng',
  'checkout.place_order': 'Đặt hàng',
  'checkout.order_success': 'Đặt hàng thành công!',
  'checkout.order_id': 'Mã đơn hàng: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'Đơn hàng của tôi',
  'order.empty': 'Chưa có đơn hàng',
  'order.status_pending': 'Chờ xử lý',
  'order.status_processing': 'Đang xử lý',
  'order.status_shipped': 'Đã gửi',
  'order.status_delivered': 'Đã giao',
  'order.status_cancelled': 'Đã hủy',
  'order.track': 'Theo dõi đơn hàng',
  'order.reorder': 'Đặt lại',
  'order.cancel': 'Hủy đơn hàng',
  'order.details': 'Chi tiết đơn hàng',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'Thông báo',
  'notification.empty': 'Không có thông báo',
  'notification.mark_read': 'Đánh dấu đã đọc',
  'notification.mark_all_read': 'Đánh dấu tất cả đã đọc',
  'notification.clear_all': 'Xóa tất cả',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'Đã xảy ra lỗi. Vui lòng thử lại.',
  'error.network': 'Không có kết nối internet. Vui lòng kiểm tra mạng.',
  'error.server': 'Lỗi máy chủ. Vui lòng thử lại sau.',
  'error.timeout': 'Yêu cầu hết thời gian. Vui lòng thử lại.',
  'error.not_found': 'Không tìm thấy',
  'error.unauthorized': 'Không được phép. Vui lòng đăng nhập lại.',
  'error.forbidden': 'Bạn không có quyền truy cập.',
  'error.validation': 'Vui lòng kiểm tra lại thông tin và thử lại.',
  'error.empty_field': 'Trường này không được để trống',
  'error.invalid_email': 'Vui lòng nhập địa chỉ email hợp lệ',
  'error.password_too_short': 'Mật khẩu phải có ít nhất 8 ký tự',
  'error.unknown': 'Đã xảy ra lỗi không xác định',