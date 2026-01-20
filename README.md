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

- `flutter_bloc: ^8.1.6` - State management (BLoC pattern)
- `equatable: ^2.0.5` - Object comparison for BLoC

#### UI/UX:

- `google_fonts: ^6.2.1` - Google Fonts integratsiyasi
- `flutter_animate: ^4.5.2` - Animatsiyalar
- `cached_network_image: ^3.4.1` - Rasmlarni cache qilish
- `shimmer: ^3.0.0` - Loading animatsiyalari
- `fluttertoast: ^8.2.8` - Toast notifications

#### Networking:

- `dio: ^5.7.0` - HTTP so'rovlar (REST API)
- `internet_connection_checker_plus: ^2.1.0` - Internet holatini tekshirish

#### Local Storage:

- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive uchun Flutter integratsiyasi
- `shared_preferences: ^2.3.3` - Simple data saqlash (settings)

#### Services & Utilities:

- `get_it: ^8.0.2` - Dependency Injection
- `flutter_dotenv: ^5.1.0` - Environment variables
- `geolocator: ^10.1.0` - GPS location services
- `onesignal_flutter: ^5.2.1` - Push notifications
- `yandex_mapkit: ^4.2.1` - Yandex xaritalar integratsiyasi
- `image_picker: ^1.1.2` - Rasmlarni tanlash va yuklash
- `intl: ^0.20.2` - Internationalization (sana, vaqt formatlari)
- `cupertino_icons: ^1.0.8` - iOS style icons

### Development Tools:

- `flutter_lints: ^6.0.0` - Code linting

---

## 📁 Loyiha Strukturasi

Loyiha **Clean Architecture** prinsiplariga asoslangan bo'lib, **Feature-based** strukturadan foydalanadi:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # Konstantalar (colors, themes, strings)
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_strings.dart
│   ├── di/                 # Dependency Injection
│   │   └── dependency_injection.dart
│   ├── init/               # App initialization
│   │   └── app_initializer.dart
│   ├── local/              # Local storage services
│   │   └── hive_service.dart
│   ├── network/            # Network configuration
│   │   └── dio_client.dart
│   ├── services/           # Global services
│   │   ├── api_service.dart
│   │   └── notification_service.dart
│   ├── utils/              # Utility functions
│   │   └── extensions.dart
│   └── widgets/            # Reusable core widgets
│       ├── app_providers.dart
│       ├── connectivity_wrapper.dart
│       └── custom_widgets/

├── features/               # Feature-based modules
│   ├── auth/              # Autentifikatsiya moduli
│   │   ├── data/          # Data layer (models, repositories)
│   │   ├── domain/        # Business logic (entities, use cases)
│   │   └── presentation/  # UI layer (screens, widgets, BLoC)
│   ├── home/              # Bosh sahifa moduli
│   ├── catalog/           # Katalog moduli
│   ├── products/          # Mahsulotlar moduli
│   ├── categories/        # Kategoriyalar moduli
│   ├── cart/              # Savat moduli
│   ├── favorites/         # Sevimlilar moduli
│   ├── checkout/          # Buyurtma berish moduli
│   ├── profile/           # Profil moduli
│   ├── search/            # Qidiruv moduli
│   └── main/              # Asosiy ekran (bottom navigation)

└── main.dart              # Application entry point
```

### Arxitektura Qatlamlari:

1. **Core Layer** - Constants, services, utilities, DI
2. **Features Layer** - Feature-based modullar (data, domain, presentation)
3. **Data Layer** - Models, repositories, data sources
4. **Domain Layer** - Business logic, entities, use cases
5. **Presentation Layer** - UI ekranlar, widgetlar, BLoC state management

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

### 2. Environment variables ni sozlash

`.env` faylini project root da yarating:

```bash
# .env faylini yarating
touch .env
```

`.env` fayliga quyidagilarni qo'shing:

```env
BASE_URL=http://45.93.201.167:8081/api
ONESIGNAL_APP_ID=your_onesignal_app_id
```

**Eslatma:**

- Emulator uchun: `http://10.0.2.2:8081/api`
- iOS Simulator uchun: `http://localhost:8081/api`
- Real device uchun: `http://<YOUR_IP>:8081/api`

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
5. Buyurtma berish flow ni tekshirish
6. Profilni tahrirlash flow ni tekshirish

---

## 📦 State Management

Ilova **BLoC (Business Logic Component)** pattern dan foydalanadi:

### BLoC Architecture:

1. **AuthBloc** - Autentifikatsiya holati
   - `AuthState` - Auth holatlari (initial, loading, authenticated, unauthenticated)
   - `AuthEvent` - Auth eventlari (LoginRequested, LogoutRequested, RegisterRequested)
   - `mapEventToState()` - Eventlarni state ga aylantirish

2. **UserBloc** - Foydalanuvchi ma'lumotlari
   - `UserState` - Foydalanuvchi holatlari
   - `UserEvent` - Foydalanuvchi eventlari (GetProfile, UpdateProfile)

3. **ProductBloc** - Mahsulotlar holati
   - `ProductState` - Mahsulotlar holatlari (loading, loaded, error)
   - `ProductEvent` - Mahsulotlar eventlari (GetProducts, GetNewArrivals, GetPopular)

4. **CategoryBloc** - Kategoriyalar holati
   - `CategoryState` - Kategoriyalar holati
   - `CategoryEvent` - Kategoriyalar eventlari (GetCategories)

5. **CartBloc** - Savat holati
   - `CartState` - Savat holati
   - `CartEvent` - Savat eventlari (AddToCart, RemoveFromCart, UpdateQuantity)

6. **FavoritesBloc** - Sevimlilar holati
   - `FavoritesState` - Sevimlilar holati
   - `FavoritesEvent` - Sevimlilar eventlari (AddToFavorites, RemoveFromFavorites)

7. **OrderBloc** - Buyurtmalar holati
   - `OrderState` - Buyurtmalar holati
   - `OrderEvent` - Buyurtmalar eventlari (CreateOrder, GetOrders)

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
- ✅ Savat (Cart) funksiyasi
- ✅ Yandex xaritalar integratsiyasi
- ✅ GPS location services
- ✅ Push notifications (OneSignal)
- ✅ Internet holatini tekshirish
- ✅ Hive local database
- ✅ BLoC state management
- ✅ Dependency Injection
- ✅ Environment variables

### 🚧 Rivojlantirilmoqda:

- To'lov integratsiyasi
- Buyurtmalar tarixi
- Izohlar va reytinglar
- Real-time chat
- Multi-language support

---

## 🔧 Konfiguratsiya

### API Base URL:

`.env` faylida sozlash mumkin:

```env
BASE_URL=http://45.93.201.167:8081/api
```

### Environment Variables:

`.env` fayl orqali sozlanadi:

```env
BASE_URL=http://45.93.201.167:8081/api
ONESIGNAL_APP_ID=your_onesignal_app_id
```

### Theme va Ranglar:

`lib/core/constants/app_colors.dart` va `app_theme.dart` fayllarida sozlash mumkin.

### Local Storage:

`Hive` orqali complex data saqlanadi, `shared_preferences` esa simple settings uchun ishlatiladi.

### Dependency Injection:

`lib/core/di/dependency_injection.dart` faylida barcha dependencylar sozlanadi.

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
