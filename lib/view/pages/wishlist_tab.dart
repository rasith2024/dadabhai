part of 'dashboard.dart';

/// Wishlist feature split from dashboard.dart.
///
/// This is a `part` file instead of a normal import so the existing private
/// dashboard types such as `_TravelPackage`, `_ExperienceCard`, and
/// `_PackageDetailPage` remain accessible without changing app logic.

class WishlistItem {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final _TravelPackage package;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.package,
  });
}

class WishlistController extends ChangeNotifier {
  WishlistController._() {
    _start();
  }
  static final WishlistController instance = WishlistController._();

  final Map<String, WishlistItem> _items = {};
  final UserDataMySQLService _db = UserDataMySQLService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _pollTimer;
  bool _loading = true;
  String? _lastHash;
  bool _refreshing = false;
  List<WishlistItem> get items => _items.values.toList();
  int get count => _items.length;
  bool get loading => _loading;

  bool isSaved(String id) => _items.containsKey(id);

  String _docId(String id) => id.replaceAll('/', '_');

  Future<User> _ensureUser() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  Future<void> _refresh(String uid) async {
    if (_refreshing) return;

    _refreshing = true;

    try {
      final rows = await _db.fetchWishlist(uid);

      final hash = jsonEncode(rows);

      if (hash == _lastHash) {
        _loading = false;
        return;
      }

      _lastHash = hash;

      _items
        ..clear()
        ..addEntries(
          rows.map((row) {
            final packageJson =
            row['package_json'];

            final packageMap =
            packageJson == null
                ? <String, dynamic>{}
                : Map<String, dynamic>.from(
              jsonDecode(
                packageJson.toString(),
              ),
            );

            final package =
            _TravelPackage.fromWishlistMap(
              packageMap,
            );

            final item = WishlistItem(
              // IMPORTANT:
              // use original ID stored inside JSON.
              id: packageMap['packageId']
                  ?.toString() ??
                  row['package_id']
                      ?.toString() ??
                  package.heroTitle,

              title: row['title']
                  ?.toString() ??
                  package.title,

              subtitle: row['subtitle']
                  ?.toString() ??
                  (package.durationText ??
                      package.country),

              imageUrl:
              row['imageUrl']?.toString(),

              package: package,
            );

            return MapEntry(
              item.id,
              item,
            );
          }),
        );

      _loading = false;

      notifyListeners();
    } catch (e) {
      _loading = false;

      debugPrint(
        'Wishlist refresh error: $e',
      );

      notifyListeners();
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _start() async {
    try {
      final user = await _ensureUser();
      _pollTimer?.cancel();
      // Initial fetch, then poll every 5s — MySQL has no native
      // push-listener like Firestore snapshots.
      await _refresh(user.uid);
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh(user.uid));
    } catch (e) {
      _loading = false;
      debugPrint('Wishlist start error: $e');
      notifyListeners();
    }
  }


  Future<void> toggle(WishlistItem item) async {
    if (isSaved(item.id)) {
      await remove(item.id);
    } else {
      await add(item);
    }
  }

  Future<void> add(WishlistItem item) async {
    final user = await _ensureUser();
    // Optimistic UI update; the next poll cycle remains the source of truth.
    _items[item.id] = item;
    notifyListeners();
    try {
      await _db.upsertWishlistItem(
        uid: user.uid,
        packageId: _docId(item.id),
        title: item.title,
        subtitle: item.subtitle,
        imageUrl: item.imageUrl,
        packageJson: {
          'packageId': item.id,
          'title': item.title,
          'subtitle': item.subtitle,
          'imageUrl': item.imageUrl,
          ...item.package.toWishlistMap(),
        },
      );
      _lastHash = null; // force next poll to pick up the confirmed state
    } catch (e) {
      _items.remove(item.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final user = await _ensureUser();
    final previous = _items.remove(id);
    notifyListeners();
    try {
      await _db.deleteWishlistItem(user.uid, _docId(id));
      _lastHash = null;
    } catch (e) {
      if (previous != null) _items[id] = previous;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishlistController.instance,
      builder: (context, _) {
        final items = WishlistController.instance.items;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [
            const _SectionTitle('My Wishlist', subtitle: 'Saved tours, holidays & cruises'),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 46, color: LogoColors.dark.withOpacity(.2)),
                    const SizedBox(height: 12),
                    Text('Nothing saved yet',
                        style: TextStyle(fontWeight: FontWeight.w700, color: LogoColors.dark.withOpacity(.5))),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the heart on any experience to save it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: LogoColors.dark.withOpacity(.4)),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: .8,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _AnimatedEntrance(
                    index: index,
                    child: _ExperienceCard(
                      imageUrl: item.imageUrl,
                      title: item.title,
                      subtitle: item.subtitle,
                      package: item.package,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _PackageDetailPage(package: item.package)),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
