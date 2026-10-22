

import 'dart:async';
import 'dart:convert';

import 'package:dadabhaitravel/view/pages/admin/admin_mysql_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:dadabhaitravel/view/pages/admin/admin_package.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminPackageService {
  AdminPackageService._();

  static final AdminPackageService instance =
  AdminPackageService._();

  final AdminMySQLService _mysql = AdminMySQLService.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  bool _tableReady = false;

  Future<void> _ensureTable() async {
    if (_tableReady) return;
    await _mysql.createTable();
    _tableReady = true;
  }

  // ── Poll-based "stream" so existing StreamBuilder widgets keep working ─
  //
  // MySQL has no native push-notification like Firestore snapshots, so we
  // poll on an interval and only emit when the fetched data actually
  // changed (compared via a cheap JSON hash) to avoid needless rebuilds.
  Stream<List<AdminPackage>> _pollStream(
      Future<List<Map<String, dynamic>>> Function() fetchRows, {
        Duration interval = const Duration(seconds: 5),
      }) async* {
    String? lastHash;
    bool tableReady = false;

    while (true) {
      try {
        // Moved inside the loop's try/catch: if the DB is unreachable,
        // this throws every tick but is now caught below instead of
        // crashing the app as an unhandled exception.
        if (!tableReady) {
          await _ensureTable();
          tableReady = true;
        }

        final rows = await fetchRows();
        final packages = rows.map(AdminPackage.fromRow).toList();

        final hash = jsonEncode(
          packages.map((p) => {'id': p.id, ...p.toSqlMap()}).toList(),
        );

        if (hash != lastHash) {
          lastHash = hash;
          yield packages;
        }
      } catch (e) {
        debugPrint('AdminPackageService poll error: $e');
        // Swallow poll errors so a transient network hiccup doesn't kill
        // the stream — the next tick will retry automatically. UI stays
        // on its "loading" or last-known-good state via StreamBuilder.
      }

      await Future.delayed(interval);
    }
  }

  Stream<List<AdminPackage>> streamAll() {
    return _pollStream(() => _mysql.fetchPackages());
  }

  Stream<List<AdminPackage>> streamByCategory(
      PackageCategory category,
      ) {
    return _pollStream(
          () => _mysql.fetchPackages(category: category.value),
    );
  }

  Stream<List<AdminPackage>> streamFeatured() {
    return _pollStream(
          () => _mysql.fetchPackages(featuredOnly: true),
    );
  }

  Future<void> addPackage(
      AdminPackage pkg,
      ) async {
    await _ensureTable();
    await _mysql.insertPackage(pkg.toSqlMap());
  }

  Future<void> updatePackage(
      String id,
      AdminPackage pkg,
      ) async {
    await _ensureTable();
    await _mysql.updatePackage(id, pkg.toSqlMap());
  }

  Future<void> deletePackage(
      AdminPackage pkg,
      ) async {
    // Image cleanup unchanged — still Firebase Storage.
    for (final url in pkg.imageUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {

      }
    }

    await _ensureTable();
    await _mysql.deletePackage(pkg.id);
  }

  /// Unchanged — images still upload to Firebase Storage.
  /// Works on:
  /// Android
  /// iOS
  /// Flutter Web
  Future<String> uploadImage(
      XFile file, {
        void Function(double progress)? onProgress,
      }) async {
    final bytes = await file.readAsBytes();

    final originalName =
    file.name.trim().isEmpty
        ? 'image.jpg'
        : file.name;

    final safeName = originalName
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final ref = _storage.ref().child(
      'admin_packages/$fileName',
    );

    final task = ref.putData(
      bytes,
      SettableMetadata(
        contentType: _contentType(originalName),
        cacheControl: 'public,max-age=31536000',
      ),
    );

    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress =
              snapshot.bytesTransferred /
                  snapshot.totalBytes;

          onProgress(progress);
        }
      });
    }

    final snapshot = await task;

    return await snapshot.ref.getDownloadURL();
  }

  String _contentType(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.png')) {
      return 'image/png';
    }

    if (name.endsWith('.webp')) {
      return 'image/webp';
    }

    if (name.endsWith('.gif')) {
      return 'image/gif';
    }

    if (name.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    return 'image/jpeg';
  }
}