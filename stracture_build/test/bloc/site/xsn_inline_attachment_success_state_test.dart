import 'package:field/bloc/site/xsn_inline_attachment_success_state.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XSNInlineAttachmentSuccessState', () {
    test('Two instances with same response and time should be equal', () {
      final state1 = XSNInlineAttachmentSuccessState('Success', time: '2023-08-04');
      final state2 = XSNInlineAttachmentSuccessState('Success', time: '2023-08-04');

      expect(state1, equals(state2));
    });

    test('Two instances with different response should not be equal', () {
      final state1 = XSNInlineAttachmentSuccessState('Success', time: '2023-08-04');
      final state2 = XSNInlineAttachmentSuccessState('Updated', time: '2023-08-04');

      expect(state1, isNot(equals(state2)));
    });

    test('Two instances with different time should not be equal', () {
      final state1 = XSNInlineAttachmentSuccessState('Success', time: '2023-08-04');
      final state2 = XSNInlineAttachmentSuccessState('Success', time: '2023-08-05');

      expect(state1, isNot(equals(state2)));
    });

    test('getStateRendererType should return POPUP_SUCCESS', () {
      final state = XSNInlineAttachmentSuccessState('Success', time: '2023-08-04');
      expect(state.getStateRendererType(), equals(StateRendererType.POPUP_SUCCESS));
    });
  });
}