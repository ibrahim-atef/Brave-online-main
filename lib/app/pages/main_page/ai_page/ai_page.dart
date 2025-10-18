import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:webinar/app/pages/main_page/home_page/home_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/config/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AiPage extends StatefulWidget {
  static const String pageName = '/ai-page';

  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  final String homeUrl = 'https://chatgpt.com'; // رابط الصفحة الرئيسية

  Future<void> secureScreen() async {
    await ScreenProtector.protectDataLeakageOn();
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  UniqueKey _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setUserAgent("Anmka")
      ..loadRequest(Uri.parse(homeUrl))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError) {
            print(WebResourceError);
            print("WebResourceError");
          },
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) async {
            setState(() {
              _isLoading = false;
            });

            String? currentUrl = await _controller.currentUrl();
            if (currentUrl != null && currentUrl != homeUrl) {
              setState(() {
                _canGoBack = true;
              });
            }
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _goBack() async {
    nextRoute(MainPage.pageName);
    // if (await _controller.canGoBack()) {
    //   await _controller.goBack();
    //
    //   String? currentUrl = await _controller.currentUrl();
    //   if (currentUrl == homeUrl) {
    //     setState(() {
    //       _canGoBack = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor(),
        leading: _canGoBack
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        )
            : null,
        title: const Text("AI Page"),
      ),
      body: Column(
        children: [
          // ClipPath(
          //   clipper: CustomTopClipper(),
          //   child: Container(
          //     height: 30,
          //     color: mainColor(),
          //   ),
          // ),
      Container(
        height: 0,
      decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(40),
      bottomRight: Radius.circular(40),
    ),

    )),
          Expanded(
            child: WebViewWidget(
              controller: _controller,
              key: _key,
              gestureRecognizers: gestureRecognizers,
            ),
          ),
        ],
      ),


    );
  }
}
class CustomTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 40, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
