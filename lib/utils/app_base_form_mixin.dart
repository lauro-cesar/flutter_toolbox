import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class AppBaseFormMixin {
  int index = 0;
  int max = 0;
  int totalSteps = 1;
  bool isLoading = true;
  bool remember = false;
  bool terms_accepted = false;
  String errorMessage = "";
  ScrollController? controller;
  int scrollOffset = 64;
  Map<String, dynamic> formValues = <String, dynamic>{'remember': false};
  List<TextEditingController>? inputControls;
  List<FocusNode>? focusNodes;

  void goTo({next: 0, message: null}) {}

  void scrollTo() {
    controller!.animateTo((scrollOffset * index.toDouble()),
        duration: Duration(milliseconds: 1500), curve: Curves.fastOutSlowIn);
  }

  void scrollToPrev() {
    controller!.animateTo((scrollOffset * (index.toDouble() - 1)),
        duration: Duration(milliseconds: 1500), curve: Curves.fastOutSlowIn);
  }

  void scrollToNext() {
    controller!.animateTo((scrollOffset * (index.toDouble() - 1)),
        duration: Duration(milliseconds: 1500), curve: Curves.fastOutSlowIn);
    // controller.animateTo(),
    //     duration: Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
  }

  void goBack({message: null}) {
    if (index > 1) {
      focusNodes?.map((e) => e.unfocus());
      index--;
      goTo(next: index, message: message);
    }
  }

  void goNext({message: null}) {
    if (index <= max) {
      focusNodes?.map((e) => e.unfocus());
      index++;
      goTo(next: index, message: message);
    }
  }

  focusVisible() {
    try {
      FocusNode node = focusNodes!.elementAt(index);
      if (node != null) {
        node.requestFocus();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
