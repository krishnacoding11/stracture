import 'package:field/presentation/managers/color_manager.dart';
import 'package:flutter/material.dart';

class StorageDetailsList extends StatelessWidget {
  const StorageDetailsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StorageDetailsWidget(
          color:AColors.modelColorForStorage,
          storageName: "Models",
        ),
        const SizedBox(
          width: 9,
        ),
        StorageDetailsWidget(
          color:
          AColors.blueColor,
          storageName: "Files",
        ),
      ],
    );
  }
}

class StorageDetailsWidget extends StatelessWidget {
  final Color color;
  final String storageName;

  StorageDetailsWidget({
    required this.color,
    required this.storageName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(100),
            ),
            color: color,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          storageName,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
