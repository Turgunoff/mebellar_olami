# Mebellar Olami - Customer App

## 📋 Loyiha Tavsifi

**Mebellar Olami** - Premium mebel marketplace platformasi uchun mijozlar (customer) mobil ilovasi. Flutter framework yordamida yaratilgan, iOS va Android platformalarida ishlaydi. Ilova foydalanuvchilarga mebel mahsulotlarini ko'rish, qidirish, sevimlilarga qo'shish va buyurtma berish imkoniyatini beradi.

### Asosiy Vazifalar:

- 🏠 Bosh sahifa - Yangi va mashhur mahsulotlar ko'rinishi
- 🛋️ Katalog - Kategoriyalar bo'yicha mahsulotlar ko'rinishi va filtrlash
- ❤️ Sevimlilar - Tanlangan mahsulotlar ro'yxati
- 👤 Profil - Foydalanuvchi profili boshqaruvi
- 🔐 Autentifikatsiya - SMS OTP orqali ro'yxatdan o'tish va kirish
- 🛒 Buyurtma - Mahsulot buyurtma berish
- 📱 Onboarding - Birinchi marta foydalanish uchun qo'llanma

---

## 🛠️ Texnologik Stek

### Core Framework:

- **Flutter SDK 3.10.4+** - Cross-platform mobil dasturlash framework
- **Dart** - Dasturlash tili

### Asosiy Paketlar (Dependencies):

#### State Management:

- `provider: ^6.1.2` - State management (Provider pattern)

#### UI/UX:

- `google_fonts: ^6.2.1` - Google Fonts integratsiyasi
- `flutter_animate: ^4.5.2` - Animatsiyalar
- `cached_network_image: ^3.4.1` - Rasmlarni cache qilish

#### Networking:

- `http: ^1.2.2` - HTTP so'rovlar (REST API)

#### Local Storage:

- `shared_preferences: ^2.3.3` - Local data saqlash (token, user data)

#### Media:

- `image_picker: ^1.1.2` - Rasmlarni tanlash va yuklash

#### Utilities:

- `intl: ^0.20.2` - Internationalization (sana, vaqt formatlari)
- `cupertino_icons: ^1.0.8` - iOS style icons

### Development Tools:

- `flutter_lints: ^6.0.0` - Code linting

---

## 📁 Loyiha Strukturasi

Loyiha **Clean Architecture** prinsiplariga asoslangan:

```
lib/
├── core/                    # Core functionality
│   ├── constants/
│   │   ├── app_colors.dart  # Rang konstantalari
│   │   └── app_theme.dart   # Theme konfiguratsiyasi
│   ├── services/
│   │   └── api_service.dart # Backend API integratsiyasi
│   └── utils/
│       └── extensions.dart  # Dart extension methods
│
├── data/                    # Data layer
│   ├── models/
│   │   ├── product_model.dart  # Mahsulot modeli
│   │   └── order_model.dart    # Buyurtma modeli
│   └── mock/
│       └── mock_data.dart       # Mock data (development)
│
├── presentation/            # UI layer
│   ├── screens/            # Ekranlar
│   │   ├── auth/          # Autentifikatsiya ekranlari
│   │   │   ├── welcome_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── verify_code_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── reset_password_screen.dart
│   │   │   └── success_screen.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── catalog/
│   │   │   └── catalog_screen.dart
│   │   ├── product/
│   │   │   └── product_detail_screen.dart
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart
│   │   ├── checkout/
│   │   │   └── checkout_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── main_screen.dart  # Bottom navigation
│   └── widgets/            # Reusable widgets
│       ├── category_card.dart
│       ├── product_card.dart
│       ├── custom_button.dart
│       └── login_dialog.dart
│
├── providers/              # State management (Provider)
│   ├── auth_provider.dart      # Autentifikatsiya holati
│   ├── user_provider.dart      # Foydalanuvchi ma'lumotlari
│   ├── product_provider.dart   # Mahsulotlar holati
│   ├── category_provider.dart  # Kategoriyalar holati
│   ├── favorites_provider.dart # Sevimlilar holati
│   └── orders_provider.dart    # Buyurtmalar holati
│
└── main.dart               # Application entry point
```

### Arxitektura Qatlamlari:

1. **Core Layer** - Constants, services, utilities
2. **Data Layer** - Models va mock data
3. **Presentation Layer** - UI ekranlar va widgetlar
4. **Providers Layer** - State management (Provider pattern)

---

## 🎨 UI/UX Yondashuvi

