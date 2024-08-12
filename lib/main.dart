import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pagenation_api/home.dart';
import 'package:pagenation_api/localalization.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

       supportedLocales: [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      localizationsDelegates: [
        AppLocalizations.delegate, // Custom localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home:  MyHomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We will fetch data from this Rest API
  final String _baseUrl = 'https://spotdev.reapmind.com/beemate/api/';

  // At the beginning, we fetch the first 10 posts
  int _page = 1;
  // You can change this value to fetch more or less posts per page (10, 15, 5, etc)
  final int _limit = 10;
  String searchText = "";

  // There is a next page or not
  bool _hasNextPage = true;

  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  // This holds the posts fetched from the server
  List _posts = [];

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    var token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjE4ZDI3ZTg5ZTNjYWU0YjhlOWY1MjkiLCJpYXQiOjE3MjI4Njc4NDQsImV4cCI6MTcyMjk1NDI0NH0.tW0Xqv6iRLFNgMUyyrMAaq2FvMYkp_thxB3KSWE3n_A';
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res = await GetRequest('trip?search=$searchText&page=$_page&limit=$_limit', token: token);
      debugPrint('res $res');

      if (res['status'] == true && res['statusCode'] == 200) {
        setState(() {
          _posts = res['data'];
        });
      } else {
        print('Trip Data API Failed');
      }
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  Future<dynamic> GetRequest(String url, {String token = ''}) async {
    var responseJson;
    try {
      debugPrint("-->${_baseUrl + url} ");
      print("token $token");
      final http.Response response = await http.get(
        Uri.parse(_baseUrl + url),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      responseJson = json.decode(response.body);
      print(responseJson);
    } catch (e) {
      print(e);
    }
    return responseJson;
  }

  // This function will be triggered whenever the user scrolls
  // to near the bottom of the list view
  void _loadMore() async {
    var token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjE4ZDI3ZTg5ZTNjYWU0YjhlOWY1MjkiLCJpYXQiOjE3MjI4Njc4NDQsImV4cCI6MTcyMjk1NDI0NH0.tW0Xqv6iRLFNgMUyyrMAaq2FvMYkp_thxB3KSWE3n_A';

    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase page by 1
      try {
        final res = await GetRequest('trip?search=$searchText&page=$_page&limit=$_limit', token: token);

        if (res['data'].isNotEmpty) {
          setState(() {
            _posts.addAll(res['data']);
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  // The controller for the ListView
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindacode.com'),
      ),
      body: _isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: _posts.length,
                    itemBuilder: (_, index) => Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(_posts[index]['name']),
                        // subtitle: Text(_posts[index]['body']),
                      ),
                    ),
                  ),
                ),

                // When the _loadMore function is running
                if (_isLoadMoreRunning)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                // if (!_hasNextPage)
                //   Container(
                //     padding: const EdgeInsets.only(top: 30, bottom: 40),
                //     color: Colors.amber,
                //     child: const Center(
                //       child: Text('You have fetched all of the content'),
                //     ),
                //   ),
              ],
            ),
    );
  }
}
