import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';

import '../../presentation/managers/color_manager.dart';
import '../../presentation/managers/font_manager.dart';
import '../normaltext.dart';

class ASidebarHeaderWidget extends StatelessWidget {
  final String username;
  final bool isOnline;
  final String imageUrl;
  final Map<String, String> httpHeaders;
  final File? offlineFile;
  static final _placeHolder = Image.asset("assets/images/ic_profile_avatar.png").image;

  const ASidebarHeaderWidget({Key? key,
    required this.username,
    required this.imageUrl,
    required this.httpHeaders,
    this.isOnline = false,
    this.offlineFile
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left:10, top: 20, right: 10, bottom: 0),
      child: Column(
        children: [
          Stack(
            children: [
              isOnline?
              CachedNetworkImage(
                height: 40,
                width: 40,
                imageUrl: imageUrl,
                httpHeaders: httpHeaders,
                imageBuilder: (context, imageProvider) =>
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                placeholder: (context, url) => Image(image: _placeHolder, fit: BoxFit.fill,),
                errorWidget: (context, url, error) => Image(image: _placeHolder, fit: BoxFit.cover,),
              ):Container(
                height: 40,
                width: 40,
                child:Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: FileImage(offlineFile!), fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: (isOnline) ? Colors.green : Colors.red,
                ),),
            ],
          ),
          const SizedBox(height: 10),
          NormalTextWidget(
            context.toLocale!.lbl_sidebar_welcome_username(username),
            fontWeight: AFontWight.medium,
            fontSize: 15.0,
            overflow: TextOverflow.ellipsis,
            color: AColors.white,
          ),
          const SizedBox(height: 10),
          ADividerWidget(thickness: 1),
        ],
      ),
    );
  }
}
