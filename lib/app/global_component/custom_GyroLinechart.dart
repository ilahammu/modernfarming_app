import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GyroChart extends StatelessWidget {
  final List<FlSpot> gyroXData;
  final List<FlSpot> gyroYData;
  final List<FlSpot> gyroZData;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final String xLabel;
  final String yLabel;
  final List<String> legends;

  const GyroChart({
    Key? key,
    required this.gyroXData,
    required this.gyroYData,
    required this.gyroZData,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xLabel,
    required this.yLabel,
    required this.legends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: -10,
              maxY: 10,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value % 10 == 0 && value >= -20 && value <= 20) {
                        return Text(value.toString());
                      }
                      return Container();
                    },
                    interval: 10,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final DateTime date =
                          DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final String formattedDate =
                          "${date.hour}:${date.minute}:${date.second}";
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(formattedDate),
                      );
                    },
                    interval: (maxX - minX) / 5,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: gyroXData,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: gyroYData,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
                if (gyroZData.isNotEmpty)
                  LineChartBarData(
                    spots: gyroZData,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                verticalInterval: (maxX - minX) / 5,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: legends
              .asMap()
              .entries
              .map((entry) => Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: entry.key == 0
                            ? Colors.red
                            : entry.key == 1
                                ? Colors.green
                                : Colors.blue,
                      ),
                      const SizedBox(width: 5),
                      Text(entry.value),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}
