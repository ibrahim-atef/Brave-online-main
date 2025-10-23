import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:egyptm/app/pages/authentication_page/custom_login.dart';
import 'package:egyptm/app/pages/introduction_page/intro_page.dart';
import 'package:egyptm/app/pages/main_page/main_page.dart';
import 'package:egyptm/app/pages/offline_page/internet_connection_page.dart';
import 'package:egyptm/app/services/guest_service/guest_service.dart';
import 'package:egyptm/common/common.dart';
import 'package:egyptm/common/data/app_data.dart';
import 'package:egyptm/common/utils/app_text.dart';
import 'package:egyptm/config/assets.dart';
import 'package:egyptm/config/styles.dart';
import '../authentication_page/login_page.dart';
import '../authentication_page/register_page.dart';



import '../../../config/colors.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // late AnimationController animationController;
  // late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 2),
    // );

    // fadeAnimation = CurvedAnimation(
    //   parent: animationController,
    //   curve: Curves.easeIn,
    // );

    FlutterNativeSplash.remove();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // animationController.forward();

      Timer(const Duration(seconds: 2), () async {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none)) {
          nextRoute(InternetConnectionPage.pageName, isClearBackRoutes: true);
        } else {
          String token = await AppData.getAccessToken();
          // nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
          if (mounted) {
            if (token.isEmpty) {
              bool isFirst = await AppData.getIsFirst();
          
              if (isFirst) {
                nextRoute(IntroPage.pageName, isClearBackRoutes: true);
              } else {
                nextRoute(LoginPage.pageName, isClearBackRoutes: true);
              }
            } else {
              nextRoute(MainPage.pageName, isClearBackRoutes: true);
            }
          }
        }
      });

      
    });

    GuestService.config();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F6C5F),
      body: Container(
        width: getSize().width,
        height: getSize().height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: mainColor(),
          // image: DecorationImage(
          //   image: AssetImage(AppAssets.splashPng),
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Center(
          child: Container(
            height: getSize().height / 2,
            width: getSize().width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                space(30),
                SlideInRight(
                  child: Text(
                    appText.webinar,
                    style: style24Bold().copyWith(color: white()),
                  ),
                ),
                space(10),
                SlideInLeft(
                  child: Text(
                    appText.splashDesc,
                    style: style16Regular().copyWith(color: white()),
                  ),
                ),
                space(10),
                SlideInUp(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.splash_logo_png),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // animationController.dispose();
    super.dispose();
  }
}
