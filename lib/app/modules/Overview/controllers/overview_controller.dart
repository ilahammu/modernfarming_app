import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/domba_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OverviewController extends GetxController {
  var dataList = <Baris>[].obs;
  var isLoading = true.obs;
  var currentPage = 1.obs;
  var totalPage = 1.obs;
  final int itemsPerPage = 5;
  final GetConnect _http = GetConnect();

  final Rx<String?> selectedSheep = Rx<String?>(null);
  final RxList<Map<String, String>> sheepList = <Map<String, String>>[].obs;
  var selectedHistory = "Current".obs;
  var isFetching = false.obs;

  late String _baseUrl;
  late String _chipEndpoint;

  late TextEditingController tanggalLahirController;

  @override
  void onInit() {
    super.onInit();
    _baseUrl = dotenv.env['BASE_URL'] ?? 'https://modernfarming-api.vercel.app';
    _chipEndpoint = dotenv.env['CHIP_ENDPOINT'] ?? '/api/chip';
    tanggalLahirController = TextEditingController();
    fetchSheepData();
  }

  @override
  void dispose() {
    tanggalLahirController.dispose();
    super.dispose();
  }

  void handlerSwitch(bool value) {
    isFetching.value = value;
  }

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
          '$_baseUrl$_chipEndpoint',
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

      sheepList.assignAll(allSheep);
      sheepList.refresh();

      if (selectedSheep.value == null && allSheep.isNotEmpty) {
        selectedSheep.value = null;
      }
    } catch (e) {
      print("Error fetching sheep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchListDomba() async {
    try {
      final response = await _http.get('$_baseUrl$_chipEndpoint');
      if (response.statusCode == 200) {
        final data = response.body['data']['rows'];
        final Set<String> seenChipIds = {};
        sheepList.clear();
        for (var item in data) {
          final chipId = item['id'].toString();
          if (!seenChipIds.contains(chipId)) {
            seenChipIds.add(chipId);
            sheepList.add({
              'nama_domba': item['nama_domba'].toString(),
              'chip_id': chipId
            });
          }
        }
        sheepList.sort((a, b) => a['nama_domba']!.compareTo(b['nama_domba']!));
      } else {
        throw Exception('Failed to load sheep list');
      }
    } catch (e) {
      print('Failed to fetch sheep list: $e');
    }
  }

  Future<void> fetchDombaData(String chipId) async {
    isLoading(true);
    try {
      final response = await _http.get(
        "$_baseUrl$_chipEndpoint/$chipId",
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body['data'];
        if (data != null) {
          final domba = DombaModels.fromJson(response.body);
          dataList.value = domba.data;
        } else {
          dataList.value = [];
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

  void resetView() {
    selectedSheep.value = null;
    dataList.clear();
    fetchSheepData();
  }
}
