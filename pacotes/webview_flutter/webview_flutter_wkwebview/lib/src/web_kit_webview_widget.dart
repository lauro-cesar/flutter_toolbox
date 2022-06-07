// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'foundation/foundation.dart';
import 'web_kit/web_kit.dart';

/// A [Widget] that displays a [WKWebView].
class WebKitWebViewWidget extends StatefulWidget {
  /// Constructs a [WebKitWebViewWidget].
  const WebKitWebViewWidget({
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required this.onBuildWidget,
    this.configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  });

  /// The initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// The handler of callbacks made made by [NavigationDelegate].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manager of named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// A collection of properties used to initialize a web view.
  ///
  /// If null, a default configuration is used.
  final WKWebViewConfiguration? configuration;

  /// The handler for constructing [WKWebView]s and calling static methods.
  ///
  /// This should only be changed for testing purposes.
  final WebViewWidgetProxy webViewProxy;

  /// A callback to build a widget once [WKWebView] has been initialized.
  final Widget Function(WebKitWebViewPlatformController controller)
      onBuildWidget;

  @override
  State<StatefulWidget> createState() => _WebKitWebViewWidgetState();
}

class _WebKitWebViewWidgetState extends State<WebKitWebViewWidget> {
  late final WebKitWebViewPlatformController controller;

  @override
  void initState() {
    super.initState();
    controller = WebKitWebViewPlatformController(
      creationParams: widget.creationParams,
      callbacksHandler: widget.callbacksHandler,
      javascriptChannelRegistry: widget.javascriptChannelRegistry,
      configuration: widget.configuration,
      webViewProxy: widget.webViewProxy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.onBuildWidget(controller);
  }
}

/// An implementation of [WebViewPlatformController] with the WebKit api.
class WebKitWebViewPlatformController extends WebViewPlatformController {
  /// Construct a [WebKitWebViewPlatformController].
  WebKitWebViewPlatformController({
    required CreationParams creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    WKWebViewConfiguration? configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  }) : super(callbacksHandler) {
    _setCreationParams(
      creationParams,
      configuration: configuration ??
          WKWebViewConfiguration(
            userContentController: WKUserContentController(),
          ),
    );

    webView.uiDelegate = uiDelegate;
    uiDelegate.onCreateWebView = (
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    ) {
      if (!navigationAction.targetFrame.isMainFrame) {
        webView.loadRequest(navigationAction.request);
      }
    };
  }

  final Map<String, WKScriptMessageHandler> _scriptMessageHandlers =
      <String, WKScriptMessageHandler>{};

  /// Handles callbacks that are made by navigation.
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Handles constructing a [WKWebView].
  ///
  /// This should only be changed when used for testing.
  final WebViewWidgetProxy webViewProxy;

  /// Represents the WebView maintained by platform code.
  late final WKWebView webView;

  /// Used to integrate custom user interface elements into web view interactions.
  @visibleForTesting
  late final WKUIDelegate uiDelegate = webViewProxy.createUIDelgate();

  /// Methods for handling navigation changes and tracking navigation requests.
  @visibleForTesting
  late final WKNavigationDelegate navigationDelegate =
      webViewProxy.createNavigationDelegate()
        ..didStartProvisionalNavigation = (WKWebView webView, String? url) {
          callbacksHandler.onPageStarted(url ?? '');
        }
        ..didFinishNavigation = (WKWebView webView, String? url) {
          callbacksHandler.onPageFinished(url ?? '');
        }
        ..didFailNavigation = (WKWebView webView, NSError error) {
          callbacksHandler.onWebResourceError(_toWebResourceError(error));
        }
        ..didFailProvisionalNavigation = (WKWebView webView, NSError error) {
          callbacksHandler.onWebResourceError(_toWebResourceError(error));
        }
        ..webViewWebContentProcessDidTerminate = (WKWebView webView) {
          callbacksHandler.onWebResourceError(WebResourceError(
            errorCode: WKErrorCode.webContentProcessTerminated,
            // Value from https://developer.apple.com/documentation/webkit/wkerrordomain?language=objc.
            domain: 'WKErrorDomain',
            description: '',
            errorType: WebResourceErrorType.webContentProcessTerminated,
          ));
        };

  Future<void> _setCreationParams(
    CreationParams params, {
    required WKWebViewConfiguration configuration,
  }) async {
    _setWebViewConfiguration(
      configuration,
      allowsInlineMediaPlayback: params.webSettings?.allowsInlineMediaPlayback,
      autoMediaPlaybackPolicy: params.autoMediaPlaybackPolicy,
    );

    webView = webViewProxy.createWebView(configuration);

    await addJavascriptChannels(params.javascriptChannelNames);

    webView.navigationDelegate = navigationDelegate;

    if (params.webSettings != null) {
      updateSettings(params.webSettings!);
    }
  }

