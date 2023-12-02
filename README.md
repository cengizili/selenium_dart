## A QUICK EXAMPLE TO SHOW HOW TO IMPLEMENT SELENIUM PACKAGE IN FLUTTER USING INAPPWEBVIEW

Selenium is a popular package available on various platforms to interact with html elements in browsers.
There is no equivalent package available in flutter so far, so I'm going to show you how to interact with html elements of webviews in flutter
using packages **inappwebview** and **beautiful_soup_dart**. As an example, we're going to log in Instagram and fetch all stories from the main page.

You can find some basic functionalities in the file `selenium.dart`. All of them inject some JavaScript code to the webview. Here are demonstrations for two basic functions.

The `findElement` function runs for the specified duration and returns the element as soon as the element appears in the outer html.

```
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
```

The `clickElement` function also runs for a specified duration, finds the element first, clicks on it, and breaks the while loop if there is a change in the outer html after clicking.

```
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
```
The implementation takes place on the SessionWebView class. In onWebViewCreated block, we're going to log in to Instagram and add a listener to html to update stories whenever scrolling operation changes the html.
As soon as we're logged in (as soon as we have a valid sessionid in onUpdateVisitedHistory block), browser will start scrolling operation and we're going to navigate to the view page. I've used **provider** package to reflect changes in SessionWebView class to our view page.
```
onWebViewCreated: (controller) async {
        widget.selenium.controller = controller;
        // Allow cookies and dismiss pop up.
        await widget.selenium.clickElement('button[class=" _acan _acap _acaq _acas _acav _aj1- _ap30"]');
        // Click log in on the landing page.
        await widget.selenium.clickElement('button[class="_aicz  _acan _acao _acas _aj1- _ap30"]');
        // Input username.
        await widget.selenium.sendText(".....", 'input[aria-label="Phone number, username, or email"]', duration: 3);
        // Input password.
        await widget.selenium.sendText(".....", 'input[aria-label="Password"]', duration: 3);
        // Click log in.
        await widget.selenium.clickElement('button[class=" _acan _acap _acas _aj1- _ap30"]', clickIndex: 1);
        // Every scroll operation will change html, and we need to fetch stories after each scroll.
        widget.selenium.html.addListener(() async {
          if (widget.selenium.html.value != ""){
            final els = await widget.selenium.findElements('img[class="xpdipgo x972fbf xcfux6l x1qhh985 xm0m39n xk390pu x5yr21d xdj266r x11i5rnm xat24cr x1mh8g0r xl1xv1r xexx8yu x4uap5 x18d9i69 xkhd6sd x11njtxf xh8yej3"]');
            elements.addAll(els);
            await widget.selenium.scrollElementHorizontally('div[class="_aaum"]');
            await widget.updateStories(Map.fromEntries(elements.map((e) => MapEntry(e.attributes["alt"]?.split("'")[0], e.attributes["src"]))));
          }
        });
      },
```




