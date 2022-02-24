// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       // Remove the debug banner
//       debugShowCheckedModeBanner: false,
//       title: 'Home',
//       home: HomePage(),
//     );
//   }
// }

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  // text fields' controllers
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('QnA');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    bool question = true;
    if (documentSnapshot != null) {
      action = 'update';
      _questionController.text = documentSnapshot['Question'];
      _answerController.text = documentSnapshot['Answer'];
    }

    // First check whether question or paragraph
    // Default is question
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Container(
                  // decoration: BoxDecoration(color: Color.fromARGB(255, 248, 194, 190)),
                  height: 230,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
              children: <Widget>[
                IconButton(
                  icon: Image.asset('assets/question.png'),
                  iconSize: 100,
                  onPressed: () {  
        Navigator.pop(context);
        showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? question = _questionController.text;
                    final String? answer = _answerController.text;
                    if (question != null && answer != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _productss.add({"Question": question, "Answer": answer});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _productss
                            .doc(documentSnapshot!.id)
                            .update({"Question": question, "Answer": answer});
                      }

                      // Clear the text fields
                      _questionController.text = '';
                      _answerController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
                  },
                ),
                Text(
                  'Question',
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
            Column(
              children: <Widget>[
                IconButton(
                  icon: Image.asset('assets/paragraph.jpg'),
                  iconSize: 100,
                  onPressed: () {
                    Navigator.pop(context);
        showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Paragraph'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? question = _questionController.text;
                    final String? answer = '';
                    if (question != null && answer != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _productss.add({"Question": question, "Answer": answer});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _productss
                            .doc(documentSnapshot!.id)
                            .update({"Question": question, "Answer": answer});
                      }

                      // Clear the text fields
                      _questionController.text = '';
                      _answerController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
                  },
                ),
                Text(
                  'Fill in blanks',
                  style: TextStyle(fontSize: 20),
                )
              ],
            )
                    ],));
        }
    );

    
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions and Answers'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Container(
                  // decoration: BoxDecoration(color: Color.fromARGB(255, 248, 194, 190)),
                  height: 200,
                  child: Card(
                    color: Color.fromARGB(255, 252, 196, 193),
                  margin: const EdgeInsets.all(10),
                  
                  child: ListTile(
                    title: Text(documentSnapshot['Question'], style: TextStyle(fontSize: 30)),
                    subtitle: Text(documentSnapshot['Answer'], style: TextStyle(fontSize: 15)),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                ));
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}