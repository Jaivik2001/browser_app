import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late InAppWebViewController inAppWebViewController;
  late PullToRefreshController pullToRefreshController;
  List bookMark = [];
  String value = "";

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController.reload();
        } else if (Platform.isIOS) {
          Uri? url = await inAppWebViewController.getUrl();
          inAppWebViewController.loadUrl(
            urlRequest: URLRequest(url: url),
          );
        }
      },
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browser'),
        actions: [
          IconButton(
            onPressed: () {
              inAppWebViewController.reload();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse('https://www.google.com/search?q=$value'),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.goBack();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse('https://www.google.com'),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              inAppWebViewController.goForward();
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              Uri? uri = await inAppWebViewController.getUrl();
              setState(() {
                bookMark.add(uri);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("BookMark Added"),
                ),
              );
            },
            child: const Icon(Icons.bookmark),
          ),
          FloatingActionButton(
            onPressed: () {
              showGeneralDialog(
                context: context,
                pageBuilder: (BuildContext context, _, __) {
                  return AlertDialog(
                    title: const Text("Book Mark"),
                    content: Column(
                      children: bookMark
                          .map(
                            (e) => GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  inAppWebViewController.loadUrl(
                                    urlRequest: URLRequest(
                                      url: e,
                                    ),
                                  );
                                });
                              },
                              child: Text(
                                '$e',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ).toList(),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.bookmark_add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(onChanged: (val) {
              setState(() {
                value = val;
              });
            }),
          ),
          Expanded(
            flex: 14,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse('https://www.google.com'),
              ),
              onWebViewCreated: (InAppWebViewController val) {
                setState(() {
                  inAppWebViewController = val;
                });
              },
              onLoadStop: (context, uri) {
                pullToRefreshController.endRefreshing();
              },
              pullToRefreshController: pullToRefreshController,
            ),
          ),
        ],
      ),
    );
  }
}
