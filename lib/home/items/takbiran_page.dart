// ignore_for_file: unused_field, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';

class JsonData {
  final String audioUrl;
  final String name;

  JsonData({
    required this.audioUrl,
    required this.name,
  });

  factory JsonData.fromJson(Map<String, dynamic> json) {
    return JsonData(
      audioUrl: json['audioUrl'],
      name: json['name'],
    );
  }
}

class TakbiranPage extends StatefulWidget {
  const TakbiranPage({super.key});

  @override
  State<TakbiranPage> createState() => _TakbiranPageState();
}

class _TakbiranPageState extends State<TakbiranPage> {
  List<JsonData> jsonDataList = [];
  bool isPlaying = false;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  Map<int, bool> isPlayingMap = {};
  final AudioPlayer player = AudioPlayer();

  Future<void> toggleAudio(String url, int index) async {
    if (isPlayingMap[index] == true) {
      await player.pause();
    } else {
      await player.play(UrlSource(url));
    }
    setState(() {
      isPlayingMap[index] = !isPlayingMap[index]!;
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8363980854824352/8657717009',
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
      adUnitId: 'ca-app-pub-8363980854824352/7536207029',
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
    fetchData();
    _loadInterstitialAd();
    _loadBannerAd();
  }

  Future<void> fetchData() async {
    const singleJsonUrl = 'https://pastebin.com/raw/VJ3Rpb1D';

    try {
      final response = await http.get(Uri.parse(singleJsonUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        jsonDataList = jsonData.map<JsonData>((data) {
          int index = jsonData.indexOf(data);
          isPlayingMap[index] = false; // Inisialisasi status play/pause
          return JsonData(
            audioUrl: data['audioUrl'],
            name: data['name'],
          );
        }).toList();

        setState(() {});
      } else {
        Scaffold(
          backgroundColor: Color(0xFF0D0D0D),
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
    } catch (e) {
      Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
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
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Nasheed",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Nasheed",
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
                  itemCount: jsonDataList.length,
                  itemBuilder: (context, index) {
                    final jsonData = jsonDataList[index];
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
                                            jsonData.name,
                                            style: GoogleFonts.domine(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          GestureDetector(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    isPlayingMap[index] == true
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color:
                                                        isPlayingMap[index] ==
                                                                true
                                                            ? Colors.black
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              _loadInterstitialAd();
                                              toggleAudio(
                                                  jsonData.audioUrl, index);
                                            },
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
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
