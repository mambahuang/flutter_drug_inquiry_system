import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:number_paginator/number_paginator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'API/STT.dart';
import 'drug_card_widge.dart';
import 'drug_information_page.dart';
import 'favorite_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecord = false;
  String speechRecognitionAudioPath = "";
  bool isNeedSendSpeechRecognition = false;
  String base64String = "";
  List<String> items = ["華語", "台語", "客語", "英語", "印尼語", "粵語"];
  String selectedLanguage = "華語";
  AudioEncoder encoder = AudioEncoder.wav;
  String sentence = "";

  Future<String> askForService(String base64String, String language) {
    print("askForService");
    return STTClient().askForService(base64String, language);
  }

  @override
  void initState() {
    super.initState();
    // 根據設備決定錄音的 encoder
    if (Platform.isIOS) {
      encoder = AudioEncoder.pcm16bit;
    } else {
      encoder = AudioEncoder.wav;
    }
  }

  int pageIndex = 0;
  int pagesElementNumber = 10;
  int total = 0;
  String keyWord = "";

  List<String> favoriteDrugNames = [];
  List<String> favoriteDrugNamesContent = [];
  List<String> imgSrcList = [];
  List<Map<String, dynamic>> tmpData = [];

  // Load data
  Future<Map<String, dynamic>> loadData() async {
    final response =
        await http.post(Uri.parse('http://10.0.2.2:3009/get_drug_list'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              'keyWord': keyWord,
              'start': ((pageIndex) * pagesElementNumber).toString(),
              'end': ((pageIndex + 1) * pagesElementNumber - 1).toString(),
            }));
    late dynamic data;

    if (response.statusCode == 200) {
      // Successful response
      data = json.decode(response.body)["data"];
      total = json.decode(response.body)["length"];
      log('Received data from Flask backend: $data');
    } else {
      // Error handling for unsuccessful response
      log('Failed to fetch data. Status code: ${response.statusCode}');
    }
    return {"data": data};
  }



  @override
  Widget build(BuildContext context) {
    late dynamic data;
    var content = TextEditingController();
    // content.addListener(() {
    //   pageIndex = 0;
    //   keyWord = content.text;
    //   print(keyWord);
    //   if (keyWord == "") {
    //     setState(() {
    //       // refresh
    //     });
    //   }
    // });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
        // Heart icon in app bar
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                debugPrint(favoriteDrugNames.length.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteDrug(
                        favoriteDrugNames: favoriteDrugNames,
                        favoriteDrugNamesContent: favoriteDrugNamesContent,
                        imgSrcList: imgSrcList),
                  ),
                );
              });
            },
            icon: const Icon(Icons.favorite_border),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot1) {
          if (snapshot1.hasData) {
            // Get the data from the snapshot
            data = snapshot1.data;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: (isNeedSendSpeechRecognition)
                          ? FutureBuilder<String>(
                              future:
                                  askForService(base64String, selectedLanguage),
                              builder: (context, snapshot2) {
                                if (snapshot2.hasError) {
                                  // 請求失敗，顯示錯誤
                                  print('askForService() 請求失敗');
                                  isNeedSendSpeechRecognition = false;
                                  content.text = '請求失敗';
                                }
                                else if (snapshot2.hasData) {
                                  // 請求成功，顯示資料
                                  print('請求成功');
                                  sentence = snapshot2.data.toString().substring(0, snapshot2.data.toString().length -1);
                                  print(sentence);

                                  isNeedSendSpeechRecognition = false;

                                  content.text = sentence;
                                  keyWord = sentence;
                                }
                                else {
                                  // 請求未結束，顯示loading
                                  print('辨識中...');
                                  // isNeedSendSpeechRecognition = false;
                                  content.text = '辨識中...';
                                }
                                return TextField(
                                  decoration: const InputDecoration(
                                    // labelText: 'Search',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  controller: content,
                                  style: TextStyle(fontSize: 20),
                                );
                              })
                          : TextField(
                              decoration: const InputDecoration(
                                labelText: 'Search',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                pageIndex = 0;
                                keyWord = value;
                                print(keyWord);
                                if (keyWord == "") {
                                  setState(() {
                                    // refresh
                                  });
                                }
                              },
                            ),
                    ),
                    IconButton(
                        onPressed: () {
                          data['data'] = tmpData;
                          setState(() {
                            // refresh
                          });
                        },
                        icon: const Icon(Icons.search))
                  ],
                ),
                Expanded(
                  // Dynamic show the drug list
                  child: ListView.builder(
                    itemCount: data!["data"].length,
                    itemBuilder: (BuildContext context, int index) {
                      String imgSrc = "";
                      String? imageLink =
                          data["data"][index]["image_link"].toString();
                      if (imageLink != "") {
                        imgSrc = data["data"][index]["image_link"].toString();
                      } else {
                        imgSrc =
                            "https://cyberdefender.hk/wp-content/uploads/2021/07/404-01-scaled.jpg";
                      }
                      //check if keyword is changed
                      for (int i = 0; i < data['data'].length; i++) {
                        if (keyWord.contains(
                            data['data'][i]['chinese_name'].toString())) {
                          tmpData.add(data['data'][i]);
                        }
                      }

                      // ListTile show the drug info
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrugInformationPage(
                                data: data['data'][index],
                                imgSrc: imgSrc,
                              ),
                            ),
                          );
                        },
                        // DrugCardWidget show the drug card
                        child: DrugCardWidget(
                          favoriteDrugNames: favoriteDrugNames,
                          favoriteDrugNamesContent: favoriteDrugNamesContent,
                          imgSrcList: imgSrcList,
                          item: data['data'][index],
                          imgSrc: imgSrc,
                        ),
                      );
                    },
                  ),
                ),
                NumberPaginator(
                  numberPages: total > 0 ?(total / 50).ceil():1,
                  onPageChange: (int index) {
                    setState(() {
                      pageIndex = index;
                    });
                  },
                  config: const NumberPaginatorUIConfig(
                    height: 54.0,
                  ),
                ),
              ],
            );
          } else if (snapshot1.hasError) {
            return Text('Error: ${snapshot1.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isRecord,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        endRadius: 70,
        child: FloatingActionButton(
          onPressed: () async {
            // 創建 Record 實例
            final record = Record();

            // 判斷是否在錄音中
            if (isRecord == false) {
              // 檢查是否有錄音權限
              if (await record.hasPermission()) {
                Directory tempDir = await getTemporaryDirectory();
                speechRecognitionAudioPath = '${tempDir.path}/record.wav';

                // 開始錄音
                await record.start(
                  numChannels: 1,
                  path: speechRecognitionAudioPath,
                  encoder: AudioEncoder.wav,
                  bitRate: 128000,
                  samplingRate: 16000,
                );

                // 更新狀態
                setState(() {
                  isRecord = true;
                  isNeedSendSpeechRecognition = false;
                });
              } else {
                debugPrint("沒有錄音權限");
              }
            } else {
              // 停止錄音
              await record.stop();

              // 釋放資源
              record.dispose();

              // 讀取錄音文件的內容
              List<int> audioBytes =
                  await File(speechRecognitionAudioPath).readAsBytesSync();

              // 更新狀態
              setState(() {
                base64String = base64Encode(audioBytes);
                isRecord = false;
                isNeedSendSpeechRecognition = true;
                // print(base64String);
              });
            }
          },
          child: Icon(
            isRecord ? Icons.mic : Icons.mic_none,
            size: 36,
          ),
        ),
      ),
    );
  }
}
