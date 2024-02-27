// ignore_for_file: unused_field, prefer_const_constructors, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, sized_box_for_whitespace

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class JsonData {
  final String title;
  final String ayat;
  final String translate;
  final String arti;

  JsonData({
    required this.title,
    required this.ayat,
    required this.translate,
    required this.arti,
  });

  factory JsonData.fromJson(Map<String, dynamic> json) {
    return JsonData(
      title: json['title'],
      ayat: json['ayat'],
      translate: json['translate'],
      arti: json['arti'],
    );
  }
}

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  List<JsonData> duas = [];
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8363980854824352/2990457356',
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
      adUnitId: 'ca-app-pub-8363980854824352/2060519066',
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
        await http.get(Uri.parse('https://pastebin.com/raw/CWP2b47p'));

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
      title: "Daily Du'a",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Du'a",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dua.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.domine(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
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
      adUnitId: 'ca-app-pub-8363980854824352/7121274053',
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
            "Du'a",
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
                    widget.dua.ayat,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.translate,
                    style: GoogleFonts.vollkorn(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.dua.arti,
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
