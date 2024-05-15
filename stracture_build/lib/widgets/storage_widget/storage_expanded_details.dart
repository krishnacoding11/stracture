import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StorageExpandedDetails extends StatelessWidget {
  bool showDetails = false;
  SfCartesianChart buildTrackerBarChart;

  StorageExpandedDetails({required this.showDetails, required this.buildTrackerBarChart, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        color: Colors.grey[100],
      ),
      width: MediaQuery.of(context).size.width / 1.1,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          SizedBox(
            height: 340,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // const Icon(
                //   Icons.arrow_drop_up_sharp,
                //   size: 150.0,
                //   color: Colors.cyan,
                // ),
                buildTrackerBarChart,
                Container()
              ],
            ), // More details chart here
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  showDetails = false;
                },
                child: Row(
                  children: const [
                    Icon(Icons.arrow_drop_up_sharp, size: 24.0, color: Colors.grey),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Hide",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 4,
            child: OutlinedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline, size: 24.0, color: Colors.blue),
                    Text(
                      "Clear Model Data",
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
