import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/weather_forcast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('WeatherForecastWidget - Test Rendering', (WidgetTester tester) async {
    final Map<String, dynamic> testData = {
      "Date": "2023-08-03",
      "Temperature": {
        "Minimum": {"Value": 15},
        "Maximum": {"Value": 25}
      },
      "Day": {"Icon": 1},
      "Night": {"Icon": 2}
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WeatherForecastWidget(data: testData),
      ),
    ));

    final formattedDate = DateFormat.EEEE().format(DateTime.parse("2023-08-03"));
    //expect(find.text(formattedDate), findsOneWidget);
    expect(find.text("25°/15°"), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(find.byType(NormalTextWidget), findsNWidgets(2));
  });
}
