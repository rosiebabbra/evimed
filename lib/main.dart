import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evimed/directory/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'evimed',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: const Text('Home')),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: const Text('About')),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: const Text('Login')),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black)),
                    child: const Text('Sign Up')),
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
                      width: 450,
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
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/conditionDetail/${document['condition']}',
                                arguments: {'condition': document['condition']},
                              );
                            },
                            child: SizedBox(
                              height: 100,
                              child: Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    document['condition'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
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
