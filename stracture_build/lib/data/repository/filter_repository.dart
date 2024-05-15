enum ResponseStatus { unknown, success, failure}

abstract class FilterRepository<REQUEST,RESPONSE> {
  Future<RESPONSE?>? getFilterDataForDefect(Map<String, dynamic> request);
  Future<RESPONSE?>? getFilterSearchData(Map<String, dynamic> request);
}