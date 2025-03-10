import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_translator/UI/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
     @override
  void initState() {
    super.initState();
    _navigateotherscreen();
  }

  _navigateotherscreen() async {
    await Future.delayed(Duration(seconds: 3), () async {
     
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
  
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
   
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -180.h,
              left: -140.w,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  width: 446.w,
                  height: 410.h,
                  decoration: ShapeDecoration(
                    color: Color(0xFF007AF5),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
                top: -230.h,
                right: -230.w,
                child: Opacity(
                  opacity: 0.50,
                  child: Container(
                    width: 446.w,
                    height: 410.h,
                    decoration: ShapeDecoration(
                      color: Color(0xFFF28739),
                      shape: OvalBorder(),
                    ),
                  ),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/translate.png',
                        width: 99.w,
                        height: 82.h,
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'TRANSLATE ON THE GO',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20.sp,
                        
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 12.r, backgroundColor: Colors.blueGrey),
                   SizedBox(width: 1.w),
                    CircleAvatar(
                        radius: 12.r, backgroundColor: Colors.blue.shade100),
                  ],
                ),
                 SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
