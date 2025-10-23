import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:egyptm/app/pages/main_page/main_page.dart';
import 'package:egyptm/common/common.dart';

import '../../../../../common/components.dart';
import '../../../../../common/utils/constants.dart';
import '../../../../../config/colors.dart';
import '../../../../providers/drawer_provider.dart';
import '../../../../services/guest_service/course_service.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

class EnrollmentPage extends StatefulWidget {
  static const String pageName = '/enrollment';

  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  final TextEditingController _codeController = TextEditingController();

  bool isLoading = false;

  Future<void> sendCode(String code) async {
    setState(() {
      isLoading = true;
    });
    const url = '${Constants.baseUrl}panel/use-code-course';

    // إرسال البيانات في الـ body
    bool  response = await CourseService.enrollment(url, code);
    // التحقق من الاستجابة
    if (response && mounted) {
      nextRoute(MainPage.pageName,);
      // يمكنك هنا إضافة كود للعرض الناجح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent successfully!')),
      );
    } else if (mounted) {
      // يمكنك هنا إضافة كود للخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send code!')),
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
                  const Text('Please enter the code below:'),
                  const SizedBox(height: 20),
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
        decoration: const InputDecoration(
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


                  const SizedBox(height: 20),
                    if (isLoading)
                      CircularProgressIndicator(color: mainColor())
                    else
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(mainColor()),
                    ),
                    onPressed: () {
                      String code = _codeController.text.trim();
                      if (code.isNotEmpty) {
                        sendCode(code); // إرسال الكود
                      } else {
                        // إذا الكود فارغ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a code')),
                        );
                      }
                    },
                    child: const Text('Send Code'),
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

  // دالة لرفع صورة من المعرض
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // قراءة QR code من الصورة المختارة
        await _scanQRFromImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  // دالة لقراءة QR code من صورة
  Future<void> _scanQRFromImage(String imagePath) async {
    try {
      // إنشاء InputImage من مسار الصورة
      final inputImage = mlkit.InputImage.fromFilePath(imagePath);
      
      // إنشاء barcode scanner
      final barcodeScanner = mlkit.BarcodeScanner();
      
      // مسح الصورة للبحث عن barcodes
      final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      
      // إغلاق الماسح الضوئي
      barcodeScanner.close();
      
      if (barcodes.isNotEmpty) {
        // العثور على QR code
        final String? qrCode = barcodes.first.rawValue;
        
        if (qrCode != null && !isScanned && mounted) {
          setState(() => isScanned = true);
          if (mounted) {
            Navigator.pop(context, qrCode);
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على بيانات صالحة في QR code')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على QR code في الصورة المختارة')),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في قراءة الصورة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(title: 'امسح الكود'),
      body: Stack(
        children: [
          // كاميرا المسح المباشر
          MobileScanner(
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
          
          // أزرار التحكم
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر رفع صورة من المعرض
                FloatingActionButton.extended(
                  onPressed: _pickImageFromGallery,
                  backgroundColor: Colors.yellow,
                  icon: const Icon(Icons.photo_library, color: Colors.black45),
                  label: const Text(
                    'رفع صورة',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                
                // زر تشغيل/إيقاف الفلاش
                FloatingActionButton(
                  onPressed: () => cameraController.toggleTorch(),
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.flash_on, color: Colors.white),
                ),
                
                // زر تبديل الكاميرا
                FloatingActionButton(
                  onPressed: () => cameraController.switchCamera(),
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.camera_front, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // إرشادات للمستخدم
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'وجه الكاميرا نحو QR Code أو اضغط "رفع صورة" لاختيار صورة من المعرض',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
