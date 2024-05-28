import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futterproj/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 8.0), // Add some spacing between the fields
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.0), // Add some spacing between the fields
        Row(            mainAxisAlignment: MainAxisAlignment.center, // Center row contents horizontally
            children: <Widget>[ ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
            var userDoc;
                // Fetch the user document with the specific ID
                try {
                   userDoc = await _db.collection('users')
                      .doc(username)
                      .get();
                }catch(e){

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter Username and password'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if (!userDoc.exists) {
                  print('No user found for that username.');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Username Not found, Please register'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                  return;
                }

                // If the document exists, check if the password matches
                String storedPassword = userDoc.get('Password');
                if (storedPassword == password) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExamplePage()),
                  );
                } else {

                  print('Incorrect password.');

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Incorrect Password.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
              },
              child: Text('LogIn'),
            ), SizedBox(width: 8.0),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );


              },
              child: Text('Register?'),
            ),
            ],
        ),
          ],
        ),
      ),
    );
  }
}


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 8.0), // Add some spacing between the fields
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.0), // Add some spacing between the fields
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                var users;
                // Check if username already exists in database
                try {
                   users = await _db.collection('users').where(
                      'Username', isEqualTo: username).get();
                }catch(e){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter Username and password'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;


                }

                if (users.docs.isNotEmpty) {
                  print('Username already exists.');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Username already exists.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;


                }

                // If username does not exist, create a new user document
                try{
                await _db.collection('users').doc(username).set({
                  'Username': username,
                  'Password': password,
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('Username Registered.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );



                }catch(e){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please Enter username and password'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                }
                print('User registered successfully.');
                return;

              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}









class ExamplePage extends StatefulWidget {
  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool isLoading = false;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'ChatGPT APP',
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return IconButton(
      icon: Icon(Icons.send),
      color: Colors.white,
      onPressed: () async {
        String currentText = _textController.text
            .trim(); // Trim to remove leading/trailing whitespaces

        if (currentText.isNotEmpty) {
          // Use the ChatApi class to get ChatGPT's response
          String assistantResponse = await getResponse(context, currentText);  //ChatApi().completeChat(_messages);

          setState(() {
            // Add the user message to the _messages list
            _messages.add(ChatMessage(currentText, true));
            // Add ChatGPT's response to the _messages list
            _messages.add(ChatMessage(assistantResponse, false));
          });

          _textController.clear();

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: Colors.blue,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];

        bool isUserMessage = message.isUserMessage;

        return ListTile(
          title: Align(
            alignment:
            isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isUserMessage ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message.content,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}


  ChatApi() {
    var apiKey = "";
    var Endpoint = "";
    var model = 'gpt-3.5-turbo';
    }
Future<String> getResponse(BuildContext context, String message) async {
  final url = Uri.parse('ENDPOINT');
  final headers = {
    'Authorization': 'Bearer [API_KEY]',
    'Content-Type': 'application/json',
  };

  final data = jsonEncode({
    "model": "MODEL_NAME",
    "max_tokens": 300,
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": message
      }
    ]
  });

  try {
    final response = await http.post(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      print('Status Code: ${response.statusCode}');
      print('Response Content:');
      print(response.body);
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Extract the assistant's message
      String assistantMessage = responseBody['choices'][0]['message']['content'];

      return assistantMessage;
    } else {
      throw Exception('Failed to load response');
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return 'Error occurred: ${e.toString()}';
  }
}


class ChatMessage {
  ChatMessage(this.content, this.isUserMessage);

  final String content;
  final bool isUserMessage;
  }


