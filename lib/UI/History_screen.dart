import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Box? translationsBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    translationsBox = await Hive.openBox('translations');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: translationsBox == null
          ? const Center(child: CircularProgressIndicator())
          : translationsBox!.isEmpty
              ? const Center(child: Text("No translation history found."))
              : ListView.builder(
                  itemCount: translationsBox!.length,
                  itemBuilder: (context, index) {
                    var history = translationsBox!.getAt(index);

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Ensures dynamic height
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history['input'],
                                maxLines: null, // Allows unlimited lines
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF003366),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Divider(),
                              Text(
                                history['output'],
                                maxLines: null, // Allows unlimited lines
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFF6600),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      translationsBox!.deleteAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
