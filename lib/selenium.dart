import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';


class Selenium {
  Selenium({this.controller});

  InAppWebViewController? controller;
  String doc = "document";

  ValueNotifier<String> html = ValueNotifier<String>('');

  Future<void> updateHtml() async {
    html.value = await controller?.evaluateJavascript(source: "${doc}.body.outerHTML") ?? "";
  }

  void switchToIframe(String iframe) {
    doc = iframe;
  }

  void exitIframe() {
    doc = "document";
  }

  Future<Bs4Element?> findElement(String xpath, {int duration=10}) async {
    final endTime = DateTime.now().add(Duration(seconds: duration));
    Bs4Element? element;
    while (DateTime.now().isBefore(endTime)) {
      await Future.delayed(Duration(seconds: 1));
      await updateHtml();
      final bs = BeautifulSoup(html.value);
      element = bs.find('', selector: xpath);
      if (element != null){ 
        break;
      }
    }
    return element;
  }

  Future<bool> searchForText(String text, {int duration=10}) async {
    final endTime = DateTime.now().add(Duration(seconds: duration));
    while (DateTime.now().isBefore(endTime)) {
      await Future.delayed(Duration(seconds: 1));
      await updateHtml();
      if (html.value.toLowerCase().contains(text.toLowerCase())){ 
        return true;
      }
    }
    return false;
  }

  Future<List<Bs4Element>> findElements(String xpath, {int duration=10}) async {
    final endTime = DateTime.now().add(Duration(seconds: duration));
    List<Bs4Element> elements = [];
    while (DateTime.now().isBefore(endTime)) {
      await Future.delayed(Duration(seconds: 1));
      await updateHtml();
      final bs = BeautifulSoup(html.value);
      elements = bs.findAll('', selector: xpath);
      if (elements.isNotEmpty){
        break;
      }
    }
    return elements;
  }

  Future<void> scrollElementHorizontally(String xpath, {int duration=10}) async {
      await findElement(xpath, duration: duration);
      final endTime = DateTime.now().add(Duration(seconds: duration));
      String? htmlBefore;
       while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(Duration(seconds: 1));
        htmlBefore = await controller?.evaluateJavascript(source: "${doc}.body.outerHTML") ?? "";
          final jsCode = '''
            var element = ${doc}.querySelector('$xpath');
            if (element) {
                element.scrollLeft = element.scrollLeft + element.offsetWidth;
            }
            ''';
          await controller?.evaluateJavascript(source: jsCode);
          await updateHtml();
          if (htmlBefore != html.value){
            break;
          }
       }
    }
  
  Future<void> sendText(String text, String xpath, {int duration=10, int index=0}) async {
      await findElement(xpath, duration: duration);
      String? htmlBefore;
      final endTime = DateTime.now().add(Duration(seconds: duration));
       while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(Duration(seconds: 1));
        htmlBefore = await controller?.evaluateJavascript(source: "${doc}.body.outerHTML") ?? "";
          final jsCode = '''
            var elements = document.querySelectorAll('$xpath');
            var el = elements[$index];
            el.value = '$text';
            var changeEvent = new Event('change', {
              bubbles: true,
              cancelable: true
            });
            el.dispatchEvent(changeEvent);
            ''';
          await controller?.evaluateJavascript(source: jsCode);
          await updateHtml();
          if (htmlBefore != html.value){
            break;
          }
       }
    }


  Future<void> clickElement(String xpath, {int duration=10, int clickIndex = 0}) async {
      await findElement(xpath, duration: duration);
      final endTime = DateTime.now().add(Duration(seconds: duration));
      String? htmlBefore;
       while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(Duration(seconds: 1));
        htmlBefore = await controller?.evaluateJavascript(source: "${doc}.body.outerHTML") ?? "";
        final jsCode = '''
          var elements = document.querySelectorAll('$xpath');
            var selected = elements[$clickIndex];
            if (selected) {
                selected.click();
            }
          ''';
        await controller?.evaluateJavascript(source: jsCode);
        await updateHtml();
        if (htmlBefore != html.value){
          break;
        }
       }
    }
  }