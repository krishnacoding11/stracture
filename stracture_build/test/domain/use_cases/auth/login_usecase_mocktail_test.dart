import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/fixture_reader.dart';


class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockSiteUseCase;
  setUp(() {
    mockSiteUseCase = MockLoginUseCase();
  });
  group("Test getProjectHash Value", () {
    test("Success response", () async {
      when(() => mockSiteUseCase.getProjectHash(any()))
          .thenAnswer((_) {
        return Future(() {
          return SUCCESS(
              fixture("get_hash_value.json"), null, null);
        });
      });
      var result = await mockSiteUseCase.getProjectHash({});
      expect(result is SUCCESS, true);
    });

      test("Fail response", () async {
        when(() => mockSiteUseCase.getProjectHash(any()))
            .thenAnswer((_) {
          return Future((){
            return FAIL("failureMessage", 602);
          });
        });
        var result = await mockSiteUseCase.getProjectHash({});
        expect(result is! SUCCESS, true);
      });
    });
}