import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'dart:convert';

import '../../../../../common/components.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../../common/utils/object_instance.dart';
import '../../../../../config/assets.dart';
import '../../../../../config/colors.dart';
import '../../../../providers/drawer_provider.dart';
import '../../../../services/guest_service/course_service.dart';



import 'package:mobile_scanner/mobile_scanner.dart';

class EnrollmentPage extends StatefulWidget {
  static const String pageName = '/enrollment';

  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  TextEditingController _codeController = TextEditingController();

  bool isLoading = false;

  Future<void> sendCode(String code) async {
    setState(() {
      isLoading = true;
    });
    final url = '${Constants.baseUrl}panel/use-code-course';

    // إرسال البيانات في الـ body
    bool  response = await CourseService.enrollment(url, code);
    // التحقق من الاستجابة
    if (response) {
      nextRoute(MainPage.pageName,);
      // يمكنك هنا إضافة كود للعرض الناجح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code sent successfully!')),
      );
    } else {
      // يمكنك هنا إضافة كود للخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code!')),
      );
    }
        setState(() {
      isLoading = false;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawerProvider>(
            builder: (context, drawerProvider, _) {
        return ClipRRect(
                borderRadius: borderRadius(radius:  drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
              appBar: appbar(
                          title: 'Enrollment',
                          // leftIcon: AppAssets.menuSvg,
                          // onTapLeftIcon: (){
                          //   print("menu");
                          //   drawerController.showDrawer();
                          // }
                        ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Please enter the code below:'),
                  SizedBox(height: 20),
                  // TextField(
                  //   controller: _codeController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Code',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),

Row(
  children: [
    Expanded(
      child: TextField(
        controller: _codeController,
        decoration: InputDecoration(
          labelText: 'Code',
          border: OutlineInputBorder(),
        ),
      ),
    ),
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.qr_code_scanner, size: 30),
      onPressed: () async {
        final scannedCode = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanPage()),
        );

        if (scannedCode != null) {
          _codeController.text = scannedCode;
          sendCode(scannedCode);
        }
      },
    ),
  ],
),


                  SizedBox(height: 20),
                    if (isLoading)
                      CircularProgressIndicator(color: mainColor(),)
                    else
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(mainColor()),
                    ),
                    onPressed: () {
                      String code = _codeController.text.trim();
                      if (code.isNotEmpty) {
                        sendCode(code); // إرسال الكود
                      } else {
                        // إذا الكود فارغ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a code')),
                        );
                      }
                    },
                    child: Text('Send Code'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}





class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late final MobileScannerController cameraController;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(title: 'امسح الكود'),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (BarcodeCapture capture) {
          if (isScanned) return;
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              setState(() => isScanned = true);
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}
