part of 'dashboard.dart';

/// Bookings feature split from dashboard.dart.
///
/// This is a `part` file so the existing private dashboard models/widgets
/// remain in the same Dart library. Booking persistence and navigation logic
/// are unchanged.

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
  final int infant;
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
    required this.infant,
    this.selectedPackageOption,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toSqlMap() => {
    'name': name,
    'email': email,
    'mobile': mobile,
    'checkIn': checkIn.toUtc().toIso8601String().replaceFirst('T', ' ').split('.').first,
    'adults': adults,
    'children': children,
    'infant': infant,
    'selectedPackageOption': selectedPackageOption,
    'status': status.value,
    // Keep a complete package snapshot so Bookings can reopen the same
    // detail page even when the admin later edits or deletes the package.
    'package_json': jsonEncode(package.toWishlistMap()),
  };

  factory BookingItem.fromRow(Map<String, dynamic> row) {
    final packageJson = row['package_json'];
    final packageMap = packageJson == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(packageJson.toString()));

    DateTime parseCheckIn(dynamic raw) {
      if (raw == null) return DateTime.now();
      return DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return BookingItem(
      id: row['id']?.toString() ?? '',
      package: _TravelPackage.fromWishlistMap(packageMap),
      name: row['name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      mobile: row['mobile']?.toString() ?? '',
      checkIn: parseCheckIn(row['checkIn']),
      adults: int.tryParse('${row['adults']}') ?? 1,
      children: int.tryParse('${row['children']}') ?? 0,
      infant: int.tryParse('${row['infant']}') ?? 0,
      selectedPackageOption: row['selectedPackageOption']?.toString(),
      status: BookingStatusX.fromValue(row['status']?.toString()),
      createdAt: parseCheckIn(row['createdAt']),
    );
  }
}

class BookingsController extends ChangeNotifier {
  BookingsController._() {
    _start();
  }
  static final BookingsController instance = BookingsController._();

  final List<BookingItem> _bookings = [];
  final UserDataMySQLService _db = UserDataMySQLService.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _pollTimer;
  String? _lastHash;
  bool _refreshing = false;

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

  Future<void> _refresh(String uid) async {
    if (_refreshing) return;

    _refreshing = true;

    try {
      final rows =
      await _db.fetchBookings(uid);

      final hash =
      jsonEncode(rows);

      if (hash == _lastHash) {
        return;
      }

      _lastHash = hash;

      _bookings
        ..clear()
        ..addAll(
          rows.map(
            BookingItem.fromRow,
          ),
        );

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Bookings refresh error: $e',
      );
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _start() async {
    final user = await _ensureUser();
    if (user == null) return;

    try {
      _pollTimer?.cancel();
      await _refresh(user.uid);
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh(user.uid));
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

    // Optimistic update keeps the current UI responsive. The next poll
    // cycle immediately replaces this with the persisted version.
    _bookings.insert(0, item);
    notifyListeners();

    try {
      await _db.insertBooking(id: id, uid: user.uid, row: item.toSqlMap());
      _lastHash = null;
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
      await _db.updateBookingStatus(user.uid, _docId(id), status.value);
      _lastHash = null;
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
    await _db.deleteBooking(user.uid, _docId(id));
    _lastHash = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

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
                      dateLabel: _fmt(bookings[i].checkIn),

                      onDelete: () async {
                        final booking = bookings[i];

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Delete Booking?',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Are you sure you want to delete "${booking.package.title}" booking?',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: LogoColors.dark.withOpacity(.65),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: LogoColors.dark.withOpacity(.60),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) return;

                        try {
                          await BookingsController.instance.remove(booking.id);

                          if (!context.mounted) return;

                          _showAppNotice(
                            context,
                            'Booking deleted successfully.',
                            type: _AppNoticeType.success,
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          _showAppNotice(
                            context,
                            'Unable to delete booking. $e',
                            type: _AppNoticeType.error,
                          );
                        }
                      },

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
  final VoidCallback onDelete;

  const _BookingCard({
    required this.booking,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = booking.package;
    final imageUrl = pkg.images.isNotEmpty ? pkg.images.first : null;

    return _TapScale(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LogoColors.dark.withOpacity(.055)),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark.withOpacity(.065),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 126,
              child: imageUrl == null
                  ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [LogoColors.primary, LogoColors.light],
                  ),
                ),
                child: const Icon(
                  Icons.luggage_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              )
                  : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: LogoColors.primary.withOpacity(.12),
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    color: LogoColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 6, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LogoColors.dark,
                        fontSize: 13.2,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 13,
                          color: LogoColors.dark.withOpacity(.38),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LogoColors.dark.withOpacity(.50),
                              fontSize: 10.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: booking.status.color.withOpacity(.11),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            booking.status.icon,
                            size: 12,
                            color: booking.status.color,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              booking.status.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.2,
                                fontWeight: FontWeight.w800,
                                color: booking.status.color,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Delete booking',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: const Color(0xffE64949).withOpacity(.85),
                    size: 20,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: LogoColors.dark.withOpacity(.23),
                  size: 14,
                ),
              ],
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
