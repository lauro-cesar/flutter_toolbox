// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import './webview_flutter_web_test.mocks.dart';

@GenerateMocks(<Type>[
  IFrameElement,
  BuildContext,
  CreationParams,
  WebViewPlatformCallbacksHandler,
  HttpRequestFactory,
  HttpRequest,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebWebViewPlatform', () {
    test('build returns a HtmlElementView', () {
      // Setup
      final WebWebViewPlatform platform = WebWebViewPlatform();
      // Run
      final Widget widget = platform.build(
        context: MockBuildContext(),
        creationParams: CreationParams(),
        webViewPlatformCallbacksHandler: MockWebViewPlatformCallbacksHandler(),
        javascriptChannelRegistry: null,
      );
      // Verify
      expect(widget, isA<HtmlElementView>());
    });
  });

  group('WebWebViewPlatformController', () {
    test('loadUrl sets url on iframe src attribute', () {
      // Setup
      final MockIFrameElement mockElement = MockIFrameElement();
      final WebWebViewPlatformController controller =
          WebWebViewPlatformController(
        mockElement,
      );
      // Run
      controller.loadUrl('test url', null);
      // Verify
      verify(mockElement.src = 'test url');
    });

    test('loadHtmlString loads html into iframe', () {
      // Setup
      final MockIFrameElement mockElement = MockIFrameElement();
      final WebWebViewPlatformController controller =
          WebWebViewPlatformController(
        mockElement,
      );
      // Run
      controller.loadHtmlString('test html');
      // Verify
      verify(mockElement.src = 'data:text/html,' + Uri.encodeFull('test html'));
    });

    group('loadRequest', () {
      test('loadRequest throws ArgumentError on missing scheme', () {
        // Setup
        final MockIFrameElement mockElement = MockIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        // Run & Verify
        expect(
            () async => await controller.loadRequest(
                  WebViewRequest(
                    uri: Uri.parse('flutter.dev'),
                    method: WebViewRequestMethod.get,
                  ),
                ),
            throwsA(const TypeMatcher<ArgumentError>()));
      });

      test('loadRequest makes request and loads response into iframe',
          () async {
        // Setup
        final MockIFrameElement mockElement = MockIFrameElement();
        final WebWebViewPlatformController controller =
            WebWebViewPlatformController(
          mockElement,
        );
        final MockHttpRequest mockHttpRequest = MockHttpRequest();
        when(mockHttpRequest.getResponseHeader('content-type'))
            .thenReturn('text/plain');
        when(mockHttpRequest.responseText).thenReturn('test data');
        final MockHttpRequestFactory mockHttpRequestFactory =
            MockHttpRequestFactory();
        when(mockHttpRequestFactory.request(
          any,
          method: anyNamed('method'),
          requestHeaders: anyNamed('requestHeaders'),
          sendData: anyNamed('sendData'),
        )).thenAnswer((_) => Future<HttpRequest>.value(mockHttpRequest));
        controller.httpRequestFactory = mockHttpRequestFactory;
        // Run
        await controller.loadRequest(
          WebViewRequest(
              uri: Uri.parse('https://flutter.dev'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('test body'.codeUnits),
              headers: <String, String>{'Foo': 'Bar'}),
        );
        // Verify
        verify(mockHttpRequestFactory.request(
          'https://flutter.dev',
          method: 'post',
          requestHeaders: <String, String>{'Foo': 'Bar'},
          sendData: Uint8List.fromList('test body'.codeUnits),
        ));
        verify(
            mockElement.src = 'data:text/plain,' + Uri.encodeFull('test data'));
      });
    });
  });
}
