import 'package:get/get.dart';

class SensorController extends GetxController {
  var sensorList = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSensorData();
  }

  void fetchSensorData() {
    // Simulasi data sensor
    sensorList.value = [
      {
        'imageUrl': 'assets/images/sensor/RaFID.png',
        'nama_sensor': 'RFID',
        'penjelasan':
            'RFID sensor MFRC522 adalah modul yang digunakan untuk membaca dan menulis data pada kartu RFID (Radio Frequency Identification). RFID bekerja dengan prinsip komunikasi nirkabel menggunakan gelombang radio untuk mentransmisikan data antara tag RFID dan pembaca (reader). Modul MFRC522 sangat populer karena mudah digunakan dan murah, serta sering digunakan dalam proyek-proyek elektronik seperti akses kontrol, identifikasi barang, dan sistem pelacakan.'
      },
      {
        'imageUrl': 'assets/images/sensor/loadcellBadan.png',
        'nama_sensor': 'Loadcell Badan',
        'penjelasan':
            'Sensor load cell adalah perangkat pengukur yang digunakan untuk mendeteksi gaya atau berat suatu objek. Sensor ini bekerja berdasarkan prinsip *deformasi elastis* pada material yang terjadi saat beban diterapkan. Load cell biasanya dilengkapi dengan *strain gauge*, yang mengukur perubahan resistansi akibat perubahan bentuk. Perubahan resistansi ini kemudian diubah menjadi sinyal listrik yang dapat dibaca sebagai berat atau gaya. Penggunaan load cell membutuhkan *amplifier* atau *modul penguat* untuk memperkuat sinyal yang lemah sebelum diproses lebih lanjut oleh sistem pengukuran, seperti mikrokontroler atau komputer.'
      },
      {
        'imageUrl': 'assets/images/sensor/loadcellPakan.png',
        'nama_sensor': 'Loadcell Pakan',
        'penjelasan':
            'Load cell adalah perangkat yang mengukur berat atau tekanan dengan mengubah tekanan yang diterima menjadi sinyal yang dapat diukur. Load cell memiliki dua jenis output, yaitu analog dan digital, yang memudahkan pembacaan dan pengolahan data di perangkat seperti komputer atau mikrokontroler. Alat ini sangat sensitif dan dapat merespons perubahan berat dengan sangat cepat, membuatnya ideal untuk digunakan dalam berbagai aplikasi.'
      },
      {
        'imageUrl': 'assets/images/sensor/aht.png',
        'nama_sensor': 'AHT20',
        'penjelasan':
            'Sensor AHT20 merupakan sensor suhu dan kelembapan digital yang menyediakan pembacaan akurat dengan antarmuka I2C. Sensor ini terkenal karena keandalannya, kemudahan penggunaan, dan kemampuan untuk beroperasi dalam rentang suhu yang luas. Dengan resolusi tinggi, AHT20 cocok untuk berbagai aplikasi seperti sistem pemantauan lingkungan, HVAC, dan perangkat IoT. Penggunaannya juga memungkinkan kalibrasi otomatis, sehingga meningkatkan presisi data yang dihasilkan.'
      },
      {
        'imageUrl': 'assets/images/sensor/mpu.png',
        'nama_sensor': 'MPU6050',
        'penjelasan':
            'Sistem deteksi perilaku kambing menggunakan sensor MPU6050 (akselerometer dan gyroskop) untuk mengukur rotasi (Roll, Pitch, Yaw) dan percepatan (AccX, AccY, AccZ), dengan kalibrasi Kalman Filter untuk akurasi sudut. Gerakan kambing dihitung dari perubahan signifikan pada RateRoll dan RatePitch. Sensor ultrasonik mendeteksi jarak kambing dari objek dengan ambang gerakan lebih tinggi jika jarak < 50 cm. Kambing dianggap tidur jika tidak bergerak selama 5 detik dan berada dekat, serta bangun jika ada gerakan atau jarak > 50 cm. Data dikirim ke server via HTTP POST untuk analisis.'
      },
    ];
  }
}
