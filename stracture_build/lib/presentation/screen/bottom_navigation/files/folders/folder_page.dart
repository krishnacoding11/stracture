import 'package:flutter/material.dart';

import '../../../../../utils/navigation_utils.dart';
import '../../tab_navigator.dart';

//TODO: Sample page for nested navigation example
class FolderPage extends StatelessWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("Pop"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Folders"),
              onPressed: () {
                NavigationUtils.pushNamed(TabNavigatorRoutes.folderSub);
              },
            ),
          ],
        ),
      ),
    );
  }
}
