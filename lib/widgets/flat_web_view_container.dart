import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class FlatWebViewContainer extends StatefulWidget {
  /// Url to load
  final String url;

  /// Set of headers to send
  Map<String, String>? sessionheaders;

  /// optional Javascript channels to subcribe
  Set<JavascriptChannel>? javascriptChannels;

  /// optional Key
  Key? webKey;

  /// required Widget to return while loading the url
  final Widget onLoadingWidget;

  /// required callback to bubble up when starting load the url
  final Function() onStartLoadingActionCallback;

  /// required callback to bubble up after loading
  final Function() onLoadedActionCallback;

  /// set debug on
  bool? debuggingEnabled;

  ///enable gestureNavigation
  bool? gestureNavigationEnabled;

  /// enable Javascript JavascriptMode. JavascriptMode.unrestricted | JavascriptMode.disabled
  JavascriptMode? javascriptMode;

  FlatWebViewContainer({
    required this.url,
    required this.onLoadingWidget,
    required this.onStartLoadingActionCallback,
    required this.onLoadedActionCallback,
    this.javascriptChannels,
    this.javascriptMode,
    this.debuggingEnabled,
    this.gestureNavigationEnabled,
    this.webKey,
    this.sessionheaders,
  });

  @override
  _FlatWebViewContainerState createState() => _FlatWebViewContainerState();
}

class _FlatWebViewContainerState extends State<FlatWebViewContainer> {
  bool isLoaded = false;
  WebViewController? _webViewController;
  Map<String, String>? sessionHeaders;
  int indexPage = 0;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    setState(() {
      sessionHeaders = <String, String>{
        HttpHeaders.refererHeader: widget.url,
      };

      isLoaded = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // JavascriptChannel _openObjectScreen(BuildContext context) {
  //   return JavascriptChannel(
  //       name: 'OpenObjectScreen',
  //       onMessageReceived: (JavascriptMessage message) {
  //         if (widget.onOpenObject != null) {
  //           widget.onOpenObject(message.message);
  //         }
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: indexPage,
      children: [
        widget.onLoadingWidget,
        WebView(
          onWebViewCreated: (WebViewController webViewController) {
            setState(() {
              _webViewController = webViewController;
            });
            _webViewController?.loadUrl(widget.url, headers: sessionHeaders);
          },
          javascriptChannels: widget.javascriptChannels,
          navigationDelegate: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() {
              indexPage = 0;
              isLoaded = false;
            });
            widget.onStartLoadingActionCallback();
          },
          onPageFinished: (String url) {
            Future.delayed(Duration(seconds: 2)).then((_) => {
                  widget.onLoadedActionCallback(),
                  setState(() {
                    indexPage = 1;
                    isLoaded = true;
                  }),
                });
          },
          gestureNavigationEnabled: widget.gestureNavigationEnabled ?? true,
          debuggingEnabled: widget.debuggingEnabled ?? false,
          javascriptMode: widget.javascriptMode ?? JavascriptMode.unrestricted,
        ),
      ],
    );
  }
}
