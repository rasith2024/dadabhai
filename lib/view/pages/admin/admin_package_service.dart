import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminPackageService {
  AdminPackageService._();

  static final AdminPackageService instance =
  AdminPackageService._();

  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('admin_packages');

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  Stream<List<AdminPackage>> streamAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
          snap.docs.map(AdminPackage.fromDoc).toList(),
    );
  }

  Stream<List<AdminPackage>> streamByCategory(
      PackageCategory category,
      ) {
    return _col
        .where(
      'category',
      isEqualTo: category.value,
    )
        .snapshots()
        .map((snap) {
      final items =
      snap.docs.map(AdminPackage.fromDoc).toList();

      items.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return items;
    });
  }

  Stream<List<AdminPackage>> streamFeatured() {
    return _col
        .where('featured', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final items =
      snap.docs.map(AdminPackage.fromDoc).toList();

      items.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return items;
    });
  }

  Future<void> addPackage(
      AdminPackage pkg,
      ) async {
    await _col.add(pkg.toMap());
  }

  Future<void> updatePackage(
      String id,
      AdminPackage pkg,
      ) async {
    final map = pkg.toMap();

    map['createdAt'] =
        Timestamp.fromDate(pkg.createdAt);

    await _col.doc(id).update(map);
  }

  Future<void> deletePackage(
      AdminPackage pkg,
      ) async {
    for (final url in pkg.imageUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {
        // Ignore storage delete failures.
      }
    }

    await _col.doc(pkg.id).delete();
  }

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