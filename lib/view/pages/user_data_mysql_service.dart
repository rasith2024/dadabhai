import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mysql_dart/mysql_dart.dart';

class UserDataMySQLService {
  UserDataMySQLService._();

  static final UserDataMySQLService instance =
  UserDataMySQLService._();

  MySQLConnection? _connection;

  bool _wishlistTableReady = false;
  bool _bookingTableReady = false;

  // Prevent simultaneous queries using the same MySQL connection.
  Future<void> _queryLock = Future.value();


  Future<void> connect() async {
    if (_connection != null) {
      return;
    }

    try {
      final connection =
      await MySQLConnection.createConnection(
        host: '95.216.42.216',
        port: 3306,
        userName: 'rootadmin',

        // Put your NEW password here.
        password: r'R6S16$lg4nEgslrka',

        databaseName: 'test_api',
        secure: false,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
            'Unable to reach MySQL server.',
          );
        },
      );

      await connection.connect();

      _connection = connection;

      debugPrint(
        'UserDataMySQLService: MySQL connected',
      );
    } catch (e) {
      debugPrint(
        'UserDataMySQLService connection error: $e',
      );

      _connection = null;

      rethrow;
    }
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Future<void> close() async {
    try {
      await _connection?.close();
    } catch (e) {
      debugPrint(
        'MySQL close error: $e',
      );
    }

    _connection = null;

    _wishlistTableReady = false;
    _bookingTableReady = false;
  }


  Future<T> _runQuery<T>(
      Future<T> Function() action,
      ) {
    final completer = Completer<T>();

    _queryLock = _queryLock.then((_) async {
      try {
        final result = await action();

        completer.complete(result);
      } catch (e, stackTrace) {
        completer.completeError(
          e,
          stackTrace,
        );
      }
    });

    return completer.future;
  }


  Future<void> createWishlistTable() async {
    if (_wishlistTableReady) {
      return;
    }

    await connect();

    await _runQuery(() async {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS wishlist_items (
          id INT NOT NULL AUTO_INCREMENT,

          uid VARCHAR(191) NOT NULL,

          package_id VARCHAR(255) NOT NULL,

          title VARCHAR(255),

          subtitle VARCHAR(255),

          imageUrl TEXT,

          package_json LONGTEXT,

          savedAt TIMESTAMP
            NOT NULL
            DEFAULT CURRENT_TIMESTAMP,

          PRIMARY KEY (id),

          UNIQUE KEY uid_package (
            uid,
            package_id
          ),

          INDEX idx_wishlist_uid (uid),

          INDEX idx_wishlist_savedAt (
            savedAt
          )
        )
      ''');
    });

    _wishlistTableReady = true;

    debugPrint(
      'wishlist_items table ready',
    );
  }


  Future<void> createBookingTable() async {
    if (_bookingTableReady) {
      return;
    }

    await connect();

    await _runQuery(() async {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS booking_items (
          id VARCHAR(191) NOT NULL,

          uid VARCHAR(191) NOT NULL,

          name VARCHAR(255),

          email VARCHAR(255),

          mobile VARCHAR(50),

          checkIn DATETIME NULL,

          adults INT
            NOT NULL
            DEFAULT 1,

          children INT
            NOT NULL
            DEFAULT 0,
            
            infant INT
            NOT NULL
            DEFAULT 0,

          selectedPackageOption
            VARCHAR(255),

          status VARCHAR(30)
            NOT NULL
            DEFAULT 'pending',

          package_json LONGTEXT,

          createdAt TIMESTAMP
            NOT NULL
            DEFAULT CURRENT_TIMESTAMP,

          PRIMARY KEY (id),

          INDEX idx_booking_uid (uid),

          INDEX idx_booking_status (
            status
          ),

          INDEX idx_booking_createdAt (
            createdAt
          )
        )
      ''');
    });

    _bookingTableReady = true;

    debugPrint(
      'booking_items table ready',
    );
  }

  // ============================================================
  // CREATE BOTH TABLES
  // ============================================================

  Future<void> createTables() async {
    await createWishlistTable();
    await createBookingTable();
  }

  // ============================================================
  // WISHLIST - FETCH
  // ============================================================

  Future<List<Map<String, dynamic>>>
  fetchWishlist(
      String uid,
      ) async {
    await createWishlistTable();

    return _runQuery(() async {
      final result =
      await _connection!.execute(
        '''
        SELECT
          id,
          uid,
          package_id,
          title,
          subtitle,
          imageUrl,
          package_json,
          savedAt

        FROM wishlist_items

        WHERE uid = :uid

        ORDER BY savedAt DESC
        ''',
        {
          'uid': uid,
        },
      );

      return result.rows
          .map(
            (row) =>
        Map<String, dynamic>.from(
          row.assoc(),
        ),
      )
          .toList();
    });
  }

  // ============================================================
  // WISHLIST - INSERT / UPDATE
  // ============================================================

  Future<void> upsertWishlistItem({
    required String uid,
    required String packageId,
    required String title,
    required String subtitle,
    required String? imageUrl,
    required Map<String, dynamic>
    packageJson,
  }) async {
    await createWishlistTable();

    await _runQuery(() async {
      await _connection!.execute(
        '''
        INSERT INTO wishlist_items (
          uid,
          package_id,
          title,
          subtitle,
          imageUrl,
          package_json
        )

        VALUES (
          :uid,
          :package_id,
          :title,
          :subtitle,
          :imageUrl,
          :package_json
        )

        ON DUPLICATE KEY UPDATE

          title =
            VALUES(title),

          subtitle =
            VALUES(subtitle),

          imageUrl =
            VALUES(imageUrl),

          package_json =
            VALUES(package_json),

          savedAt =
            CURRENT_TIMESTAMP
        ''',
        {
          'uid': uid,
          'package_id': packageId,
          'title': title,
          'subtitle': subtitle,
          'imageUrl': imageUrl,
          'package_json':
          jsonEncode(packageJson),
        },
      );
    });
  }

  // ============================================================
  // WISHLIST - DELETE
  // ============================================================

  Future<void> deleteWishlistItem(
      String uid,
      String packageId,
      ) async {
    await createWishlistTable();

    await _runQuery(() async {
      await _connection!.execute(
        '''
        DELETE FROM wishlist_items

        WHERE uid = :uid
          AND package_id = :package_id
        ''',
        {
          'uid': uid,
          'package_id': packageId,
        },
      );
    });
  }

  // ============================================================
  // WISHLIST - CHECK SAVED
  // ============================================================

  Future<bool> isWishlistSaved(
      String uid,
      String packageId,
      ) async {
    await createWishlistTable();

    return _runQuery(() async {
      final result =
      await _connection!.execute(
        '''
        SELECT id

        FROM wishlist_items

        WHERE uid = :uid
          AND package_id = :package_id

        LIMIT 1
        ''',
        {
          'uid': uid,
          'package_id': packageId,
        },
      );

      return result.rows.isNotEmpty;
    });
  }

  // ============================================================
  // BOOKING - FETCH USER BOOKINGS
  // ============================================================

  Future<List<Map<String, dynamic>>>
  fetchBookings(
      String uid,
      ) async {
    await createBookingTable();

    return _runQuery(() async {
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

        WHERE uid = :uid

        ORDER BY createdAt DESC
        ''',
        {
          'uid': uid,
        },
      );

      return result.rows
          .map(
            (row) =>
        Map<String, dynamic>.from(
          row.assoc(),
        ),
      )
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>>
  fetchAllBookings() async {
    await createBookingTable();

    return _runQuery(() async {
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
    });
  }


  Future<void> insertBooking({
    required String id,
    required String uid,
    required Map<String, dynamic> row,
  }) async {
    await createBookingTable();

    final params =
    Map<String, dynamic>.from(
      row,
    );

    params['id'] = id;
    params['uid'] = uid;

    await _runQuery(() async {
      await _connection!.execute(
        '''
        INSERT INTO booking_items (
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
          package_json
        )

        VALUES (
          :id,
          :uid,
          :name,
          :email,
          :mobile,
          :checkIn,
          :adults,
          :children,
          :selectedPackageOption,
          :status,
          :package_json
        )
        ''',
        params,
      );
    });
  }

  // ============================================================
  // BOOKING - UPDATE STATUS
  // ============================================================

  Future<void> updateBookingStatus(
      String uid,
      String id,
      String status,
      ) async {
    await createBookingTable();

    await _runQuery(() async {
      await _connection!.execute(
        '''
        UPDATE booking_items

        SET status = :status

        WHERE uid = :uid
          AND id = :id
        ''',
        {
          'status': status,
          'uid': uid,
          'id': id,
        },
      );
    });
  }

  // ============================================================
  // BOOKING - ADMIN STATUS UPDATE
  // Doesn't require uid.
  // ============================================================

  Future<void> updateBookingStatusById(
      String id,
      String status,
      ) async {
    await createBookingTable();

    await _runQuery(() async {
      await _connection!.execute(
        '''
        UPDATE booking_items

        SET status = :status

        WHERE id = :id
        ''',
        {
          'status': status,
          'id': id,
        },
      );
    });
  }

  // ============================================================
  // BOOKING - DELETE
  // ============================================================

  Future<void> deleteBooking(
      String uid,
      String id,
      ) async {
    await createBookingTable();

    await _runQuery(() async {
      await _connection!.execute(
        '''
        DELETE FROM booking_items

        WHERE uid = :uid
          AND id = :id
        ''',
        {
          'uid': uid,
          'id': id,
        },
      );
    });
  }
}