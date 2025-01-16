import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/datatable_model.dart';

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
    'Nama Domba',
    'Usia (Bulan)',
    'Jenis Kelamin',
    'Created At',
  ].obs;

  void fetchChipId() async {
    try {
      final response = await _http.get('http://localhost:3000/api/v2/rfid/get');
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
    try {
      final response = await _http.post(
        'http://localhost:3000/api/v2/chip',
        jsonEncode({
          'id': chipIdController.text,
          'nama_domba': namaDombaController.text,
          'usia': selectedDate.toString(),
          'jenis_kelamin': selectedJenisKelamin.value,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.defaultDialog(
          title: "Success",
          middleText: "Data Berhasil Ditambahkan",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            Get.back();
          },
        );
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      throw Exception('Failed to post data');
    }
  }

  void fetchDataTable(int page) async {
    try {
      final response = await _http.get("http://localhost:3000/api/v2/chip",
          query: {'page': page.toString()});
      if (response.statusCode == 200) {
        final data = response.body;
        print(response.body);
        listDataTable.clear();
        for (var item in data['data']['rows']) {
          listDataTable.add(DataTableModel({
            'UID': item['id'],
            'Nama Domba': item['nama_domba'],
            'Usia (Bulan)': item['usia'].toString(),
            'Jenis Kelamin': item['jenis_kelamin'],
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
  void onInit() {
    namaDombaController = TextEditingController();
    chipIdController = TextEditingController();
    tanggalLahirController = TextEditingController();
    fetchDataTable(currentPage);
    fetchChipId();
    super.onInit();
  }

  @override
  void dispose() {
    namaDombaController.dispose();
    chipIdController.dispose();
    tanggalLahirController.dispose();
    super.dispose();
  }
}
