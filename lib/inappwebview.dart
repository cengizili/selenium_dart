import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:selenium_dart/selenium.dart';
import 'package:selenium_dart/story_view.dart';
import 'package:url_launcher/url_launcher.dart';


class SessionWebView extends StatefulWidget with ChangeNotifier {
   SessionWebView({super.key,});

   Map stories = {};
   Selenium selenium = Selenium();

   Future<void> updateStories(Map _stories) async {
      stories = Map.fromEntries(_stories.entries.where((element) => element.key != ""));
      await selenium.updateHtml();
      notifyListeners();
    }
  
  @override
  State<SessionWebView> createState() => _SessionWebViewState();
}

class _SessionWebViewState extends State<SessionWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  CookieManager cookieManager = CookieManager.instance();
  List elements = []; 


  @override
  void initState() {
     pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    bool sessionGate = false;

    InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);
     
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest:
      URLRequest(url: WebUri("https://www.instagram.com")),
      initialSettings: settings,
      pullToRefreshController: pullToRefreshController,
      shouldOverrideUrlLoading:(controller, navigationAction) async {
      var uri = navigationAction.request.url!;
      if (![
        "http",
        "https",
        "file",
        "chrome",
        "data",
        "javascript",
        "about"
      ].contains(uri.scheme)) {
        if (await canLaunchUrl(uri)) {
          // Launch the App
          await launchUrl(
            uri,
          );
          // and cancel the request
          return NavigationActionPolicy.CANCEL;
        }
      }

      return NavigationActionPolicy.ALLOW;
    },
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT);
      },
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
      onWebViewCreated: (controller) async {
        widget.selenium.controller = controller;
        await widget.selenium.clickElement('button[class=" _acan _acap _acaq _acas _acav _aj1- _ap30"]');
        await widget.selenium.clickElement('button[class="_aicz  _acan _acao _acas _aj1- _ap30"]');
        await widget.selenium.sendText("moridas8t", 'input[aria-label="Phone number, username, or email"]', duration: 3);
        await widget.selenium.sendText("morbidangel", 'input[aria-label="Password"]', duration: 3);
        await widget.selenium.clickElement('button[class=" _acan _acap _acas _aj1- _ap30"]', clickIndex: 1);
        widget.selenium.html.addListener(() async {
          if (widget.selenium.html.value != ""){
            final els = await widget.selenium.findElements('img[class="xpdipgo x972fbf xcfux6l x1qhh985 xm0m39n xk390pu x5yr21d xdj266r x11i5rnm xat24cr x1mh8g0r xl1xv1r xexx8yu x4uap5 x18d9i69 xkhd6sd x11njtxf xh8yej3"]');
            elements.addAll(els);
            await widget.selenium.scrollElementHorizontally('div[class="_aaum"]');
            await widget.updateStories(Map.fromEntries(elements.map((e) => MapEntry(e.attributes["alt"]?.split("'")[0], e.attributes["src"]))));
          }
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) async {
        List<Cookie> cookies = await cookieManager.getCookies(url: url!);
        String sessionId = cookies.firstWhere((element) => element.name=="sessionid", orElse: () => Cookie(name: "", value: ""),).value;
        if (sessionId.isNotEmpty && sessionGate==false){
          // We'd like to make sure that this block is accesible only once as repetitive calls may manipulate the operation.
          sessionGate = true;
          // You can send the cookies to another client for later use.
          final cookiesMap = Map.fromEntries(cookies.map((e){
            return MapEntry(e.toMap()["name"], e.toMap()["value"]);
          }));
          // Now we can move to the view.
          Navigator.push(context, MaterialPageRoute(builder: (context) => Stories(),));
          await widget.selenium.updateHtml();
      }}
    );
  }
}