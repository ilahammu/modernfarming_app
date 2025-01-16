import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monitoring_kambing/app/data/chart_model.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:intl/intl.dart';

class CustomLineChart extends StatelessWidget {
  final List<ChartModel> dataList;
  final String dataType;

  CustomLineChart({
    required this.dataList,
    required this.dataType,
  });

  @override
  Widget build(BuildContext context) {
    return buildChart(dataList, dataType);
  }

  Widget buildChart(List<ChartModel> dataList, String dataType) {
    print('Building Chart with data: $dataList');
    return Card(
      shape: const RoundedRectangleBorder(
        
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 53, 53, 53)),
          color: Color.fromARGB(255, 183, 182, 182),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 92, 90, 90),
              blurRadius: 2,
              spreadRadius: 0.1,
              offset: Offset(2, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: 400.0,
          maxWidth: Get.width,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Chart(
          layers: layers(dataList, dataType),
          padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(
            bottom: 12.0,
          ),
        ),
      ),
    );
  }

  List<ChartLayer> layers(List<ChartModel> dataList, String dataType) {
    double yMax;
    double yFrequency;

    switch (dataType) {
      case 'suhu':
        yMax = 100.0;
        yFrequency = 20.0;
        break;
      case 'kelembapan':
        yMax = 100.0;
        yFrequency = 20.0;
        break;
      case 'berat':
        yMax = 200.0;
        yFrequency = 25.0;
        break;
      case 'pakan':
        yMax = 10000.0;
        yFrequency = 2500.0;
        break;
      case 'vitamin':
        yMax = 10000.0;
        yFrequency = 2500.0;
        break;
      case 'rumput':
        yMax = 10000.0;
        yFrequency = 2500.0;
        break;
      default:
        yMax = 100.0;
        yFrequency = 10.0;
    }

    return [
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Color.fromARGB(255, 37, 9, 9),
          circleBackgroundColor: Colors.grey,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (item) => '$dataType: ${item.value.toString()} ',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: 1.0,
            max: (dataList.isNotEmpty ? dataList.length - 1 : 0).toDouble(),
            min: 0.0,
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 11.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: yFrequency,
            max: yMax,
            min: 0.0,
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 12.0,
            ),
          ),
        ),
        labelX: (value) {
          if ((dataType == 'berat' ||
                  dataType == 'pakan' ||
                  dataType == 'suhu' ||
                  dataType == 'kelembapan') &&
              dataList.length == 7) {
            final dateTime =
                dataList[dataList.length - 1 - value.toInt()].createdAt;
            final date =
                DateFormat('yyyy-MM-dd').format(dateTime); // Extract date
            final day =
                DateFormat('EEEE').format(dateTime); // Extract day of the week
            return '$day\n$date'; // Show day and date
          } else if ((dataType == 'berat' ||
                  dataType == 'pakan' ||
                  dataType == 'suhu' ||
                  dataType == 'kelembapan') &&
              dataList.length == 4) {
            switch (value.toInt()) {
              case 0:
                return 'Minggu 1';
              case 1:
                return 'Minggu 2';
              case 2:
                return 'Minggu 3';
              case 3:
                return 'Minggu 4';
              default:
                return '';
            }
          } else {
            if (value < dataList.length) {
              final dateTime =
                  dataList[dataList.length - 1 - value.toInt()].createdAt;
              final date =
                  DateFormat('yyyy-MM-dd').format(dateTime); // Extract date
              final time =
                  DateFormat('HH:mm:ss').format(dateTime); // Extract time
              return '$date\n$time'; // Combine date and time with newline
            }
            return '';
          }
        },
        labelY: (value) => value.toDouble().toString(),
      ),
      ChartGridLayer(
        settings: ChartGridSettings(
          x: ChartGridSettingsAxis(
            frequency: 1.0,
            max: (dataList.isNotEmpty ? dataList.length - 1 : 0).toDouble(),
            min: 0.0,
            color: Colors.black.withOpacity(0.1),
          ),
          y: ChartGridSettingsAxis(
            frequency: yFrequency,
            max: yMax,
            min: 0.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      ChartLineLayer(
        items: dataList.asMap().entries.map((entry) {
          int index = dataList.length - 1 - entry.key;
          ChartModel data = entry.value;
          double value;
          switch (dataType) {
            case 'suhu':
              value = data.suhu != null ? data.suhu!.toDouble() : 0.0;
              break;
            case 'kelembapan':
              value =
                  data.kelembaban != null ? data.kelembaban!.toDouble() : 0.0;
              break;
            case 'berat':
              value = data.berat != null ? data.berat!.toDouble() : 0.0;
              break;
            case 'pakan':
              value =
                  data.beratPakan != null ? data.beratPakan!.toDouble() : 0.0;
              break;
            default:
              value = 0.0;
          }
          return ChartLineDataItem(
            value: value,
            x: index.toDouble(),
          );
        }).toList(),
        settings: const ChartLineSettings(
          color: Color.fromARGB(255, 68, 80, 84),
          thickness: 3.5,
        ),
      ),
    ];
  }
}
