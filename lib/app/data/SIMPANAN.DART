// final RxList<FlSpot> gyroXData = <FlSpot>[].obs;
  // final RxList<FlSpot> gyroYData = <FlSpot>[].obs;
  // final RxList<FlSpot> gyroZData = <FlSpot>[].obs;
  // final Rx<double> minX = 0.0.obs;
  // final Rx<double> maxX = 0.0.obs;
  // final Rx<double> minY = 0.0.obs;
  // final Rx<double> maxY = 0.0.obs;

//     if (response.statusCode == 200) {
  //       final data = response.body;
  //       dataList.clear();
  //       List<FlSpot> newGyroXData = [];
  //       List<FlSpot> newGyroYData = [];
  //       List<FlSpot> newGyroZData = [];

  //       double minXValue = double.infinity;
  //       double maxXValue = double.negativeInfinity;
  //       double minYValue = double.infinity;
  //       double maxYValue = double.negativeInfinity;

  //       for (var item in data['data']['rows']) {
  //         final chartModel = ChartModel(
  //           id: item['id'] ?? 0,
  //           chipId: item['id'].toString(),
  //           rate_roll: item['rate_roll']?.toDouble() ?? 0,
  //           rate_pitch: item['rate_pitch']?.toDouble() ?? 0,
  //           rate_yaw: item['rate_yaw']?.toDouble() ?? 0,
  //           angle_roll: item['angle_roll']?.toDouble() ?? 0,
  //           angle_pitch: item['angle_pitch']?.toDouble() ?? 0,
  //           createdAt: item['createdAt'] != null
  //               ? DateTime.parse(item['createdAt'])
  //               : DateTime.now(),
  //         );

  //         dataList.add(chartModel);

  //         double xValue =
  //             chartModel.createdAt.millisecondsSinceEpoch.toDouble();
  //         newGyroXData.add(FlSpot(xValue, chartModel.rate_roll ?? 0));
  //         newGyroYData.add(FlSpot(xValue, chartModel.rate_pitch ?? 0));
  //         newGyroZData.add(FlSpot(xValue, chartModel.rate_yaw ?? 0));

  //         // Update min and max values
  //         minXValue = xValue < minXValue ? xValue : minXValue;
  //         maxXValue = xValue > maxXValue ? xValue : maxXValue;
  //         minYValue = [
  //           chartModel.rate_roll ?? 0,
  //           chartModel.rate_pitch ?? 0,
  //           chartModel.rate_yaw ?? 0,
  //           minYValue
  //         ].reduce((a, b) => a < b ? a : b);
  //         maxYValue = [
  //           chartModel.rate_roll ?? 0,
  //           chartModel.rate_pitch ?? 0,
  //           chartModel.rate_yaw ?? 0,
  //           maxYValue
  //         ].reduce((a, b) => a > b ? a : b);
  //       }

  //       // Sort the data by x-value (timestamp)
  //       newGyroXData.sort((a, b) => a.x.compareTo(b.x));
  //       newGyroYData.sort((a, b) => a.x.compareTo(b.x));
  //       newGyroZData.sort((a, b) => a.x.compareTo(b.x));

  //       if (newGyroXData.length > 20) {
  //         newGyroXData = newGyroXData.sublist(newGyroXData.length - 20);
  //         newGyroYData = newGyroYData.sublist(newGyroYData.length - 20);
  //         newGyroZData = newGyroZData.sublist(newGyroZData.length - 20);
  //       }
  //       // Update all reactive variables at once
  //       gyroXData.value = newGyroXData;
  //       gyroYData.value = newGyroYData;
  //       gyroZData.value = newGyroZData;
  //       minX.value = minXValue;
  //       maxX.value = maxXValue;
  //       minY.value = minYValue;
  //       maxY.value = maxYValue;

  //       print(
  //           'Data fetched and processed for chart: ${newGyroXData.length} items');
  //     } else {
  //       print('Failed to load data: ${response.statusCode}');
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Failed to fetch data: $e');
  //     throw Exception('Failed to fetch data');
  //   }
  // }

 