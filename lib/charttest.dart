import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';

class ChartTest extends StatelessWidget {
  const ChartTest({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Center(
          child: Container(
            color: Colors.red,
            height: 250,
            child: BezierChart(
              bezierChartScale: BezierChartScale.CUSTOM,
              xAxisCustomValues: const [0, 3, 10, 15, 20, 25, 30, 35],
              series: const [
                BezierLine(
                  label: "Custom 1",
                  lineColor: Colors.green,
                  data: const [
                    DataPoint<double>(value: 10, xAxis: 0),
                    DataPoint<double>(value: 130, xAxis: 5),
                    DataPoint<double>(value: 50, xAxis: 10),
                    DataPoint<double>(value: 150, xAxis: 15),
                    DataPoint<double>(value: 75, xAxis: 20),
                    DataPoint<double>(value: 0, xAxis: 25),
                    DataPoint<double>(value: 5, xAxis: 30),
                    DataPoint<double>(value: 45, xAxis: 35),
                  ],
                ),
                BezierLine(
                  lineColor: Colors.blue,
                  lineStrokeWidth: 2.0,
                  label: "Custom 2",
                  data: const [
                    DataPoint<double>(value: 5, xAxis: 0),
                    DataPoint<double>(value: 50, xAxis: 5),
                    DataPoint<double>(value: 30, xAxis: 10),
                    DataPoint<double>(value: 30, xAxis: 15),
                    DataPoint<double>(value: 50, xAxis: 20),
                    DataPoint<double>(value: 40, xAxis: 25),
                    DataPoint<double>(value: 10, xAxis: 30),
                    DataPoint<double>(value: 30, xAxis: 35),
                  ],
                ),
                BezierLine(
                  lineColor: Colors.white,
                  lineStrokeWidth: 2.0,
                  label: "Custom 3",
                  data: const [
                    DataPoint<double>(value: 5, xAxis: 0),
                    DataPoint<double>(value: 10, xAxis: 5),
                    DataPoint<double>(value: 35, xAxis: 10),
                    DataPoint<double>(value: 40, xAxis: 15),
                    DataPoint<double>(value: 40, xAxis: 20),
                    DataPoint<double>(value: 40, xAxis: 25),
                    DataPoint<double>(value: 9, xAxis: 30),
                    DataPoint<double>(value: 11, xAxis: 35),
                  ],
                ),
              ],
              config: BezierChartConfig(
                verticalIndicatorStrokeWidth: 2.0,
                verticalIndicatorColor: Colors.white,
                showVerticalIndicator: true,
                contentWidth: 300,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sample1(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.red,
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width * 0.9,
        child: BezierChart(
          bezierChartScale: BezierChartScale.CUSTOM,
          xAxisCustomValues: const [0, 5, 10, 15, 20, 25, 30, 35],
          series: const [
            BezierLine(
              data: const [
                DataPoint<double>(value: 10, xAxis: 0),
                DataPoint<double>(value: 130, xAxis: 5),
                DataPoint<double>(value: 50, xAxis: 10),
                DataPoint<double>(value: 150, xAxis: 15),
                DataPoint<double>(value: 75, xAxis: 20),
                DataPoint<double>(value: 0, xAxis: 25),
                DataPoint<double>(value: 5, xAxis: 30),
                DataPoint<double>(value: 45, xAxis: 35),
              ],
            ),
          ],
          config: BezierChartConfig(
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.black26,
            showVerticalIndicator: true,
            backgroundColor: Colors.red,
            snap: false,
          ),
        ),
      ),
    );
  }
}
