import 'package:cloud_firestore/cloud_firestore.dart';

enum PackageCategory { inbound, holidays, cruises }

extension PackageCategoryX on PackageCategory {
  String get value {
    switch (this) {
      case PackageCategory.inbound:
        return 'inbound';
      case PackageCategory.holidays:
        return 'holidays';
      case PackageCategory.cruises:
        return 'cruises';
    }
  }

  String get label {
    switch (this) {
      case PackageCategory.inbound:
        return 'UAE / Inbound';
      case PackageCategory.holidays:
        return 'Holidays';
      case PackageCategory.cruises:
        return 'Cruises';
    }
  }

  static PackageCategory fromValue(String value) {
    return PackageCategory.values.firstWhere(
          (c) => c.value == value,
      orElse: () => PackageCategory.inbound,
    );
  }
}

class AdminRouteStop {
  final String title;
  final String subtitle;
  final String duration;
  final String admission;
  final bool passBy;

  const AdminRouteStop({
    required this.title,
    this.subtitle = '',
    this.duration = '',
    this.admission = '',
    this.passBy = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'duration': duration,
    'admission': admission,
    'passBy': passBy,
  };

  factory AdminRouteStop.fromMap(Map<String, dynamic> map) {
    return AdminRouteStop(
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      duration: map['duration'] ?? '',
      admission: map['admission'] ?? '',
      passBy: map['passBy'] ?? false,
    );
  }
}

class AdminPackage {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final PackageCategory category;
  final bool featured;

  /// Legacy/general price. Kept so old Firestore documents still work.
  final String? priceText;

  /// New per-person prices.
  final String? adultPriceText;
  final String? childPriceText;

  final String? durationText;
  final String country;
  final List<AdminRouteStop> route;

  /// Admin-managed content. UI limits each list to 5 non-empty values.
  final List<String> faqs;
  final List<String> inclusions;
  final List<String> exclusions;

  final DateTime createdAt;

  const AdminPackage({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.category,
    required this.featured,
    required this.country,
    this.priceText,
    this.adultPriceText,
    this.childPriceText,
    this.durationText,
    this.route = const [],
    this.faqs = const [],
    this.inclusions = const [],
    this.exclusions = const [],
    required this.createdAt,
  });

  /// Price used on compact cards. Prefer Adult price for new packages and
  /// fall back to the old priceText for existing Firestore data.
  String? get displayPriceText =>
      (adultPriceText != null && adultPriceText!.trim().isNotEmpty)
          ? adultPriceText
          : priceText;

  static List<String> _cleanFive(Iterable<String> values) => values
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(5)
      .toList(growable: false);

  Map<String, dynamic> toMap() => {
    'title': title,
    'content': content,
    'imageUrls': imageUrls,
    'category': category.value,
    'featured': featured,
    // Keep this populated for backward compatibility with older app builds.
    'priceText': displayPriceText,
    'adultPriceText': adultPriceText,
    'childPriceText': childPriceText,
    'durationText': durationText,
    'country': country,
    'route': route.map((r) => r.toMap()).toList(),
    'faqs': _cleanFive(faqs),
    'inclusions': _cleanFive(inclusions),
    'exclusions': _cleanFive(exclusions),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory AdminPackage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    List<String> stringList(String key) =>
        List<String>.from(data[key] ?? const <String>[])
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(5)
            .toList(growable: false);

    return AdminPackage(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? const []),
      category: PackageCategoryX.fromValue(data['category'] ?? 'inbound'),
      featured: data['featured'] ?? false,
      priceText: data['priceText'],
      adultPriceText: data['adultPriceText'] ?? data['priceText'],
      childPriceText: data['childPriceText'],
      durationText: data['durationText'],
      country: data['country'] ?? 'United Arab Emirates',
      route: (data['route'] as List<dynamic>? ?? const [])
          .map((r) => AdminRouteStop.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList(),
      faqs: stringList('faqs'),
      inclusions: stringList('inclusions'),
      exclusions: stringList('exclusions'),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