  void _setWebViewConfiguration(
    WKWebViewConfiguration configuration, {
    required bool? allowsInlineMediaPlayback,
    required AutoMediaPlaybackPolicy autoMediaPlaybackPolicy,
  }) {
    if (allowsInlineMediaPlayback != null) {
      configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback;
    }

    late final bool requiresUserAction;
    switch (autoMediaPlaybackPolicy) {
      case AutoMediaPlaybackPolicy.require_user_action_for_all_media_types:
        requiresUserAction = true;
        break;
      case AutoMediaPlaybackPolicy.always_allow:
        requiresUserAction = false;
        break;
    }

    configuration.mediaTypesRequiringUserActionForPlayback =
        <WKAudiovisualMediaType>{
      if (requiresUserAction) WKAudiovisualMediaType.all,
      if (!requiresUserAction) WKAudiovisualMediaType.none,
    };
  }

  @override
  Future<void> updateSettings(WebSettings setting) async {
    if (setting.hasNavigationDelegate != null) {
      _setHasNavigationDelegate(setting.hasNavigationDelegate!);
    }
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) async {
    await Future.wait<void>(
      javascriptChannelNames.where(
        (String channelName) {
          return !_scriptMessageHandlers.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final WKScriptMessageHandler handler =
              webViewProxy.createScriptMessageHandler()
                ..didReceiveScriptMessage = (
                  WKUserContentController userContentController,
                  WKScriptMessage message,
                ) {
                  javascriptChannelRegistry.onJavascriptChannelMessage(
                    message.name,
                    message.body!.toString(),
                  );
                };
          _scriptMessageHandlers[channelName] = handler;

          final String wrapperSource =
              'window.$channelName = webkit.messageHandlers.$channelName;';
          final WKUserScript wrapperScript = WKUserScript(
            wrapperSource,
            WKUserScriptInjectionTime.atDocumentStart,
            isMainFrameOnly: false,
          );
          webView.configuration.userContentController
              .addUserScript(wrapperScript);
          return webView.configuration.userContentController
              .addScriptMessageHandler(
            handler,
            channelName,
          );
        },
      ),
    );
  }

  @override
  Future<void> removeJavascriptChannels(
    Set<String> javascriptChannelNames,
  ) async {
    if (javascriptChannelNames.isEmpty) {
      return;
    }

    // WKWebView does not support removing a single user script, so this removes
    // all user scripts and all message handlers and re-registers channels that
    // shouldn't be removed. Note that this workaround could interfere with
    // exposing support for custom scripts from applications.
    webView.configuration.userContentController.removeAllUserScripts();
    webView.configuration.userContentController
        .removeAllScriptMessageHandlers();

    javascriptChannelNames.forEach(_scriptMessageHandlers.remove);
    final Set<String> remainingNames = _scriptMessageHandlers.keys.toSet();
    _scriptMessageHandlers.clear();

    await addJavascriptChannels(remainingNames);
  }

  void _setHasNavigationDelegate(bool hasNavigationDelegate) {
    if (hasNavigationDelegate) {
      navigationDelegate.decidePolicyForNavigationAction =
          (WKWebView webView, WKNavigationAction action) async {
        final bool allow = await callbacksHandler.onNavigationRequest(
          url: action.request.url,
          isForMainFrame: action.targetFrame.isMainFrame,
        );

        return allow
            ? WKNavigationActionPolicy.allow
            : WKNavigationActionPolicy.cancel;
      };
    } else {
      navigationDelegate.decidePolicyForNavigationAction = null;
    }
  }

  static WebResourceError _toWebResourceError(NSError error) {
    WebResourceErrorType? errorType;

    switch (error.code) {
      case WKErrorCode.unknown:
        errorType = WebResourceErrorType.unknown;
        break;
      case WKErrorCode.webContentProcessTerminated:
        errorType = WebResourceErrorType.webContentProcessTerminated;
        break;
      case WKErrorCode.webViewInvalidated:
        errorType = WebResourceErrorType.webViewInvalidated;
        break;
      case WKErrorCode.javaScriptExceptionOccurred:
        errorType = WebResourceErrorType.javaScriptExceptionOccurred;
        break;
      case WKErrorCode.javaScriptResultTypeIsUnsupported:
        errorType = WebResourceErrorType.javaScriptResultTypeIsUnsupported;
        break;
    }

    return WebResourceError(
      errorCode: error.code,
      domain: error.domain,
      description: error.localizedDescription,
      errorType: errorType,
    );
  }
}

/// Handles constructing objects and calling static methods.
///
/// This should only be used for testing purposes.
@visibleForTesting
class WebViewWidgetProxy {
  /// Constructs a [WebViewWidgetProxy].
  const WebViewWidgetProxy();

  /// Constructs a [WKWebView].
  WKWebView createWebView(WKWebViewConfiguration configuration) {
    return WKWebView(configuration);
  }

  /// Constructs a [WKScriptMessageHandler].
  WKScriptMessageHandler createScriptMessageHandler() {
    return WKScriptMessageHandler();
  }

  /// Constructs a [WKUIDelegate].
  WKUIDelegate createUIDelgate() {
    return WKUIDelegate();
  }

  /// Constructs a [WKNavigationDelegate].
  WKNavigationDelegate createNavigationDelegate() {
    return WKNavigationDelegate();
  }
}
