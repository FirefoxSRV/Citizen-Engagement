import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBBNYQr3nvr2fHeG_qqN4yEWqza4kit53Q',
        appId: '1:955380141521:android:8bce4331a03ed8904c24f0',
        messagingSenderId: '955380141521',
        projectId: 'iot-project-dc972',
        storageBucket: 'iot-project-dc972.appspot.com',
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('data');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      List<dynamic> newItems = [];
      snapshot.children.forEach((child) {
        newItems.add(child.value);
      });
      setState(() {
        items = newItems;
      });
    } else {
      setState(() {
        items = [];
      });
    }
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add New Entry'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Enter title"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Enter description"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addDataToFirebase();
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                _refreshList();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDataToFirebase() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('data').push();
    await ref.set({
      'title': titleController.text,
      'description': descriptionController.text
    });
    titleController.clear();
    descriptionController.clear();

  }

  Future<void> _refreshList() async {
    await fetchData();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),child: Icon(Icons.add),),
      appBar: AppBar(
          title: Text("Citizen Engagement",style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),)
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return Card(
              child: ListTile(
                title: Text(item['title']),
                subtitle: Text(item['description']),
              ),
            );
          },
        ),
      ),
    );
  }
}


