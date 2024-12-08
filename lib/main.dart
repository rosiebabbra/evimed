import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evimed/directory/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allData = [];
  List<QueryDocumentSnapshot> filteredData = [];
  var colors = [
    Color.fromARGB(255, 145, 214, 236),
    Color.fromARGB(255, 228, 167, 228),
    Color(0xFF90EE90)
  ];

  void updateResults(String query) {
    setState(() {
      filteredData = allData.where((element) {
        return element['condition']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
              ]),
              const SizedBox(height: 50),
              const Text(
                'AI-powered, evidence backed wellness directory',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: MediaQuery.sizeOf(context).width * .6,
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
                        .collection('conditions')
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
                            // onTap: () {
                            //   Navigator.pushNamed(
                            //     context,
                            //     '/conditionDetail/${document['condition']}',
                            //     arguments: {'condition': document['condition']},
                            //   );
                            // },
                            child: Card(
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      document['condition'],
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
                                              // launchUrl(
                                              //     Uri.parse(document['source']));
                                            },
                                            style: ButtonStyle(
                                                backgroundColor: document[
                                                            'sourceName'] ==
                                                        'Mayo Clinic'
                                                    ? MaterialStateProperty.all(
                                                        colors[1])
                                                    : document['sourceName'] ==
                                                            'Cleveland Clinic'
                                                        ? MaterialStateProperty
                                                            .all(colors[2])
                                                        : MaterialStateProperty
                                                            .all(colors[0])),
                                            child: Text(
                                              document['sourceName'],
                                              style: TextStyle(
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
