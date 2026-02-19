---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 4/7)
---
  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'Medan ini diperlukan',
  'validation.email': 'Sila masukkan e-mel yang sah',
  'validation.min_length': 'Mestilah sekurang-kurangnya @count aksara',
  'validation.max_length': 'Mestilah paling banyak @count aksara',
  'validation.phone': 'Sila masukkan nombor telefon yang sah',
  'validation.password_weak':
      'Kata laluan mestilah mengandungi huruf besar, huruf kecil, dan nombor',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Hari ini',
  'date.yesterday': 'Semalam',
  'date.tomorrow': 'Esok',
  'date.days_ago': '@count hari lepas',
  'date.hours_ago': '@count jam lepas',
  'date.minutes_ago': '@count minit lepas',
  'date.just_now': 'Baru sahaja',

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

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/translations/th_th.dart`

```dart
// lib/core/translations/th_th.dart

const Map<String, String> thTH = {
  // ============================================================
  // General / Common
  // ============================================================
  'app.title': 'แอปพลิเคชันของฉัน',
  'app.description': 'แอปพลิเคชัน Flutter พร้อม GetX',

  'common.save': 'บันทึก',
  'common.cancel': 'ยกเลิก',
  'common.delete': 'ลบ',
  'common.edit': 'แก้ไข',
  'common.add': 'เพิ่ม',
  'common.search': 'ค้นหา',
  'common.filter': 'กรอง',
  'common.sort': 'เรียงลำดับ',
  'common.refresh': 'รีเฟรช',
  'common.loading': 'กำลังโหลด...',
  'common.retry': 'ลองอีกครั้ง',
  'common.confirm': 'ยืนยัน',
  'common.back': 'กลับ',
  'common.next': 'ถัดไป',
  'common.done': 'เสร็จสิ้น',
  'common.close': 'ปิด',
  'common.yes': 'ใช่',
  'common.no': 'ไม่',
  'common.ok': 'ตกลง',
  'common.submit': 'ส่ง',
  'common.continue': 'ดำเนินการต่อ',
  'common.skip': 'ข้าม',
  'common.select_all': 'เลือกทั้งหมด',
  'common.deselect_all': 'ยกเลิกเลือกทั้งหมด',
  'common.no_data': 'ไม่มีข้อมูล',
  'common.see_all': 'ดูทั้งหมด',
  'common.view_details': 'ดูรายละเอียด',

  'common.name': 'ชื่อ',
  'common.email': 'อีเมล',
  'common.phone': 'โทรศัพท์',
  'common.address': 'ที่อยู่',
  'common.date': 'วันที่',
  'common.time': 'เวลา',
  'common.status': 'สถานะ',
  'common.description': 'คำอธิบาย',
  'common.amount': 'จำนวน',
  'common.total': 'รวม',
  'common.price': 'ราคา',
  'common.quantity': 'ปริมาณ',

  // ============================================================
  // Authentication
  // ============================================================
  'auth.login': 'เข้าสู่ระบบ',
  'auth.logout': 'ออกจากระบบ',
  'auth.register': 'สมัครสมาชิก',
  'auth.forgot_password': 'ลืมรหัสผ่าน?',
  'auth.reset_password': 'รีเซ็ตรหัสผ่าน',
  'auth.email_hint': 'กรอกอีเมลของคุณ',
  'auth.password_hint': 'กรอกรหัสผ่านของคุณ',
  'auth.confirm_password': 'ยืนยันรหัสผ่าน',
  'auth.login_success': 'เข้าสู่ระบบสำเร็จ',
  'auth.login_failed': 'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูลของคุณ',
  'auth.register_success': 'สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ',
  'auth.logout_confirm': 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
  'auth.password_mismatch': 'รหัสผ่านไม่ตรงกัน',
  'auth.welcome_back': 'ยินดีต้อนรับกลับ, @name!',
  'auth.new_user': 'ผู้ใช้ใหม่? สร้างบัญชี',
  'auth.existing_user': 'มีบัญชีแล้ว? เข้าสู่ระบบ',
  'auth.or_continue_with': 'หรือดำเนินการต่อด้วย',
  'auth.terms_agree': 'เมื่อดำเนินการต่อ คุณยอมรับข้อกำหนดการใช้งานของเรา',

  // ============================================================
  // Navigation / Menu
  // ============================================================
  'nav.home': 'หน้าหลัก',
  'nav.profile': 'โปรไฟล์',
  'nav.settings': 'ตั้งค่า',
  'nav.notifications': 'การแจ้งเตือน',
  'nav.favorites': 'รายการโปรด',
  'nav.history': 'ประวัติ',
  'nav.help': 'ช่วยเหลือและสนับสนุน',
  'nav.about': 'เกี่ยวกับ',
  'nav.dashboard': 'แดชบอร์ด',
  'nav.orders': 'คำสั่งซื้อ',
  'nav.products': 'สินค้า',
  'nav.categories': 'หมวดหมู่',
  'nav.cart': 'ตะกร้า',
  'nav.checkout': 'ชำระเงิน',

  // ============================================================
  // Settings
  // ============================================================
  'settings.title': 'ตั้งค่า',
  'settings.language': 'ภาษา',
  'settings.language_subtitle': 'เลือกภาษาที่คุณต้องการ',
  'settings.theme': 'ธีม',
  'settings.theme_subtitle': 'เลือกธีมสว่างหรือมืด',
  'settings.theme_light': 'สว่าง',
  'settings.theme_dark': 'มืด',
  'settings.theme_system': 'ระบบ',
  'settings.notifications': 'การแจ้งเตือน',
  'settings.notifications_subtitle': 'จัดการการตั้งค่าการแจ้งเตือน',
  'settings.push_notifications': 'การแจ้งเตือนแบบพุช',
  'settings.email_notifications': 'การแจ้งเตือนทางอีเมล',
  'settings.sound': 'เสียง',
  'settings.vibration': 'สั่น',
  'settings.privacy': 'ความเป็นส่วนตัว',
  'settings.privacy_subtitle': 'จัดการการตั้งค่าความเป็นส่วนตัว',
  'settings.account': 'บัญชี',
  'settings.account_subtitle': 'จัดการรายละเอียดบัญชีของคุณ',
  'settings.about_app': 'เกี่ยวกับแอป',
  'settings.version': 'เวอร์ชัน',
  'settings.terms': 'ข้อกำหนดการใช้งาน',
  'settings.privacy_policy': 'นโยบายความเป็นส่วนตัว',
  'settings.rate_app': 'ให้คะแนนแอปนี้',
  'settings.share_app': 'แชร์แอป',
  'settings.delete_account': 'ลบบัญชี',
  'settings.delete_account_confirm':
      'คุณแน่ใจหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้',
  'settings.cache_cleared': 'ล้างแคชสำเร็จ',
  'settings.clear_cache': 'ล้างแคช',

  // ============================================================
  // Profile
  // ============================================================
  'profile.title': 'โปรไฟล์ของฉัน',
  'profile.edit': 'แก้ไขโปรไฟล์',
  'profile.update_success': 'อัปเดตโปรไฟล์สำเร็จ',
  'profile.update_failed': 'อัปเดตโปรไฟล์ไม่สำเร็จ',
  'profile.change_photo': 'เปลี่ยนรูปภาพ',
  'profile.full_name': 'ชื่อเต็ม',
  'profile.bio': 'ประวัติย่อ',
  'profile.date_of_birth': 'วันเกิด',
  'profile.gender': 'เพศ',
  'profile.gender_male': 'ชาย',
  'profile.gender_female': 'หญิง',
  'profile.gender_other': 'อื่นๆ',
  'profile.member_since': 'สมาชิกตั้งแต่ @date',
  'profile.orders_count': '@count คำสั่งซื้อ',

  // ============================================================
  // Home
  // ============================================================
  'home.greeting_morning': 'สวัสดีตอนเช้า',
  'home.greeting_afternoon': 'สวัสดีตอนบ่าย',
  'home.greeting_evening': 'สวัสดีตอนเย็น',
  'home.featured': 'แนะนำ',
  'home.popular': 'ยอดนิยม',
  'home.recent': 'ล่าสุด',
  'home.recommended': 'แนะนำสำหรับคุณ',
  'home.whats_new': 'มีอะไรใหม่',
  'home.trending': 'กำลังเทรนด์',

  // ============================================================
  // Products / Catalog
  // ============================================================
  'product.details': 'รายละเอียดสินค้า',
  'product.add_to_cart': 'เพิ่มลงตะกร้า',
  'product.buy_now': 'ซื้อเลย',
  'product.out_of_stock': 'สินค้าหมด',
  'product.in_stock': 'มีสินค้า',
  'product.reviews': 'รีวิว (@count)',
  'product.no_reviews': 'ยังไม่มีรีวิว',
  'product.write_review': 'เขียนรีวิว',
  'product.specifications': 'สเปค',
  'product.related': 'สินค้าที่เกี่ยวข้อง',
  'product.added_to_cart': 'เพิ่มลงตะกร้าแล้ว',
  'product.price_from': 'เริ่มต้นที่ @price',
  'product.discount': 'ลด @percent%',

  // ============================================================
  // Cart & Checkout
  // ============================================================
  'cart.title': 'ตะกร้าสินค้า',
  'cart.empty': 'ตะกร้าของคุณว่าง',
  'cart.subtotal': 'ยอดรวมย่อย',
  'cart.shipping': 'ค่าจัดส่ง',
  'cart.tax': 'ภาษี',
  'cart.total': 'รวมทั้งหมด',
  'cart.checkout': 'ดำเนินการชำระเงิน',
  'cart.remove_item': 'ลบสินค้า?',
  'cart.item_count': '@count รายการ',
  'cart.free_shipping': 'ส่งฟรี',

  'checkout.title': 'ชำระเงิน',
  'checkout.shipping_address': 'ที่อยู่จัดส่ง',
  'checkout.payment_method': 'วิธีการชำระเงิน',
  'checkout.order_summary': 'สรุปคำสั่งซื้อ',
  'checkout.place_order': 'สั่งซื้อ',
  'checkout.order_success': 'สั่งซื้อสำเร็จ!',
  'checkout.order_id': 'รหัสคำสั่งซื้อ: @id',

  // ============================================================
  // Orders
  // ============================================================
  'order.title': 'คำสั่งซื้อของฉัน',
  'order.empty': 'ยังไม่มีคำสั่งซื้อ',
  'order.status_pending': 'รอดำเนินการ',
  'order.status_processing': 'กำลังดำเนินการ',
  'order.status_shipped': 'จัดส่งแล้ว',
  'order.status_delivered': 'ส่งถึงแล้ว',
  'order.status_cancelled': 'ยกเลิกแล้ว',
  'order.track': 'ติดตามคำสั่งซื้อ',
  'order.reorder': 'สั่งซื้ออีกครั้ง',
  'order.cancel': 'ยกเลิกคำสั่งซื้อ',
  'order.details': 'รายละเอียดคำสั่งซื้อ',

  // ============================================================
  // Notifications
  // ============================================================
  'notification.title': 'การแจ้งเตือน',
  'notification.empty': 'ไม่มีการแจ้งเตือน',
  'notification.mark_read': 'ทำเครื่องหมายว่าอ่านแล้ว',
  'notification.mark_all_read': 'ทำเครื่องหมายทั้งหมดว่าอ่านแล้ว',
  'notification.clear_all': 'ล้างทั้งหมด',

  // ============================================================
  // Error Messages
  // ============================================================
  'error.generic': 'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง',
  'error.network': 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบเครือข่าย',
  'error.server': 'เซิร์ฟเวอร์ผิดพลาด กรุณาลองอีกครั้งภายหลัง',
  'error.timeout': 'หมดเวลาคำขอ กรุณาลองอีกครั้ง',
  'error.not_found': 'ไม่พบ',
  'error.unauthorized': 'ไม่ได้รับอนุญาต กรุณาเข้าสู่ระบบอีกครั้ง',
  'error.forbidden': 'คุณไม่มีสิทธิ์เข้าถึง',
  'error.validation': 'กรุณาตรวจสอบข้อมูลของคุณแล้วลองอีกครั้ง',
  'error.empty_field': 'ช่องนี้ไม่สามารถเว้นว่างได้',
  'error.invalid_email': 'กรุณากรอกอีเมลที่ถูกต้อง',
  'error.password_too_short': 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
  'error.unknown': 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',