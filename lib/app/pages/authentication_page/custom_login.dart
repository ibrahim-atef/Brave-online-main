import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../config/colors.dart';

class CustomLoginPage extends StatelessWidget {
  static const String pageName = '/CustomLoginPage';

  const CustomLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Logo
                Image.asset(
                  'assets/image/png/anmka.png',
                  width: 100,
                  height: 100,
                ),

                const SizedBox(height: 20),

                Text(
                  'سجل دخولك أو أنشئ حساب جديد',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'اختر طريقة الدخول',
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 20),

                // TabBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: mainColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: mainColor(),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'برقم الهاتف'),
                      Tab(text: 'بالبريد الإلكتروني'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // TabBarView
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Phone login
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IntlPhoneField(
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              initialCountryCode: 'EG',
                              onChanged: (phone) {
                                print(phone.completeNumber);
                              },
                            ),

                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'يجب أن يحتوي على واتساب',
                                  style: TextStyle(fontSize: 12, color: mainColor()),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // تنفيذ الدخول
                                },
                                child: const Text(
                                  'دخول',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tab 2: Email login
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // تنفيذ الدخول بالبريد
                                },
                                child: const Text(
                                  'دخول',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    // الانتقال للدعم
                  },
                  child: Text(
                    'هل تواجه مشكلة في التسجيل ؟',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
