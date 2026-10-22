import 'dart:typed_data';

import 'package:dadabhaitravel/view/pages/admin/admin_mysql_service.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package.dart';
import 'package:dadabhaitravel/view/pages/admin/admin_package_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';

import 'package:dadabhaitravel/view/pages/dashboard.dart' show LogoColors;


enum _AdminNoticeType { success, warning, error, info }

void _showAdminNotice(
    BuildContext context,
    String message, {
      _AdminNoticeType type = _AdminNoticeType.info,
    }) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final Color accent;
  final IconData icon;
  final String title;

  switch (type) {
    case _AdminNoticeType.success:
      accent = const Color(0xff23B26D);
      icon = Icons.check_circle_rounded;
      title = 'Updated';
      break;
    case _AdminNoticeType.warning:
      accent = const Color(0xffF59F00);
      icon = Icons.warning_amber_rounded;
      title = 'Attention';
      break;
    case _AdminNoticeType.error:
      accent = const Color(0xffE64949);
      icon = Icons.error_rounded;
      title = 'Action failed';
      break;
    case _AdminNoticeType.info:
      accent = LogoColors.primary;
      icon = Icons.info_rounded;
      title = 'Information';
      break;
  }

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
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

/// Entry point: a list of every admin package with Add / Edit / Delete.
/// Push this from wherever the admin should be able to reach it (e.g. a
/// button on the Profile page — see integration notes).
class AdminPackagesPage extends StatefulWidget {
  const AdminPackagesPage({super.key});

  @override
  State<AdminPackagesPage> createState() =>
      _AdminPackagesPageState();
}

