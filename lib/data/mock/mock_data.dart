import '../models/product_model.dart';
import '../models/order_model.dart';

/// Mock ma'lumotlar sinfi
/// Backend ishlamagan paytda fallback sifatida ishlatiladi
class MockData {
  MockData._();

  /// Banner rasmlari
  static const List<Map<String, String>> banners = [
    {
      'image':
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      'title': 'Yangi Kolleksiya',
      'subtitle': '30% gacha chegirma',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
      'title': 'Premium Divanlar',
      'subtitle': 'Maxsus narxlarda',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=800',
      'title': 'Yotoqxona to\'plami',
      'subtitle': 'Bepul yetkazib berish',
    },
  ];

  /// Kategoriyalar
  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'cat_1',
      name: 'Yotoqxona',
      iconName: 'bed',
      subCategories: [
        CategoryModel(
          id: 'cat_1_1',
          name: 'Karavotlar',
          parentId: 'cat_1',
          iconName: 'bed',
        ),
        CategoryModel(
          id: 'cat_1_2',
          name: 'Shkaflar',
          parentId: 'cat_1',
          iconName: 'door_sliding',
        ),
        CategoryModel(
          id: 'cat_1_3',
          name: 'Tumbalar',
          parentId: 'cat_1',
          iconName: 'nightlight',
        ),
      ],
    ),
    CategoryModel(
      id: 'cat_2',
      name: 'Yashash xonasi',
      iconName: 'weekend',
      subCategories: [
        CategoryModel(
          id: 'cat_2_1',
          name: 'Divanlar',
          parentId: 'cat_2',
          iconName: 'weekend',
        ),
        CategoryModel(
          id: 'cat_2_2',
          name: 'Stollar',
          parentId: 'cat_2',
          iconName: 'table_restaurant',
        ),
        CategoryModel(
          id: 'cat_2_3',
          name: 'Kresollar',
          parentId: 'cat_2',
          iconName: 'chair',
        ),
      ],
    ),
    CategoryModel(
      id: 'cat_3',
      name: 'Oshxona',
      iconName: 'kitchen',
      subCategories: [
        CategoryModel(
          id: 'cat_3_1',
          name: 'Oshxona stollari',
          parentId: 'cat_3',
          iconName: 'table_restaurant',
        ),
        CategoryModel(
          id: 'cat_3_2',
          name: 'Stullar',
          parentId: 'cat_3',
          iconName: 'chair_alt',
        ),
        CategoryModel(
          id: 'cat_3_3',
          name: 'Oshxona javonlari',
          parentId: 'cat_3',
          iconName: 'shelves',
        ),
      ],
    ),
    CategoryModel(
      id: 'cat_4',
      name: 'Ofis',
      iconName: 'business_center',
      subCategories: [
        CategoryModel(
          id: 'cat_4_1',
          name: 'Ofis stollari',
          parentId: 'cat_4',
          iconName: 'desk',
        ),
        CategoryModel(
          id: 'cat_4_2',
          name: 'Ofis kreslosari',
          parentId: 'cat_4',
          iconName: 'chair',
        ),
        CategoryModel(
          id: 'cat_4_3',
          name: 'Kitob javonlari',
          parentId: 'cat_4',
          iconName: 'shelves',
        ),
      ],
    ),
    CategoryModel(id: 'cat_5', name: 'Bog\' mebellari', iconName: 'deck'),
  ];

  /// Mahsulotlar (yangi strukturada)
  static const List<ProductModel> products = [
    // Yotoqxona - Karavotlar
    ProductModel(
      id: 'prod_1',
      name: 'Premium Karavot "Milano"',
      price: 4500000,
      description:
          'Zamonaviy italyan dizaynidagi premium karavot. Yumshoq bosh qismi va mustahkam yog\'och ramkasi.',
      category: 'Karavotlar',
      categoryId: 'cat_1_1',
      images: [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600',
      ],
      rating: 4.8,
      isPopular: true,
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Klassik Karavot "Royal"',
      price: 6200000,
      description:
          'Hashamatli klassik uslubdagi karavot. Premium sifatli eman yog\'ochidan yasalgan.',
      category: 'Karavotlar',
      categoryId: 'cat_1_1',
      images: [
        'https://images.unsplash.com/photo-1617325247661-675ab4b64ae2?w=600',
      ],
      rating: 4.9,
      isNew: true,
    ),
    // Yotoqxona - Shkaflar
    ProductModel(
      id: 'prod_3',
      name: 'Ko\'zguyli Shkaf "Elegance"',
      price: 3800000,
      description:
          'Katta ko\'zguli zamonaviy shkaf. 4 ta bo\'lim va ko\'p xonali ichki tuzilishi.',
      category: 'Shkaflar',
      categoryId: 'cat_1_2',
      images: [
        'https://images.unsplash.com/photo-1558997519-83ea9252edf8?w=600',
      ],
      rating: 4.7,
      isPopular: true,
    ),
    // Yashash xonasi - Divanlar (Chegirmali)
    ProductModel(
      id: 'prod_4',
      name: 'Burchak Divan "Comfort Plus"',
      price: 8500000,
      discountPrice: 6800000,
      description:
          'Keng oilalar uchun ideal burchak divani. Yotish funksiyasi mavjud.',
      category: 'Divanlar',
      categoryId: 'cat_2_1',
      images: [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
      ],
      specs: {'Material': 'Velvet', 'O\'lcham': '280x180 sm'},
      rating: 4.9,
      isPopular: true,
      isNew: true,
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Ikki kishilik Divan "Nordic"',
      price: 4200000,
      description:
          'Skandinav uslubidagi zamonaviy divan. Premium mato qoplamasi.',
      category: 'Divanlar',
      categoryId: 'cat_2_1',
      images: [
        'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=600',
      ],
      rating: 4.6,
      isNew: true,
    ),
    // Yashash xonasi - Stollar (Chegirmali)
    ProductModel(
      id: 'prod_6',
      name: 'Kofe stoli "Marble"',
      price: 2400000,
      discountPrice: 1920000,
      description: 'Tabiiy marmar ustki qismi va metall oyoqlari.',
      category: 'Stollar',
      categoryId: 'cat_2_2',
      images: [
        'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?w=600',
      ],
      specs: {'Material': 'Marmar + Metall', 'Diametr': '80 sm'},
      rating: 4.5,
      isPopular: true,
    ),
    // Yashash xonasi - Kresollar
    ProductModel(
      id: 'prod_7',
      name: 'Kreslo "Vintage"',
      price: 2400000,
      description: 'Retro uslubidagi qulay kreslo. Mustahkam yog\'och ramkasi.',
      category: 'Kresollar',
      categoryId: 'cat_2_3',
      images: [
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
      ],
      rating: 4.7,
      isNew: true,
    ),
    // Oshxona (Chegirmali)
    ProductModel(
      id: 'prod_8',
      name: 'Oshxona to\'plami "Family"',
      price: 4200000,
      discountPrice: 3570000,
      description: 'Stol va 6 ta stuldan iborat to\'plam. Oila uchun ideal.',
      category: 'Oshxona stollari',
      categoryId: 'cat_3_1',
      images: [
        'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=600',
      ],
      specs: {'Stullar': '6 dona', 'Stol o\'lchami': '160x90 sm'},
      rating: 4.8,
      isPopular: true,
    ),
    // Ofis
    ProductModel(
      id: 'prod_9',
      name: 'Ofis stoli "Executive"',
      price: 2800000,
      description: 'Professional ofis stoli. Ko\'p tortmali.',
      category: 'Ofis stollari',
      categoryId: 'cat_4_1',
      images: [
        'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600',
      ],
      rating: 4.6,
    ),
    ProductModel(
      id: 'prod_10',
      name: 'Ergonomik Kreslo "ProSit"',
      price: 3800000,
      description: 'To\'liq sozlanishi mumkin ergonomik ofis kreslosi.',
      category: 'Ofis kreslosari',
      categoryId: 'cat_4_2',
      images: [
        'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=600',
      ],
      specs: {'Kafolat': '5 yil', 'Yuk sig\'imi': '150 kg'},
      rating: 4.9,
      isPopular: true,
      isNew: true,
    ),
    // Bog' mebellari
    ProductModel(
      id: 'prod_11',
      name: 'Bog\' to\'plami "Garden Lounge"',
      price: 5600000,
      description: 'Suv va quyoshga chidamli bog\' mebellari to\'plami.',
      category: 'Bog\' mebellari',
      categoryId: 'cat_5',
      images: [
        'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=600',
      ],
      rating: 4.5,
    ),
    ProductModel(
      id: 'prod_12',
      name: 'Osilgan Kreslo "Cocoon"',
      price: 1900000,
      description: 'Zamonaviy osilgan kreslo. Dam olish uchun ideal.',
      category: 'Bog\' mebellari',
      categoryId: 'cat_5',
      images: [
        'https://images.unsplash.com/photo-1520038410233-7141be7e6f97?w=600',
      ],
      rating: 4.8,
      isNew: true,
    ),
  ];

  /// Mashhur mahsulotlar
  static List<ProductModel> get popularProducts =>
      products.where((p) => p.isPopular).toList();

  /// Yangi mahsulotlar
  static List<ProductModel> get newProducts =>
      products.where((p) => p.isNew).toList();

  /// Kategoriya bo'yicha mahsulotlar
  static List<ProductModel> getProductsByCategory(String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  /// Namuna buyurtmalar
  static List<OrderModel> sampleOrders = [
    OrderModel(
      id: 'order_1',
      productId: 'prod_4',
      productName: 'Burchak Divan "Comfort Plus"',
      productImage:
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
      totalPrice: 6800000,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 15)),
      selectedColor: 'D6CFC4',
      customerName: 'Alisher Karimov',
      customerPhone: '+998901234567',
      deliveryAddress: 'Toshkent sh., Chilonzor t., 12-uy, 45-xonadon',
    ),
    OrderModel(
      id: 'order_2',
      productId: 'prod_10',
      productName: 'Ergonomik Kreslo "ProSit"',
      productImage:
          'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=600',
      totalPrice: 3800000,
      status: OrderStatus.processing,
      date: DateTime.now().subtract(const Duration(days: 2)),
      selectedColor: '1E1E20',
      customerName: 'Alisher Karimov',
      customerPhone: '+998901234567',
      deliveryAddress: 'Toshkent sh., Chilonzor t., 12-uy, 45-xonadon',
    ),
    OrderModel(
      id: 'order_3',
      productId: 'prod_6',
      productName: 'Kofe stoli "Marble"',
      productImage:
          'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?w=600',
      totalPrice: 1920000,
      status: OrderStatus.newOrder,
      date: DateTime.now(),
      selectedColor: 'FFFFFF',
      customerName: 'Alisher Karimov',
      customerPhone: '+998901234567',
      deliveryAddress: 'Toshkent sh., Chilonzor t., 12-uy, 45-xonadon',
    ),
  ];
}
