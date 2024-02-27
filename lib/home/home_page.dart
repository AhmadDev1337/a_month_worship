// ignore_for_file: prefer_const_constructors, prefer_final_fields, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'items/doa_page.dart';
import 'items/hadits_page.dart';
import 'items/pop&que_page.dart';
import 'items/takbiran_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _pageController.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://pastebin.com/raw/AdTVSmUF'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        imageUrls = List<String>.from(data);
      });
    } else {
      Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: SpinKitWave(
              color: Color(0xff1a936f),
              size: 25,
            ),
          ),
        ),
      );
    }
  }

  List items = [
    {
      "image": "assets/icons/ques.png",
      "name": "Pupular Questions",
      "widget": PopQuePage(),
    },
    {
      "image": "assets/icons/dua.png",
      "name": "Daily Du'as",
      "widget": DoaPage(),
    },
    {
      "image": "assets/icons/hadits.png",
      "name": "Hadits",
      "widget": HaditsPage(),
    },
    {
      "image": "assets/icons/nasheed.png",
      "name": "Nasheed",
      "widget": TakbiranPage(),
    },
  ];

  void _navigateToDetailPage(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "A Month Worhsip",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "A Month Worship",
            style: GoogleFonts.breeSerif(),
          ),
          backgroundColor: Color(0xff1a936f),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(imageUrls[index],
                            fit: BoxFit.fill);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: imageUrls.length,
              effect: ExpandingDotsEffect(
                dotWidth: 7.0,
                dotHeight: 7.0,
                dotColor: Colors.grey,
                activeDotColor: Color(0xff1a936f),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              direction: Axis.horizontal,
              children: items.map((item) {
                return GestureDetector(
                  onTap: () {
                    _navigateToDetailPage(context, item["widget"]);
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xfff3e9d2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(4.0, 4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0,
                          color: Colors.grey.shade500,
                        ),
                        BoxShadow(
                          offset: Offset(-4.0, -4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0,
                          color: Color(0xfff3e9d2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            item["image"],
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          SizedBox(height: 10),
                          Text(
                            item["name"],
                            style: GoogleFonts.breeSerif(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
