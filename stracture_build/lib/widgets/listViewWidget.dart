import 'package:field/presentation/screen/custom_list_tile/site_project_list_tile.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
//ignore: must_be_immutable
class ListViewWidget extends StatelessWidget {
  // const ListViewWidget({Key? key}) : super(key: key);

  List<dynamic>? items;
  bool? isLoading = false;
  ScrollController? scrollController;
  ListTile? listTile;
  bool? hasNextPage = true;

  ListViewWidget({Key? key, this.items, this.isLoading, this.scrollController, this.hasNextPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    if ((items?.length)! < 1 && !isLoading!) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      );
    }else if((items?.length)! < 1 && isLoading!){
      return _buildProgressIndicator();
    } else {
      return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: hasNextPage! ? (items?.length)! + 1 : (items?.length)!,
      padding: (Utility.isTablet && MediaQuery.of(context).orientation == Orientation.landscape) ? const EdgeInsets.only(left: 100,right: 100) : const EdgeInsets.only(left: 10,right: 10),
      itemBuilder: (BuildContext context, int index) {
        if (index == (items?.length)! && isLoading!) {
          return _buildProgressIndicator();
        } else {
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: index == 0
                  ? const Border() // This will create no border for the first item
                  : Border(
                  top: BorderSide(
                      width: 1,
                      color: Theme.of(context)
                          .dividerColor)), // This will create top borders for the rest
            ),
            // child: SiteProjectListTile(project: items![index]),
            child: (Utility.isTablet && MediaQuery.of(context).orientation == Orientation.landscape) ? SiteProjectListTile(project: items![index]) : MyListTile(project: items![index],),
          );
        }
      },
      controller: scrollController!,
    );
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading! ? 1.0 : 00,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}