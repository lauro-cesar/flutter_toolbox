import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import '../utils/static_constants.dart';

class FlatWebViewContainer extends StatefulWidget {
  /// Url to load
  final String url;
  String? userAgent;
  String? htmlContent;

  /// Set of headers to send
  Map<String, dynamic>? sessionheaders;

  /// optional Javascript channels to subcribe
  Set<dynamic>? javascriptChannels;

  /// optional Key
  Key? webKey;

  /// required Widget to return while loading the url
  final Widget onLoadingWidget;

  /// required callback to bubble up when starting load the url
  final Function(String url) onStartLoadingActionCallback;

  /// required callback to bubble up after loading
  final Function(String url) onLoadedActionCallback;

  /// set debug on
  bool? debuggingEnabled;
  bool? zoomEnabled;

  ///enable gestureNavigation
  bool? gestureNavigationEnabled;

  /// enable Javascript JavascriptMode. JavascriptMode.unrestricted | JavascriptMode.disabled
  dynamic? javascriptMode;

  FlatWebViewContainer(
      {required this.url,
      required this.onLoadingWidget,
      required this.onStartLoadingActionCallback,
      required this.onLoadedActionCallback,
      this.javascriptChannels,
      this.javascriptMode,
      this.debuggingEnabled,
      this.zoomEnabled,
      this.gestureNavigationEnabled,
      this.webKey,
      this.sessionheaders,
      this.userAgent,
      this.htmlContent});

  @override
  _FlatWebViewContainerState createState() => _FlatWebViewContainerState();
}

class _FlatWebViewContainerState extends State<FlatWebViewContainer> {
  bool enableZoom = true;
  bool isLoaded = false;
  WebViewController? _webViewController;
  Map<String, String>? localSessionHeaders = {};
  Map<String, String> localheaders = {};
  int indexPage = 0;
  int serial = 0;
  int totalLoaded = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final zoom = widget.zoomEnabled ?? false;
    setState(() {
      indexPage = 0;
      enableZoom = zoom;
      isLoading = true;
      widget.sessionheaders?.forEach((key, value) {
        localheaders.addAll({key: value.toString()});
      });
      isLoaded = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: IndexedStack(
        index: indexPage,
        children: [
          widget.onLoadingWidget,
          Stack(
            children: [
              Container(
                child: Builder(builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () async {
                      final podeVoltar = await _webViewController?.canGoBack();
                      if (podeVoltar ?? false) {
                        _webViewController?.goBack();
                        return false;
                      }
                      return true;
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Text("Descontinued...")
                        ),
                      ],
                    ),
                  );
                }),
              ),

            ],
          )
        ],
      ),
    );
  }
}
