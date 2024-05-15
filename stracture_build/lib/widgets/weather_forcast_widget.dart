import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'normaltext.dart';


class WeatherForecastWidget extends StatelessWidget {
  Map data = {};
  WeatherForecastWidget({required this.data});
  final _placeHolder = Utility.transparentImage;

  @override
  Widget build(BuildContext context) {
    String temperatureMin = "";
    String temperatureMax = "";
    String date = data["Date"] ?? "";
    var parsedDate = DateTime.parse(date);
    date = DateFormat("EEE").format(parsedDate);

    if(data.containsKey("Temperature")){
      var tempData = data["Temperature"] as Map;
      if(tempData.containsKey("Minimum")){
        var min = tempData["Minimum"] as Map;
        if(min.containsKey("Value")){
          temperatureMin = min["Value"].round().toString();
          temperatureMin = "$temperatureMin°";
        }
      }
      if(tempData.containsKey("Maximum")){
        var max = tempData["Maximum"] as Map;
        if(max.containsKey("Value")){
          temperatureMax = max["Value"].round().toString();
          temperatureMax = "$temperatureMax°";
        }
      }
    }

    String temperature = "$temperatureMax/$temperatureMin";
    double width = 0;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    if ((Utility.isTablet && (deviceHeight > deviceWidth)) ||
        (MediaQuery.of(context).orientation == Orientation.portrait)) {
      width = 60;
    } else {
      width = deviceWidth - (MediaQuery.of(context).padding.left +
          MediaQuery.of(context).padding.right + 30 + 30 + 15 + 15 + 8 + 8 + 20 + 20 +32);
      width = (width/3) - 20;
      width = width/5;
    }

    return Column(
      children: [
        NormalTextWidget(date,color: AColors.white.withOpacity(0.7),fontSize: 13,fontWeight: AFontWight.regular),
        Expanded(
          child: CachedNetworkImage(
              height: 40,
              width: width,
              imageUrl: getImageURL(),
              useOldImageOnUrlChange: false,
              imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                  )),
              placeholder: (context, url) => _placeHolder,
              errorWidget: (context, url, error) => _placeHolder),
        ),
        FittedBox(fit: BoxFit.fitWidth, child: NormalTextWidget(temperature,color: AColors.white,fontSize: 15,fontWeight: AFontWight.medium)),
      ],
    );
  }


  String getImageURL(){
    String url = "";
    DateTime currentTime = DateTime.now();
    var timeData = {};
    if(currentTime.hour >=6 && currentTime.hour <=18){
      timeData = data["Day"];
    }
    else{
      timeData = data["Night"];
    }
    if(timeData.containsKey("Icon")){
      NumberFormat formatter = NumberFormat("00");
      int icon = 0;
      if(timeData["Icon"] is String){
        icon = int.tryParse(timeData["Icon"]) ?? 0;
      }
      else if(timeData["Icon"] is num){
        icon = timeData["Icon"];
      }

      url =
      "https://developer.accuweather.com/sites/default/files/${formatter.format(icon)}-s.png";
    }
    return url;
  }
}

