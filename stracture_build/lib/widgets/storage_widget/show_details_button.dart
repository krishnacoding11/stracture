import 'package:flutter/material.dart';

class ShowDetailsButton extends StatelessWidget {
  bool showDetails = false;

  ShowDetailsButton({
    required this.showDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDetails = true;
      },
      child: Row(
        children: const [
          Icon(Icons.arrow_drop_down_outlined, size: 24.0, color: Colors.grey),
          SizedBox(
            width: 5,
          ),
          Text(
            "Details",
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
