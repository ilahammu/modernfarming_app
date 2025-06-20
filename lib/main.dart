import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Modern Farming | STAS-RG",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
