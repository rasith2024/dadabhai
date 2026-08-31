import 'package:dadabhaitravel/view/pages/admin/admin_package_page.dart';
import 'package:flutter/material.dart';
import 'about_us.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onBookingsTap;

  const ProfilePage({
    super.key,
    required this.onBookingsTap,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Temporary authentication state.
  // Later connect this with Firebase/Auth/API login.
  bool _isSignedIn = false;

  // Change this whenever your app version changes.
  static const String _appVersion = '1.0.0';

  static const Color dark = Color(0xff0F4C81);
  static const Color primary = Color(0xff1C7ED6);
  static const Color light = Color(0xff4DABF7);
  static const Color background = Color(0xffF5F8FC);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildProfileHeader(),

                      const SizedBox(height: 22),

                      _AnimatedProfileItem(
                        index: 0,
                        child: _ProfileMenuTile(
                          icon: Icons.confirmation_num_rounded,
                          title: 'Bookings',
                          subtitle: 'View and track your bookings',
                          onTap: widget.onBookingsTap,
                        ),
                      ),

                      _AnimatedProfileItem(
                        index: 1,
                        child: _ProfileMenuTile(
                          icon: Icons.description_outlined,
                          title: 'Terms and Conditions',
                          subtitle: 'Read our terms of service',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const TermsAndConditionsPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      _AnimatedProfileItem(
                        index: 2,
                        child: _ProfileMenuTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle:
                          'Learn how we protect your information',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      _AnimatedProfileItem(
                        index: 3,
                        child: _ProfileMenuTile(
                          icon: Icons.currency_exchange_rounded,
                          title: 'Refund Policy',
                          subtitle: 'View cancellation and refund rules',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RefundPolicyPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      _AnimatedProfileItem(
                        index: 4,
                        child: _ProfileMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About Us',
                          subtitle: 'Know more about Dadabhai Travel',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AboutUs(),
                              ),
                            );
                          },
                        ),
                      ),


                      const SizedBox(height: 12),

                      _AnimatedProfileItem(
                        index: 6,
                        child: _buildAuthButton(),
                      ),
                    ],
                  ),
                ),

                _buildAppVersion(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            dark,
            primary,
            light,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -50,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),

          Row(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.15),
                      gradient: const LinearGradient(
                        colors: [
                          primary,
                          light,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignedIn ? 'Welcome Back' : 'Welcome',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _isSignedIn
                          ? 'Mohamed Rasith'
                          : 'Guest User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _isSignedIn
                          ? 'Manage your travel account'
                          : 'Sign in to manage your account',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.8),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton() {
    final color = _isSignedIn
        ? const Color(0xffE5484D)
        : primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (_isSignedIn) {
              _showLogoutDialog();
            } else {
              _signIn();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _isSignedIn
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
                    color: color,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    _isSignedIn
                        ? 'Sign Out'
                        : 'Sign In',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: color.withOpacity(.65),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() {
    // Replace this with your actual login page later.
    setState(() {
      _isSignedIn = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed in successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Sign Out?'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _isSignedIn = false;
                });
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: dark.withOpacity(.08),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dadabhai Travel',
            style: TextStyle(
              color: dark.withOpacity(.45),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Version $_appVersion',
            style: TextStyle(
              color: dark.withOpacity(.32),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ProfileMenuTile> createState() =>
      _ProfileMenuTileState();
}

class _ProfileMenuTileState
    extends State<_ProfileMenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: _ProfilePageState.dark.withOpacity(.055),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: widget.onTap,
            onTapDown: (_) =>
                setState(() => _pressed = true),
            onTapUp: (_) =>
                setState(() => _pressed = false),
            onTapCancel: () =>
                setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _ProfilePageState.primary
                              .withOpacity(.13),
                          _ProfilePageState.light
                              .withOpacity(.07),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 21,
                      color: _ProfilePageState.primary,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _ProfilePageState.dark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 10.8,
                            color: _ProfilePageState.dark
                                .withOpacity(.48),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _ProfilePageState.dark
                        .withOpacity(.25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProfileItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedProfileItem({
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedProfileItem> createState() =>
      _AnimatedProfileItemState();
}

class _AnimatedProfileItemState
    extends State<_AnimatedProfileItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      Duration(milliseconds: 80 * widget.index),
          () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Terms & Conditions',
      subtitle: 'Booking Terms and Conditions',
      icon: Icons.description_outlined,
      content: '''
Agreement between You and Dadabhai Travel LLC.

Thank you for visiting dadabhaitravel.ae (the "Web Site"). The Web Site is offered by us, Dadabhai Travel LLC conditioned on acceptance by you, the user of the Web Site, without modification, limitation or qualification, of the terms and conditions contained herein.

By accessing and using this Web Site, you are deemed to have agreed to all such terms and conditions.

MODIFICATION OF TERMS

We may change these terms and conditions at any time without advance notice. Changed terms will become effective once posted on the Web Site and will not have any retrospective effect on existing contractual arrangements made through this Web Site.

DISCLAIMER OF WARRANTIES & LIMITATION OF LIABILITY

General

Your access to and use of software and other materials on, or through, this Web Site is solely at your own risk.

DISCLAIMER OF WARRANTY

To the maximum extent permitted by applicable law, we disclaim all warranties relating to the information, software, products and services contained in this Web Site.

LIMITATION OF LIABILITY

In no event will we be liable for any direct, special, indirect, incidental or consequential damages arising from access to, or use of, this Web Site.

INDEMNITY

As a condition of use of this Web Site, you agree to indemnify Dadabhai Travel LLC from and against liabilities, expenses and damages arising out of claims resulting from your use of this Web Site.

LINKS TO THIRD-PARTY WEB SITES

This Web Site may contain links to Internet sites maintained by third parties. Dadabhai Travel LLC does not operate or control those third-party sites.

LIMITATIONS ON USE

You agree to use this Web Site solely to determine availability of goods and services and to make legitimate reservations or transact business with us.

WEB SITE BOOKINGS

You may book holidays, hotels, car hire, excursions and various land arrangements as offered on the website.

Modifications or cancellations to bookings are subject to the applicable booking, supplier and Dadabhai Travel LLC conditions.

PERSONAL PROFILE AND LOGIN

Users wishing to make a booking may be required to register. Please keep your Login/ID and password confidential.

USE OF CREDIT CARD

Dadabhai Travel accepts major credit cards including Visa and MasterCard, subject to the applicable booking and payment conditions.

SECURITY

Dadabhai Travel LLC will take reasonable measures to protect information transmitted through the Web Site.

PASSPORTS

Passengers are responsible for ensuring their passports are valid for their journey and for obtaining any required visas.

AIRPORT TAXES

Certain airports may levy local departure taxes payable directly by passengers.

HEALTH / INSURANCE REQUIREMENTS

Travellers should check applicable health and immunisation requirements and are recommended to obtain appropriate travel insurance.

CONDITIONS OF CARRIAGE

Air transportation is subject to the Conditions of Carriage of the relevant carrier.

DADABHAI TRAVEL LLC
BOOKING TERMS AND CONDITIONS

BOOKING FORM

All bookings must be completed through the applicable booking process. A booking is confirmed only after successful submission and payment processing, subject to availability.

CLIENT'S RESPONSIBILITY

Travellers are responsible for checking their travel documents and ensuring that the details correspond with the booking request.

PAYMENTS

A deposit or full payment must be made according to the conditions of the selected tour or service.

ACCEPTANCE OF TERMS & CONDITIONS

By submitting a booking and making payment, the customer acknowledges and agrees to Dadabhai Travel LLC's applicable terms and conditions.

METHODS OF PAYMENT

Major credit cards including Visa and MasterCard are accepted subject to applicable payment conditions.

CONFIRMATION OF PAYMENT

Following successful payment, confirmation may be provided by Dadabhai Travel LLC by email.

REFUND POLICY

• Refund eligibility depends on the conditions applicable to the booking and relevant suppliers.
• Refund processing may take additional time where supplier refunds are required.
• Airlines, cruise lines, attractions and other suppliers may impose cancellation charges.

CANCELLATION POLICY

Each tour, activity, attraction, hotel, airline or other travel service may have its own cancellation policy. Customers should review the applicable policy before confirming a booking.

GENERAL CANCELLATION TERMS

• Combo-package conditions may change if an individual service is cancelled.
• Tourist visa fees may be non-refundable after processing.
• Airline cancellations and refunds are governed by the applicable airline's rules.
• Once a tour has commenced, partial refunds may not be available.
• No-show charges may be up to 100% of the booked service.

NO-SHOW POLICY

Failure to attend a confirmed tour or service may result in the loss of the amount paid, subject to the applicable booking conditions.

INSURANCE

Travel insurance is strongly recommended for personal accidents, medical expenses, baggage loss and other travel risks.

TIME LIMIT

Reservations may have payment or confirmation deadlines. Failure to meet these deadlines may result in automatic cancellation.

HOTEL ACCOMMODATION & CHECK-IN / CHECK-OUT

Customers must carry the appropriate travel documentation.

Hotel ratings are provided as guidance and may vary by country or property.

Early check-in and late check-out are subject to hotel availability unless specifically confirmed.

PASSPORT, VISA AND HEALTH REQUIREMENTS

Before travelling, customers must ensure that they possess valid passports, visas, entry permits and any required health documentation.

COMPLAINTS

Any issue experienced during a holiday should be reported as soon as possible so that assistance can be provided.

DEFINITIONS

"Company" means Dadabhai Travel LLC.

"Customer" means the person entering into a booking or contract with the Company.

"Contract" means the contract for provision of services by the Company to the Customer.

"Services" means holidays, tours or other services offered by the Company or through third-party suppliers.

LIABILITY OF THE COMPANY

Dadabhai Travel LLC and its agents act subject to the applicable conditions governing the travel services provided by airlines, hotels, tour operators and other suppliers.

GOVERNING LAW

These conditions are subject to the applicable laws of the United Arab Emirates.

ALL TOURS ARE OPERATED BY DADABHAI TRAVEL LLC AS PER THE APPLICABLE TERMS AND CONDITIONS.
''',
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Privacy Policy',
      subtitle: 'Your privacy matters to us',
      icon: Icons.privacy_tip_outlined,
      content: '''
GENERAL INFORMATION

This Privacy Policy applies to dadabhaitravel.ae and the services operated by Dadabhai Travel LLC.

DADABHAI TRAVEL LLC
Gulf Towers, Oud Metha Road
Dubai, United Arab Emirates

Tel: +971 4 3885566
Email: info@dadabhaitravel.ae
Data Protection: data-protection@dadabhaitravel.ae

HOW DO WE PROCESS PERSONAL DATA?

We save and use personal data where necessary to process enquiries, bookings and orders and to communicate with customers.

WHAT CATEGORIES OF DATA DO WE COLLECT?

Information collected may include details such as:

• Name
• Email address
• Mobile/telephone number
• Address information
• Booking and enquiry information
• Technical information related to use of the website

BOOKING A PRODUCT OR SERVICE

When you make an enquiry or booking, Dadabhai Travel may collect information required to process and manage your request.

Payment card information may be processed directly by the applicable payment-service provider.

EMAIL ADDRESSES

Where you subscribe to newsletters or automated communications, your email address may be used for those purposes.

CONTACTING CUSTOMER SERVICES

When contacting customer services, Dadabhai Travel may request information necessary to identify your booking and assist with your enquiry.

COOKIES

Dadabhai Travel websites may use cookies and similar technologies to improve website functionality, understand website usage and support relevant services.

You may control cookies through your browser settings, although disabling certain cookies may affect website functionality.

YOUR RIGHTS

Subject to applicable law, you may have rights relating to:

• Access to your personal information
• Correction of inaccurate information
• Deletion of eligible information
• Restriction of processing
• Objection to certain processing
• Data portability where applicable

VOLUNTARY NATURE OF DATA PROVISION

Providing personal information is generally voluntary. However, certain information may be necessary in order to provide particular booking or travel services.

INFORMATION SECURITY

Dadabhai Travel takes reasonable organisational and technical measures to protect personal information.

However, no method of Internet transmission or electronic storage can be guaranteed to be completely secure.

VIEWING AND EDITING YOUR INFORMATION

Customers may contact Dadabhai Travel to request corrections or updates to information held about them.

Requests concerning personal data may be sent to:

data-protection@dadabhaitravel.ae

or

bookings@dadabhaitravel.ae

COOKIE POLICY

Cookies may be used to improve usability and understand website traffic and interaction.

THIRD-PARTY LINKS

Dadabhai Travel websites may contain links to third-party websites.

Third-party websites operate under their own privacy practices and Dadabhai Travel is not responsible for those external privacy policies.

PROMOTIONS AND SPECIAL OFFERS

Promotional communications may be provided to customers who have subscribed or otherwise agreed to receive them.

Recipients can unsubscribe from promotional emails using the unsubscribe mechanism provided.

PRIVACY POLICY AMENDMENTS

Dadabhai Travel may update its Privacy Policy from time to time.

Any applicable updates may be published on the Dadabhai Travel website.

CONTACT US

For questions regarding privacy or personal information, please contact:

Dadabhai Travel LLC
Dubai, United Arab Emirates

Phone: +971 4 3885566
Email: bookings@dadabhaitravel.ae
Data Protection: data-protection@dadabhaitravel.ae
''',
    );
  }
}

class _LegalPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String content;

  const _LegalPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });

  @override
  State<_LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<_LegalPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static const dark = Color(0xff0F4C81);
  static const primary = Color(0xff1C7ED6);
  static const light = Color(0xff4DABF7);
  static const background = Color(0xffF5F8FC);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, .04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isHeading(String line) {
    final text = line.trim();

    if (text.isEmpty || text.length > 60) {
      return false;
    }

    final letters =
    text.replaceAll(RegExp(r'[^A-Za-z]'), '');

    if (letters.isEmpty) return false;

    return text == text.toUpperCase() ||
        const [
          'General',
          'Modification of Terms',
          'Indemnity',
          'Security',
          'Passports',
          'Airport Taxes',
          'Conditions of Carriage',
          'General Cancellation Terms',
          'Cancellation Charges',
        ].contains(text);
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.content
        .split('\n')
        .map((e) => e.trim())
        .toList();

    return Scaffold(
      backgroundColor: background,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                36,
              ),
              children: [

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: _GlassBackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 100,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Keeps logo perfectly centered
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildHeader(),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: dark.withOpacity(.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      for (final line in lines)
                        if (line.isEmpty)
                          const SizedBox(height: 9)
                        else if (_isHeading(line))
                          _heading(line)
                        else if (line.startsWith('•'))
                            _bullet(line.substring(1).trim())
                          else
                            _paragraph(line),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: dark.withOpacity(.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Dadabhai Travel LLC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: dark.withOpacity(.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            dark,
            primary,
            light,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.icon,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'dadabhaitravel.ae',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.6),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primary, light],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _titleCase(text),
              style: const TextStyle(
                color: dark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          color: dark.withOpacity(.72),
          fontSize: 12.5,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5,
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(
              top: 7,
              right: 10,
            ),
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: dark.withOpacity(.72),
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String text) {
    if (text.length <= 3) return text;

    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }
}

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalPage(
      title: 'Refund Policy',
      subtitle: 'Booking Cancellation & Refund Policy',
      icon: Icons.currency_exchange_rounded,
      content: '''
REFUND POLICY

Dadabhai Travel accepts Mastercard and Visa credit cards.

Full payment by credit card is required to make a reservation. Payment will appear as Dadabhai Travel on the customer's credit card statement.

NO REFUNDS AFTER SERVICE COMMENCES

No refunds are available once a tour or service has commenced.

This also applies to any package, accommodation, meals, or other services that have already been used.

CANCELLATION FEES

Cancelling a booking with Dadabhai Travel may result in cancellation fees.

Additional cancellation fees may also be charged by the individual supplier or operator.

Please refer to your Dadabhai Travel voucher for any specific supplier conditions.

When cancelling a booking, the applicable cancellation charges will be communicated to you by email, telephone, or other available communication method.

EVENT, ATTRACTION, THEATER, SHOW OR COUPON TICKETS

• These products are non-refundable in all circumstances.

TOURS OR PACKAGES DURING SPECIAL EVENT PERIODS

Tours or packages commencing during a special-event period are non-refundable.

Special-event periods include, but are not limited to:

• Trade fairs
• Public holidays
• National holidays
• School holidays
• New Year's
• Thanksgiving
• Christmas
• Easter
• Ramadan

OTHER TOUR PRODUCTS & SERVICES

For other eligible tour products and services, the following general cancellation charges apply:

• Cancellation at least 7 calendar days before the scheduled departure or commencement time:
No cancellation fee.

• Cancellation between 2 and 6 calendar days before the scheduled departure or commencement time:
50% cancellation fee.

• Cancellation within 24 hours of the scheduled departure or commencement time:
100% cancellation fee.

SUPPLIER CANCELLATION CONDITIONS

Individual hotels, airlines, attractions, cruise companies, tour operators and other suppliers may have their own cancellation and refund policies.

Supplier charges may apply in addition to Dadabhai Travel's cancellation conditions.

Customers should review the specific booking conditions before confirming a reservation.

NO-SHOW

Failure to attend a confirmed tour, attraction, transfer, accommodation, activity or other travel service may result in a 100% cancellation charge.

No refund may be available for a no-show.

SERVICES ALREADY USED

Once a tour or service has started, refunds are not available for services that have already been consumed or used.

This includes accommodation, meals, packages and other included travel services.

REFUND REQUESTS

Where a refund is applicable, it will be processed according to the booking conditions and applicable supplier rules.

Dadabhai Travel's Terms and Conditions also state that refund processing may take approximately 15 to 30 days where supplier payments or confirmations are required.

Customers may be required to provide original documents, unused vouchers or other supporting documents required for refund processing.

AIRLINE TICKETS

Airline cancellation, refund and rebooking conditions are governed by the relevant airline's fare rules and policies.

Cancellation penalties or other airline charges may apply.

Dadabhai Travel is not responsible for airline charges that are outside its control.

CONTACT

For booking cancellation or refund enquiries, please contact:

Dadabhai Travel LLC

Office No: 103A1-4, A2 1st Floor
Gulf Towers
Beside KM Trading
Oud Metha Road
Dubai, UAE

Phone: +971 4 3885566

Please contact Dadabhai Travel as early as possible if you need to cancel or amend a booking.
''',
    );
  }
}

class _GlassBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _GlassBackButton({
    required this.onTap,
  });

  @override
  State<_GlassBackButton> createState() =>
      _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            // Glass background
            color: _pressed
                ? Colors.white.withOpacity(.75)
                : Colors.white.withOpacity(.45),

            borderRadius: BorderRadius.circular(15),

            // Glass border
            border: Border.all(
              color: Colors.white.withOpacity(.75),
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  _pressed ? .05 : .10,
                ),
                blurRadius: _pressed ? 5 : 14,
                offset: Offset(
                  0,
                  _pressed ? 2 : 5,
                ),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}