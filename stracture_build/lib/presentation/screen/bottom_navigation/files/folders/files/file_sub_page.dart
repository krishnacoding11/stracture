import 'package:flutter/material.dart';

import '../../../../../../utils/navigation_utils.dart';
import '../../../../project_tabbar_screen.dart';

class FolderSubPage extends StatelessWidget {
  const FolderSubPage({Key? key}) : super(key: key);

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
              child: const Text("Parent navigation"),
              onPressed: () {
                NavigationUtils.mainPush(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectTabbar(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
