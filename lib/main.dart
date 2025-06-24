// lib/main.dart

import 'dart:io'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';
import 'http_overrides.dart'; // <-- 2. TAMBAHKAN IMPORT FILE BARU ANDA

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. TAMBAHKAN BARIS INI UNTUK MENGIZINKAN KONEKSI HTTPS
  HttpOverrides.global = MyHttpOverrides();

  await dotenv.load(fileName: ".env");

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Modern Farming | STAS-RG",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
