// ignore_for_file: unused_field, prefer_const_constructors, avoid_unnecessary_containers, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, sized_box_for_whitespace, file_names

import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class JsonData {
  final String question;
  final String audioUrl;
  final String ayat;
  final String source;
  final String translate;
  final String arti;

  JsonData({
    required this.question,
    required this.audioUrl,
    required this.ayat,
    required this.source,
    required this.translate,
    required this.arti,
  });

  factory JsonData.fromJson(Map<String, dynamic> json) {
    return JsonData(
      question: json['question'],
      audioUrl: json['audioUrl'],
      ayat: json['ayat'],
      source: json['source'],
      translate: json['translate'],
      arti: json['arti'],
    );
  }
}

class PopQuePage extends StatefulWidget {
  const PopQuePage({super.key});

  @override
  State<PopQuePage> createState() => _PopQuePageState();
}

class _PopQuePageState extends State<PopQuePage> {
  List<JsonData> popques = [];
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8363980854824352/7755359568',
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
      adUnitId: 'ca-app-pub-8363980854824352/3788533701',
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
    fetchPopQue();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  Future<void> fetchPopQue() async {
    final response =
        await http.get(Uri.parse('https://pastebin.com/raw/LAWQGq7d'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final popquesJson = jsonData['popques'] as List<dynamic>;

      setState(() {
        popques = popquesJson
            .map((popqueJson) => JsonData.fromJson(popqueJson))
            .toList();
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
      title: "Popular Questions",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Popular Questions",
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
                  itemCount: popques.length,
                  itemBuilder: (context, index) {
                    final popque = popques[index];
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
                                        popque.question,
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
                                builder: (context) =>
                                    DetailPage(popque: popque),
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
  final JsonData popque;

  DetailPage({required this.popque});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  BannerAd? _bannerAd;
  Map<int, bool> isPlayingMap = {};
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();

  Future<void> toggleAudio(String url) async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.play(UrlSource(url));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8363980854824352/1162370363',
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
      title: "Popular Questions",
      home: Scaffold(
        backgroundColor: Color(0xfff3e9d2),
        appBar: AppBar(
          title: Text(
            "Popular Questions",
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
                    widget.popque.question,
                    style: GoogleFonts.domine(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.popque.ayat,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.popque.source,
                    style: GoogleFonts.vollkorn(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.popque.translate,
                    style: GoogleFonts.vollkorn(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.popque.arti,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            toggleAudio(widget.popque.audioUrl);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                isPlaying == true ? Icons.pause : Icons.play_arrow,
                color: isPlaying == true ? Colors.grey : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
