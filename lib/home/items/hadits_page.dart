// ignore_for_file: unused_field, prefer_const_constructors, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, sized_box_for_whitespace

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';

class JsonData {
  final String title;
  final String subtitle;
  final String hadits;
  final String arti;
  final String source;
  final String grade;

  JsonData({
    required this.title,
    required this.subtitle,
    required this.hadits,
    required this.arti,
    required this.source,
    required this.grade,
  });

  factory JsonData.fromJson(Map<String, dynamic> json) {
    return JsonData(
      title: json['title'],
      subtitle: json['subtitle'],
      hadits: json['hadits'],
      arti: json['arti'],
      source: json['source'],
      grade: json['grade'],
    );
  }
}

class HaditsPage extends StatefulWidget {
  const HaditsPage({super.key});

  @override
  State<HaditsPage> createState() => _HaditsPageState();
}

class _HaditsPageState extends State<HaditsPage> {
  List<JsonData> duas = [];
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8363980854824352/3148215937',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.show();
          log('Ad onAdLoaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8363980854824352/4495110717',
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('Ad onAdLoaded');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError err) {
          log('Ad onAdFailedToLoad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    fetchDua();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  Future<void> fetchDua() async {
    final response =
        await http.get(Uri.parse('https://pastebin.com/raw/pz56F1zm'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final duasJson = jsonData['duas'] as List<dynamic>;

      setState(() {
        duas = duasJson.map((duaJson) => JsonData.fromJson(duaJson)).toList();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hadits",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Hadits",
            style: GoogleFonts.breeSerif(),
          ),
          backgroundColor: Color(0xff1a936f),
        ),
        body: Stack(
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    return Column(
                      children: [
                        GestureDetector(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dua.title,
                                            style: GoogleFonts.domine(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Icon(
                                            IconlyLight.arrow_right_2,
                                            color: Color(0xFF0D0D0D),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(
                                        color: Color(0xFF0D0D0D),
                                        indent: 5,
                                        endIndent: 5,
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            _loadInterstitialAd();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(dua: dua),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 9.9,
                height: 50,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final JsonData dua;

  DetailPage({required this.dua});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  BannerAd? _bannerAd;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8363980854824352/7965428349',
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('Ad onAdLoaded');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError err) {
          log('Ad onAdFailedToLoad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Daily Dua",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Hadits",
            style: GoogleFonts.breeSerif(),
          ),
          backgroundColor: Color(0xff1a936f),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/background.png", fit: BoxFit.fill),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Text(
                    widget.dua.title,
                    style: GoogleFonts.domine(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.subtitle,
                    style: GoogleFonts.domine(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.hadits,
                    style: GoogleFonts.vollkorn(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.arti,
                    style: GoogleFonts.vollkorn(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.source,
                    style: GoogleFonts.vollkorn(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.dua.grade,
                    style: GoogleFonts.vollkorn(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 9.9,
                height: 50,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
