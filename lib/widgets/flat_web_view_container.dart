import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class FlatWebViewContainer extends StatefulWidget {
  /// Url to load
  final String url;
  String? userAgent;
  String? htmlContent;

  /// Set of headers to send
  Map<String, dynamic>? sessionheaders;

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

  FlatWebViewContainer(
      {required this.url,
      required this.onLoadingWidget,
      required this.onStartLoadingActionCallback,
      required this.onLoadedActionCallback,
      this.javascriptChannels,
      this.javascriptMode,
      this.debuggingEnabled,
      this.gestureNavigationEnabled,
      this.webKey,
      this.sessionheaders,
      this.userAgent,
      this.htmlContent});

  @override
  _FlatWebViewContainerState createState() => _FlatWebViewContainerState();
}

class _FlatWebViewContainerState extends State<FlatWebViewContainer> {
  bool isLoaded = false;
  WebViewController? _webViewController;
  Map<String, String>? localSessionHeaders = {};
  Map<String, String> localheaders = {};
  int indexPage = 0;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    setState(() {
      indexPage = 0;
      widget.sessionheaders?.forEach((key, value) {
        localheaders.addAll({key: value.toString()});
        print(value.toString());
      });
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
    return Container(
      color: Color.fromRGBO(51, 51, 51, 1),
      alignment: Alignment.center,
      child: IndexedStack(
        index: indexPage,
        children: [
          widget.onLoadingWidget,
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                color: Colors.red,
              ),
              WebView(
                userAgent: widget.userAgent ??
                    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 M",
                allowsInlineMediaPlayback: true,
                initialMediaPlaybackPolicy:
                    AutoMediaPlaybackPolicy.always_allow,
                onWebViewCreated: (WebViewController webViewController) {
                  webViewController.loadUrl(widget.url, headers: localheaders);
                  if (mounted) {
                    setState(() {
                      _webViewController = webViewController;
                    });
                  }
                },
                javascriptChannels: widget.javascriptChannels,
                navigationDelegate: (NavigationRequest request) {
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  if (mounted) {
                    setState(() {
                      indexPage = 0;
                      isLoaded = false;
                    });
                    widget.onStartLoadingActionCallback();
                  }
                },
                onPageFinished: (String url) {
                  /// Testing
                  ///
                  Future.delayed(Duration(seconds: 5)).then((value) => {
                        if (mounted)
                          {
                            setState(() {
                              indexPage = 1;
                              isLoaded = true;
                            }),
                            widget.onLoadedActionCallback(),
                          }
                      });
                },
                gestureNavigationEnabled:
                    widget.gestureNavigationEnabled ?? true,
                debuggingEnabled: widget.debuggingEnabled ?? false,
                javascriptMode:
                    widget.javascriptMode ?? JavascriptMode.unrestricted,
              ),
            ],
          )
        ],
      ),
    );
  }
}
