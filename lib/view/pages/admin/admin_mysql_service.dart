
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mysql_dart/mysql_dart.dart';

class AdminMySQLService {
  AdminMySQLService._();

  static final AdminMySQLService instance =
  AdminMySQLService._();

  MySQLConnection? _connection;


  Future<void> connect() async {
    if (_connection != null) return;

    try {
      final connection =
      await MySQLConnection.createConnection(
        host: '95.216.42.216',
        port: 3306,
        userName: 'rootadmin',

        // Use your database password here.
        password: r'R6S16$lg4nEgslrka',

        databaseName: 'test_api',
        secure: false,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
          'Unable to reach the database server. '
              'Please check your connection.',
        ),
      );

      await connection.connect();

      _connection = connection;
    } catch (e) {
      debugPrint(
        'MySQL connection error: $e',
      );

      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();

    _connection = null;
  }

  // ============================================================
  // ADMIN PACKAGES TABLE
  // ============================================================

  Future<void> createTable() async {
    await connect();

    await _connection!.execute(
      '''
      CREATE TABLE IF NOT EXISTS admin_packages (
        id INT NOT NULL AUTO_INCREMENT,
        title VARCHAR(255) NOT NULL,
        content TEXT,
        imageUrls TEXT,
        category VARCHAR(50)
          NOT NULL DEFAULT 'inbound',
        featured TINYINT(1)
          NOT NULL DEFAULT 0,
        priceText VARCHAR(100),
        adultPriceText VARCHAR(100),
        childPriceText VARCHAR(100),
        infantPriceText VARCHAR(100),
        durationText VARCHAR(100),
        country VARCHAR(150)
          NOT NULL DEFAULT 'United Arab Emirates',
        route TEXT,
        faqs TEXT,
        inclusions TEXT,
        exclusions TEXT,
        createdAt TIMESTAMP
          NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
      )
      ''',
    );
  }

  // ============================================================
  // ADMIN - FETCH ALL BOOKINGS
  // ============================================================

  Future<List<Map<String, dynamic>>>
  fetchAllBookings() async {
    await connect();

    final result =
    await _connection!.execute(
      '''
      SELECT
        id,
        uid,
        name,
        email,
        mobile,
        checkIn,
        adults,
        children,
        selectedPackageOption,
        status,
        package_json,
        createdAt
      FROM booking_items
      ORDER BY createdAt DESC
      ''',
    );

    return result.rows
        .map(
          (row) =>
      Map<String, dynamic>.from(
        row.assoc(),
      ),
    )
        .toList();
  }

  // ============================================================
  // ADMIN - UPDATE BOOKING STATUS
  // ============================================================

  Future<void> updateBookingStatus(
      String bookingId,
      String status,
      ) async {
    await connect();

    await _connection!.execute(
      '''
      UPDATE booking_items
      SET status = :status
      WHERE id = :id
      ''',
      {
        'status': status,
        'id': bookingId,
      },
    );
  }

  // ============================================================
  // ADMIN - DELETE BOOKING
  // ============================================================

  Future<void> deleteBooking(
      String bookingId,
      ) async {
    await connect();

    await _connection!.execute(
      '''
      DELETE FROM booking_items
      WHERE id = :id
      ''',
      {
        'id': bookingId,
      },
    );
  }

  // ============================================================
  // FETCH PACKAGES
  // ============================================================

  Future<List<Map<String, dynamic>>>
  fetchPackages({
    String? category,
    bool featuredOnly = false,
  }) async {
    await connect();

    String sql =
        'SELECT * FROM admin_packages';

    final params =
    <String, dynamic>{};

    final conditions = <String>[];

    if (category != null) {
      conditions.add(
        'category = :category',
      );

      params['category'] = category;
    }

    if (featuredOnly) {
      conditions.add(
        'featured = 1',
      );
    }

    if (conditions.isNotEmpty) {
      sql +=
      ' WHERE ${conditions.join(' AND ')}';
    }

    sql +=
    ' ORDER BY createdAt DESC';

    final result =
    await _connection!.execute(
      sql,
      params,
    );

    return result.rows
        .map(
          (row) => row.assoc(),
    )
        .toList();
  }

  // ============================================================
  // INSERT PACKAGE
  // ============================================================

  Future<String> insertPackage(
      Map<String, dynamic> row,
      ) async {
    await connect();

    final result =
    await _connection!.execute(
      '''
      INSERT INTO admin_packages (
        title,
        content,
        imageUrls,
        category,
        featured,
        priceText,
        adultPriceText,
        childPriceText,
        infantPriceText,
        durationText,
        country,
        route,
        faqs,
        inclusions,
        exclusions
      )
      VALUES (
        :title,
        :content,
        :imageUrls,
        :category,
        :featured,
        :priceText,
        :adultPriceText,
        :childPriceText,
        :infantPriceText,
        :durationText,
        :country,
        :route,
        :faqs,
        :inclusions,
        :exclusions
      )
      ''',
      row,
    );

    return result.lastInsertID
        .toString();
  }

  // ============================================================
  // UPDATE PACKAGE
  // ============================================================

  Future<void> updatePackage(
      String id,
      Map<String, dynamic> row,
      ) async {
    await connect();

    final params =
    Map<String, dynamic>.from(row)
      ..['id'] =
          int.tryParse(id) ?? 0;

    await _connection!.execute(
      '''
      UPDATE admin_packages
      SET
        title = :title,
        content = :content,
        imageUrls = :imageUrls,
        category = :category,
        featured = :featured,
        priceText = :priceText,
        adultPriceText = :adultPriceText,
        childPriceText = :childPriceText,
        infantPriceText = :infantPriceText,
        durationText = :durationText,
        country = :country,
        route = :route,
        faqs = :faqs,
        inclusions = :inclusions,
        exclusions = :exclusions,
        createdAt = :createdAt
      WHERE id = :id
      ''',
      params,
    );
  }

  // ============================================================
  // DELETE PACKAGE
  // ============================================================

  Future<void> deletePackage(
      String id,
      ) async {
    await connect();

    await _connection!.execute(
      '''
      DELETE FROM admin_packages
      WHERE id = :id
      ''',
      {
        'id': int.tryParse(id) ?? 0,
      },
    );
  }
}

/// Small JSON helpers shared with AdminPackage's SQL (de)serialization.
List<String> decodeStringList(dynamic raw) {
  if (raw == null) return const [];
  if (raw is String && raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw as String);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
  } catch (_) {}
  return const [];
}

String encodeStringList(List<String> values) => jsonEncode(values);