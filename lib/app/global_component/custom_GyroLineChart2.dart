import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DistanceChart extends StatelessWidget {
  final List<FlSpot> distanceData;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final String xLabel;
  final String yLabel;
  final List<String> legends;

  const DistanceChart({
    Key? key,
    required this.distanceData,
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
              minY: 0,
              maxY: 100,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0 && value >= 0 && value <= 100) {
                        return Text(value.toString());
                      }
                      return Container();
                    },
                    interval: 20,
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
                          "${date.minute}:${date.second}";
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
                  spots: distanceData,
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
                horizontalInterval: 20,
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
                        color: Colors.blue,
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
