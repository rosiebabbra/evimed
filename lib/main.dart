import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evimed/directory/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: const String.fromEnvironment('API_KEY'),
    authDomain: const String.fromEnvironment('AUTH_DOMAIN'),
    projectId: const String.fromEnvironment('PROJECT_ID'),
    storageBucket: const String.fromEnvironment('STORAGE_BUCKET'),
    messagingSenderId: const String.fromEnvironment('MESSAGING_SENDER_ID'),
    appId: const String.fromEnvironment('APP_ID'),
    measurementId: const String.fromEnvironment('MEASUREMENT_ID'),
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evimed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Montserrat'),
      home: const MyHomePage(title: 'Evimed'),
      onGenerateRoute: (settings) {
        // Handle dynamic route generation
        if (settings.name != null &&
            settings.name!.startsWith('/conditionDetail/')) {
          final condition =
              settings.name!.replaceFirst('/conditionDetail/', '');
          return MaterialPageRoute(
            builder: (context) => ConditionDetailPage(condition: condition),
          );
        }

        // Default home route
        return MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Evimed'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Mixpanel? mixpanel;
  bool mixPanelIsLoading = true;
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allData = [];
  List<QueryDocumentSnapshot> filteredData = [];
  var colors = [
    const Color.fromARGB(255, 145, 214, 236),
    const Color.fromARGB(255, 228, 167, 228),
    const Color(0xFF90EE90)
  ];

  @override
  void initState() {
    super.initState();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("248788f6c59eef61f948039194eb6b07",
        trackAutomaticEvents: true);
    setState(() {
      mixPanelIsLoading = false; // Mark initialization as complete
    });
  }

  void updateResults(String query) {
    setState(() {
      filteredData = allData.where((element) {
        return element['Condition']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (mixPanelIsLoading) {
      return CircularProgressIndicator(); // Show loading UI
    } else {
      mixpanel!.track('Page Visit');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 35.0),
                  child: Text(
                    'evimed',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              MediaQuery.sizeOf(context).width >= 680
                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          child: const Text(
                            'Home',
                            style: TextStyle(fontSize: 16),
                          )),
                      TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          child: const Text(
                            'About',
                            style: TextStyle(fontSize: 16),
                          )),
                      TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          )),
                      const SizedBox(width: 5),
                      TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 253, 165, 195)),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.black)),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16),
                            ),
                          )),
                      const SizedBox(width: 35)
                    ])
                  : Container(),
              const SizedBox(height: 50),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'AI-powered, evidence backed wellness directory',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize:
                            MediaQuery.sizeOf(context).width >= 680 ? 20 : 18),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: MediaQuery.sizeOf(context).width >= 680
                          ? MediaQuery.sizeOf(context).width * .6
                          : MediaQuery.sizeOf(context).width * .85,
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) {
                          updateResults(value);
                        },
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(29))),
                          hintText: 'Search here',
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 35),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 25),
                  const Text(
                    'Conditions',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    filteredData.isNotEmpty
                        ? filteredData.length.toString()
                        : '50',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w100),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: SizedBox(
                  height: 500,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('conditions_v3')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }

                      // Update allData and filteredData lists
                      allData = snapshot.data!.docs;
                      filteredData = filteredData.isEmpty
                          ? allData
                          : filteredData; // To show all results initially

                      return ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final document = filteredData[index];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext buildContext) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      content: SizedBox(
                                        height: 500,
                                        width: 500,
                                        child: SelectableText(
                                          filteredData[index]
                                              ['Parsed_Interactions'],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Card(
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      document['Condition'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      ((document.data()
                                                      as Map<String, dynamic>?)
                                                  ?.containsKey('desc') ??
                                              false)
                                          ? (document.data()
                                              as Map<String, dynamic>)['desc']
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ((document.data() as Map<String, dynamic>?)
                                                ?.containsKey('sourceName') ??
                                            false)
                                        ? TextButton(
                                            onPressed: () {
                                              mixpanel!.track(
                                                  'Source Page Visit',
                                                  properties: {
                                                    'Condition Name':
                                                        document['Condition']
                                                  });

                                              launchUrl(
                                                  Uri.parse(document['source']),
                                                  webOnlyWindowName: '_blank');
                                            },
                                            style: ButtonStyle(
                                                backgroundColor: document[
                                                            'sourceName'] ==
                                                        'Mayo Clinic'
                                                    ? MaterialStateProperty.all(
                                                        colors[0])
                                                    : document['sourceName'] ==
                                                            'Cleveland Clinic'
                                                        ? MaterialStateProperty
                                                            .all(colors[2])
                                                        : MaterialStateProperty
                                                            .all(colors[1])),
                                            child: Text(
                                              document['sourceName'],
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ))
                                        : Container()
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