class _AdminPackagesPageState extends State<AdminPackagesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      floatingActionButton:
      _tabController.index == 0
          ? _ResponsiveAddPackageButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AdminPackageFormPage(),
            ),
          );
        },
      )
          : null,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;

            final content = Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ManagePackagesTab(),
                  _AdminBookingsTab(),
                ],
              ),
            );

            if (desktop) {
              return Row(
                children: [
                  _AdminSidebar(tabController: _tabController),
                  Expanded(
                    child: Column(
                      children: [
                        _AdminTopBar(tabController: _tabController),
                        content,
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _AdminDashboardHeader(tabController: _tabController),
                content,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminSidebar extends StatefulWidget {
  final TabController tabController;
  const _AdminSidebar({required this.tabController});

  @override
  State<_AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<_AdminSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChange);
    _entranceCtrl.dispose();
    super.dispose();
  }

  static const _items = [
    (icon: Icons.inventory_2_rounded, label: 'Manage Packages'),
    (icon: Icons.confirmation_num_rounded, label: 'Bookings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        width: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LogoColors.dark, LogoColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < _items.length; i++)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 380 + (i * 90)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(-14 * (1 - value), 0),
                      child: child,
                    ),
                  ),
                  child: _SidebarItem(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    selected: widget.tabController.index == i,
                    onTap: () => widget.tabController.animateTo(i),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_rounded,
                          color: Colors.white, size: 15),
                      SizedBox(width: 7),
                      Text(
                        'Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? Colors.white
                : (_hovering
                ? Colors.white.withOpacity(.10)
                : Colors.transparent),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 19,
                color: widget.selected
                    ? LogoColors.primary
                    : Colors.white.withOpacity(.85),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.selected
                        ? LogoColors.primary
                        : Colors.white.withOpacity(.85),
                    fontSize: 12.5,
                    fontWeight:
                    widget.selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final TabController tabController;
  const _AdminTopBar({required this.tabController});

  static const _titles = ['Manage Packages', 'Bookings'];
  static const _subtitles = [
    'Create and update travel packages',
    'Review and manage customer bookings',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController.animation ?? tabController,
      builder: (context, _) {
        final i = tabController.index.clamp(0, _titles.length - 1);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 22, 32, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: LogoColors.dark.withOpacity(.06)),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Column(
              key: ValueKey(i),
              children: [
                Text(
                  _titles[i],
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: LogoColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitles[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LogoColors.dark.withOpacity(.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PackagesSummary extends StatelessWidget {
  final List<AdminPackage> packages;

  const _PackagesSummary({
    required this.packages,
  });

  @override
  Widget build(BuildContext context) {
    final featured =
        packages.where((e) => e.featured).length;

    final inbound =
        packages
            .where(
              (e) =>
          e.category ==
              PackageCategory.inbound,
        )
            .length;

    final holidays =
        packages
            .where(
              (e) =>
          e.category ==
              PackageCategory.holidays,
        )
            .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 650;

        final cards = [
          _SummaryData(
            title: 'Total Packages',
            value: '${packages.length}',
            icon:
            Icons.inventory_2_rounded,
          ),
          _SummaryData(
            title: 'Inbound',
            value: '$inbound',
            icon: Icons
                .location_city_rounded,
          ),
          _SummaryData(
            title: 'Holidays',
            value: '$holidays',
            icon:
            Icons.flight_takeoff_rounded,
          ),
          _SummaryData(
            title: 'Featured',
            value: '$featured',
            icon: Icons.star_rounded,
          ),
        ];

        if (compact) {
          return GridView.builder(
            shrinkWrap: true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.25,
            ),
            itemBuilder:
                (_, i) =>
                _SummaryCard(
                  data: cards[i],
                  index: i,
                ),
          );
        }

        return Row(
          children: [
            for (
            int i = 0;
            i < cards.length;
            i++
            ) ...[
              Expanded(
                child: _SummaryCard(
                  data: cards[i],
                  index: i,
                ),
              ),
              if (i != cards.length - 1)
                const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryData {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  final int index;

  const _SummaryCard({
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds:
        350 + (index * 80),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              14 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color: LogoColors.dark
                .withOpacity(.055),
          ),
          boxShadow: [
            BoxShadow(
              color: LogoColors.dark
                  .withOpacity(.055),
              blurRadius: 18,
              offset:
              const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    LogoColors.primary
                        .withOpacity(.12),
                    LogoColors.light
                        .withOpacity(.15),
                  ],
                ),
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
              ),
              child: Icon(
                data.icon,
                color:
                LogoColors.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      color:
                      LogoColors.dark,
                      fontSize: 19,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      color: LogoColors.dark
                          .withOpacity(.48),
                      fontSize: 10.5,
                      fontWeight:
                      FontWeight.w600,
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

class _AnimatedPackageCard
    extends StatefulWidget {
  final AdminPackage pkg;
  final int index;

  const _AnimatedPackageCard({
    super.key,
    required this.pkg,
    required this.index,
  });

  @override
  State<_AnimatedPackageCard> createState() =>
      _AnimatedPackageCardState();
}

class _AnimatedPackageCardState
    extends State<_AnimatedPackageCard> {
  bool _hovering = false;

  AdminPackage get pkg => widget.pkg;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds:
        420 +
            ((widget.index % 8) * 55),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              24 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor:
        SystemMouseCursors.click,
        onEnter: (_) {
          if (mounted) {
            setState(
                  () => _hovering = true,
            );
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(
                  () => _hovering = false,
            );
          }
        },
        child: AnimatedScale(
          scale:
          _hovering ? 1.018 : 1,
          duration: const Duration(
            milliseconds: 180,
          ),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                22,
              ),
              border: Border.all(
                color: _hovering
                    ? LogoColors.primary
                    .withOpacity(.20)
                    : LogoColors.dark
                    .withOpacity(.055),
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovering
                      ? LogoColors.primary
                      .withOpacity(.13)
                      : LogoColors.dark
                      .withOpacity(.06),
                  blurRadius:
                  _hovering ? 26 : 15,
                  offset: Offset(
                    0,
                    _hovering ? 12 : 7,
                  ),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(
                22,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Expanded(
                    flex: 6,
                    child:
                    _ResponsivePackageImage(
                      pkg: pkg,
                    ),
                  ),

                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .fromLTRB(
                        15,
                        13,
                        12,
                        11,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pkg.title,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  TextStyle(
                                    color:
                                    LogoColors
                                        .dark,
                                    fontWeight:
                                    FontWeight
                                        .w900,
                                    fontSize:
                                    14,
                                  ),
                                ),
                              ),

                              if (pkg.featured)
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .all(5),
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xffFFF4D6,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  child:
                                  const Icon(
                                    Icons
                                        .star_rounded,
                                    color:
                                    Color(
                                      0xffFFB020,
                                    ),
                                    size:
                                    14,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Row(
                            children: [
                              _PackageChip(
                                icon:
                                _categoryIcon(
                                  pkg.category,
                                ),
                                label: pkg
                                    .category
                                    .label,
                              ),

                              if ((pkg
                                  .durationText ??
                                  '')
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  width: 6,
                                ),
                                Flexible(
                                  child:
                                  _PackageChip(
                                    icon: Icons
                                        .schedule_rounded,
                                    label: pkg
                                        .durationText!,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pkg.adultPriceText ??
                                      pkg.priceText ??
                                      '',
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  TextStyle(
                                    color:
                                    LogoColors
                                        .primary,
                                    fontSize:
                                    13,
                                    fontWeight:
                                    FontWeight
                                        .w900,
                                  ),
                                ),
                              ),

                              _AdminCardAction(
                                icon: Icons
                                    .edit_rounded,
                                tooltip:
                                'Edit package',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                          AdminPackageFormPage(
                                            existing:
                                            pkg,
                                          ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              _AdminCardAction(
                                icon: Icons
                                    .delete_outline_rounded,
                                tooltip:
                                'Delete package',
                                danger: true,
                                onTap:
                                    () =>
                                    _deletePackage(
                                      context,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(
      PackageCategory category,
      ) {
    switch (category) {
      case PackageCategory.inbound:
        return Icons
            .location_city_rounded;

      case PackageCategory.holidays:
        return Icons
            .flight_takeoff_rounded;

      case PackageCategory.cruises:
        return Icons
            .directions_boat_filled_rounded;
    }
  }

  Future<void> _deletePackage(
      BuildContext context,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),
          title: const Row(
            children: [
              Icon(
                Icons
                    .delete_outline_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Delete package?',
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "${pkg.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              icon: const Icon(
                Icons.delete_rounded,
                size: 17,
              ),
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors
                    .redAccent,
                foregroundColor:
                Colors.white,
              ),
              label:
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await AdminPackageService.instance
          .deletePackage(pkg);
    }
  }
}

class _ResponsivePackageImage
    extends StatelessWidget {
  final AdminPackage pkg;

  const _ResponsivePackageImage({
    required this.pkg,
  });

  @override
  Widget build(BuildContext context) {
    if (pkg.imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        color:
        LogoColors.light.withOpacity(
          .10,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .image_not_supported_rounded,
              size: 34,
              color: LogoColors.primary
                  .withOpacity(.45),
            ),
            const SizedBox(height: 6),
            Text(
              'No image',
              style: TextStyle(
                color: LogoColors.dark
                    .withOpacity(.38),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          pkg.imageUrls.first,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,

          loadingBuilder: (
              context,
              child,
              progress,
              ) {
            if (progress == null) {
              return child;
            }

            return Container(
              color: LogoColors.light
                  .withOpacity(.08),
              alignment: Alignment.center,
              child:
              const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          },

          errorBuilder:
              (
              context,
              error,
              stackTrace,
              ) {
            debugPrint(
              'Package image error: $error',
            );

            return Container(
              color: LogoColors.light
                  .withOpacity(.10),
              alignment:
              Alignment.center,
              child: Icon(
                Icons
                    .broken_image_rounded,
                size: 35,
                color:
                LogoColors.primary,
              ),
            );
          },
        ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient:
              LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black
                      .withOpacity(.04),
                  Colors.black
                      .withOpacity(.30),
                ],
                begin:
                Alignment.topCenter,
                end:
                Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.92),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .photo_library_rounded,
                  size: 12,
                  color:
                  LogoColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${pkg.imageUrls.length}',
                  style: TextStyle(
                    color:
                    LogoColors.dark,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PackageChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: LogoColors.primary
            .withOpacity(.075),
        borderRadius:
        BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color:
            LogoColors.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color:
                LogoColors.primary,
                fontSize: 9.5,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCardAction
    extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  const _AdminCardAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_AdminCardAction> createState() =>
      _AdminCardActionState();
}

class _AdminCardActionState
    extends State<_AdminCardAction> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
    widget.danger
        ? Colors.redAccent
        : LogoColors.primary;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor:
        SystemMouseCursors.click,
        onEnter: (_) =>
            setState(
                  () => hovered = true,
            ),
        onExit: (_) =>
            setState(
                  () => hovered = false,
            ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 160,
            ),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(
                hovered ? .15 : .07,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveAddPackageButton
    extends StatelessWidget {
  final VoidCallback onPressed;

  const _ResponsiveAddPackageButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    if (width < 600) {
      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor:
        LogoColors.primary,
        foregroundColor: Colors.white,
        child:
        const Icon(Icons.add_rounded),
      );
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor:
      LogoColors.primary,
      foregroundColor: Colors.white,
      elevation: 5,
      icon: const Icon(
        Icons.add_rounded,
      ),
      label: const Text(
        'Add Package',
        style: TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyPackagesView
    extends StatelessWidget {
  const _EmptyPackagesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .8, end: 1),
        duration: const Duration(
          milliseconds: 500,
        ),
        curve: Curves.easeOutBack,
        builder: (
            context,
            value,
            child,
            ) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          margin:
          const EdgeInsets.all(24),
          padding:
          const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(
              26,
            ),
            boxShadow: [
              BoxShadow(
                color: LogoColors.dark
                    .withOpacity(.06),
                blurRadius: 25,
                offset:
                const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration:
                BoxDecoration(
                  color:
                  LogoColors.primary
                      .withOpacity(
                    .08,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .luggage_rounded,
                  size: 31,
                  color:
                  LogoColors.primary,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'No packages yet',
                style: TextStyle(
                  color:
                  LogoColors.dark,
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Create your first travel package.',
                style: TextStyle(
                  color: LogoColors.dark
                      .withOpacity(.48),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminErrorView
    extends StatelessWidget {
  final String message;

  const _AdminErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              color: Colors.redAccent,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load packages',
              style: TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: LogoColors.dark
                    .withOpacity(.55),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagePackagesTab extends StatelessWidget {
  const _ManagePackagesTab();

  int _columnCount(double width) {
    if (width >= 1500) return 4;
    if (width >= 1050) return 3;
    if (width >= 700) return 2;

    return 1;
  }

  double _aspectRatio(double width) {
    if (width >= 1500) return 1.18;
    if (width >= 1050) return 1.14;
    if (width >= 700) return 1.10;

    return 1.45;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminPackage>>(
      stream:
      AdminPackageService.instance.streamAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _AdminErrorView(
            message: snapshot.error.toString(),
          );
        }

        final packages =
            snapshot.data ?? <AdminPackage>[];

        if (packages.isEmpty) {
          return const _EmptyPackagesView();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns =
            _columnCount(width);

            final horizontalPadding =
            width >= 1200
                ? 32.0
                : width >= 700
                ? 24.0
                : 14.0;

            return Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 1450,
                ),
                child: CustomScrollView(
                  physics:
                  const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        12,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _PackagesSummary(
                          packages: packages,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8,
                        horizontalPadding,
                        110,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          columns,
                          crossAxisSpacing:
                          18,
                          mainAxisSpacing:
                          18,
                          childAspectRatio:
                          _aspectRatio(
                            width,
                          ),
                        ),
                        delegate:
                        SliverChildBuilderDelegate(
                              (
                              context,
                              index,
                              ) {
                            final pkg =
                            packages[index];

                            return _AnimatedPackageCard(
                              key:
                              ValueKey(
                                pkg.id,
                              ),
                              pkg: pkg,
                              index:
                              index,
                            );
                          },
                          childCount:
                          packages.length,
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
  }
}

/// Admin-safe representation of a booking document.
///
/// Customer bookings are stored at:
/// `bookings/<uid>/items/<bookingId>`.
/// A collection-group query lets the admin read every nested `items`
/// collection, then this screen keeps only documents whose path starts with
/// `bookings/`. This also supports bookings that were already created before
/// the admin screen was added.
class _AdminBooking {
  final String userId;
  final String id;

  final String name;
  final String email;
  final String mobile;

  final DateTime checkIn;

  final int adults;
  final int children;

  final String? selectedPackageOption;

  final String status;

  final DateTime createdAt;

  final Map<String, dynamic> package;

  const _AdminBooking({
    required this.userId,
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.checkIn,
    required this.adults,
    required this.children,
    required this.selectedPackageOption,
    required this.status,
    required this.createdAt,
    required this.package,
  });

  // ============================================================
  // MYSQL ROW -> ADMIN BOOKING
  // ============================================================

  factory _AdminBooking.fromRow(
      Map<String, dynamic> row,
      ) {
    // ---------------- Package JSON ----------------

    Map<String, dynamic> package = {};

    final rawPackage = row['package_json'];

    if (rawPackage != null &&
        rawPackage.toString().trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(
          rawPackage.toString(),
        );

        if (decoded is Map) {
          package =
          Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (e) {
        debugPrint(
          'Booking package JSON error: $e',
        );
      }
    }

    // ---------------- Date helper ----------------

    DateTime parseDate(dynamic raw) {
      if (raw == null) {
        return DateTime.now();
      }

      final value =
      raw.toString().trim();

      if (value.isEmpty) {
        return DateTime.now();
      }

      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    // ---------------- Integer helper ----------------

    int parseInt(
        dynamic raw, {
          int fallback = 0,
        }) {
      if (raw is int) {
        return raw;
      }

      if (raw is num) {
        return raw.toInt();
      }

      return int.tryParse(
        raw?.toString() ?? '',
      ) ??
          fallback;
    }

    return _AdminBooking(
      userId:
      row['uid']?.toString() ?? '',

      id:
      row['id']?.toString() ?? '',

      name:
      row['name']?.toString() ?? '',

      email:
      row['email']?.toString() ?? '',

      mobile:
      row['mobile']?.toString() ?? '',

      checkIn:
      parseDate(row['checkIn']),

      adults:
      parseInt(
        row['adults'],
        fallback: 1,
      ),

      children:
      parseInt(
        row['children'],
      ),

      selectedPackageOption:
      row['selectedPackageOption']
          ?.toString(),

      status:
      row['status']?.toString() ??
          'pending',

      createdAt:
      parseDate(row['createdAt']),

      package: package,
    );
  }

  // ============================================================
  // PACKAGE TITLE
  // ============================================================

  String get packageTitle {
    final title =
    package['title']?.toString().trim();

    if (title != null &&
        title.isNotEmpty) {
      return title;
    }

    return 'Package';
  }

  // ============================================================
  // PACKAGE IMAGE
  // ============================================================

  String? get imageUrl {
    // Your TravelPackage wishlist map normally uses images.
    final images = package['images'];

    if (images is List &&
        images.isNotEmpty) {
      final value =
      images.first?.toString();

      if (value != null &&
          value.trim().isNotEmpty) {
        return value;
      }
    }

    // Also support imageUrl.
    final singleImage =
    package['imageUrl']?.toString();

    if (singleImage != null &&
        singleImage.trim().isNotEmpty) {
      return singleImage;
    }

    // Also support imageUrls.
    final imageUrls =
    package['imageUrls'];

    if (imageUrls is List &&
        imageUrls.isNotEmpty) {
      return imageUrls.first?.toString();
    }

    return null;
  }
}

class _AdminBookingsTab
    extends StatefulWidget {
  const _AdminBookingsTab();

  @override
  State<_AdminBookingsTab>
  createState() =>
      _AdminBookingsTabState();
}

class _AdminBookingsTabState
    extends State<_AdminBookingsTab> {

  final AdminMySQLService _db =
      AdminMySQLService.instance;

  late final Stream<
      List<_AdminBooking>> _bookingsStream;

  bool _streamRunning = true;

  @override
  void initState() {
    super.initState();

    _bookingsStream =
        _createBookingsStream();
  }

  // ============================================================
  // MYSQL POLLING STREAM
  // ============================================================

  Stream<List<_AdminBooking>>
  _createBookingsStream() async* {

    while (_streamRunning) {
      try {
        // ADMIN gets ALL bookings from MySQL.
        final rows =
        await _db.fetchAllBookings();

        final bookings = rows
            .map(
              (row) =>
              _AdminBooking.fromRow(
                row,
              ),
        )
            .toList();

        bookings.sort(
              (a, b) =>
              b.createdAt.compareTo(
                a.createdAt,
              ),
        );

        yield bookings;
      } catch (e) {
        debugPrint(
          'Admin bookings MySQL error: $e',
        );

        yield* Stream.error(e);
      }

      await Future.delayed(
        const Duration(seconds: 5),
      );
    }
  }

  @override
  void dispose() {
    _streamRunning = false;
    super.dispose();
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

  @override
  Widget build(
      BuildContext context,
      ) {
    return StreamBuilder<
        List<_AdminBooking>>(
      stream: _bookingsStream,
      builder: (
          context,
          snapshot,
          ) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load bookings.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: LogoColors.dark.withOpacity(.65)),
              ),
            ),
          );
        }

        final bookings = snapshot.data ?? const <_AdminBooking>[];

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.confirmation_num_outlined,
                  size: 48,
                  color: LogoColors.dark.withOpacity(.2),
                ),
                const SizedBox(height: 12),
                Text(
                  'No bookings yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LogoColors.dark.withOpacity(.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final status = _AdminBookingStatusX.fromValue(booking.status);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _AdminBookingDetailPage(booking: booking),
                      ),
                    ),
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
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: booking.imageUrl == null
                                ? Container(
                              width: 66,
                              height: 66,
                              color: LogoColors.light.withOpacity(.15),
                              child: Icon(
                                Icons.card_travel_rounded,
                                color: LogoColors.primary,
                              ),
                            )
                                : Image.network(
                              booking.imageUrl!,
                              width: 66,
                              height: 66,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 66,
                                height: 66,
                                color: LogoColors.light.withOpacity(.15),
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: LogoColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.packageTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: LogoColors.dark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  booking.name.isEmpty
                                      ? booking.email
                                      : booking.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: LogoColors.dark.withOpacity(.58),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11,
                                      color: LogoColors.dark.withOpacity(.4),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _date(booking.checkIn),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: LogoColors.dark.withOpacity(.52),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _AdminStatusBadge(status: status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: LogoColors.dark.withOpacity(.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum _AdminBookingStatus { pending, confirmed, cancelled }

extension _AdminBookingStatusX on _AdminBookingStatus {
  String get value {
    switch (this) {
      case _AdminBookingStatus.pending:
        return 'pending';
      case _AdminBookingStatus.confirmed:
        return 'confirmed';
      case _AdminBookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case _AdminBookingStatus.pending:
        return 'Pending Confirmation';
      case _AdminBookingStatus.confirmed:
        return 'Confirmed';
      case _AdminBookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case _AdminBookingStatus.pending:
        return Icons.hourglass_top_rounded;
      case _AdminBookingStatus.confirmed:
        return Icons.verified_rounded;
      case _AdminBookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _AdminBookingStatus.pending:
        return const Color(0xffFFA033);
      case _AdminBookingStatus.confirmed:
        return const Color(0xff23B26D);
      case _AdminBookingStatus.cancelled:
        return const Color(0xffFF5C5C);
    }
  }

  static _AdminBookingStatus fromValue(String? value) {
    switch (value) {
      case 'confirmed':
        return _AdminBookingStatus.confirmed;
      case 'cancelled':
        return _AdminBookingStatus.cancelled;
      case 'pending':
      default:
        return _AdminBookingStatus.pending;
    }
  }
}

class _AdminStatusBadge extends StatelessWidget {
  final _AdminBookingStatus status;
  const _AdminStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBookingDetailPage extends StatefulWidget {
  final _AdminBooking booking;
  const _AdminBookingDetailPage({required this.booking});

  @override
  State<_AdminBookingDetailPage> createState() =>
      _AdminBookingDetailPageState();
}

class _AdminBookingDetailPageState extends State<_AdminBookingDetailPage> {
  late _AdminBookingStatus _status;
  bool _saving = false;

  _AdminBooking get booking => widget.booking;

  @override
  void initState() {
    super.initState();
    _status = _AdminBookingStatusX.fromValue(booking.status);
  }

  String _dateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';

  Future<void> _submitStatus() async {
    if (_saving) return;

    setState(
          () => _saving = true,
    );

    try {
      await AdminMySQLService
          .instance
          .updateBookingStatus(
        booking.id,
        _status.value,
      );

      if (!mounted) return;

      _showAdminNotice(
        context,
        'Booking status changed to '
            '${_status.label}.',
        type:
        _AdminNoticeType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showAdminNotice(
        context,
        'Unable to update booking status.\n$e',
        type:
        _AdminNoticeType.error,
      );
    } finally {
      if (mounted) {
        setState(
              () => _saving = false,
        );
      }
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: LogoColors.dark.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: LogoColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: LogoColors.primary),
            const SizedBox(width: 9),
          ],
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: LogoColors.dark.withOpacity(.55),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: LogoColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _strings(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pkg = booking.package;
    final inclusions = _strings(pkg['inclusions']);
    final exclusions = _strings(pkg['exclusions']);
    final faqs = _strings(pkg['faqs']);

    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        title: const Text('Booking Details'),
        centerTitle: true,
      ),
      // Center + constrain the content so on web/desktop the page shows a
      // fixed-width, mobile-proportioned column of cards instead of
      // stretching edge-to-edge across a wide browser window.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              if (booking.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    booking.imageUrl!,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              if (booking.imageUrl != null) const SizedBox(height: 14),

              _section(
                'Booking',
                [
                  _row('Booking ID', booking.id, icon: Icons.confirmation_num_rounded),
                  _row('Created', _dateTime(booking.createdAt), icon: Icons.schedule_rounded),
                  _row('Check-in', _dateTime(booking.checkIn), icon: Icons.calendar_month_rounded),
                  _row('Adults', booking.adults.toString(), icon: Icons.person_rounded),
                  _row('Children', booking.children.toString(), icon: Icons.child_care_rounded),
                  if ((booking.selectedPackageOption ?? '').isNotEmpty)
                    _row(
                      'Option',
                      booking.selectedPackageOption!,
                      icon: Icons.tune_rounded,
                    ),
                ],
              ),

              _section(
                'Customer',
                [
                  _row('Name', booking.name, icon: Icons.person_outline_rounded),
                  _row('Email', booking.email, icon: Icons.mail_outline_rounded),
                  _row('Mobile', booking.mobile, icon: Icons.phone_rounded),
                ],
              ),

              _section(
                'Package',
                [
                  _row('Title', booking.packageTitle, icon: Icons.card_travel_rounded),
                  _row('Country', (pkg['country'] ?? '').toString(), icon: Icons.public_rounded),
                  _row('Duration', (pkg['durationText'] ?? '').toString(), icon: Icons.timelapse_rounded),
                  _row(
                    'Adult price',
                    (pkg['adultPriceText'] ?? pkg['priceText'] ?? '').toString(),
                    icon: Icons.person_rounded,
                  ),
                  _row(
                    'Child price',
                    (pkg['childPriceText'] ?? '').toString(),
                    icon: Icons.child_care_rounded,
                  ),
                  if ((pkg['infantPriceText'] ?? '').toString().trim().isNotEmpty)
                    _row(
                      'Infant price',
                      pkg['infantPriceText'].toString(),
                      icon: Icons.baby_changing_station_rounded,
                    ),
                  if ((pkg['about'] ?? '').toString().trim().isNotEmpty)
                    _row('About', pkg['about'].toString(), icon: Icons.info_outline_rounded),
                ],
              ),

              if (inclusions.isNotEmpty)
                _section(
                  'Inclusions',
                  inclusions
                      .map(
                        (e) => _row(
                      'Included',
                      e,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  )
                      .toList(),
                ),

              if (exclusions.isNotEmpty)
                _section(
                  'Exclusions',
                  exclusions
                      .map(
                        (e) => _row(
                      'Excluded',
                      e,
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  )
                      .toList(),
                ),

              if (faqs.isNotEmpty)
                _section(
                  'FAQs',
                  faqs
                      .map(
                        (e) => _row(
                      'FAQ',
                      e,
                      icon: Icons.help_outline_rounded,
                    ),
                  )
                      .toList(),
                ),

              _section(
                'Booking Status',
                [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _status.color.withOpacity(.055),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _status.color.withOpacity(.22),
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonFormField<_AdminBookingStatus>(
                      value: _status,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      menuMaxHeight: 240,
                      icon: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _status.color.withOpacity(.11),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _status.color,
                          size: 20,
                        ),
                      ),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: LogoColors.dark.withOpacity(.58),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: _status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      selectedItemBuilder: (context) {
                        return _AdminBookingStatus.values.map((status) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: status.color.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    status.icon,
                                    size: 18,
                                    color: status.color,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Flexible(
                                  child: Text(
                                    status.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: LogoColors.dark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      items: _AdminBookingStatus.values.map((status) {
                        return DropdownMenuItem<_AdminBookingStatus>(
                          value: status,
                          child: Container(
                            height: 50,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: status.color.withOpacity(.11),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    status.icon,
                                    size: 18,
                                    color: status.color,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    status.label,
                                    style: TextStyle(
                                      color: LogoColors.dark,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (status == _status)
                                  Icon(
                                    Icons.check_rounded,
                                    color: status.color,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _saving
                          ? null
                          : (value) {
                        if (value != null) {
                          setState(() => _status = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submitStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LogoColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _saving
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving ? 'Updating...' : 'Submit',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add / Edit form. Pass `existing` to edit a package in place.
class AdminPackageFormPage extends StatefulWidget {
  final AdminPackage? existing;
  const AdminPackageFormPage({super.key, this.existing});

  @override
  State<AdminPackageFormPage> createState() => _AdminPackageFormPageState();
}

class _AdminPackageFormPageState extends State<AdminPackageFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'United Arab Emirates');
  final _adultPriceCtrl = TextEditingController();
  final _childPriceCtrl = TextEditingController();
  final _infantPriceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  final List<TextEditingController> _faqCtrls =
  List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _inclusionCtrls =
  List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _exclusionCtrls =
  List.generate(5, (_) => TextEditingController());

  PackageCategory _category = PackageCategory.inbound;
  bool _featured = false;
  bool _saving = false;

  // Existing (already-uploaded) image URLs + newly picked local files.
  final List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  double? _uploadProgress;

  final List<_RouteStopDraft> _route = [];

  late final AnimationController _pageController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fadeAnimation = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, .035), end: Offset.zero).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
    );
    _pageController.forward();

    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _contentCtrl.text = e.content;
      _countryCtrl.text = e.country;
      _adultPriceCtrl.text = e.adultPriceText ?? e.priceText ?? '';
      _childPriceCtrl.text = e.childPriceText ?? '';
      _infantPriceCtrl.text = e.infantPriceText ?? '';
      _durationCtrl.text = e.durationText ?? '';
      for (var i = 0; i < e.faqs.length && i < 5; i++) {
        _faqCtrls[i].text = e.faqs[i];
      }
      for (var i = 0; i < e.inclusions.length && i < 5; i++) {
        _inclusionCtrls[i].text = e.inclusions[i];
      }
      for (var i = 0; i < e.exclusions.length && i < 5; i++) {
        _exclusionCtrls[i].text = e.exclusions[i];
      }
      _category = e.category;
      _featured = e.featured;
      _existingImageUrls.addAll(e.imageUrls);
      _route.addAll(e.route.map((r) => _RouteStopDraft.fromModel(r)));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _countryCtrl.dispose();
    _adultPriceCtrl.dispose();
    _childPriceCtrl.dispose();
    _infantPriceCtrl.dispose();
    _durationCtrl.dispose();
    for (final c in _faqCtrls) { c.dispose(); }
    for (final c in _inclusionCtrls) { c.dispose(); }
    for (final c in _exclusionCtrls) { c.dispose(); }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (picked.isNotEmpty && mounted) {
        setState(() {
          _newImages.addAll(picked);
        });
      }
    } catch (e) {
      if (!mounted) return;

      _showAdminNotice(
        context,
        'Unable to select images. $e',
        type: _AdminNoticeType.error,
      );
    }
  }

  Future<_RouteStopDraft?> _showRouteStopDialog({_RouteStopDraft? initial}) {
    return showGeneralDialog<_RouteStopDraft>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Route stop',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return initial == null
            ? const _RouteStopDialog()
            : _RouteStopDialog(initial: initial);
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _addRouteStop() async {
    final draft = await _showRouteStopDialog();
    if (draft != null) {
      setState(() => _route.add(draft));
      _pulseRouteChange();
    }
  }

  Future<void> _editRouteStop(int index) async {
    final draft = await _showRouteStopDialog(initial: _route[index]);
    if (draft != null) {
      setState(() => _route[index] = draft);
      _pulseRouteChange();
    }
  }

// Brief highlight so the user's eye catches the change in the list.
  final ValueNotifier<bool> _routePulse = ValueNotifier(false);

  void _pulseRouteChange() {
    _routePulse.value = true;
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _routePulse.value = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      _showAdminNotice(
        context,
        'Please add at least one package image.',
        type: _AdminNoticeType.warning,
      );
      return;
    }

    setState(() {
      _saving = true;
      _uploadProgress = 0;
    });

    try {
      final uploadedUrls = <String>[];

      for (var i = 0; i < _newImages.length; i++) {
        final url =
        await AdminPackageService.instance.uploadImage(
          _newImages[i],
          onProgress: (p) {
            if (!mounted) return;

            setState(() {
              _uploadProgress =
                  (i + p) / _newImages.length;
            });
          },
        );

        uploadedUrls.add(url);
      }

      final pkg = AdminPackage(
        id: widget.existing?.id ?? '',
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        imageUrls: [..._existingImageUrls, ...uploadedUrls],
        category: _category,
        featured: _featured,
        country: _countryCtrl.text.trim(),
        priceText: _adultPriceCtrl.text.trim().isEmpty ? null : _adultPriceCtrl.text.trim(),
        adultPriceText: _adultPriceCtrl.text.trim().isEmpty ? null : _adultPriceCtrl.text.trim(),
        childPriceText: _childPriceCtrl.text.trim().isEmpty ? null : _childPriceCtrl.text.trim(),
        infantPriceText: _infantPriceCtrl.text.trim().isEmpty ? null : _infantPriceCtrl.text.trim(),
        faqs: _faqCtrls.map((c) => c.text.trim()).where((v) => v.isNotEmpty).take(5).toList(),
        inclusions: _inclusionCtrls.map((c) => c.text.trim()).where((v) => v.isNotEmpty).take(5).toList(),
        exclusions: _exclusionCtrls.map((c) => c.text.trim()).where((v) => v.isNotEmpty).take(5).toList(),
        durationText:
        _durationCtrl.text.trim().isEmpty ? null : _durationCtrl.text.trim(),
        route: _route.map((r) => r.toModel()).toList(),
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await AdminPackageService.instance.updatePackage(pkg.id, pkg);
      } else {
        await AdminPackageService.instance.addPackage(pkg);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showAdminNotice(
          context,
          'Failed to save package. $e',
          type: _AdminNoticeType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

  Widget _sectionCard({required String title, required IconData icon, String? subtitle, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LogoColors.dark.withOpacity(.06)),
        boxShadow: [BoxShadow(color: LogoColors.dark.withOpacity(.07), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [LogoColors.primary, LogoColors.light], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: LogoColors.dark)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11.5, color: LogoColors.dark.withOpacity(.45))),
            ],
          ])),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _animatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index * 75)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
      ),
      child: child,
    );
  }

  Widget _fiveFieldList({
    required String title,
    required String hint,
    required IconData icon,
    required List<TextEditingController> controllers,
  }) {
    return _sectionCard(
      title: title,
      icon: icon,
      subtitle: 'Optional — maximum 5 items. Empty fields are ignored.',
      child: Column(
        children: List.generate(5, (i) => Padding(
          padding: EdgeInsets.only(bottom: i == 4 ? 0 : 10),
          child: TextFormField(
            controller: controllers[i],
            maxLines: title == 'FAQs' ? 2 : 1,
            decoration: _decoration('$hint ${i + 1}'),
          ),
        )),
      ),
    );
  }

  Widget _categorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PackageCategory.values.map((c) {
        final selected = c == _category;
        final icon = c == PackageCategory.inbound
            ? Icons.location_city_rounded
            : c == PackageCategory.holidays
            ? Icons.flight_takeoff_rounded
            : Icons.directions_boat_filled_rounded;
        return AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: selected ? 1.03 : 1,
          child: ChoiceChip(
            avatar: Icon(icon, size: 16, color: selected ? Colors.white : LogoColors.primary),
            label: Text(c.label),
            selected: selected,
            selectedColor: LogoColors.primary,
            backgroundColor: LogoColors.bg,
            side: BorderSide(color: selected ? Colors.transparent : LogoColors.dark.withOpacity(.10)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            labelStyle: TextStyle(color: selected ? Colors.white : LogoColors.dark, fontWeight: FontWeight.w700, fontSize: 12),
            onSelected: (_) => setState(() => _category = c),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      appBar: AppBar(
        backgroundColor: LogoColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? 'Edit Package' : 'Add Package'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                  children: [
                    _animatedItem(
                      0,
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [LogoColors.dark, LogoColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: LogoColors.primary.withOpacity(.25), blurRadius: 22, offset: const Offset(0, 10))],
                        ),
                        child: Row(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(16)),
                            child: Icon(_isEditing ? Icons.edit_note_rounded : Icons.add_business_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_isEditing ? 'Update travel package' : 'Create a new travel package', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('Published data appears automatically in Home and the selected category.', style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 11.5, height: 1.35)),
                          ])),
                        ]),
                      ),
                    ),
                    _animatedItem(
                      1,
                      _sectionCard(
                        title: 'Package Information', icon: Icons.article_rounded, subtitle: 'Basic details shown to customers',
                        child: Column(children: [
                          TextFormField(controller: _titleCtrl, decoration: _decoration('Title', required: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _contentCtrl, maxLines: 5, decoration: _decoration('Content / About', required: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _countryCtrl, decoration: _decoration('Country', required: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: TextFormField(
                              controller: _adultPriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _decoration('Adult Price (e.g. AED 199)'),
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: TextFormField(
                              controller: _childPriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _decoration('Child Price (e.g. AED 149)'),
                            )),
                          ]),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _infantPriceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _decoration('Infant Price (e.g. AED 49)'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(controller: _durationCtrl, decoration: _decoration('Duration (e.g. 3 Nights/4 Days)')),
                        ]),
                      ),
                    ),
                    _animatedItem(
                      2,
                      _sectionCard(
                        title: 'Where to Show', icon: Icons.dashboard_customize_rounded, subtitle: 'Choose Inbound, Holidays or Cruises',
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _categorySelector(),
                          const SizedBox(height: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            decoration: BoxDecoration(color: _featured ? LogoColors.primary.withOpacity(.08) : LogoColors.bg, borderRadius: BorderRadius.circular(16)),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              value: _featured,
                              activeColor: LogoColors.primary,
                              title: Text('Featured flag', style: TextStyle(color: LogoColors.dark, fontWeight: FontWeight.w700, fontSize: 12.5)),
                              subtitle: Text('Saved for future featured usage', style: TextStyle(color: LogoColors.dark.withOpacity(.45), fontSize: 10.5)),
                              onChanged: (v) => setState(() => _featured = v),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    _animatedItem(
                      3,
                      _fiveFieldList(
                        title: 'Inclusions',
                        hint: 'Inclusive option',
                        icon: Icons.check_circle_rounded,
                        controllers: _inclusionCtrls,
                      ),
                    ),
                    _animatedItem(
                      4,
                      _fiveFieldList(
                        title: 'Exclusions',
                        hint: 'Exclusive option',
                        icon: Icons.cancel_rounded,
                        controllers: _exclusionCtrls,
                      ),
                    ),
                    _animatedItem(
                      5,
                      _fiveFieldList(
                        title: 'FAQs',
                        hint: 'FAQ',
                        icon: Icons.help_rounded,
                        controllers: _faqCtrls,
                      ),
                    ),
                    _animatedItem(
                      6,
                      _sectionCard(
                        title: 'Package Images', icon: Icons.photo_library_rounded, subtitle: 'Add one or more images for cards and detail pages',
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Wrap(
                              key: ValueKey('${_existingImageUrls.length}_${_newImages.length}'),
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (int i = 0; i < _existingImageUrls.length; i++)
                                  _ImageThumb(child: Image.network(_existingImageUrls[i], fit: BoxFit.cover), onRemove: () => setState(() => _existingImageUrls.removeAt(i))),
                                for (int i = 0; i < _newImages.length; i++)
                                  _ImageThumb(
                                    child: XFileImage(
                                      file: _newImages[i],
                                      fit: BoxFit.cover,
                                    ),
                                    onRemove: () {
                                      setState(() {
                                        _newImages.removeAt(i);
                                      });
                                    },
                                  ),                            _TapAddTile(onTap: _pickImages),
                              ],
                            ),
                          ),
                          if (_saving && _uploadProgress != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(minHeight: 7, value: _uploadProgress!.clamp(0, 1), color: LogoColors.primary, backgroundColor: LogoColors.dark.withOpacity(.08))),
                            const SizedBox(height: 6),
                            Text('Uploading ${(100 * _uploadProgress!.clamp(0, 1)).round()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: LogoColors.primary)),
                          ],
                        ]),
                      ),
                    ),
                    _animatedItem(
                      7,
                      _sectionCard(
                        title: 'Route / Itinerary', icon: Icons.route_rounded, subtitle: 'Optional stops displayed on the package detail page',
                        child: Column(children: [
                          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _addRouteStop, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Stop'))),
                          if (_route.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                              decoration: BoxDecoration(color: LogoColors.bg, borderRadius: BorderRadius.circular(16)),
                              child: Text('No stops added — optional, but recommended for tours.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: LogoColors.dark.withOpacity(.45))),
                            )
                          else
                            Column(children: [
                              for (int i = 0; i < _route.length; i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: LogoColors.bg, borderRadius: BorderRadius.circular(14)),
                                  child: Row(children: [
                                    Container(
                                      width: 28, height: 28, alignment: Alignment.center,
                                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [LogoColors.primary, LogoColors.light]), shape: BoxShape.circle),
                                      child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(_route[i].title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: LogoColors.dark)),
                                      if (_route[i].subtitle.isNotEmpty) Text(_route[i].subtitle, style: TextStyle(fontSize: 11, color: LogoColors.dark.withOpacity(.55))),
                                    ])),
                                    IconButton(icon: Icon(Icons.edit_rounded, size: 17, color: LogoColors.dark.withOpacity(.45)), onPressed: () => _editRouteStop(i)),
                                    IconButton(icon: const Icon(Icons.close_rounded, size: 17, color: Colors.redAccent), onPressed: () => setState(() => _route.removeAt(i))),
                                  ]),
                                ),
                            ]),
                        ]),
                      ),
                    ),
                    _animatedItem(
                      8,
                      SizedBox(
                        height: 56,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _saving
                              ? Container(key: const ValueKey('saving'), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Center(child: CircularProgressIndicator()))
                              : ElevatedButton.icon(
                            key: const ValueKey('publish'),
                            onPressed: _submit,
                            icon: Icon(_isEditing ? Icons.save_rounded : Icons.rocket_launch_rounded, color: Colors.white, size: 19),
                            style: ElevatedButton.styleFrom(backgroundColor: LogoColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                            label: Text(_isEditing ? 'Save Changes' : 'Publish Package', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _ImageThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 78, height: 78, child: child),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _TapAddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _TapAddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: LogoColors.light.withOpacity(.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LogoColors.primary.withOpacity(.3)),
        ),
        child: Icon(Icons.add_photo_alternate_rounded, color: LogoColors.primary),
      ),
    );
  }
}

/// Local editable draft for a route stop, used only inside the form.
class _RouteStopDraft {
  String title;
  String subtitle;
  String duration;
  String admission;
  bool passBy;

  _RouteStopDraft({
    this.title = '',
    this.subtitle = '',
    this.duration = '',
    this.admission = '',
    this.passBy = false,
  });

  factory _RouteStopDraft.fromModel(AdminRouteStop r) => _RouteStopDraft(
    title: r.title,
    subtitle: r.subtitle,
    duration: r.duration,
    admission: r.admission,
    passBy: r.passBy,
  );

  AdminRouteStop toModel() => AdminRouteStop(
    title: title,
    subtitle: subtitle,
    duration: duration,
    admission: admission,
    passBy: passBy,
  );
}

class _RouteStopDialog extends StatefulWidget {
  final _RouteStopDraft? initial;
  const _RouteStopDialog({this.initial});

  @override
  State<_RouteStopDialog> createState() => _RouteStopDialogState();
}

class _RouteStopDialogState extends State<_RouteStopDialog> {
  late final _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
  late final _subtitleCtrl = TextEditingController(text: widget.initial?.subtitle ?? '');
  late final _durationCtrl = TextEditingController(text: widget.initial?.duration ?? '');
  late final _admissionCtrl =
  TextEditingController(text: widget.initial?.admission ?? '');
  late bool _passBy = widget.initial?.passBy ?? false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _durationCtrl.dispose();
    _admissionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(widget.initial == null ? 'Add Stop' : 'Edit Stop'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Stop title*'),
            ),
            TextField(
              controller: _subtitleCtrl,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            TextField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Duration (e.g. 45 minutes)'),
            ),
            TextField(
              controller: _admissionCtrl,
              decoration:
              const InputDecoration(labelText: 'Admission (e.g. Included)'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _passBy,
              title: const Text('Pass-by only (no admission/duration)'),
              onChanged: (v) => setState(() => _passBy = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _RouteStopDraft(
                title: _titleCtrl.text.trim(),
                subtitle: _subtitleCtrl.text.trim(),
                duration: _durationCtrl.text.trim(),
                admission: _admissionCtrl.text.trim(),
                passBy: _passBy,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
class XFileImage extends StatelessWidget {
  final XFile file;
  final BoxFit fit;

  const XFileImage({
    super.key,
    required this.file,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Icon(
              Icons.broken_image_rounded,
              color: Colors.grey,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}

class _AdminDashboardHeader extends StatelessWidget {
  final TabController tabController;

  const _AdminDashboardHeader({
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final desktop = width >= 900;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 18,
            desktop ? 24 : 16,
            desktop ? 40 : 18,
            0,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                LogoColors.dark,
                LogoColors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(maxWidth: 1450),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween:
                        Tween(begin: .75, end: 1),
                        duration:
                        const Duration(
                          milliseconds: 600,
                        ),
                        curve: Curves.easeOutBack,
                        builder:
                            (
                            context,
                            value,
                            child,
                            ) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: desktop ? 56 : 46,
                          height: desktop ? 56 : 46,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(.15),
                            borderRadius:
                            BorderRadius.circular(
                              16,
                            ),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(.15),
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child:
                        TweenAnimationBuilder<
                            double
                        >(
                          tween: Tween(
                            begin: 0,
                            end: 1,
                          ),
                          duration:
                          const Duration(
                            milliseconds:
                            650,
                          ),
                          curve:
                          Curves.easeOutCubic,
                          builder:
                              (
                              context,
                              value,
                              child,
                              ) {
                            return Opacity(
                              opacity: value,
                              child: Transform
                                  .translate(
                                offset:
                                Offset(
                                  20 *
                                      (1 -
                                          value),
                                  0,
                                ),
                                child:
                                child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                'Admin Dashboard',
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  desktop
                                      ? 25
                                      : 19,
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                  letterSpacing:
                                  -.4,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Manage travel packages and customer bookings',
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style: TextStyle(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    .72,
                                  ),
                                  fontSize:
                                  desktop
                                      ? 13
                                      : 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (desktop)
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(.12),
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(.13),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons
                                    .verified_user_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Administrator',
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                    height: desktop ? 24 : 18,
                  ),

                  Container(
                    height: 54,
                    padding:
                    const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(.10),
                      borderRadius:
                      const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: TabBar(
                      controller: tabController,
                      dividerColor:
                      Colors.transparent,
                      indicatorSize:
                      TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.10),
                            blurRadius: 12,
                            offset:
                            const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelColor:
                      LogoColors.primary,
                      unselectedLabelColor:
                      Colors.white70,
                      labelStyle:
                      const TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                        FontWeight.w800,
                      ),
                      unselectedLabelStyle:
                      const TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(
                            Icons
                                .inventory_2_rounded,
                            size: 18,
                          ),
                          text: 'Manage Packages',
                        ),
                        Tab(
                          icon: Icon(
                            Icons
                                .confirmation_num_rounded,
                            size: 18,
                          ),
                          text: 'Bookings',
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
  }
}