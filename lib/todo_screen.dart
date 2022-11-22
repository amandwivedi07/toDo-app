import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TodoScreen extends StatefulWidget {
  TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final textController = TextEditingController();
  final updateTextController = TextEditingController();

  bool editing = false;

  String? updatetextTodo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          'TO DO App',
          style: TextStyle(fontSize: 32, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Card(
              elevation: 5,
              child: SizedBox(
                height: 40,
                child: TextFormField(
                    controller: textController,
                    decoration: InputDecoration(
                        hintText: '   Type Something here...',
                        hintStyle: TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                            onPressed: () async {
                              final alert = AlertDialog(
                                content: WillPopScope(
                                  onWillPop: () async => false,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            color:
                                                Theme.of(context).primaryColor,
                                            strokeWidth: 5,
                                          ),
                                        ),
                                        SizedBox(width: 30),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Please wait...',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );

                              await addTodo(context);
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.black,
                            )))),
              ),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("todo")
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            }
            if (snapshot.data!.size == 0) {
              return const Center(
                child: Text(
                  'No Todo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool value = snapshot.data!.docs[index]['completed'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16),
                        child: SizedBox(
                          height: 80,
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: Card(
                            elevation: 5,
                            shadowColor: Colors.grey[200],
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8)),
                            ),
                            child: ListTile(
                                leading: Checkbox(
                                  value: value,
                                  onChanged: (bool? value) {
                                    FirebaseFirestore.instance
                                        .collection('todo')
                                        .doc(
                                          snapshot.data!.docs[index].id,
                                        )
                                        .update({'completed': value});
                                  },
                                ),
                                title: TextFormField(
                                  initialValue: snapshot.data!.docs[index]
                                      ['todo'],
                                  enabled: editing,
                                  onChanged: (value) => setState(() {
                                    try {
                                      updatetextTodo = value.toString();
                                    } catch (e) {
                                      updatetextTodo = '';
                                    }
                                  }),
                                  onFieldSubmitted: (String? value) {
                                    updateTodo(
                                        snapshot.data!.docs[index].id, context);
                                    setState(() {
                                      editing = false;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: SizedBox(
                                  height: 30,
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              editing = true;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          )),
                                      IconButton(
                                          onPressed: () async {
                                            (FirebaseFirestore.instance
                                                .collection('todo')
                                                .limit(1)
                                                .get()
                                                .then((snapshot) {
                                              if (snapshot.size >= 1) {
                                                final alert = AlertDialog(
                                                  content: WillPopScope(
                                                    onWillPop: () async =>
                                                        false,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 40,
                                                            height: 40,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              strokeWidth: 5,
                                                            ),
                                                          ),
                                                          SizedBox(width: 30),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'Please wait...',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                              }
                                            }));

                                            if (mounted) {
                                              await deleteTodo(
                                                  snapshot.data!.docs[index].id,
                                                  context);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                          ))
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      );
                    }));
          },
        ),
      ]),
    ));
  }

  updateTodo(String docId, context) async {
    await FirebaseFirestore.instance
        .collection('todo')
        .doc(docId)
        .update({'todo': updatetextTodo});
  }

  deleteTodo(String docId, context) async {
    await FirebaseFirestore.instance.collection('todo').doc(docId).delete();
    (FirebaseFirestore.instance
        .collection('todo')
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.size >= 1) {
        Navigator.pop(context);
      }
    }));
  }

  addTodo(context) async {
    if (textController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('todo').doc().set({
        'todo': textController.text.trim(),
        'createdAt': Timestamp.now(),
        'completed': false
      });
      textController.clear();
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoScreen(),
          ));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Add notes First",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
