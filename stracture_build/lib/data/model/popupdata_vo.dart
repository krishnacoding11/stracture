import 'package:equatable/equatable.dart';

import '../../utils/field_enums.dart';
//ignore: must_be_immutable
class Popupdata extends Equatable{
  String? id;
  String? value;
  int? dataCenterId;
  bool? isSelected;
  int? imgId;
  bool? isActive;
  dynamic childfolderTreeVOList;// Added for handle recent location permission error
  bool? isMarkOffline;
  String? projectSizeInByte;
  double? progress;
  ESyncStatus? syncStatus;
  bool? hasLocationMarkOffline;
  ESyncStatus? locationSyncStatus;
  bool? hasLocationSyncedSuccessfully;

  Popupdata(
      {this.id,
        this.value,
        this.dataCenterId,
        this.isSelected,
        this.imgId,
        this.isActive,
        this.childfolderTreeVOList});

  Popupdata.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    value = json['value'];
    dataCenterId = json['dataCenterId'];
    isSelected = json['isSelected'];
    imgId = json['imgId'];
    isActive = json['isActive'];
    childfolderTreeVOList = json['childfolderTreeVOList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    data['dataCenterId'] = this.dataCenterId;
    data['isSelected'] = this.isSelected;
    data['imgId'] = this.imgId;
    data['isActive'] = this.isActive;
    data['projectSizeInByte'] = this.projectSizeInByte;
    return data;
  }
  @override
  List<Object?> get props => [];
}