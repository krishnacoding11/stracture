import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:field/networking/request_body.dart';

class Result<Model> extends Equatable {
  Model? data;
  final String? failureMessage;
  @override
  int? responseCode;
  Headers? responseHeader;
  NetworkRequestBody? requestData;

  Result(this.data, {this.failureMessage, this.responseCode, this.responseHeader, this.requestData});

  factory Result.success(Model data) {
    return Result(data);
  }
  factory Result.fail(String message) {
    return Result(null, failureMessage: message);
  }

  @override
  List<Object?> get props => [data, failureMessage, responseCode, responseHeader, requestData];
}

class SUCCESS<Model> extends Result<Model> {
  Headers? responseHeader;
  Model? data;
  int? responseCode;
  NetworkRequestBody? requestData;
  SUCCESS(this.data, this.responseHeader, this.responseCode, {this.requestData}) : super(data, responseHeader: responseHeader, responseCode: responseCode, requestData: requestData);
}

class FAIL<Model> extends Result<Model> {
  String? failureMessage;
  int? responseCode;

  FAIL(this.failureMessage, this.responseCode) : super(null, failureMessage: failureMessage, responseCode: responseCode);
}
