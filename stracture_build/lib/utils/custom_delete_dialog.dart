import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomDeleteDialogBox extends StatelessWidget {
  const CustomDeleteDialogBox({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(7.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.delete_outline_outlined,
                    color: Colors.red,
                    size: 36,
                  ),
                ) //
                    ),
                const SizedBox(height: 10.0),
                const Text(
                  "Clear Model Data",
                  style: TextStyle(color: Colors.black, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "This will clear all offline model data from this device.",
                    style: TextStyle(color: Colors.grey, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(color: Colors.black),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 5.0, color: Colors.white),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 20),
                          ),
                        )),
                        SizedBox(
                            height: Utility.isTablet ? 70 : 50,
                            child: const VerticalDivider(color: Colors.black)),
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 5.0, color: Colors.white),
                                ),
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
