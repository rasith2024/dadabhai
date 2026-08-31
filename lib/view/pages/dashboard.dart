import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dadabhaitravel/view/pages/about_us.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package_service.dart';
import 'package:dadabhaitravel/view/pages/profile_page.dart';
import 'package:flutter/material.dart';

class LogoColors {
  static const dark = Color(0xff0F4C81); // Replace with logo dark color
  static const primary = Color(0xff1C7ED6); // Replace with logo primary color
  static const light = Color(0xff4DABF7); // Replace with logo light color
  static const bg = Color(0xffF5F8FC);
}


enum _AppNoticeType { success, warning, error, info }

void _showAppNotice(
    BuildContext context,
    String message, {
      _AppNoticeType type = _AppNoticeType.info,
    }) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final Color accent;
  final IconData icon;
  final String title;

  switch (type) {
    case _AppNoticeType.success:
      accent = const Color(0xff23B26D);
      icon = Icons.check_circle_rounded;
      title = 'Success';
      break;
    case _AppNoticeType.warning:
      accent = const Color(0xffF59F00);
      icon = Icons.warning_amber_rounded;
      title = 'Attention';
      break;
    case _AppNoticeType.error:
      accent = const Color(0xffE64949);
      icon = Icons.error_rounded;
      title = 'Something went wrong';
      break;
    case _AppNoticeType.info:
      accent = LogoColors.primary;
      icon = Icons.info_rounded;
      title = 'Information';
      break;
  }

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: EdgeInsets.zero,
      duration: const Duration(milliseconds: 3200),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(.18)),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark.withOpacity(.16),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .72, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 21),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: LogoColors.dark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LogoColors.dark.withOpacity(.68),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: messenger.hideCurrentSnackBar,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: LogoColors.dark.withOpacity(.35),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PrettyDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool required;
  final Widget? prefixIcon;

  const _PrettyDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.required = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: LogoColors.primary.withOpacity(.09),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: LogoColors.primary,
          size: 18,
        ),
      ),
      decoration: InputDecoration(
        labelText: required ? '$label*' : label,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LogoColors.dark.withOpacity(.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LogoColors.dark.withOpacity(.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
          const BorderSide(color: LogoColors.primary, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

/// ===========================================================================
/// WISHLIST (GLOBAL STATE)
/// ===========================================================================
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _loading = true;

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

  CollectionReference<Map<String, dynamic>> _wishlistCol(String uid) =>
      _db.collection('wishlists').doc(uid).collection('items');

  Future<void> _start() async {
    try {
      final user = await _ensureUser();
      await _subscription?.cancel();
      _subscription = _wishlistCol(user.uid)
          .orderBy('savedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _items
          ..clear()
          ..addEntries(snapshot.docs.map((doc) {
            final data = doc.data();
            final package = _TravelPackage.fromWishlistMap(data);
            final item = WishlistItem(
              id: data['packageId'] ?? package.heroTitle,
              title: data['title'] ?? package.title,
              subtitle: data['subtitle'] ?? package.durationText ?? package.country,
              imageUrl: data['imageUrl'],
              package: package,
            );
            return MapEntry(item.id, item);
          }));
        _loading = false;
        notifyListeners();
      }, onError: (Object error) {
        _loading = false;
        debugPrint('Wishlist Firestore error: $error');
        notifyListeners();
      });
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
    // Optimistic UI update; Firestore snapshot remains the source of truth.
    _items[item.id] = item;
    notifyListeners();
    try {
      await _wishlistCol(user.uid).doc(_docId(item.id)).set({
        'packageId': item.id,
        'title': item.title,
        'subtitle': item.subtitle,
        'imageUrl': item.imageUrl,
        ...item.package.toWishlistMap(),
        'savedAt': FieldValue.serverTimestamp(),
      });
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
      await _wishlistCol(user.uid).doc(_docId(id)).delete();
    } catch (e) {
      if (previous != null) _items[id] = previous;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// ===========================================================================
/// BOOKINGS (GLOBAL STATE)
/// ===========================================================================
enum BookingStatus { pending, confirmed, cancelled }

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus fromValue(String? value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_top_rounded;
      case BookingStatus.confirmed:
        return Icons.verified_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xffFFA033);
      case BookingStatus.confirmed:
        return const Color(0xff23B26D);
      case BookingStatus.cancelled:
        return const Color(0xffFF5C5C);
    }
  }
}

class BookingItem {
  final String id;
  final _TravelPackage package;
  final String name;
  final String email;
  final String mobile;
  final DateTime checkIn;
  final int adults;
  final int children;
  final String? selectedPackageOption;
  final DateTime createdAt;
  BookingStatus status;

  BookingItem({
    required this.id,
    required this.package,
    required this.name,
    required this.email,
    required this.mobile,
    required this.checkIn,
    required this.adults,
    required this.children,
    this.selectedPackageOption,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toFirestoreMap() => {
    'name': name,
    'email': email,
    'mobile': mobile,
    'checkIn': Timestamp.fromDate(checkIn),
    'adults': adults,
    'children': children,
    'selectedPackageOption': selectedPackageOption,
    'status': status.value,
    // Keep a complete package snapshot so Bookings can reopen the same
    // detail page even when the admin later edits or deletes the package.
    'package': package.toWishlistMap(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory BookingItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawPackage = data['package'];
    final packageMap = rawPackage is Map
        ? Map<String, dynamic>.from(rawPackage)
        : <String, dynamic>{};

    return BookingItem(
      id: doc.id,
      package: _TravelPackage.fromWishlistMap(packageMap),
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      checkIn: data['checkIn'] is Timestamp
          ? (data['checkIn'] as Timestamp).toDate()
          : DateTime.now(),
      adults: (data['adults'] as num?)?.toInt() ?? 1,
      children: (data['children'] as num?)?.toInt() ?? 0,
      selectedPackageOption: data['selectedPackageOption'],
      status: BookingStatusX.fromValue(data['status'] as String?),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class BookingsController extends ChangeNotifier {
  BookingsController._() {
    _start();
  }
  static final BookingsController instance = BookingsController._();

  final List<BookingItem> _bookings = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<BookingItem> get bookings => List.unmodifiable(_bookings);
  int get count => _bookings.length;

  String _docId(String id) => id.replaceAll('/', '_');

  Future<User?> _ensureUser() async {
    try {
      final existing = _auth.currentUser;
      if (existing != null) return existing;

      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Bookings Firebase Auth error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Bookings auth error: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _bookingsCol(String uid) =>
      _db.collection('bookings').doc(uid).collection('items');

  Future<void> _start() async {
    final user = await _ensureUser();
    if (user == null) return;

    try {
      await _subscription?.cancel();

      _subscription = _bookingsCol(user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
          _bookings
            ..clear()
            ..addAll(snapshot.docs.map(BookingItem.fromFirestore));
          notifyListeners();
        },
        onError: (Object error) {
          debugPrint('Bookings Firestore error: $error');
        },
      );
    } catch (e) {
      debugPrint('Bookings start error: $e');
    }
  }

  Future<void> add(BookingItem item) async {
    final user = await _ensureUser();
    if (user == null) {
      throw StateError(
        'Firebase user is unavailable. Booking was not saved.',
      );
    }

    final id = _docId(item.id);

    // Optimistic update keeps the current UI responsive. The Firestore
    // snapshot immediately replaces this with the persisted version.
    _bookings.insert(0, item);
    notifyListeners();

    try {
      await _bookingsCol(user.uid).doc(id).set(item.toFirestoreMap());
    } catch (e) {
      _bookings.removeWhere((b) => b.id == item.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String id, BookingStatus status) async {
    final user = await _ensureUser();
    if (user == null) return;

    final index = _bookings.indexWhere((b) => b.id == id);
    BookingStatus? previous;

    if (index != -1) {
      previous = _bookings[index].status;
      _bookings[index].status = status;
      notifyListeners();
    }

    try {
      await _bookingsCol(user.uid).doc(_docId(id)).update({
        'status': status.value,
      });
    } catch (e) {
      if (index != -1 && previous != null) {
        _bookings[index].status = previous;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final user = await _ensureUser();
    if (user == null) return;
    await _bookingsCol(user.uid).doc(_docId(id)).delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// ===========================================================================
/// SHARED ANIMATION HELPERS
/// ===========================================================================

/// Fades + slides a child up into place. Used everywhere a list/grid needs
/// a GetYourGuide-style staggered entrance: each item starts `index * 55ms`
/// after the previous one.
class _AnimatedEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  final Axis axis;

  const _AnimatedEntrance({
    required this.index,
    required this.child,
    this.axis = Axis.vertical,
  });

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _fade =
  CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: widget.axis == Axis.vertical
        ? const Offset(0, .12)
        : const Offset(.12, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 55 * widget.index.clamp(0, 12));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScale({required this.child, required this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _GlassIconButton({required this.icon, this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.black.withOpacity(.28),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 19, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final WishlistItem item;
  const _FavoriteButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishlistController.instance,
      builder: (context, _) {
        final saved = WishlistController.instance.isSaved(item.id);
        return _GlassIconButton(
          icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: saved ? const Color(0xffFF5C7A) : Colors.white,
          onTap: () => WishlistController.instance.toggle(item),
        );
      },
    );
  }
}

/// Small rounded rating pill, e.g. "★ 4.8 (365)". Sample/placeholder
/// rating shown for visual consistency with GetYourGuide-style cards —
/// wire this up to real review data when available.
class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviews;
  final bool light;

  const _RatingBadge({this.rating = 4.8, this.reviews = 240, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xffFFB020)),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: light ? Colors.white : LogoColors.dark,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '($reviews)',
          style: TextStyle(
            fontSize: 11,
            color: light ? Colors.white.withOpacity(.85) : LogoColors.dark.withOpacity(.5),
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// DASHBOARD SHELL
/// ===========================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(
      label: 'Home',
      icon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Wishlist',
      icon: Icons.favorite_rounded,
    ),
    _NavItem(
      label: 'Bookings',
      icon: Icons.confirmation_num_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_rounded,
    ),
  ];

  late final List<Widget> _pages = [
    const _HomeTab(),
    const _WishlistTab(),
    const _BookingsTab(),

    ProfilePage(
      onBookingsTap: () {
        setState(() {
          // Bookings is index 2
          _currentIndex = 2;
        });
      },
    ),
  ];


  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      extendBodyBehindAppBar: false,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: LogoColors.dark,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     _items[_currentIndex].label,
      //     style: const TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Navigator.push(
      //             context, MaterialPageRoute(builder: (context) => AboutUs()));
      //       },
      //       icon: const Icon(Icons.info),
      //       color: Colors.white,
      //     )
      //   ],
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, animation) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(fade);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        items: _items,
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}

/// A custom bottom navigation bar with a sliding pill indicator and
/// per-item scale/color animation, built only from logo colors.
class _AnimatedBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: itemWidth * currentIndex,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Center(
                  child: Container(
                    width: itemWidth,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [LogoColors.primary, LogoColors.light],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LogoColors.primary.withOpacity(.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final selected = index == currentIndex;
                  final item = items[index];
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onTap(index),
                      child: SizedBox(
                        height: 52,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: selected ? 11.5 : 11,
                            fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : LogoColors.dark.withOpacity(.55),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 250),
                                scale: selected ? 1.15 : 1.0,
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  item.icon,
                                  size: 22,
                                  color: selected
                                      ? Colors.white
                                      : LogoColors.dark.withOpacity(.55),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(item.label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ===========================================================================
/// HOME TAB — GetYourGuide-style: search bar, category chips, a parallax
/// hero carousel, and staggered-entrance experience cards.
/// ===========================================================================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _heroController = PageController(viewportFraction: .92);
  int _heroIndex = 0;

  late final Stream<List<AdminPackage>> _inboundStream =
  AdminPackageService.instance.streamByCategory(PackageCategory.inbound);
  late final Stream<List<AdminPackage>> _holidaysStream =
  AdminPackageService.instance.streamByCategory(PackageCategory.holidays);

  static const _heroImages = [
    'https://www.dadabhaitravel.ae/images/background/evening-desert-safari-dubai.jpg',
    'https://www.dadabhaitravel.ae/images/background/Quad-Bike-Ride.jpg',
  ];

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  Widget _homeLoading({double height = 180}) => SizedBox(
    height: height,
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _homeEmpty(String message, {double height = 120}) => SizedBox(
    height: height,
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          color: LogoColors.dark.withOpacity(.45),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100, top: 14),
      children: [
        const _SearchBar(),
        const SizedBox(height: 18),

        // Keep only the three requested top tabs.
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              _AnimatedEntrance(
                index: 0,
                axis: Axis.horizontal,
                child: _QuickLinkIcon(
                  label: 'InBound',
                  icon: Icons.holiday_village_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _InboundPage()),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _AnimatedEntrance(
                index: 1,
                axis: Axis.horizontal,
                child: _QuickLinkIcon(
                  label: 'Holidays',
                  icon: Icons.flight_takeoff,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _HolidaysPage()),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _AnimatedEntrance(
                index: 2,
                axis: Axis.horizontal,
                child: _QuickLinkIcon(
                  label: 'Cruises',
                  icon: Icons.directions_boat_filled_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _CruisesPage()),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Existing hero design is unchanged.
        SizedBox(
          height: 190,
          child: AnimatedBuilder(
            animation: _heroController,
            builder: (context, _) {
              return PageView.builder(
                controller: _heroController,
                itemCount: _heroImages.length,
                onPageChanged: (i) => setState(() => _heroIndex = i),
                itemBuilder: (context, index) {
                  double scale = 1;
                  if (_heroController.position.haveDimensions) {
                    final page = _heroController.page ??
                        _heroController.initialPage.toDouble();
                    scale =
                        (1 - ((page - index).abs() * .06)).clamp(.94, 1.0);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Transform.scale(
                      scale: scale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _heroImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: LogoColors.dark,
                                child: const Icon(
                                  Icons.image_rounded,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    LogoColors.dark.withOpacity(.8),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: LogoColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'FEATURED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Unlock your personal adventure in the UAE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroImages.length, (i) {
            final active = i == _heroIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? LogoColors.primary
                    : LogoColors.dark.withOpacity(.18),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        const SizedBox(height: 26),

        // UAE Activities now comes ONLY from Firebase Inbound packages.
        const _SectionTitle(
          'UAE Tours and Activities',
          subtitle: 'Top-rated things to do',
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<AdminPackage>>(
          stream: _inboundStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return _homeLoading(height: 210);
            }
            if (snap.hasError) {
              return _homeEmpty('Unable to load UAE activities right now.');
            }
            final items = snap.data ?? const <AdminPackage>[];
            if (items.isEmpty) {
              return _homeEmpty('No UAE activities have been added yet.');
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GridView.builder(
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
                  final pkg = _travelPackageFromAdmin(items[index]);
                  return _AnimatedEntrance(
                    index: index,
                    child: _ExperienceCard(
                      imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
                      title: pkg.title,
                      subtitle: pkg.durationText ?? pkg.country,
                      priceText: pkg.priceText,
                      package: pkg,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _PackageDetailPage(package: pkg),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 28),

        // Explore keeps the same destination-card design, but Holiday data is Firebase-only.
        const _SectionTitle(
          'Explore The World',
          subtitle: 'Holiday packages, handpicked for you',
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<AdminPackage>>(
          stream: _holidaysStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return _homeLoading(height: 168);
            }
            if (snap.hasError) {
              return _homeEmpty('Unable to load holiday packages right now.');
            }
            final items = snap.data ?? const <AdminPackage>[];
            if (items.isEmpty) {
              return _homeEmpty('No holiday packages have been added yet.');
            }
            return SizedBox(
              height: 168,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final pkg = _travelPackageFromAdmin(items[index]);
                  return _AnimatedEntrance(
                    index: index,
                    axis: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == items.length - 1 ? 0 : 12,
                      ),
                      child: _DestinationChipCard(
                        label: pkg.title,
                        imageUrl: pkg.images.isNotEmpty ? pkg.images.first : '',
                        priceText: pkg.priceText,
                        package: pkg,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _PackageDetailPage(package: pkg),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 28),
        const _SectionTitle('Services'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: const [
              _ServiceCard(icon: Icons.airplane_ticket_rounded, label: 'Air Tickets'),
              _ServiceCard(icon: Icons.hotel_rounded, label: 'Hotels'),
              _ServiceCard(icon: Icons.badge_rounded, label: 'Visas'),
              _ServiceCard(icon: Icons.beach_access_rounded, label: 'Holidays'),
            ],
          ),
        ),

        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LogoColors.dark, LogoColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: LogoColors.dark.withOpacity(.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dadabhai Travel LLC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const _ContactRow(
                  icon: Icons.location_on_rounded,
                  text:
                  'Office No: 103A1-4, A2 1st Floor, Gulf Towers, beside KM Trading, Oud Metha Road, Dubai',
                ),
                const SizedBox(height: 8),
                const _ContactRow(
                  icon: Icons.phone_rounded,
                  text: '+971 4 388 5566',
                ),
                const SizedBox(height: 8),
                const _ContactRow(
                  icon: Icons.mail,
                  text: 'bookings@dadabhaitravel.ae',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [LogoColors.primary, LogoColors.light])
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : LogoColors.dark.withOpacity(.12),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: LogoColors.primary.withOpacity(.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : LogoColors.dark.withOpacity(.65),
          ),
        ),
      ),
    );
  }
}

/// A circular gradient-icon quick-link button used in the horizontal
/// "InBound / Holidays / Cruises" row at the top of Home.
class _QuickLinkIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLinkIcon({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LogoColors.primary, LogoColors.light],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: LogoColors.primary.withOpacity(.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: LogoColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone page wrapper for the InBound tab content, reached via the
/// quick-link row on Home (previously a bottom-nav destination).
class _InboundPage extends StatelessWidget {
  const _InboundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('InBound Tours'),
        centerTitle: true,
      ),
      body: SafeArea(child: _InboundTab()),
    );
  }
}

/// Standalone page wrapper for the Holidays tab content.
class _HolidaysPage extends StatelessWidget {
  const _HolidaysPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Holiday Packages'),
        centerTitle: true,
      ),
      body: const SafeArea(child: _HolidaysTab()),
    );
  }
}

/// Standalone page wrapper for the Cruises tab content.
class _CruisesPage extends StatelessWidget {
  const _CruisesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cruises'),
        centerTitle: true,
      ),
      body: const SafeArea(child: _CruisesTab()),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: LogoColors.dark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: LogoColors.dark.withOpacity(.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// GetYourGuide-style vertical experience card: rounded photo up top with
/// a favorite heart + rating badge floating over it, then title / subtitle
/// / price beneath. Used across Home, Holidays and Cruises grids.
class _ExperienceCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? priceText;
  final VoidCallback onTap;
  final bool showRating;
  final _TravelPackage package;

  const _ExperienceCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.package,
    this.priceText,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistItem = WishlistItem(
      id: package.heroTitle,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      package: package,
    );
    return _TapScale(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl == null
                      ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [LogoColors.primary, LogoColors.light],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_rounded,
                          color: Colors.white70, size: 28),
                    ),
                  )
                      : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: LogoColors.dark.withOpacity(.12),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [LogoColors.primary, LogoColors.light],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded,
                            color: Colors.white70, size: 26),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _MiniFavorite(item: wishlistItem),
                  ),
                  if (showRating)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const _RatingBadge(),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.8,
                      color: LogoColors.dark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.8,
                      color: LogoColors.dark.withOpacity(.5),
                    ),
                  ),
                  if (priceText != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text("From", style: TextStyle(color: Colors.grey, fontSize: 11.5),),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          priceText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: LogoColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small solid (non-blur) favorite heart for use over lighter card
/// photos in grids, where the frosted-glass look isn't necessary.
class _MiniFavorite extends StatelessWidget {
  final WishlistItem item;
  const _MiniFavorite({required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishlistController.instance,
      builder: (context, _) {
        final saved = WishlistController.instance.isSaved(item.id);
        return GestureDetector(
          onTap: () => WishlistController.instance.toggle(item),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.9),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(saved),
                size: 14,
                color: saved ? const Color(0xffFF5C7A) : LogoColors.dark.withOpacity(.55),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A horizontal destination "chip card" for the Explore The World rail —
/// full-bleed photo, gradient, heart, title and price.
class _DestinationChipCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final String? priceText;
  final VoidCallback onTap;
  final _TravelPackage package;

  const _DestinationChipCard({
    required this.label,
    required this.imageUrl,
    required this.onTap,
    required this.package,
    this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistItem = WishlistItem(
      id: package.heroTitle,
      title: label,
      subtitle: package.country,
      imageUrl: imageUrl,
      package: package,
    );
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 168,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: LogoColors.dark,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: LogoColors.primary,
                child: const Icon(Icons.image_not_supported_rounded,
                    color: Colors.white70, size: 22),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    LogoColors.dark.withOpacity(.9),
                  ],
                  stops: const [0, .45, 1],
                ),
              ),
            ),
            Positioned(top: 8, right: 8, child: _MiniFavorite(item: wishlistItem)),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const _RatingBadge(light: true),
                  if (priceText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      priceText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A service tile with a soft icon badge instead of a stock photo — cleaner
/// and avoids depending on unrelated external images.
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LogoColors.primary, LogoColors.light],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: LogoColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// INBOUND TAB
/// ===========================================================================
class _InboundCategory {
  final String title;
  final String imageUrl;
  final String price;
  final List<_InboundItem> items;

  const _InboundCategory({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.items,
  });
}

class _InboundItem {
  final String name;
  final String? imageUrl;

  const _InboundItem({required this.name, this.imageUrl});
}

const _inboundCategories = [
  _InboundCategory(
    title: 'Desert Safari',
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Dune-Ride-Desert-Safari.jpg',
    price: "AED 120",
    items: [
      _InboundItem(name: 'Desert Safari'),
      _InboundItem(name: 'Quad Bike'),
      _InboundItem(name: 'Dune Buggy'),
      _InboundItem(name: 'Camel Safari'),
    ],
  ),
  _InboundCategory(
    title: 'Dhow Cruise',
    price: "AED 140",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Rustar-Cruise.jpg',
    items: [
      _InboundItem(name: 'Dhow Cruise'),
      _InboundItem(name: 'Yellow Boat'),
      _InboundItem(name: 'Dubai Marina'),
    ],
  ),
  _InboundCategory(
    title: 'Dubai Shopping Tour',
    price: "AED 230",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Dubai-Shopping-Tour.jpg',
    items: [
      _InboundItem(name: 'Dubai Shopping Tour'),
    ],
  ),
  _InboundCategory(
    title: 'City Tour',
    price: "AED 600",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Dubai-City-Tour.jpg',
    items: [
      _InboundItem(name: 'Dubai'),
      _InboundItem(name: 'Trio Package'),
      _InboundItem(name: 'Abu Dhabi'),
      _InboundItem(name: 'Sharjah & Ajman'),
      _InboundItem(name: 'East Coast'),
      _InboundItem(name: 'Al Ain'),
      _InboundItem(name: 'Big Bus'),
    ],
  ),
  _InboundCategory(
    title: 'Water Park',
    price: "AED 550",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Water-Park-in-Dubai.jpg',
    items: [
      _InboundItem(name: 'Atlantis'),
      _InboundItem(name: 'Dubai Dolphin'),
      _InboundItem(name: 'World Iceland'),
      _InboundItem(name: 'Wild Wadi'),
      _InboundItem(name: 'Yas Waterworld'),
      _InboundItem(name: 'Legoland Water Park'),
    ],
  ),
  _InboundCategory(
    title: 'Theme Park',
    price: "AED 350",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Motiongate-Dubai-Entrance-Tickets.jpg',
    items: [
      _InboundItem(name: 'Ferrari World'),
      _InboundItem(name: 'LEGOLAND Dubai'),
      _InboundItem(name: 'MOTIONGATE Dubai'),
      _InboundItem(name: 'Bollywood Parks Dubai'),
      _InboundItem(name: 'IMG Worlds of Adventure'),
      _InboundItem(name: 'Warner Bros. Abu Dhabi'),
    ],
  ),
  _InboundCategory(
    title: 'Burj Khalifa',
    price: "AED 180",
    imageUrl:
    'https://www.dadabhaitravel.ae/imgs/tours/Burj-Khalifa-General-Admission.jpg',
    items: [
      _InboundItem(
        name: '124 Floor General Admission',
        imageUrl:
        'https://www.dadabhaitravel.ae/imgs/tours/Burj-Khalifa-General-Admission.jpg',
      ),
      _InboundItem(
        name: '148 Floor Sky',
        imageUrl:
        'https://www.dadabhaitravel.ae/imgs/tours/Burj-Khalifa-Sky.jpg',
      ),
      _InboundItem(
        name: '124 Floor + Dubai Aquarium',
        imageUrl:
        'https://www.dadabhaitravel.ae/imgs/tours/Burj-Khalifa-124-Floor-and-Dubai-Aquarium.jpg',
      ),
      _InboundItem(
        name: '124 Floor with the Cafe',
        imageUrl:
        'https://www.dadabhaitravel.ae/imgs/tours/Burj-Khalifa-Tickets-with-the-Cafe.jpg',
      ),
    ],
  ),
  _InboundCategory(
    title: 'Other Activities',
    price: "AED 80",
    imageUrl:
    'https://www.dadabhaitravel.ae/images/background/Atlantis-Aquaventure-Dubai.jpg',
    items: [
      _InboundItem(name: 'Seaplane'),
      _InboundItem(name: 'Horseback Ride'),
      _InboundItem(name: 'Helicopter Ride'),
      _InboundItem(name: 'Emirates Zoo'),
      _InboundItem(name: 'World Island'),
      _InboundItem(name: 'La Perle by Dragone'),
      _InboundItem(name: 'Sindbad Air Balloon'),
      _InboundItem(name: 'Air Ballooning'),
      _InboundItem(name: 'Safari Park'),
      _InboundItem(name: 'Scuba Diving'),
      _InboundItem(name: 'VR Park Dubai'),
    ],
  ),
];

class _InboundTab extends StatefulWidget {
  const _InboundTab();

  @override
  State<_InboundTab> createState() => _InboundTabState();
}

class _InboundTabState extends State<_InboundTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search desert safari, cruises, tours…',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: StreamBuilder<List<AdminPackage>>(
            stream: AdminPackageService.instance
                .streamByCategory(PackageCategory.inbound),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Unable to load Inbound packages.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                );
              }

              final all = snap.data ?? const <AdminPackage>[];
              final packages = _query.isEmpty
                  ? all
                  : all.where((p) {
                return p.title.toLowerCase().contains(_query) ||
                    p.country.toLowerCase().contains(_query) ||
                    p.content.toLowerCase().contains(_query);
              }).toList();

              if (packages.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No Inbound packages have been added yet.'
                        : 'No matching Inbound packages.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final admin = packages[index];
                  final pkg = _travelPackageFromAdmin(admin);
                  return _AnimatedEntrance(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InboundFirebaseCard(
                        adminPackage: admin,
                        package: pkg,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _PackageDetailPage(package: pkg),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Same visual language as the original Inbound cards, now backed by Firestore.
class _InboundFirebaseCard extends StatelessWidget {
  final AdminPackage adminPackage;
  final _TravelPackage package;
  final VoidCallback onTap;

  const _InboundFirebaseCard({
    required this.adminPackage,
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = package.images.isNotEmpty ? package.images.first : null;
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 158,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: LogoColors.dark),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [LogoColors.primary, LogoColors.dark],
                  ),
                ),
                child: const Icon(Icons.image_rounded, color: Colors.white54, size: 34),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, LogoColors.dark.withOpacity(.9)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const _RatingBadge(),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          package.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          package.durationText ?? package.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 11,
                          ),
                        ),
                        if (package.priceText != null && package.priceText!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            package.priceText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboundCategoryCard extends StatelessWidget {
  final _InboundCategory category;
  final bool expanded;
  final VoidCallback onTap;

  const _InboundCategoryCard({
    required this.category,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    category.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: LogoColors.dark.withOpacity(.3),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: LogoColors.dark,
                      child: const Icon(Icons.image_rounded,
                          color: Colors.white54, size: 32),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          LogoColors.dark.withOpacity(.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const _RatingBadge(),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${category.items.length} activities',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 250),
                          turns: expanded ? 0.5 : 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState:
            expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _InboundItemsList(items: category.items, category: category),
            secondChild: const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _InboundItemsList extends StatelessWidget {
  final List<_InboundItem> items;
  final _InboundCategory category;
  const _InboundItemsList({required this.items, required this.category});

  void _openDetail(BuildContext context, _InboundItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PackageDetailPage(
          package: _packageFromInboundItem(item, category),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final withImages = items.where((i) => i.imageUrl != null).toList();
    final withoutImages = items.where((i) => i.imageUrl == null).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (withImages.isNotEmpty)
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: withImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = withImages[i];
                  return _TapScale(
                    onTap: () => _openDetail(context, item),
                    child: SizedBox(
                      width: 112,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              item.imageUrl!,
                              width: 112,
                              height: 74,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 112,
                                height: 74,
                                color: LogoColors.light.withOpacity(.15),
                                child: Icon(Icons.image_not_supported_rounded,
                                    color: LogoColors.primary, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: LogoColors.dark,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (withImages.isNotEmpty && withoutImages.isNotEmpty)
            const SizedBox(height: 12),
          if (withoutImages.isNotEmpty)
            Column(
              children: withoutImages
                  .map(
                    (item) => _TapScale(
                  onTap: () => _openDetail(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: LogoColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: LogoColors.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.place_rounded,
                              color: LogoColors.primary, size: 15),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: LogoColors.dark,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: LogoColors.dark.withOpacity(.3), size: 18),
                      ],
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

WishlistItem _wishlistItemFromPackage(_TravelPackage pkg) {
  return WishlistItem(
    id: pkg.heroTitle,
    title: pkg.title,
    subtitle: pkg.durationText ?? pkg.country,
    imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
    package: pkg,
  );
}

/// ===========================================================================
/// SHARED PACKAGE MODEL + DETAIL PAGE + BOOKING FORM
/// ===========================================================================
class _TravelPackage {
  final String title;
  final String heroTitle;
  final List<String> images;
  final String? priceText;
  final String? adultPriceText;
  final String? childPriceText;
  final String? durationText;
  final String country;
  final String about;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> faqs;
  final List<String>? packageOptions;
  final List<_ItineraryStop>? itinerary;

  const _TravelPackage({
    required this.title,
    required this.heroTitle,
    required this.images,
    this.priceText,
    this.adultPriceText,
    this.childPriceText,
    this.durationText,
    required this.country,
    required this.about,
    this.inclusions = const [],
    this.exclusions = const [],
    this.faqs = const [],
    this.packageOptions,
    this.itinerary,
  });

  Map<String, dynamic> toWishlistMap() => {
    'title': title,
    'heroTitle': heroTitle,
    'images': images,
    'priceText': priceText,
    'adultPriceText': adultPriceText,
    'childPriceText': childPriceText,
    'durationText': durationText,
    'country': country,
    'about': about,
    'inclusions': inclusions.take(5).toList(),
    'exclusions': exclusions.take(5).toList(),
    'faqs': faqs.take(5).toList(),
    'itinerary': itinerary?.map((stop) => {
      'title': stop.title,
      'subtitle': stop.subtitle,
      'duration': stop.duration,
      'admission': stop.admission,
      'passBy': stop.passBy,
    }).toList(),
  };

  factory _TravelPackage.fromWishlistMap(Map<String, dynamic> map) {
    final rawItinerary = map['itinerary'] as List<dynamic>?;
    return _TravelPackage(
      title: map['title'] ?? '',
      heroTitle: map['heroTitle'] ?? map['packageId'] ?? '',
      images: List<String>.from(map['images'] ?? const <String>[]),
      priceText: map['priceText'],
      adultPriceText: map['adultPriceText'] ?? map['priceText'],
      childPriceText: map['childPriceText'],
      durationText: map['durationText'],
      country: map['country'] ?? 'United Arab Emirates',
      about: map['about'] ?? '',
      inclusions: List<String>.from(map['inclusions'] ?? const <String>[]).take(5).toList(),
      exclusions: List<String>.from(map['exclusions'] ?? const <String>[]).take(5).toList(),
      faqs: List<String>.from(map['faqs'] ?? const <String>[]).take(5).toList(),
      itinerary: rawItinerary?.map((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        return _ItineraryStop(
          title: m['title'] ?? '',
          subtitle: m['subtitle'],
          duration: m['duration'],
          admission: m['admission'],
          passBy: m['passBy'] ?? false,
        );
      }).toList(),
    );
  }
}


const _desertSafariItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    subtitle: 'Pickup in a 4x4 Land Cruiser',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Al Awir Road',
    subtitle: 'Drive out towards the Dubai desert conservation area',
    passBy: true,
    icon: Icons.route_rounded,
  ),
  _ItineraryStop(
    title: 'Red Dunes Desert',
    subtitle: 'Dune bashing',
    duration: '45 minutes',
    admission: 'Included',
    icon: Icons.terrain_rounded,
  ),
  _ItineraryStop(
    title: 'Camel Farm',
    subtitle: 'Photo stop with camels',
    duration: '10 minutes',
    admission: 'Free viewing',
    icon: Icons.pets_rounded,
  ),
  _ItineraryStop(
    title: 'Al Marmoom Desert Camp',
    subtitle: 'Sandboarding, henna, shisha, BBQ dinner & belly dance show',
    duration: '3 hours',
    admission: 'Admission Ticket Included',
    icon: Icons.local_fire_department_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    subtitle: 'Return transfer',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _dhowCruiseItinerary = [
  _ItineraryStop(
    title: 'Dubai Marina Walk',
    subtitle: 'Boarding point',
    icon: Icons.directions_walk_rounded,
  ),
  _ItineraryStop(
    title: 'Boarding the Dhow',
    subtitle: 'Traditional wooden vessel',
    duration: '15 minutes',
    admission: 'Included',
    icon: Icons.directions_boat_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Dubai Marina Skyline',
    subtitle: 'Cruise past the marina towers',
    passBy: true,
    icon: Icons.location_city_rounded,
  ),
  _ItineraryStop(
    title: 'Ain Dubai (Bluewaters)',
    subtitle: "World's largest observation wheel",
    passBy: true,
    icon: Icons.album_rounded,
  ),
  _ItineraryStop(
    title: 'Buffet Dinner Onboard',
    subtitle: 'International buffet with live entertainment',
    duration: '2 hours',
    admission: 'Admission Ticket Included',
    icon: Icons.restaurant_rounded,
  ),
  _ItineraryStop(
    title: 'Return to Marina Walk',
    subtitle: 'Disembark',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _shoppingTourItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Deira Gold Souk',
    subtitle: 'Browse gold, diamonds & jewellery',
    duration: '40 minutes',
    admission: 'Free entry',
    icon: Icons.diamond_rounded,
  ),
  _ItineraryStop(
    title: 'Dubai Spice Souk',
    subtitle: 'Spices, perfumes & dried fruits',
    duration: '20 minutes',
    admission: 'Free entry',
    icon: Icons.storefront_rounded,
  ),
  _ItineraryStop(
    title: 'Abra Ride across Dubai Creek',
    subtitle: 'Traditional water taxi',
    duration: '10 minutes',
    admission: 'AED 1 per person',
    icon: Icons.directions_boat_rounded,
  ),
  _ItineraryStop(
    title: 'The Dubai Mall',
    subtitle: 'Free time for shopping',
    duration: '90 minutes',
    admission: 'Free entry',
    icon: Icons.shopping_bag_rounded,
  ),
  _ItineraryStop(
    title: 'Mall of the Emirates',
    subtitle: 'Ski Dubai viewing & shopping (time permitting)',
    passBy: true,
    icon: Icons.ac_unit_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _cityTourItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Dubai Museum & Al Fahidi Fort',
    subtitle: 'Heritage site',
    passBy: true,
    icon: Icons.museum_rounded,
  ),
  _ItineraryStop(
    title: 'Jumeirah Mosque',
    subtitle: 'Photo stop at one of the oldest mosques',
    duration: '10 minutes',
    admission: 'Exterior viewing',
    icon: Icons.mosque_rounded,
  ),
  _ItineraryStop(
    title: 'Burj Al Arab',
    subtitle: 'Photo stop from Jumeirah Beach',
    passBy: true,
    icon: Icons.apartment_rounded,
  ),
  _ItineraryStop(
    title: 'Palm Jumeirah & Atlantis',
    subtitle: 'Drive along the Palm to Atlantis The Palm',
    duration: '20 minutes',
    admission: 'Exterior viewing',
    icon: Icons.beach_access_rounded,
  ),
  _ItineraryStop(
    title: 'Downtown Dubai',
    subtitle: 'Burj Khalifa & Dubai Fountain photo stop',
    duration: '20 minutes',
    admission: 'Exterior viewing',
    icon: Icons.location_city_rounded,
  ),
  _ItineraryStop(
    title: 'Dubai Frame',
    subtitle: 'Photo stop (entry optional)',
    passBy: true,
    icon: Icons.crop_original_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _waterParkItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Arrival & Locker Check-in',
    subtitle: 'Collect wristband and locker key',
    duration: '15 minutes',
    admission: 'Included',
    icon: Icons.lock_rounded,
  ),
  _ItineraryStop(
    title: 'Full Day Water Park Access',
    subtitle: 'Slides, wave pools & rides',
    duration: 'Full day',
    admission: 'Admission Ticket Included',
    icon: Icons.pool_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    subtitle: 'End of day transfer',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _themeParkItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Arrival at Theme Park',
    subtitle: 'Ticket collection & entry',
    duration: '15 minutes',
    admission: 'Included',
    icon: Icons.confirmation_num_rounded,
  ),
  _ItineraryStop(
    title: 'Full Day Park Access',
    subtitle: 'Rides, shows & attractions',
    duration: 'Full day',
    admission: 'Admission Ticket Included',
    icon: Icons.attractions_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

const _burjKhalifaItinerary = [
  _ItineraryStop(
    title: 'The Dubai Mall Entrance',
    subtitle: 'Level B2 ticketing entrance',
    icon: Icons.meeting_room_rounded,
  ),
  _ItineraryStop(
    title: 'Multimedia Journey',
    subtitle: 'History of Dubai & Burj Khalifa exhibit',
    duration: '10 minutes',
    admission: 'Included',
    icon: Icons.museum_rounded,
  ),
  _ItineraryStop(
    title: "High-Speed Elevator",
    subtitle: 'Ride to level 124/125',
    duration: '1 minute',
    admission: 'Included',
    icon: Icons.elevator_rounded,
  ),
  _ItineraryStop(
    title: 'Observation Deck',
    subtitle: '360° views over Dubai',
    duration: '45 minutes',
    admission: 'Admission Ticket Included',
    icon: Icons.visibility_rounded,
  ),
  _ItineraryStop(
    title: 'Souvenir Shop',
    subtitle: 'Exit through the gift shop',
    passBy: true,
    icon: Icons.card_giftcard_rounded,
  ),
];

const _otherActivitiesItinerary = [
  _ItineraryStop(
    title: 'Hotel Pickup',
    icon: Icons.directions_car_filled_rounded,
  ),
  _ItineraryStop(
    title: 'Activity Briefing & Safety Check',
    subtitle: 'Equipment fitting and instructions',
    duration: '15 minutes',
    admission: 'Included',
    icon: Icons.health_and_safety_rounded,
  ),
  _ItineraryStop(
    title: 'Main Activity',
    subtitle: 'Guided experience',
    duration: 'Varies by activity',
    admission: 'Admission Ticket Included',
    icon: Icons.star_rounded,
  ),
  _ItineraryStop(
    title: 'Hotel Drop-off',
    passBy: true,
    icon: Icons.home_rounded,
  ),
];

/// Maps an inbound category title to its itinerary. Returns null if no
/// itinerary is defined for that title.
List<_ItineraryStop>? _inboundItineraryFor(String categoryTitle) {
  switch (categoryTitle) {
    case 'Desert Safari':
      return _desertSafariItinerary;
    case 'Dhow Cruise':
      return _dhowCruiseItinerary;
    case 'Dubai Shopping Tour':
      return _shoppingTourItinerary;
    case 'City Tour':
      return _cityTourItinerary;
    case 'Water Park':
      return _waterParkItinerary;
    case 'Theme Park':
      return _themeParkItinerary;
    case 'Burj Khalifa':
      return _burjKhalifaItinerary;
    case 'Other Activities':
      return _otherActivitiesItinerary;
    default:
      return null;
  }
}

_TravelPackage _travelPackageFromAdmin(AdminPackage p) {
  return _TravelPackage(
    title: p.title,
    heroTitle: 'admin_${p.id}',
    images: p.imageUrls,
    priceText: p.displayPriceText,
    adultPriceText: p.adultPriceText ?? p.priceText,
    childPriceText: p.childPriceText,
    durationText: p.durationText,
    country: p.country,
    about: p.content,
    inclusions: p.inclusions,
    exclusions: p.exclusions,
    faqs: p.faqs,
    itinerary: p.route.isEmpty
        ? null
        : p.route
        .map((r) => _ItineraryStop(
      title: r.title,
      subtitle: r.subtitle.isEmpty ? null : r.subtitle,
      duration: r.duration.isEmpty ? null : r.duration,
      admission: r.admission.isEmpty ? null : r.admission,
      passBy: r.passBy,
    ))
        .toList(),
  );
}

_TravelPackage _packageFromInboundCategory(_InboundCategory category) {
  return _TravelPackage(
    title: category.title,
    heroTitle: category.title,
    images: [category.imageUrl],
    country: 'United Arab Emirates',
    about:
    'Explore our ${category.title} experiences across the UAE. Tap Book Now to send an enquiry and one of our team will confirm timings, pricing and pickup.',
    inclusions: category.items.map((i) => i.name).toList(),
    itinerary: _inboundItineraryFor(category.title),
  );
}

_TravelPackage _packageFromInboundItem(_InboundItem item, _InboundCategory category) {
  return _TravelPackage(
    title: item.name,
    heroTitle: item.name,
    images: [item.imageUrl ?? category.imageUrl],
    country: 'United Arab Emirates',
    about:
    'Part of our ${category.title} experiences in the UAE. Tap Book Now to send an enquiry and one of our team will confirm timings, pricing and pickup.',
    itinerary: _inboundItineraryFor(category.title),
  );
}

_TravelPackage _findHolidayPackage(String title) {
  return _holidayPackages.firstWhere(
        (p) => p.title == title,
    orElse: () => _holidayPackages.first,
  );
}

const _holidayPackages = [
  _TravelPackage(
    title: 'Qatar',
    heroTitle: 'Discover the Allure of Doha, Qatar',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/Doha-Package-From-UAE.jpg',
    ],
    priceText: 'AED 2360',
    durationText: '03 Nights/04 Days',
    country: 'Qatar',
    about:
    'Step into the heart of the Middle East with our exclusive Doha City Package - a perfect blend of culture, luxury and adventure. Qatar invites you to explore its capital, Doha, one of the world\'s most exciting emerging destinations, with iconic skyline views, world-class shopping, timeless souqs and rich heritage sites.',
    inclusions: [
      'Return flights with Air Arabia from Sharjah to Doha',
      '4-star hotel accommodation in central Doha',
      'Daily breakfast',
      'Doha City Tour',
      'Sunset Dhow Cruise',
    ],
    exclusions: [
      'International air ticket (if not travelling via Air Arabia route)',
      'Entry visa (if applicable)',
      'Any expense of personal nature',
    ],
    // FIXED: was previously a Dubai city-tour itinerary — now the actual
    // Doha routing that matches this package's destination.
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Doha',
        subtitle: 'Hamad International Airport transfer to hotel',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'The Pearl-Qatar',
        subtitle: 'Waterfront district',
        passBy: true,
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Doha Corniche',
        subtitle: 'Sightseeing',
        duration: '20 minutes',
        admission: 'Free',
        icon: Icons.water_rounded,
      ),
      _ItineraryStop(
        title: 'Souq Waqif',
        subtitle: 'Traditional market, shops & cafés',
        duration: '45 minutes',
        admission: 'Free entry',
        icon: Icons.storefront_rounded,
      ),
      _ItineraryStop(
        title: 'Museum of Islamic Art',
        subtitle: 'Photo stop',
        passBy: true,
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Sunset Dhow Cruise',
        subtitle: 'Traditional dhow along Doha Bay',
        duration: '1 hour',
        admission: 'Admission Ticket Included',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Malaysia',
    heroTitle: 'Malaysia Package for 04 Nights/05 Days',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/malaysia-holidays.jpg',
      'https://www.dadabhaitravel.ae/images/Holiday/photo/Malaysia-Package-from-Dubai.jpg',
    ],
    priceText: 'AED 799',
    durationText: '04 Nights/05 Days',
    country: 'Malaysia',
    about:
    'The above rates are per person sharing a double room. Spend two nights in vibrant Kuala Lumpur and two nights in the cool highlands of Genting, combining city sightseeing with theme-park thrills.',
    inclusions: [
      '02 nights accommodation in Kuala Lumpur',
      '02 nights accommodation in Genting Highlands',
      'Daily breakfast',
      'Half day city tour of Kuala Lumpur',
      'Genting Indoor Theme Park and Snow World ticket',
      'All the way transportation',
      'All taxes and service charges',
    ],
    exclusions: [
      'International air ticket',
      'Entry visa to Malaysia',
      'Any expense of personal nature',
    ],
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Kuala Lumpur',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Petronas Twin Towers',
        subtitle: 'Photo stop',
        passBy: true,
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Half Day Kuala Lumpur City Tour',
        subtitle: 'King\'s Palace, National Monument & Merdeka Square',
        duration: '4 hours',
        admission: 'Included',
        icon: Icons.tour_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Genting Highlands',
        subtitle: 'Scenic drive to the highlands',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Genting Skyway Cable Car',
        subtitle: 'Ride up to Genting Highlands',
        duration: '15 minutes',
        admission: 'Included',
        icon: Icons.cable_rounded,
      ),
      _ItineraryStop(
        title: 'Genting Indoor Theme Park & Snow World',
        subtitle: 'Rides & snow play',
        duration: '3 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.ac_unit_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Kuala Lumpur',
        subtitle: 'Transfer back to the city',
        passBy: true,
        icon: Icons.directions_car_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Italy & Austria',
    heroTitle: 'Italy & Austria Package for 08 Nights/09 Days',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/italy-package.jpg',
      'https://www.dadabhaitravel.ae/images/Holiday/photo/italy-holidays.jpg',
    ],
    priceText: 'AED 2499',
    durationText: '08 Nights/09 Days',
    country: 'Italy',
    about:
    'The above rates are per person sharing a double room. Discover Vienna, Innsbruck, Venice and Rome on this classic European itinerary that mixes imperial palaces, alpine scenery and ancient ruins.',
    inclusions: [
      '2 nights stay in Vienna',
      '2 nights stay in Innsbruck',
      '2 nights stay in Venice',
      '2 nights stay in Rome',
      'Daily breakfast',
      'Half day city & Schonbrunn Palace tour in Vienna',
      'Half day tour of Classical Rome',
      'All taxes and service charges',
    ],
    exclusions: [
      'Schengen visa',
      'International air ticket',
      'Train ticket/pass (2nd class, 4-day Swiss & Austria pass AED 1500 pp)',
      'Any other expenses or services not specified above',
    ],
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Vienna',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Schönbrunn Palace',
        subtitle: 'Half day city & palace tour',
        duration: '4 hours',
        admission: 'Included',
        icon: Icons.castle_rounded,
      ),
      _ItineraryStop(
        title: 'Vienna State Opera',
        subtitle: 'Photo stop',
        passBy: true,
        icon: Icons.theater_comedy_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Innsbruck',
        subtitle: 'Scenic Alpine drive',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Innsbruck Old Town',
        subtitle: 'Golden Roof & city centre',
        duration: '2 hours',
        admission: 'Free walking',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Venice',
        subtitle: 'Cross the border into Italy',
        passBy: true,
        icon: Icons.directions_car_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Venice Canals & St. Mark\'s Square',
        subtitle: 'Gondola-lined streets and landmarks',
        duration: '3 hours',
        admission: 'Free walking',
        icon: Icons.directions_boat_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Rome',
        subtitle: 'High-speed train or coach',
        passBy: true,
        icon: Icons.train_rounded,
      ),
      _ItineraryStop(
        title: 'Half Day Classical Rome Tour',
        subtitle: 'Colosseum, Roman Forum & Trevi Fountain',
        duration: '4 hours',
        admission: 'Included',
        icon: Icons.account_balance_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Kenya',
    heroTitle: 'Kenya Safari Holiday Package',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/kenya-holidays.jpg',
    ],
    country: 'Kenya',
    about:
    'Experience the wild heart of Africa with a Kenya safari package - game drives across the Masai Mara, encounters with the Big Five and unforgettable sunsets over the savannah. Contact us for the latest itineraries and rates.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Nairobi',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Masai Mara',
        subtitle: 'Road or light-aircraft transfer',
        passBy: true,
        icon: Icons.flight_rounded,
      ),
      _ItineraryStop(
        title: 'Masai Mara Game Drive',
        subtitle: 'Search for the Big Five',
        duration: 'Half day',
        admission: 'Park fees included',
        icon: Icons.pets_rounded,
      ),
      _ItineraryStop(
        title: 'Maasai Village Visit',
        subtitle: 'Cultural experience with the local community',
        duration: '1 hour',
        admission: 'Included',
        icon: Icons.groups_rounded,
      ),
      _ItineraryStop(
        title: 'Sundowner Game Drive',
        subtitle: 'Sunset over the savannah',
        duration: '2 hours',
        admission: 'Included',
        icon: Icons.wb_twilight_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Nairobi',
        subtitle: 'Transfer back to the city',
        passBy: true,
        icon: Icons.directions_car_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Mauritius',
    heroTitle: 'Mauritius Holiday Package',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/Mauritius-Maldives-Package.jpg',
    ],
    country: 'Mauritius',
    about:
    'Turquoise lagoons, powder-white beaches and lush tropical scenery make Mauritius one of the Indian Ocean\'s most romantic getaways. Contact us for the latest itineraries and rates.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Mauritius',
        subtitle: 'Airport to resort transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Resort Check-in & Beach Time',
        subtitle: 'Powder-white beaches & lagoon',
        passBy: true,
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Île aux Cerfs Catamaran Trip',
        subtitle: 'Island hopping with lunch',
        duration: 'Full day',
        admission: 'Admission Ticket Included',
        icon: Icons.sailing_rounded,
      ),
      _ItineraryStop(
        title: 'Chamarel Seven Coloured Earth',
        subtitle: 'Geological landmark & waterfall',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.landscape_rounded,
      ),
      _ItineraryStop(
        title: 'Port Louis City Tour',
        subtitle: 'Central Market & Caudan Waterfront',
        passBy: true,
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Resort to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Spain',
    heroTitle: 'Spain Holiday Package',
    images: [
      'https://www.dadabhaitravel.ae/images/Holiday/photo/Spain-barcelona-package.jpg',
    ],
    country: 'Spain',
    about:
    'From Barcelona\'s Gaudi architecture to Madrid\'s world-class museums, a Spain holiday blends culture, cuisine and coastline. Contact us for the latest itineraries and rates.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Barcelona',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Sagrada Família',
        subtitle: 'Gaudí\'s iconic basilica',
        duration: '1.5 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.church_rounded,
      ),
      _ItineraryStop(
        title: 'Park Güell & Las Ramblas',
        subtitle: 'City sightseeing',
        passBy: true,
        icon: Icons.park_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Madrid',
        subtitle: 'High-speed AVE train',
        passBy: true,
        icon: Icons.train_rounded,
      ),
      _ItineraryStop(
        title: 'Prado Museum',
        subtitle: 'World-class art collection',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Plaza Mayor & Royal Palace',
        subtitle: 'Historic city centre',
        passBy: true,
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Georgia',
    heroTitle: 'Georgia Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=395,height=400,dpr=2/tour_img/5d41eeda56cd4ab02d0800a578b218b382df092b1ffa7743f69e103b2fb2e4d4.png",
      "https://cdn.getyourguide.com/image/format=auto,fit=cover,gravity=auto,quality=60,width=182,height=182,dpr=2/location_img/5ffeb392eb81e.jpeg"
    ],
    country: 'Georgia',
    about:
    'Tbilisi\'s old town, the Caucasus mountains and the wine region of Kakheti make Georgia an increasingly popular escape. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Tbilisi',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Old Town Tbilisi',
        subtitle: 'Narikala Fortress & cobblestone streets',
        duration: '3 hours',
        admission: 'Free walking',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Sulphur Bath District',
        subtitle: 'Photo stop',
        passBy: true,
        icon: Icons.hot_tub_rounded,
      ),
      _ItineraryStop(
        title: 'Kakheti Wine Region',
        subtitle: 'Vineyard tour & wine tasting',
        duration: 'Full day',
        admission: 'Admission Ticket Included',
        icon: Icons.wine_bar_rounded,
      ),
      _ItineraryStop(
        title: 'Caucasus Mountains Drive',
        subtitle: 'Scenic mountain views',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Oman',
    heroTitle: 'Oman Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/4c45927055c853ca098721ab897091b06ee1f1a3e25125a4a278dd176eb9c71e.jpeg"
    ],
    country: 'Oman',
    about:
    'Rugged mountains, golden dunes and a dramatic coastline just a short drive from Dubai make Oman a favourite quick getaway. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Dubai to Oman Border Crossing',
        subtitle: 'Land transfer with visa processing',
        icon: Icons.directions_car_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Musandam or Muscat Route',
        subtitle: 'Scenic coastal mountain drive',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Dhow Cruise in the Fjords',
        subtitle: 'Dolphin watching & swimming stop',
        duration: '3 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Sultan Qaboos Grand Mosque',
        subtitle: 'Photo stop',
        passBy: true,
        icon: Icons.mosque_rounded,
      ),
      _ItineraryStop(
        title: 'Wadi Exploration',
        subtitle: 'Natural pools & rugged mountains',
        duration: '2 hours',
        admission: 'Free access',
        icon: Icons.water_drop_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Dubai',
        subtitle: 'Evening transfer back',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'London',
    heroTitle: 'London Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/a78ad5ee7afb6c51c8410ed1ef24efb59a3cfab7b0e9fbaa4349e0a9c356cc51.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/b977aa6d5872eab66d7edf64b44856e5d3727854d05f51bfe27a2f244e218099.jpg"
    ],
    country: 'United Kingdom',
    about:
    'Iconic landmarks, world-class shopping and West End theatre - a London holiday package built around the sights you can\'t miss. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in London',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Tower of London & Tower Bridge',
        subtitle: 'Historic landmark visit',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.castle_rounded,
      ),
      _ItineraryStop(
        title: 'Buckingham Palace',
        subtitle: 'Changing of the Guard',
        passBy: true,
        icon: Icons.account_balance_rounded,
      ),
      _ItineraryStop(
        title: 'London Eye',
        subtitle: 'Panoramic views over the Thames',
        duration: '45 minutes',
        admission: 'Admission Ticket Included',
        icon: Icons.album_rounded,
      ),
      _ItineraryStop(
        title: 'West End Theatre Show',
        subtitle: 'Evening show (optional add-on)',
        duration: '2.5 hours',
        admission: 'Not included',
        icon: Icons.theater_comedy_rounded,
      ),
      _ItineraryStop(
        title: 'Oxford Street & Covent Garden',
        subtitle: 'Shopping',
        passBy: true,
        icon: Icons.shopping_bag_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Maldives',
    heroTitle: 'Maldives Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/b292501721384aa228a230db53e07eb4ceb2f649e58e76da697f7468202a2e47.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/c7d84c70012f2373a29afa4e73033d0225a07639d1729922430e823a8db528fe.jpg"
    ],
    country: 'Maldives',
    about:
    'Overwater villas, private beaches and world-famous diving - the Maldives is the ultimate barefoot-luxury island escape. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival at Malé Airport',
        subtitle: 'Speedboat or seaplane transfer to resort',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Overwater Villa Check-in',
        subtitle: 'Private beach & lagoon views',
        passBy: true,
        icon: Icons.villa_rounded,
      ),
      _ItineraryStop(
        title: 'Snorkeling Excursion',
        subtitle: 'House reef exploration',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.scuba_diving_rounded,
      ),
      _ItineraryStop(
        title: 'Sunset Dolphin Cruise',
        subtitle: 'Evening boat trip',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Sandbank Picnic',
        subtitle: 'Private island lunch (optional add-on)',
        passBy: true,
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Resort to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'France',
    heroTitle: 'France Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/59556593ddb3d843d78ca3e21dcf6171571a9e7f8802aac463e6110ad4ea5617.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/7dd487f8a44ab0c657943c3620225e7e66965e10a9b6e1ff8f7bfc3614236af7.jpg"
    ],
    country: 'France',
    about:
    'From the boulevards of Paris to the lavender fields of Provence, a France holiday package can be tailored to romance, culture or countryside. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Paris',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Eiffel Tower',
        subtitle: 'Summit access & views over Paris',
        duration: '1.5 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Louvre Museum',
        subtitle: 'Home to the Mona Lisa',
        duration: '2 hours',
        admission: 'Admission Ticket Included',
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Champs-Élysées & Arc de Triomphe',
        subtitle: 'Shopping avenue',
        passBy: true,
        icon: Icons.shopping_bag_rounded,
      ),
      _ItineraryStop(
        title: 'Seine River Cruise',
        subtitle: 'Evening cruise past illuminated landmarks',
        duration: '1 hour',
        admission: 'Admission Ticket Included',
        icon: Icons.directions_boat_rounded,
      ),
      _ItineraryStop(
        title: 'Provence Lavender Fields',
        subtitle: 'Optional countryside day trip',
        passBy: true,
        icon: Icons.local_florist_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Austria',
    heroTitle: 'Austria Holiday Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/c68d8fd0abcd04536c3506b76b6a123e1647419705da0fe4cb802ec6edb31c8f.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/14ce27b592f895de9596d1d292f72bbb966a464c9c04aa74380abeb08af4a4f2.jpg",
    ],
    country: 'Austria',
    about:
    'Imperial Vienna, alpine Innsbruck and the music of Salzburg make Austria a classic European holiday choice. Contact us for the full itinerary and current pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Arrival in Vienna',
        subtitle: 'Airport to hotel transfer',
        icon: Icons.flight_land_rounded,
      ),
      _ItineraryStop(
        title: 'Schönbrunn Palace & Vienna City Tour',
        subtitle: 'Imperial palace & city landmarks',
        duration: '4 hours',
        admission: 'Included',
        icon: Icons.castle_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Salzburg',
        subtitle: 'Scenic Alpine route',
        passBy: true,
        icon: Icons.directions_car_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Mozart\'s Birthplace & Old Town Salzburg',
        subtitle: 'Sound of Music filming locations',
        duration: '2.5 hours',
        admission: 'Free walking',
        icon: Icons.music_note_rounded,
      ),
      _ItineraryStop(
        title: 'Transfer to Innsbruck',
        subtitle: 'Continue into the Tyrolean Alps',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Innsbruck Old Town',
        subtitle: 'Golden Roof & mountain backdrop',
        duration: '2 hours',
        admission: 'Free walking',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Departure',
        subtitle: 'Hotel to airport transfer',
        passBy: true,
        icon: Icons.flight_takeoff_rounded,
      ),
    ],
  ),
];

const _cruiseRegions = [
  _TravelPackage(
    title: 'Caribbean',
    heroTitle: 'Caribbean Package for 7 to 14 Nights',
    images: [
      'https://www.dadabhaitravel.ae/images/cruise/Caribbean%20Cruises.jpg',
    ],
    country: 'United States',
    about:
    'More ships cruise the Caribbean islands than any other region in the world, and Miami is considered the cruise capital of the world. Caribbean cruises offer crystal clear waters, pristine beaches, abundant water sports and duty-free shopping, divided into the Western, Eastern and Southern Caribbean regions - each with its own distinct ports of call.',
    packageOptions: [
      '7-nights Eastern/Western Caribbean from Fort Lauderdale, FL (Princess Cruise Line, from \$799)',
      '7-nights Western Caribbean from Miami, FL (Norwegian Cruise Line, from \$599)',
    ],
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Fort Lauderdale/Miami, FL',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Day at Sea',
        subtitle: 'Onboard pools, shows & dining',
        passBy: true,
        icon: Icons.waves_rounded,
      ),
      _ItineraryStop(
        title: 'Nassau, Bahamas',
        subtitle: 'Port call — beaches & shore excursions',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Cozumel or St. Thomas',
        subtitle: 'Port call — snorkeling & duty-free shopping',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.scuba_diving_rounded,
      ),
      _ItineraryStop(
        title: 'Private Island (Cruise Line Beach Day)',
        subtitle: 'Line-operated island stop',
        passBy: true,
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Port',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Bahamas',
    heroTitle: 'Bahamas Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/c253e75646e9b1da364cd8b948d9529b395dd9c5c3be1df0ec5261e23f83b21f.jpg"
    ],
    country: 'The Bahamas',
    about:
    'Short, easy sailings to crystal-clear waters and powder-white beaches make the Bahamas one of the most popular cruise getaways from Florida. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Florida',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Nassau',
        subtitle: 'Colonial architecture & straw markets',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Great Stirrup Cay / CocoCay',
        subtitle: 'Private island beach day',
        duration: 'Full day',
        admission: 'Included',
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Port',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Northern Europe or Baltic',
    heroTitle: 'Northern Europe / Baltic Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/64747b05d3bba.jpeg"
    ],
    country: 'Europe',
    about:
    'Sail between historic capitals such as Copenhagen, Stockholm and St. Petersburg on a Northern Europe or Baltic cruise. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Copenhagen, Denmark',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Stockholm, Sweden',
        subtitle: 'Gamla Stan old town & royal palace',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.account_balance_rounded,
      ),
      _ItineraryStop(
        title: 'Helsinki, Finland',
        subtitle: 'Senate Square & city sightseeing',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'St. Petersburg, Russia',
        subtitle: 'Hermitage Museum & Peterhof Palace',
        passBy: true,
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Tallinn, Estonia',
        subtitle: 'Medieval old town walk',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.castle_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Copenhagen',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Greek Isles',
    heroTitle: 'Greek Isles Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/ec516ebbc6902669.jpeg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/7e608520968abc0c.jpeg"
    ],
    country: 'Greece',
    about:
    'Whitewashed villages, ancient ruins and turquoise water - a Greek Isles cruise island-hops through Mykonos, Santorini and beyond. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Athens (Piraeus), Greece',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Mykonos',
        subtitle: 'Whitewashed alleys & windmills',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Santorini',
        subtitle: 'Caldera views from Oia & Fira',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.landscape_rounded,
      ),
      _ItineraryStop(
        title: 'Rhodes',
        subtitle: 'Medieval old town',
        passBy: true,
        icon: Icons.castle_rounded,
      ),
      _ItineraryStop(
        title: 'Kusadasi, Turkey',
        subtitle: 'Ephesus ancient ruins',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.account_balance_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Athens',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Mediterranean',
    heroTitle: 'Mediterranean Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/414dde6bd08b7c5149d62df6acdaf3c9522c7142df64dc17f5e2366caeff8612.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/df2f897457880352358f79f94ec7c11d31b8f25da20956d75e0fb9026a92c07a.jpg"
    ],
    country: 'Europe',
    about:
    'From the Riviera to the Amalfi Coast, a Mediterranean cruise combines art, history and coastline across some of Europe\'s most iconic port cities. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Barcelona, Spain',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'French Riviera (Marseille/Nice)',
        subtitle: 'Coastal port call',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Rome (Civitavecchia)',
        subtitle: 'Colosseum & Vatican City',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.account_balance_rounded,
      ),
      _ItineraryStop(
        title: 'Amalfi Coast / Naples',
        subtitle: 'Cliffside villages',
        passBy: true,
        icon: Icons.landscape_rounded,
      ),
      _ItineraryStop(
        title: 'Florence/Pisa (Livorno)',
        subtitle: 'Leaning Tower & Renaissance art',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Barcelona',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Alaskan',
    heroTitle: 'Alaskan Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/5cba20ecd0cff.jpeg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/5cba213e260b6.jpeg"
    ],
    country: 'United States',
    about:
    'Glaciers, fjords and wildlife-rich wilderness make an Alaskan cruise one of the most scenic sailings in the world. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Seattle, WA or Vancouver, BC',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Juneau, Alaska',
        subtitle: 'Mendenhall Glacier & whale watching',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.ac_unit_rounded,
      ),
      _ItineraryStop(
        title: 'Skagway, Alaska',
        subtitle: 'Gold Rush era town & scenic railway',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.train_rounded,
      ),
      _ItineraryStop(
        title: 'Glacier Bay National Park',
        subtitle: 'Scenic glacier cruising',
        passBy: true,
        icon: Icons.terrain_rounded,
      ),
      _ItineraryStop(
        title: 'Ketchikan, Alaska',
        subtitle: 'Totem poles & wildlife',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.pets_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Port',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Asia',
    heroTitle: 'Asia Cruise Package',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/9fe08db7b14f7f104e5198d523ae6f02c3f4b092d5820094a963a7e6cbabedbe.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,width=1210,dpr=2/tour_img/557e5d7f503ff60b4f1294d0ed4c2214d07b5726b080d4acbf50f9ba69f75a3a.jpg"
    ],
    country: 'Asia',
    about:
    'From Singapore to Hong Kong, an Asia cruise blends bustling cities, temples and island beaches into one itinerary. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Singapore',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Penang, Malaysia',
        subtitle: 'Georgetown heritage & street food',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.storefront_rounded,
      ),
      _ItineraryStop(
        title: 'Phuket, Thailand',
        subtitle: 'Beaches & island hopping',
        passBy: true,
        icon: Icons.beach_access_rounded,
      ),
      _ItineraryStop(
        title: 'Ho Chi Minh City, Vietnam',
        subtitle: 'War Remnants Museum & city tour',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Hong Kong',
        subtitle: 'Victoria Peak & skyline views',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.location_city_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Singapore',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
  _TravelPackage(
    title: 'Arabian Gulf - Eid Sailing',
    heroTitle: 'Arabian Gulf Cruise - Eid Sailing',
    images: [
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/1b68b43f3da19d41048b2fde0ea68404cd0b2347ecb201527b62430af4d50c1d.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/18d371b940bb3d36c0b25a887f1c80468504dff02084d7df25d5295b2b08e4ca.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/50d30d12d53cf9aae4ae240f7e52b49e3a8b92ffe7b038d0b22cbf162695e485.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/1217d19bcb6d24ec477632be0404b556aafcac50bbeaa8190b7a833ff14714f2.jpg",
      "https://cdn.getyourguide.com/image/format=auto,fit=crop,gravity=auto,quality=60,height=730,dpr=2/tour_img/c25a70ec7657c4d837983f0d5d7b194f69ebddaf206f738a014454888a2a97e7.jpg"
    ],
    country: 'United Arab Emirates',
    about:
    'Sail the Arabian Gulf from Dubai, calling at ports across the region - a popular short getaway, especially around Eid. Contact us for current sailings and pricing.',
    itinerary: const [
      _ItineraryStop(
        title: 'Embarkation — Dubai (Port Rashid/Mina Rashid)',
        subtitle: 'Board your cruise ship',
        icon: Icons.directions_boat_filled_rounded,
      ),
      _ItineraryStop(
        title: 'Abu Dhabi',
        subtitle: 'Sheikh Zayed Grand Mosque & Louvre Abu Dhabi',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.mosque_rounded,
      ),
      _ItineraryStop(
        title: 'Sir Bani Yas Island',
        subtitle: 'Wildlife reserve & safari',
        passBy: true,
        icon: Icons.pets_rounded,
      ),
      _ItineraryStop(
        title: 'Doha, Qatar',
        subtitle: 'Souq Waqif & Museum of Islamic Art',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.museum_rounded,
      ),
      _ItineraryStop(
        title: 'Muscat, Oman',
        subtitle: 'Sultan Qaboos Grand Mosque & old town',
        duration: 'Full day',
        admission: 'Shore excursions extra',
        icon: Icons.mosque_rounded,
      ),
      _ItineraryStop(
        title: 'Return to Dubai',
        subtitle: 'Disembarkation',
        passBy: true,
        icon: Icons.home_rounded,
      ),
    ],
  ),
];

/// ===========================================================================
/// SEARCH
/// ===========================================================================
class _SearchEntry {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final _TravelPackage package;
  const _SearchEntry({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.package,
  });
}

List<_SearchEntry> _buildSearchIndex() {
  final entries = <_SearchEntry>[];

  for (final cat in _inboundCategories) {
    entries.add(_SearchEntry(
      title: cat.title,
      subtitle: 'UAE Activity · ${cat.items.length} experiences',
      imageUrl: cat.imageUrl,
      package: _packageFromInboundCategory(cat),
    ));
    for (final item in cat.items) {
      entries.add(_SearchEntry(
        title: item.name,
        subtitle: cat.title,
        imageUrl: item.imageUrl ?? cat.imageUrl,
        package: _packageFromInboundItem(item, cat),
      ));
    }
  }

  for (final pkg in _holidayPackages) {
    entries.add(_SearchEntry(
      title: pkg.title,
      subtitle: 'Holiday Package · ${pkg.country}',
      imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
      package: pkg,
    ));
  }

  for (final pkg in _cruiseRegions) {
    entries.add(_SearchEntry(
      title: pkg.title,
      subtitle: 'Cruise · ${pkg.country}',
      imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
      package: pkg,
    ));
  }

  return entries;
}

final List<_SearchEntry> _searchIndex = _buildSearchIndex();

/// A tappable search bar — placed at the top of every tab. Tapping opens
/// the full search page (rather than filtering inline), matching the
/// GetYourGuide-style flow already used for the Home tab.
class _SearchBar extends StatelessWidget {
  final String hint;
  const _SearchBar({this.hint = 'Search things to do, tours & tickets'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: _TapScale(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const _SearchPage()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: LogoColors.dark.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: LogoColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(fontSize: 13, color: LogoColors.dark.withOpacity(.45)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: LogoColors.light.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune_rounded, size: 16, color: LogoColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPage extends StatefulWidget {
  const _SearchPage();

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SearchEntry> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _searchIndex.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q) ||
          e.package.country.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 42,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: LogoColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search tours, activities, holidays…',
                  ),
                  style: TextStyle(fontSize: 13.5, color: LogoColors.dark),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
                  child: Icon(Icons.close_rounded, size: 18, color: LogoColors.dark.withOpacity(.4)),
                ),
            ],
          ),
        ),
      ),
      body: _query.isEmpty
          ? Center(
        child: Text('Start typing to search',
            style: TextStyle(color: LogoColors.dark.withOpacity(.4), fontSize: 13)),
      )
          : results.isEmpty
          ? Center(
        child: Text('No results for "$_query"',
            style: TextStyle(color: LogoColors.dark.withOpacity(.5), fontSize: 13)),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final r = results[i];
          return _TapScale(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _PackageDetailPage(package: r.package)),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: LogoColors.dark.withOpacity(.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: r.imageUrl == null
                        ? Container(
                      width: 58,
                      height: 58,
                      color: LogoColors.light.withOpacity(.15),
                      child: Icon(Icons.image_rounded, color: LogoColors.primary, size: 20),
                    )
                        : Image.network(
                      r.imageUrl!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 58,
                        height: 58,
                        color: LogoColors.light.withOpacity(.15),
                        child: Icon(Icons.image_not_supported_rounded,
                            color: LogoColors.primary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13, color: LogoColors.dark)),
                        const SizedBox(height: 3),
                        Text(r.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: LogoColors.dark.withOpacity(.5))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: LogoColors.dark.withOpacity(.3)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HOLIDAYS TAB
/// ---------------------------------------------------------------------
class _HolidaysTab extends StatelessWidget {
  const _HolidaysTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        const _SearchBar(hint: 'Search holiday packages…'),
        const SizedBox(height: 18),
        const _SectionTitle(
          'Explore The World',
          subtitle: 'Hand-picked holiday packages, tailored to your budget',
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<AdminPackage>>(
          stream: AdminPackageService.instance
              .streamByCategory(PackageCategory.holidays),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'Unable to load holiday packages.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                ),
              );
            }
            final all = (snap.data ?? const <AdminPackage>[])
                .map(_travelPackageFromAdmin)
                .toList();
            if (all.isEmpty) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No holiday packages have been added yet.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .78,
              ),
              itemBuilder: (context, index) {
                final pkg = all[index];
                return _AnimatedEntrance(
                  index: index,
                  child: _ExperienceCard(
                    imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
                    title: pkg.title,
                    subtitle: pkg.durationText ?? pkg.country,
                    priceText: pkg.priceText,
                    package: pkg,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _PackageDetailPage(package: pkg),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// WISHLIST TAB
/// ---------------------------------------------------------------------
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

/// ---------------------------------------------------------------------
/// BOOKINGS TAB — every successful "Check availability" enquiry lands
/// here, newest first, with a status badge. Tapping one opens the same
/// package detail page, but with the Book Now bar replaced by the
/// booking's current status.
/// ---------------------------------------------------------------------
///
class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BookingsController.instance,
      builder: (context, _) {
        final bookings = BookingsController.instance.bookings;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [
            const _SectionTitle('My Bookings', subtitle: 'Track the status of your enquiries'),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.confirmation_num_outlined,
                        size: 46, color: LogoColors.dark.withOpacity(.2)),
                    const SizedBox(height: 12),
                    Text('No bookings yet',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: LogoColors.dark.withOpacity(.5))),
                    const SizedBox(height: 4),
                    Text(
                      'Submit "Check availability" on any package to see it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: LogoColors.dark.withOpacity(.4)),
                    ),
                  ],
                ),
              )
            else
              for (int i = 0; i < bookings.length; i++)
                _AnimatedEntrance(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BookingCard(
                      booking: bookings[i],
                      dateLabel:
                      '${_fmt(bookings[i].checkIn)}',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _PackageDetailPage(
                            package: bookings[i].package,
                            booking: bookings[i],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingItem booking;
  final String dateLabel;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.dateLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pkg = booking.package;
    final imageUrl = pkg.images.isNotEmpty ? pkg.images.first : null;
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark.withOpacity(.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl == null
                  ? Container(
                width: 64,
                height: 64,
                color: LogoColors.light.withOpacity(.15),
                child: Icon(Icons.card_travel_rounded, color: LogoColors.primary, size: 22),
              )
                  : Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: LogoColors.light.withOpacity(.15),
                  child: Icon(Icons.image_not_supported_rounded,
                      color: LogoColors.primary, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5, color: LogoColors.dark),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11, color: LogoColors.dark.withOpacity(.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: LogoColors.dark.withOpacity(.5)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: booking.status.color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(booking.status.icon, size: 12, color: booking.status.color),
                        const SizedBox(width: 5),
                        Text(
                          booking.status.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: booking.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: LogoColors.dark.withOpacity(.3)),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// CRUISES TAB
/// ---------------------------------------------------------------------
class _CruisesTab extends StatelessWidget {
  const _CruisesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        const _SearchBar(hint: 'Search cruise regions…'),
        const SizedBox(height: 18),
        const _SectionTitle(
          'Cruise World Wide',
          subtitle: 'Unpack once, wake up somewhere new',
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<AdminPackage>>(
          stream: AdminPackageService.instance
              .streamByCategory(PackageCategory.cruises),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'Unable to load cruise packages.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                ),
              );
            }
            final packages = (snap.data ?? const <AdminPackage>[])
                .map(_travelPackageFromAdmin)
                .toList();
            if (packages.isEmpty) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No cruise packages have been added yet.',
                    style: TextStyle(color: LogoColors.dark.withOpacity(.5)),
                  ),
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: packages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .78,
              ),
              itemBuilder: (context, index) {
                final pkg = packages[index];
                return _AnimatedEntrance(
                  index: index,
                  child: _ExperienceCard(
                    imageUrl: pkg.images.isNotEmpty ? pkg.images.first : null,
                    title: pkg.title,
                    subtitle: pkg.durationText ?? pkg.country,
                    priceText: pkg.priceText,
                    package: pkg,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _PackageDetailPage(package: pkg),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// DETAIL PAGE — GetYourGuide style: hero image carousel with floating
/// frosted-glass back/share/favorite buttons, a rounded content sheet
/// overlapping the photo, expandable inclusion/exclusion sections and a
/// sticky booking bar.
///
/// NOTE: this page intentionally has NO entrance/route-adjacent animation
/// on the floating header buttons or the booking bar (no SlideTransition,
/// AnimatedSlide, AnimatedPositioned, or Transform on them). Those all
/// caused "RenderBox was not laid out" crashes when tapped quickly or
/// during route transitions. They are now plain static Positioned
/// widgets, which are always laid out synchronously as part of the
/// Stack's normal layout pass and can never be hit-tested or painted
/// before they have a size.
/// ---------------------------------------------------------------------
class _PackageDetailPage extends StatefulWidget {
  final _TravelPackage package;
  final BookingItem? booking;

  const _PackageDetailPage({
    required this.package,
    this.booking,
  });

  @override
  State<_PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<_PackageDetailPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openBookingForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _BookingFormPage(package: widget.package),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;
    final images = pkg.images;

    return Scaffold(
      extendBody: true,
      backgroundColor: LogoColors.bg,

      body: SafeArea(
        top: false,
        child: Stack(
          children: [

            /// MAIN SCROLL CONTENT
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                SliverAppBar(
                  expandedHeight: 300,
                  pinned: false,
                  backgroundColor: LogoColors.dark,
                  automaticallyImplyLeading: false,

                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [

                        images.isEmpty
                            ? Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                LogoColors.primary,
                                LogoColors.dark
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        )

                            : PageView.builder(
                          controller: _controller,
                          itemCount: images.length,
                          onPageChanged: (i){
                            setState(() {
                              _index = i;
                            });
                          },
                          itemBuilder: (_,i){

                            return Image.network(
                              images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_,__,___){
                                return Container(
                                  color: LogoColors.dark,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            );
                          },
                        ),


                        /// DARK OVERLAY
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(.35),
                                  Colors.transparent
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),


                        if(images.length > 1)

                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,

                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: List.generate(
                                images.length,
                                    (i){

                                  return AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds:200),

                                    margin:
                                    const EdgeInsets.symmetric(
                                        horizontal:3),

                                    width:
                                    i==_index ? 20 : 6,

                                    height:6,

                                    decoration:
                                    BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),


                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0,-20),

                    child: Container(

                      padding:
                      const EdgeInsets.fromLTRB(
                          20,25,20,150),

                      decoration:
                      const BoxDecoration(

                        color: LogoColors.bg,

                        borderRadius:
                        BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),


                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            pkg.title,

                            style:
                            const TextStyle(
                              fontSize:22,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),


                          const SizedBox(height:10),


                          Text(
                            pkg.about,

                            style:
                            TextStyle(
                              fontSize:14,
                              height:1.5,
                              color:
                              LogoColors.dark
                                  .withOpacity(.7),
                            ),
                          ),


                          const SizedBox(height:20),

                          if ((pkg.adultPriceText != null && pkg.adultPriceText!.isNotEmpty) ||
                              (pkg.childPriceText != null && pkg.childPriceText!.isNotEmpty)) ...[
                            _PriceTypeSelector(
                              adultPrice: pkg.adultPriceText ?? pkg.priceText,
                              childPrice: pkg.childPriceText,
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (pkg.itinerary != null && pkg.itinerary!.isNotEmpty) ...[
                            _ItineraryTimeline(stops: pkg.itinerary!),
                            const SizedBox(height: 16),
                          ],


                          if(pkg.inclusions.isNotEmpty)

                            _ExpandableSection(
                              title:"What's included",
                              icon:
                              Icons.check_circle,
                              accent:
                              LogoColors.primary,
                              items:
                              pkg.inclusions,
                              initiallyExpanded:true,
                            ),
                          SizedBox(height: 10,),


                          if(pkg.exclusions.isNotEmpty)

                            _ExpandableSection(
                              title:"Not included",
                              icon:
                              Icons.cancel,
                              accent:
                              Colors.redAccent,
                              items:
                              pkg.exclusions,
                            ),

                          if (pkg.faqs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _ExpandableSection(
                              title: 'FAQs',
                              icon: Icons.help_rounded,
                              accent: LogoColors.primary,
                              items: pkg.faqs,
                            ),
                          ],

                        ],
                      ),
                    ),
                  ),
                )

              ],
            ),



            /// TOP BUTTONS
            Positioned(
              top:40,
              left:15,
              right:15,

              child: Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children:[

                  _GlassIconButton(

                    icon:
                    Icons.arrow_back,

                    onTap:(){

                      Navigator.of(context)
                          .maybePop();

                    },
                  ),


                  Row(

                    children:[

                      _GlassIconButton(
                        icon:
                        Icons.share,
                        onTap:(){},
                      ),


                      const SizedBox(width:8),


                      _FavoriteButton(item: _wishlistItemFromPackage(pkg)),

                    ],
                  )

                ],
              ),
            ),



            /// BOTTOM BAR
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: widget.booking != null

                  // ==========================================
                  // EXISTING BOOKING → SHOW STATUS
                  // ==========================================
                      ? Container(
                    height: 55,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: widget.booking!.status.color.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.booking!.status.color.withOpacity(.30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.booking!.status.icon,
                          color: widget.booking!.status.color,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.booking!.status.label,
                          style: TextStyle(
                            color: widget.booking!.status.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )

                  // ==========================================
                  // NORMAL PACKAGE → SHOW BOOK NOW
                  // ==========================================
                      : SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: _TapScale(
                      onTap: _openBookingForm,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              LogoColors.primary,
                              LogoColors.light,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}

class _PriceTypeSelector extends StatefulWidget {
  final String? adultPrice;
  final String? childPrice;

  const _PriceTypeSelector({this.adultPrice, this.childPrice});

  @override
  State<_PriceTypeSelector> createState() => _PriceTypeSelectorState();
}

class _PriceTypeSelectorState extends State<_PriceTypeSelector> {
  late String _selected =
  (widget.adultPrice != null && widget.adultPrice!.isNotEmpty) ? 'Adult' : 'Child';

  @override
  Widget build(BuildContext context) {
    final options = <String>[
      if (widget.adultPrice != null && widget.adultPrice!.isNotEmpty) 'Adult',
      if (widget.childPrice != null && widget.childPrice!.isNotEmpty) 'Child',
    ];
    if (options.isEmpty) return const SizedBox.shrink();
    if (!options.contains(_selected)) _selected = options.first;
    final value = _selected == 'Adult' ? widget.adultPrice : widget.childPrice;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _PrettyDropdown<String>(
              value: _selected,
              label: 'Price for',
              prefixIcon: const Icon(
                Icons.payments_rounded,
                color: LogoColors.primary,
                size: 19,
              ),
              items: options
                  .map(
                    (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        type == 'Adult'
                            ? Icons.person_rounded
                            : Icons.child_care_rounded,
                        color: LogoColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        type,
                        style: TextStyle(
                          color: LogoColors.dark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$_selected price',
                  style: TextStyle(fontSize: 10.5, color: LogoColors.dark.withOpacity(.5))),
              const SizedBox(height: 3),
              Text(value ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: LogoColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: LogoColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: LogoColors.dark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An animated, collapsible section (What's included / Not included /
/// Sailing options) — tap the header to expand or collapse with a smooth
/// AnimatedSize + rotating chevron, GetYourGuide-style.
class _ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(widget.icon, size: 17, color: widget.accent),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: LogoColors.dark,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.items.length}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: LogoColors.dark.withOpacity(.4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: LogoColors.dark.withOpacity(.4), size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: _expanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: widget.items
                    .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 5, color: widget.accent),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: LogoColors.dark.withOpacity(.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// BOOKING FORM
/// ===========================================================================
class _BookingFormPage extends StatefulWidget {
  final _TravelPackage package;

  const _BookingFormPage({required this.package});

  @override
  State<_BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<_BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 1;
  int _children = 0;
  String? _selectedPackage;
  String? _selectedCountry;

  static const _countries = [
    'United Arab Emirates', 'United States', 'United Kingdom', 'Canada',
    'India', 'Pakistan', 'Bangladesh', 'Sri Lanka', 'Philippines', 'Egypt',
    'Saudi Arabia', 'Qatar', 'Kuwait', 'Oman', 'Bahrain', 'Jordan',
    'Australia', 'Germany', 'France', 'Italy', 'Spain', 'Russia', 'China',
    'South Africa', 'Nigeria', 'Kenya', 'Others',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.package.packageOptions != null &&
        widget.package.packageOptions!.isNotEmpty) {
      _selectedPackage = widget.package.packageOptions!.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final initial = isCheckIn
        ? (_checkIn ?? now)
        : (_checkOut ?? (_checkIn ?? now).add(const Duration(days: 3)));

    DateTime selected = initial.isBefore(now) ? now : initial;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: LogoColors.dark.withOpacity(.38),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: .96, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, alignment: Alignment.bottomCenter, child: child),
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                padding: EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  MediaQuery.of(context).padding.bottom + 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LogoColors.dark.withOpacity(.18),
                      blurRadius: 32,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: LogoColors.dark.withOpacity(.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [LogoColors.primary, LogoColors.light],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckIn ? 'Select travel date' : 'Select return date',
                                style: TextStyle(
                                  color: LogoColors.dark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, .15),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                child: Text(
                                  _fmt(selected),
                                  key: ValueKey(selected),
                                  style: TextStyle(
                                    color: LogoColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: Icon(
                            Icons.close_rounded,
                            color: LogoColors.dark.withOpacity(.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: LogoColors.primary,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: LogoColors.dark,
                        ),
                        datePickerTheme: DatePickerThemeData(
                          backgroundColor: Colors.white,
                          headerBackgroundColor: Colors.white,
                          headerForegroundColor: LogoColors.dark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          dayShape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selected,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 730)),
                        onDateChanged: (value) {
                          setSheetState(() => selected = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, selected),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: LogoColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirm Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && _checkOut!.isBefore(picked)) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null) {
      _showAppNotice(
        context,
        'Please select your travel date before continuing.',
        type: _AppNoticeType.warning,
      );
      return;
    }

    // Create booking
    final booking = BookingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      package: widget.package,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      checkIn: _checkIn!,
      adults: _adults,
      children: _children,
      selectedPackageOption: _selectedPackage,
      status: BookingStatus.pending,
    );

    // Save to Firebase. The Bookings tab is listening to the same Firestore
    // collection, so no design/UI changes are needed there.
    try {
      await BookingsController.instance.add(booking);
    } catch (e) {
      if (!mounted) return;
      _showAppNotice(
        context,
        'Unable to save booking. $e',
        type: _AppNoticeType.error,
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: LogoColors.primary.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: LogoColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Booking Submitted'),
          ],
        ),
        content: const Text(
          'Your trip has been added to My Bookings. '
              'One of our staff will contact you shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(context);       // close booking form
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: LogoColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, {bool required = false}) {
    return InputDecoration(
      labelText: required ? '$label*' : label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LogoColors.dark.withOpacity(.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LogoColors.dark.withOpacity(.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LogoColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        title: const Text('Send Enquiry'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
          children: [
            _AnimatedEntrance(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LogoColors.dark, LogoColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.card_travel_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            _AnimatedEntrance(
              index: 1,
              child: TextFormField(
                controller: _nameCtrl,
                decoration: _decoration('Name', required: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedEntrance(
              index: 2,
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Email address', required: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedEntrance(
              index: 3,
              child: TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: _decoration('Mobile Number', required: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),

            _AnimatedEntrance(
              index: 4,
              child: Expanded(
                child: InkWell(
                  onTap: () => _pickDate(isCheckIn: true),
                  child: InputDecorator(
                    decoration: _decoration('Date', required: true),
                    child: Text(_checkIn == null ? '' : _fmt(_checkIn!)),
                  ),
                ),
              ),
            ),

            if (pkg.packageOptions != null && pkg.packageOptions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _AnimatedEntrance(
                index: 5,
                child: _PrettyDropdown<String>(
                  value: _selectedPackage,
                  label: 'Select Package',
                  required: true,
                  prefixIcon: const Icon(
                    Icons.luggage_rounded,
                    color: LogoColors.primary,
                    size: 19,
                  ),
                  items: pkg.packageOptions!
                      .map(
                        (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: LogoColors.dark,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPackage = v),
                ),
              ),
            ],

            const SizedBox(height: 18),
            Text(
              'Number Of Pax*',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: LogoColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            _AnimatedEntrance(
              index: 6,
              child: _CounterField(
                label: 'Adult(s)',
                value: _adults,
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => _adults = v),
              ),
            ),
            const SizedBox(height: 8),
            _AnimatedEntrance(
              index: 7,
              child: _CounterField(
                label: 'Child(ren)',
                value: _children,
                min: 0,
                max: 10,
                onChanged: (v) => setState(() => _children = v),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: _TapScale(
                onTap: _submit,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [LogoColors.primary, LogoColors.light],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LogoColors.primary.withOpacity(.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Check availability',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small stepper counter used for Adults/Children in the booking form.
/// Capped at [max] (10, matching dadabhaitravel.ae's booking widgets),
/// with an animated number swap on change.
class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LogoColors.dark.withOpacity(.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: LogoColors.dark,
                  ),
                ),
                Text(label == "Adult(s)"?"(Age 13-99)":"(Age 12 and younger)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12),)
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: LogoColors.dark,
                ),
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? LogoColors.primary.withOpacity(.12)
              : LogoColors.dark.withOpacity(.05),
        ),
        child: Icon(
          icon,
          size: 17,
          color: enabled ? LogoColors.primary : LogoColors.dark.withOpacity(.25),
        ),
      ),
    );
  }
}

class _ItineraryStop {
  final String title;
  final String? subtitle;      // e.g. "Heritage Site", "Visit to spice souq"
  final String? duration;      // e.g. "15 minutes"
  final String? admission;     // e.g. "Admission Ticket Free"
  final bool passBy;           // true = small dot, no number, no duration/admission row
  final IconData icon;

  const _ItineraryStop({
    required this.title,
    this.subtitle,
    this.duration,
    this.admission,
    this.passBy = false,
    this.icon = Icons.place_rounded,
  });
}
class _ItineraryTimeline extends StatefulWidget {
  final List<_ItineraryStop> stops;
  final bool initiallyExpanded;

  const _ItineraryTimeline({
    required this.stops,
    this.initiallyExpanded = true,
  });

  @override
  State<_ItineraryTimeline> createState() => _ItineraryTimelineState();
}

class _ItineraryTimelineState extends State<_ItineraryTimeline> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    int stopNumber = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 17,
                    color: LogoColors.primary,
                  ),
                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'Itinerary',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: LogoColors.dark,
                      ),
                    ),
                  ),


                  const SizedBox(width: 6),

                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: LogoColors.dark.withOpacity(.4),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: _expanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                6,
              ),
              child: Column(
                children: [
                  for (int i = 0; i < widget.stops.length; i++)
                    _buildStop(
                      widget.stops[i],
                      isLast: i == widget.stops.length - 1,
                      number: widget.stops[i].passBy
                          ? null
                          : ++stopNumber,
                    ),
                ],
              ),
            )
                : const SizedBox(
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStop(
      _ItineraryStop stop, {
        required bool isLast,
        int? number,
      }) {
    final bool numbered = number != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              numbered
                  ? Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      LogoColors.primary,
                      LogoColors.light,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      LogoColors.primary.withOpacity(.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
                  : Container(
                width: 12,
                height: 12,
                margin:
                const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LogoColors.dark.withOpacity(.85),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      LogoColors.dark.withOpacity(.25),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin:
                    const EdgeInsets.symmetric(vertical: 2),
                    color:
                    LogoColors.dark.withOpacity(.15),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(bottom: 18, top: 2),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: stop.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: LogoColors.dark,
                          ),
                        ),
                        if (stop.passBy)
                          TextSpan(
                            text: '  (Pass By)',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w500,
                              fontSize: 12,
                              color: LogoColors.dark
                                  .withOpacity(.45),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (stop.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      stop.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: LogoColors.dark
                            .withOpacity(.6),
                      ),
                    ),
                  ],

                  if (stop.duration != null) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: LogoColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          stop.duration!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: LogoColors.dark
                                .withOpacity(.65),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (stop.admission != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 14,
                          color: LogoColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            stop.admission!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: LogoColors.dark
                                  .withOpacity(.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