### Design System:

- **Nabolen Style** - Premium, minimalist dizayn
- **Material Design 3** - Flutter Material Design
- **Custom Theme** - Brand-specific ranglar va typography

### Asosiy Ranglar:

- Primary Color - Brand rang
- Surface Color - Background ranglar
- Text Colors - Primary, Secondary, Light

### Animatsiyalar:

- `flutter_animate` paketi orqali smooth animatsiyalar
- Bottom navigation bar animatsiyasi
- Screen transition animatsiyalari

### Navigation:

- **Bottom Navigation Bar** - 4 ta asosiy tab:
  1. Asosiy (Home)
  2. Katalog (Catalog)
  3. Sevimli (Favorites)
  4. Profil (Profile)

---

## 📱 Asosiy Modullar

### 1. Autentifikatsiya Moduli (`auth/`)

- **Welcome Screen** - Login/Register tanlovi
- **Login Screen** - Telefon + parol orqali kirish
- **Signup Screen** - Ro'yxatdan o'tish
- **Verify Code Screen** - SMS OTP tasdiqlash
- **Forgot Password Screen** - Parolni tiklash
- **Reset Password Screen** - Yangi parol o'rnatish
- **Success Screen** - Muvaffaqiyatli operatsiya

### 2. Onboarding Moduli (`onboarding/`)

- Birinchi marta foydalanish uchun qo'llanma ekranlari

### 3. Bosh Sahifa Moduli (`home/`)

- Yangi mahsulotlar ko'rinishi
- Mashhur mahsulotlar ko'rinishi
- Kategoriyalar ko'rinishi
- Banner va reklamalar

### 4. Katalog Moduli (`catalog/`)

- Barcha mahsulotlar ro'yxati
- Kategoriya bo'yicha filtrlash
- Qidiruv funksiyasi
- Sortlash (narx, sana, mashhurlik)

### 5. Mahsulot Detali Moduli (`product/`)

- Mahsulot rasmlari (gallery)
- Mahsulot tavsifi
- Narx va xususiyatlar
- Buyurtma berish tugmasi
- Sevimlilarga qo'shish

### 6. Sevimlilar Moduli (`favorites/`)

- Tanlangan mahsulotlar ro'yxati
- O'chirish funksiyasi
- Buyurtma berish

### 7. Buyurtma Moduli (`checkout/`)

- Buyurtma ma'lumotlarini to'ldirish
- Yetkazib berish manzili
- To'lov usuli
- Buyurtmani tasdiqlash

### 8. Profil Moduli (`profile/`)

- Foydalanuvchi ma'lumotlari
- Profilni tahrirlash
- Avatar yuklash
- Chiqish (Logout)

---

## 🔌 Backend Integratsiya

### API Service

Ilova `lib/core/services/api_service.dart` orqali backend API bilan integratsiya qilinadi.

### Base URL:

```dart
static const String baseUrl = 'http://45.93.201.167:8081/api';
```

### Asosiy API Endpointlar:

#### Autentifikatsiya:

- `POST /auth/send-otp` - OTP yuborish
- `POST /auth/verify-otp` - OTP tasdiqlash
- `POST /auth/register` - Ro'yxatdan o'tish
- `POST /auth/login` - Kirish
- `POST /auth/forgot-password` - Parolni tiklash
- `POST /auth/reset-password` - Parolni yangilash

#### Mahsulotlar:

- `GET /products` - Barcha mahsulotlar
- `GET /products/new` - Yangi mahsulotlar
- `GET /products/popular` - Mashhur mahsulotlar
- `GET /products/{id}` - Mahsulot detali

#### Kategoriyalar:

- `GET /categories` - Barcha kategoriyalar

#### Profil:

- `GET /user/me` - Profilni olish (JWT)
- `PUT /user/me` - Profilni yangilash (JWT)
- `DELETE /user/me` - Hisobni o'chirish (JWT)

#### Buyurtmalar:

- `POST /orders` - Yangi buyurtma yaratish

### Autentifikatsiya:

JWT token `shared_preferences` da saqlanadi va barcha himoyalangan so'rovlarda `Authorization: Bearer {token}` header sifatida yuboriladi.

---

## ⚙️ O'rnatish va Ishga Tushirish

### Talablar:

- Flutter SDK 3.10.4 yoki yuqori versiya
- Dart SDK
- Android Studio / Xcode (platform-specific build uchun)
- Backend server ishlamoqda bo'lishi kerak

### 1. Dependencies o'rnatish

