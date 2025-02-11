import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/domba_model.dart';

class OverviewController extends GetxController {
  var dataList = <Baris>[].obs;
  var isLoading = true.obs;
  var currentPage = 1.obs;
  var totalPage = 1.obs;
  final int itemsPerPage = 5; // Jumlah item per halaman
  final GetConnect _http = GetConnect();

  @override
  void onInit() {
    super.onInit();
    tanggalLahirController = TextEditingController();
    tanggalLahirControlleer = TextEditingController();
    fetchSheepData();
  }

  @override
  void dispose() {
    tanggalLahirController.dispose();
    tanggalLahirControlleer.dispose();
    super.dispose();
  }

  final Rx<String?> selectedSheep = Rx<String?>(null);

  // Membuat variabel sheepList yang berisi list dari Map<String, String>
  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;

  var selectedHistory = "Current".obs;
  var isFetching = false.obs;

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

  late TextEditingController tanggalLahirController;
  late TextEditingController tanggalLahirControlleer;

  get selectedDate => null;

  void updateSelectedDate2(DateTime? date) {}
  void updateSelectedDate(DateTime? date) {}

  void handlerDropdownSheep(String? sheep) {
    selectedSheep.value = sheep;
    if (sheep != null) {
      fetchDombaData(sheep);
    } else {
      dataList.clear();
    }
  }

  void handlerDropdownHistory(String? history) {
    selectedHistory.value = history!;
  }

  Future<void> fetchSheepData() async {
    isLoading.value = true;
    try {
      int page = 1;
      final Set<String> seenChipIds = {};
      final List<Map<String, String>> allSheep = [];

      while (true) {
        final response = await _http.get(
          'http://localhost:3000/api/chip',
          query: {'page': page.toString()},
        );

        if (response.statusCode == 200) {
          final data = response.body['data']['rows'];
          for (var item in data) {
            final chipId = item['id'].toString();
            if (!seenChipIds.contains(chipId)) {
              seenChipIds.add(chipId);
              allSheep.add({
                'nama_domba': item['nama_domba'].toString(),
                'chip_id': chipId,
              });
            }
          }

          final totalPages = response.body['pagination']['totalPages'];
          if (page >= totalPages) break;
          page++;
        } else {
          throw Exception("Failed to load sheep data");
        }
      }

      sheepList.assignAll(allSheep); // Perbarui daftar dropdown
      sheepList.refresh(); // Paksa UI diperbarui

      // Hanya set default jika belum ada yang dipilih sebelumnya
      if (selectedSheep.value == null && allSheep.isNotEmpty) {
        selectedSheep.value = null; // Pastikan tetap null agar hint muncul
      }
    } catch (e) {
      print("Error fetching sheep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchListDomba() async {
    try {
      final response = await _http.get('http://localhost:3000/api/chip');
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        final Set<String> seenChipIds = {};
        sheepList.clear();
        for (var item in data) {
          final chipId = item['chip_id'].toString();
          if (!seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId
            });
          }
        }
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
        print("Sheep list: $sheepList");
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      throw Exception('Failed to fetch sheep list: $e');
    }
  }

  Future<void> fetchDombaData(String chipId) async {
    isLoading(true);
    try {
      final response = await _http.get(
        "http://localhost:3000/api/chip/$chipId",
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data != null) {
          final domba = DombaModels.fromJson(response.body);
          dataList.value = domba.data;
          print("Data successfully fetched: $dataList");
        } else {
          dataList.value = [];
          print("No data available for chip ID: $chipId");
        }
      } else {
        throw Exception("Failed to fetch data: ${response.statusText}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading(false);
    }
  }

  void resetView() {}

  void handlerDropdownDate(String? value) {}

  void updateBirthDate(DateTime? date) {}
}
