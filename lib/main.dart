import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String base_url = "https://jsonplaceholder.typicode.com/posts";
  int _page = 0;
  final int _limit = 20;
  bool _isFirstLoadingRunning = false;
  List posts = [];

  bool hasNext = true;
  bool isLoadingMore = false;

  void _loadMore() async {
    if (hasNext == true &&
        _isFirstLoadingRunning == false &&
        isLoadingMore == false) {
      setState(() {
        isLoadingMore = true;
      });

      _page += 1;

      try {
        final response =
            await http.get(Uri.parse('$base_url?_page=$_page&_limit=$_limit'));

        final List fetchPosts = json.decode(response.body);
        if (fetchPosts.isNotEmpty) {
          setState(() {
            posts.addAll(fetchPosts);
          });
        } else {
          setState(() {
            hasNext = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('something went wrong');
        }
      }
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void firstLoad() async {
    setState(() {
      _isFirstLoadingRunning = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$base_url?_page=$_page&_limit=$_limit'));
      setState(() {
        posts = json.decode(response.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print('something went wrong');
      }
    }

    setState(() {
      _isFirstLoadingRunning = false;
    });
  }

  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    firstLoad();
    _controller = ScrollController()
      ..addListener(() {
        _loadMore();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: _isFirstLoadingRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    controller: _controller,
                    itemBuilder: (_, index) => Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(posts[index]['title']),
                        subtitle: Text(posts[index]['body']),
                      ),
                    ),
                  ),
                ),
                if (isLoadingMore == true)
                  
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 40,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                 if (hasNext == false)
              Container(
                padding: const EdgeInsets.only(top: 30, bottom: 40),
                color: Colors.amber,
                child: const Center(
                  child: Text('You have fetched all of the content'),
                )
              )
                  
              ],
            ),
    );
  }
}