```bash
cd mebellar_olami
flutter pub get
```

### 2. API Base URL ni sozlash

`lib/core/services/api_service.dart` faylida base URL ni o'zgartiring:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8081/api';
```

**Eslatma:**

- Emulator uchun: `10.0.2.2:8081`
- iOS Simulator uchun: `localhost:8081`
- Real device uchun: `<YOUR_IP>:8081`

### 3. Ilovani ishga tushirish

```bash
# Development mode
flutter run

# Specific device uchun
flutter run -d <device_id>

# Release mode (production)
flutter run --release
```

### 4. Build qilish

#### Android:

```bash
flutter build apk --release
# yoki
flutter build appbundle --release
```

#### iOS:

```bash
flutter build ios --release
```

---

## 🧪 Testing

### Development Testing:

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart
```

### Manual Testing:

1. Ilovani emulator yoki real device da ishga tushirish
2. Barcha ekranlarni tekshirish
3. API integratsiyasini tekshirish
4. Autentifikatsiya flow ni tekshirish

---

## 📦 State Management

Ilova **Provider** pattern dan foydalanadi:

### Providers:

1. **AuthProvider** - Autentifikatsiya holati

   - `isLoggedIn` - Tizimga kirganmi?
   - `isOnboardingCompleted` - Onboarding ko'rilganmi?
   - `checkAuthStatus()` - Auth holatini tekshirish
   - `login()`, `logout()`, `register()` - Auth operatsiyalari

2. **UserProvider** - Foydalanuvchi ma'lumotlari

   - `user` - Joriy foydalanuvchi
   - `getProfile()` - Profilni yuklash
   - `updateProfile()` - Profilni yangilash

3. **ProductProvider** - Mahsulotlar holati

   - `products` - Mahsulotlar ro'yxati
   - `getProducts()` - Mahsulotlarni yuklash
   - `getNewArrivals()` - Yangi mahsulotlar
   - `getPopularProducts()` - Mashhur mahsulotlar

4. **CategoryProvider** - Kategoriyalar holati

   - `categories` - Kategoriyalar ro'yxati
   - `getCategories()` - Kategoriyalarni yuklash

5. **FavoritesProvider** - Sevimlilar holati

   - `favorites` - Sevimli mahsulotlar
   - `addToFavorites()` - Qo'shish
   - `removeFromFavorites()` - O'chirish

6. **OrdersProvider** - Buyurtmalar holati
   - `orders` - Buyurtmalar ro'yxati
   - `createOrder()` - Yangi buyurtma

---

## 🎯 Asosiy Xususiyatlar

### ✅ Amalga oshirilgan:

- ✅ SMS OTP autentifikatsiya
- ✅ Mahsulotlar ko'rinishi va filtrlash
- ✅ Kategoriyalar bo'yicha qidiruv
- ✅ Sevimlilar ro'yxati
- ✅ Profil boshqaruvi
- ✅ Avatar yuklash
- ✅ Buyurtma berish
- ✅ Onboarding flow

### 🚧 Rivojlantirilmoqda:

- Push notifications
- To'lov integratsiyasi
- Buyurtmalar tarixi
- Izohlar va reytinglar

---

## 🔧 Konfiguratsiya

### API Base URL:

`lib/core/services/api_service.dart` faylida sozlash mumkin.

### Theme va Ranglar:

`lib/core/constants/app_colors.dart` va `app_theme.dart` fayllarida sozlash mumkin.

### Local Storage:

`shared_preferences` orqali token va user data saqlanadi.

---

## 📱 Platform Support

- ✅ Android (min SDK: 21)
- ✅ iOS (min version: 12.0)
- ⚠️ Web (qisman qo'llab-quvvatlanadi)
- ⚠️ Desktop (qisman qo'llab-quvvatlanadi)

---

## 🐛 Ma'lum Xatoliklar va Yechimlar

### Backend ulanish muammosi:

- Base URL ni tekshiring
- Backend server ishlamoqda ekanligini tekshiring
- Network permissions ni tekshiring

### Token saqlash muammosi:

- `shared_preferences` permissions ni tekshiring
- Token formatini tekshiring

---

## 📚 Qo'shimcha Ma'lumotlar

- **Backend API**: `mebellar-backend` loyihasiga qarang
- **Design System**: Nabolen Style dizayn prinsiplari
- **State Management**: Provider pattern dokumentatsiyasi

---

## 👥 Mualliflar

Mebellar Olami Development Team

---

## 📄 License

Proprietary - All rights reserved
