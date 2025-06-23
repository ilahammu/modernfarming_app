import 'package:get/get.dart';

class TeamController extends GetxController {
  var teamList = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeamData();
  }

  void fetchTeamData() {
    // Simulasi data tim
    teamList.value = [
      {
        'imageUrl': 'assets/images/anggota/ichlasul.JPG',
        'name': 'Ichlasul Amal Restu',
        'jobType': 'Backend & Hardware Engineer',
        'text': "TEAM LEADER",
      },
      {
        'imageUrl': 'assets/images/anggota/reinoo.jpg',
        'name': 'Reino Wahyu Warsono',
        'jobType': 'Hardware Engineer [Loadcell Badan]',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/aura.jpg',
        'name': 'Aura Resty Yulistia',
        'jobType': 'Hardware Engineer [Loadcell Pakan]',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/rafid.png',
        'name': 'M. Rafid Habibi',
        'jobType': 'Hardware Engineer [RFID]',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/alfahri.png',
        'name': 'Alfahri Suhaimi',
        'jobType': 'Hardware Engineer [MPU]',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/citra.jpg',
        'name': 'Citra Nathania',
        'jobType': 'Hardware Engineer [AHT20]',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/kevin.jpg',
        'name': 'Kevin Rafi Pranaja',
        'jobType': 'Computer Vision Engineer',
        'text': "MEMBER",
      },
      {
        'imageUrl': 'assets/images/anggota/ganteng.jpg',
        'name': 'Ilham Muhijri Yosefin',
        'jobType': 'Software Engineer',
        'text': "asdasd",
      },
    ];
  }
}
