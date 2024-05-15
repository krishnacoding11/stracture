import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:flutter/material.dart';

import '../tab_navigator.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          child: const Text("Files"),
          onPressed: () {
            navigatorKeys[getIt<NavigationCubit>().currSelectedItem]!
                .currentState!.pushNamed(TabNavigatorRoutes.folder);
            //Navigator.pushNamed(context, TabNavigatorRoutes.folder);
          },
        ),
      ),
    );
  }
}
