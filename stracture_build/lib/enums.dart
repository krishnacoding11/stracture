import 'package:flutter/material.dart';

enum ListSortField {
  creation_date("formCreationDate"),
  due_date("responseRequestBy"),
  creationDate("formCreationDate"),
  lastUpdatedDate("lastupdatedate"),
  title("planTitle"),
  siteTitle("title");

  final String fieldName;
  const ListSortField(this.fieldName);

  static ListSortField fromString(String iValue) {
    return ListSortField.values.firstWhere((x) => x.fieldName.toLowerCase() == iValue.toLowerCase(),
        orElse:() => ListSortField.lastUpdatedDate);
  }
}

enum ActivityTypeEnum {
  holdPoint(1);

  final int value;
  const ActivityTypeEnum(this.value);
}

enum ActivityStatusId {
  complete('3'),
  inProgress('2'),
  open('1');

  final String value;
  const ActivityStatusId(this.value);
}

enum AssociationTypeEnum {
  file(1),
  form(2);

  final num value;
  const AssociationTypeEnum(this.value);
}

enum PRIVILEGES {
  manageQuality("168"),
  viewQuality("169");

  final String value;
  const PRIVILEGES(this.value);
}

enum FormAction {
  assignStatus("2"),
  respond("3"),
  releaseResponse("4"),
  attachDocs("5"),
  distribute("6"),
  forInformation("7"),
  forApproval("27"),
  infoPublisher("32"),
  reviewDraft("34"),
  forAction("36"),
  forAcknowledgement("37"),
  forStatusChange("14"),
  informationExchange("73");

  final String value;
  const FormAction(this.value);

  static FormAction fromString(String iValue) {
    return FormAction.values.firstWhere((x) => x.value == iValue);
  }
}

///Homepage sortCut category
enum HomePageSortCutCategory{
  createNewTask("1"),
  newTasks("2"),
  taskDueToday("3"),
  taskDueThisWeek("4"),
  overDueTasks("5"),
  jumpBackToSite("6"),
  createSiteForm("7"),
  filter("8"),
  createForm("9"),
  undefineCategory("-1");

  final String value;
  const HomePageSortCutCategory(this.value);

  static HomePageSortCutCategory? fromString(String iValue) {
    return HomePageSortCutCategory.values.firstWhere((x) => x.value == iValue,orElse: () => HomePageSortCutCategory.undefineCategory);
  }
}

enum HomePageIconCategory {
  createNewTask("1", Icons.add_task),
  newTasks("2", Icons.task_alt),
  taskDueToday("3", Icons.task_alt),
  taskDueThisWeek("4", Icons.task_alt),
  overDueTasks("5", Icons.task_alt),
  jumpBackToSite("6", Icons.location_on),
  createSiteForm("7", Icons.contact_page_sharp),
  filter("8", Icons.filter_list_alt),
  createForm("9", Icons.list_alt);

  final String value;
  final IconData icon;

  const HomePageIconCategory(this.value, this.icon);

  static HomePageIconCategory fromString(String iValue) {
    return HomePageIconCategory.values.firstWhere((x) => x.value == iValue);
  }
}
