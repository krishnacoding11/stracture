import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/repository/site/location_tree_repository.dart';
import 'package:field/widgets/location_tree.dart';
import 'package:flutter/material.dart';

import '../../managers/font_manager.dart';

//ignore: must_be_immutable
class SiteProjectListTile extends StatelessWidget {
  Popupdata project = Popupdata();

  SiteProjectListTile({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(project.value ?? "",
        style: const TextStyle(
            fontFamily: 'Sofia',
            fontSize: 22,
            fontWeight: AFontWight.medium
        ),),
      // subtitle: Text(project.projectBaseUrlForCollab ?? ""),
      trailing: Wrap(
        spacing: 1, // space between two icons
        children: <Widget>[
          IconButton(
            icon: (project.imgId! == 1)
                ? Image.asset('assets/images/selectedStar.png')
                : Image.asset('assets/images/unselectedStar.png'),
            tooltip: 'Favourite',
            onPressed: () {
            },
          ), // icon-1
          IconButton(
            icon: Image.asset('assets/images/more.png'),
            tooltip: 'More',
            onPressed: () {
            },
          ), // icon-2
        ],
      ),
      onTap: () {
        showLocationTreeDialog(context, project);
      },
    );
  }

  Widget? showLocationTreeDialog(BuildContext context, Popupdata project){
     showDialog(context: context, builder: (context){
       Map<String, dynamic> arguments = {};
       arguments['projectDetail'] = project;
       arguments['isFrom'] = LocationTreeViewFrom.projectList;
       return ScaffoldMessenger(child: Builder(builder: (context) {
         return Scaffold(backgroundColor: Colors.transparent, body: LocationTreeWidget(arguments));
       }));
    });
     return null;
  }
}
//ignore: must_be_immutable
class MyListTile extends StatelessWidget {
  Popupdata project = Popupdata();
  MyListTile({
    Key? key, required this.project
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: () {
          showDialog(context: context, builder: (context){
            Map<String, dynamic> arguments = {};
            arguments['projectDetail'] = project;
            arguments['isFrom'] = LocationTreeViewFrom.projectList;
            return ScaffoldMessenger(child: Builder(builder: (context) {
              return Scaffold(backgroundColor: Colors.transparent, body: LocationTreeWidget(arguments));
            }));
          });
        },
        child: Stack(
          children: <Widget>[
            // Text(project.projectName ?? ""),
            Align(
                alignment: Alignment.topLeft,
                child:  Text(project.value ?? "",
                  style: const TextStyle(
                      fontFamily: 'Sofia',
                      fontSize: 22,
                      fontWeight: AFontWight.medium
                  ),)
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: (project.imgId! == 1) ? Image.asset('assets/images/selectedStar.png') : Image.asset('assets/images/unselectedStar.png'),
                    tooltip: 'Favourite',
                    onPressed: (){
                    },
                  ), // icon-1
                  IconButton(
                    icon: Image.asset('assets/images/more.png'),
                    tooltip: 'More',
                    onPressed: () {
                    },
                  ), // icon-2
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}