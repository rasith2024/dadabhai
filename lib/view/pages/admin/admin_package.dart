// ════════════════════════════════════════════════════════════════════════
//  AdminPackage model
//  Fields are UNCHANGED from the Firestore version. Only the (de)serialize
//  helpers changed: fromDoc(DocumentSnapshot) -> fromRow(Map) for MySQL,
//  and toMap() (which used FieldValue.serverTimestamp(), Firestore-only)
//  -> toSqlMap() for MySQL parameterized queries.
// ════════════════════════════════════════════════════════════════════════

import 'dart:convert';

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
      passBy: map['passBy'] == true || map['passBy'] == 1 || map['passBy'] == '1',
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

  /// Legacy/general price. Kept so old records still work.
  final String? priceText;

  /// New per-person prices.
  final String? adultPriceText;
  final String? childPriceText;
  final String? infantPriceText;

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
    this.infantPriceText,
    this.durationText,
    this.route = const [],
    this.faqs = const [],
    this.inclusions = const [],
    this.exclusions = const [],
    required this.createdAt,
  });

  /// Price used on compact cards. Prefer Adult price for new packages and
  /// fall back to the old priceText for existing records.
  String? get displayPriceText =>
      (adultPriceText != null && adultPriceText!.trim().isNotEmpty)
          ? adultPriceText
          : priceText;

  static List<String> _cleanFive(Iterable<String> values) => values
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(5)
      .toList(growable: false);

  // ── SQL (de)serialization ──────────────────────────────────────────

  /// Parameters for an INSERT/UPDATE. `id` and `createdAt` are handled
  /// separately by AdminMySQLService (auto-increment on insert, preserved
  /// original createdAt on update), so they're not included here except
  /// where explicitly added by the caller.
  Map<String, dynamic> toSqlMap() => {
    'title': title,
    'content': content,
    'imageUrls': jsonEncode(imageUrls),
    'category': category.value,
    'featured': featured ? 1 : 0,
    // Keep this populated for backward compatibility with older app builds.
    'priceText': displayPriceText,
    'adultPriceText': adultPriceText,
    'childPriceText': childPriceText,
    'infantPriceText': infantPriceText,
    'durationText': durationText,
    'country': country,
    'route': jsonEncode(route.map((r) => r.toMap()).toList()),
    'faqs': jsonEncode(_cleanFive(faqs)),
    'inclusions': jsonEncode(_cleanFive(inclusions)),
    'exclusions': jsonEncode(_cleanFive(exclusions)),
    // Included for UPDATEs so the original createdAt is preserved
    // (matches the old Firestore behaviour where the timestamp was
    // fixed to pkg.createdAt on edit instead of being overwritten).
    'createdAt': createdAt.toUtc().toIso8601String().replaceFirst('T', ' ').split('.').first,
  };

  static List<String> _decodeStringList(dynamic raw) {
    if (raw == null) return const [];
    final str = raw.toString();
    if (str.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(str);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .take(5)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  static List<String> _decodeImageUrls(dynamic raw) {
    if (raw == null) return const [];
    final str = raw.toString();
    if (str.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(str);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  static List<AdminRouteStop> _decodeRoute(dynamic raw) {
    if (raw == null) return const [];
    final str = raw.toString();
    if (str.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(str);
      if (decoded is List) {
        return decoded
            .map((r) => AdminRouteStop.fromMap(Map<String, dynamic>.from(r as Map)))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  static DateTime _parseCreatedAt(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    final parsed = DateTime.tryParse(raw.toString());
    return parsed ?? DateTime.now();
  }

  /// Builds an AdminPackage from a MySQL row (as returned by
  /// `row.assoc()` from the mysql_dart package).
  factory AdminPackage.fromRow(Map<String, dynamic> row) {
    final featuredRaw = row['featured'];
    final isFeatured = featuredRaw == 1 ||
        featuredRaw == true ||
        featuredRaw?.toString() == '1';

    return AdminPackage(
      id: row['id']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      content: row['content']?.toString() ?? '',
      imageUrls: _decodeImageUrls(row['imageUrls']),
      category: PackageCategoryX.fromValue(row['category']?.toString() ?? 'inbound'),
      featured: isFeatured,
      priceText: row['priceText']?.toString(),
      adultPriceText: row['adultPriceText']?.toString() ?? row['priceText']?.toString(),
      childPriceText: row['childPriceText']?.toString(),
      infantPriceText: row['infantPriceText']?.toString(),
      durationText: row['durationText']?.toString(),
      country: row['country']?.toString() ?? 'United Arab Emirates',
      route: _decodeRoute(row['route']),
      faqs: _decodeStringList(row['faqs']),
      inclusions: _decodeStringList(row['inclusions']),
      exclusions: _decodeStringList(row['exclusions']),
      createdAt: _parseCreatedAt(row['createdAt']),
    );
  }
}