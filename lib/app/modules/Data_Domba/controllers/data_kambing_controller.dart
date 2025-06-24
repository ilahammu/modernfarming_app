import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataKambingController extends GetxController {
  late TextEditingController namaDombaController;
  late TextEditingController chipIdController;
  late TextEditingController tanggalLahirController;
  final listDataTable = <DataTableModel>[].obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final _http = GetConnect(); // Use GetConnect instead of Dio
  int currentPage = 1;
  int totalPage = 1;

  final Rx<String?> selectedJenisKelamin = Rx<String?>(null);
  final RxList<String> listDomba = <String>[].obs;

  void addDomba(String name) {
    listDomba.add(name);
  }

  void clearDombaList() {
    listDomba.clear();
  }

  void handlerDropdownJenisKelamin(String? jenisKelamin) {
    selectedJenisKelamin.value = jenisKelamin!;
  }

  final List<String> listDropdownJenisKelamin = [
    "Male",
    "Female",
  ];
  final listColumnDataTable = [
    'UID',
    'Sheep Name',
    'Age (Month)',
    'Gender',
    'Created At',
  ].obs;

  late String _baseUrl;
  late String _chipEndpoint;
  late String _rfidGetEndpoint;

  @override
  void onInit() {
    super.onInit();
    _baseUrl = dotenv.env['BASE_URL']!;
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT']!;
    _rfidGetEndpoint = dotenv.env['RFID']!;
    namaDombaController = TextEditingController();
    chipIdController = TextEditingController();
    tanggalLahirController = TextEditingController();
    fetchDataTable(currentPage);
    fetchChipId();
  }

  void fetchChipId() async {
    try {
      final response = await _http.get('$_baseUrl$_rfidGetEndpoint');
      if (response.statusCode == 200) {
        chipIdController.text = response.body['data']['chip_id'];
      } else {
        throw Exception('Failed to load chip ID');
      }
    } catch (e) {
      chipIdController.text = 'Failed To Fetch Chip ID';
    }
  }

  void postData() async {
    if (chipIdController.text.isEmpty) {
      print("Chip ID kosong");
      Get.snackbar("Error", "Chip ID Tidak Boleh Kosong");
      return;
    }
    if (namaDombaController.text.isEmpty) {
      print("Nama Domba kosong");
      Get.snackbar("Error", "Nama Domba Tidak Boleh Kosong");
      return;
    }
    if (selectedDate.value == null) {
      print("Tanggal Lahir kosong");
      Get.snackbar("Error", "Tanggal Lahir Tidak Boleh Kosong");
      return;
    }
    if (selectedJenisKelamin.value == null) {
      print("Jenis Kelamin kosong");
      Get.snackbar("Error", "Jenis Kelamin Tidak Boleh Kosong");
      return;
    }

    final payload = {
      'id': chipIdController.text,
      'nama_domba': namaDombaController.text,
      'usia': selectedDate.value!.toIso8601String(), // Konversi ke ISO 8601
      'jenis_kelamin': selectedJenisKelamin.value,
    };

    // Log payload dan header
    print("Payload: $payload");
    print("Headers: {'Content-Type': 'application/json'}");

    try {
      final response = await _http.post(
        '$_baseUrl$_chipEndpoint',
        jsonEncode(payload), // Pastikan payload di-encode menjadi JSON
        headers: {
          'Content-Type': 'application/json', // Tetapkan header yang benar
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Data berhasil dikirim");
        Get.defaultDialog(
          title: "Success",
          middleText: "Data Berhasil Ditambahkan",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            fetchDataTable(currentPage); // Refresh data di UI
          },
        );
      } else {
        print('Failed to post data: ${response.body}');
        Get.snackbar("Error", "Gagal Menambahkan Data: ${response.body}");
      }
    } catch (e) {
      print('Error posting data: $e');
      Get.snackbar("Error", "Terjadi Kesalahan: $e");
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http
          .get("$_baseUrl$_chipEndpoint", query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body;
        print(response.body);
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          listDataTable.add(DataTableModel({
            'UID': item['id'],
            'Sheep Name': item['nama_domba'],
            'Age (Month)': item['usia'].toString(),
            'Gender': item['jenis_kelamin'],
            'Created At': item['createdAt'],
          }));
        }
        currentPage = page;
        totalPage = data['pagination']['totalPages'];
      } else {
        throw Exception("Failed to Fetch Data");
      }
    } catch (e) {
      // Log error for debugging
      print(e);
      throw Exception("Failed to fetch data");
    }
  }

  void fetchNextPage() {
    if (currentPage < totalPage) {
      fetchDataTable(currentPage + 1);
    }
  }

  void fetchPreviousPage() {
    if (currentPage > 1) {
      fetchDataTable(currentPage - 1);
    }
  }

  String? chipIDValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Chip ID Tidak Boleh Kosong";
    } else {
      return null;
    }
  }

  String? namaDombaValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Nama Domba Tidak Boleh Kosong";
    } else {
      return null;
    }
  }

  String? tanggalLahirValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Tanggal Lahir Tidak Boleh Kosong";
    } else {
      return null;
    }
  }

  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  @override
  void dispose() {
    namaDombaController.dispose();
    chipIdController.dispose();
    tanggalLahirController.dispose();
    super.dispose();
  }
}
