import 'package:dadabhaitravel/view/pages/dashboard.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget{
  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LogoColors.bg,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 8,),
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
                  const SizedBox(height: 10,),
                  Image.network(
                    "https://images.unsplash.com/photo-1612873649383-edf91f1cf7fe?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",

                    height: 320,
                    width: MediaQuery.of(context).size.width,

                    fit: BoxFit.cover,

                    loadingBuilder: (context, child, loadingProgress) {

                      if (loadingProgress == null) {
                        return child; // Image loaded
                      }

                      return Container(
                        height: 320,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey.shade200,

                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LogoColors.primary,
                            ),

                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },


                    errorBuilder: (context, error, stackTrace) {

                      return Container(
                        height: 320,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey.shade200,

                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8,),
                  AppTitle(text: "About Us - Dadabhai Travel", fontSize: 16,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "DADABHAI GROUP, one of the most progressive and diversified conglomerates in the Kingdom of Bahrain, anticipating the potential, decided to establish a travel agency and in 1981 launched their first travel shop in downtown area of Kingdom of Bahrain. Over the years the travel agency has expanded and today we have seven offices, two GSA offices and seventeen implant locations, catering innovatively to the demanding requirements of our diversified corporate clientele, always adapting to keep pace with industry trends. Our growth would not have been possible without our greatest asset: our dedicated, professional and multilingual team of travel and tour consultants who provide levels of service, which is a benchmark in the local industry.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "Our enviable expansion over the years has never halted us opening new avenues and offices across the region. In 2011 we have spread our wings into Saudi Arabia Eastern Province (Al Khobar) and expanded our network by adding more offices in Saudi Arabia i.e in Al Khobar, Jubail, Jeddah (Western Province), Riyadh (Central Province), Dammam.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "Considering the importance of the regional presence, DADABHAI TRAVEL expansion plan took place in the year 2012 and we have opened our office in Dubai, United Arab Emirates by acquiring a Destination Management Company which has been in operation since 2005 and expanded our network by adding another Corporate Office thus making two prime offices in Dubai. To serve more actively and efficiently in UAE, we have added one more office at Abu Dhabi in April 2014. Our UAE expansion plan include few more offices in other Emirates to be opened in the course of time.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "Our United Arab Emirate operation include our own Desert Safari Camp, which can accommodate over 700 passengers. The facility includes overnight camping, Quad bike, Dune buggy ride etc. We do own fleet of vehicles ie. Large air-conditioned luxury coaches, Land Cruisers, Luxury cars, etc. Currently put together we employ over 220 employees thereby enjoying the best reputation amongst our loyal corporate clients.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppTitle(text: "VISION", fontSize: 16,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "To become the epitome of success in the travel and tourism industry through a customer-centric approach built around unparalleled service coupled with innovative concepts.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppTitle(text: "MISSION", fontSize: 16,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "To establish Dadabhai Travel as band that radiates optimum, trust and satisfaction among customers, providing reliable and quality travel solutions through a team of highly motivated employees and quality management systems.", fontSize: 13,),
                  const SizedBox(height: 8,),
                  AppTitle(text: "VALUES", fontSize: 16,),
                  const SizedBox(height: 8,),
                  AppParagraph(text: "Four values are at the heart of everything we do, as a team and individuals.", fontSize: 13,),
                  AppTitle(text: "Secure Server Certificate – renewal:", fontSize: 13,),
                  AppParagraph(text: "Building productive, symbiotic relationships by being transparent and promoting open communication.", fontSize: 13,),
                  AppParagraph(text: "1. Customer Care: Putting the needs of clients first and striving to continuously provide outstanding service. 2. Teamwork: Working together to produce extraordinary results, becoming natural partners with our clients, colleagues, and community. 3. Reliability: Being a dependable and trustworthy business partner, committed to offering industry-leading products services.", fontSize: 13,),
                  const SizedBox(height: 30,)
                ],
            ),
          ),
        ),
      ),
    );
  }
}
class AppTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;

  const AppTitle({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      style: TextStyle(
        color: color ?? const Color(0xFF1A1A1A),
        fontSize: fontSize ?? 22,
        fontWeight: fontWeight,
        height: 1.3,
      ),
    );
  }
}

class AppParagraph extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final double height;
  final int? maxLines;

  const AppParagraph({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.textAlign = TextAlign.start,
    this.height = 1.6,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      style: TextStyle(
        color: color ?? Colors.black87,
        fontSize: fontSize ?? 15,
        fontWeight: fontWeight,
        height: height,
      ),
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