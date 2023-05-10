import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RandomResponse {
  final String message;
  final String status;
  const RandomResponse({
    required this.message,
    required this.status,
  });
  factory RandomResponse.fromJson(Map<String, dynamic> json) {
    return RandomResponse(
      message: json['message'],
      status: json['status'],
    );
  }
}

class BreedListResponse {
  final List<String> message;
  final String status;
  const BreedListResponse({
    required this.message,
    required this.status,
  });
  factory BreedListResponse.fromJson(Map<String, dynamic> json) {
    List<String> msgs = List<String>.from(json['message']);
    return BreedListResponse(
      message: msgs,
      status: json['status'],
    );
  }
}

class BreedImageUrlsResponse {
  final List<String> message;
  final String status;
  const BreedImageUrlsResponse({
    required this.message,
    required this.status,
  });

  factory BreedImageUrlsResponse.fromJson(Map<String, dynamic> json) {
    List<String> msgs = List<String>.from(json['message']);
    return BreedImageUrlsResponse(
      message: msgs,
      status: json['status'],
    );
  }
}

Future<RandomResponse> getRandomImageResponse() async {
  final response =
      await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
  if (response.statusCode == 200) {
    return RandomResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load RandomResponse');
  }
}

Future<BreedListResponse> getBreedListResponse() async {
  final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list'));
  if (response.statusCode == 200) {
    return BreedListResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load BreedListResponse');
  }
}

Future<BreedImageUrlsResponse> getBreedImageUrlsResponse(String breed) async {
  final url = 'https://dog.ceo/api/breed/$breed/images';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return BreedImageUrlsResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load BreedListResponse');
  }
}

void main() => runApp(const DogsApiApp());

class ScrollUpArrowIntent extends Intent {
  const ScrollUpArrowIntent();
}

class ScrollDownArrowIntent extends Intent {
  const ScrollDownArrowIntent();
}

class ScrollPageUpIntent extends Intent {
  const ScrollPageUpIntent();
}

class ScrollPageDownIntent extends Intent {
  const ScrollPageDownIntent();
}

class ScrollHomeIntent extends Intent {
  const ScrollHomeIntent();
}

class ScrollEndIntent extends Intent {
  const ScrollEndIntent();
}

class DogsApiApp extends StatefulWidget {
  const DogsApiApp({super.key});

  @override
  State<DogsApiApp> createState() => _DogsApiAppState();
}

class _DogsApiAppState extends State<DogsApiApp> {
  late Future<RandomResponse> _futureRandomResponse;
  late Future<BreedListResponse> _futureBreedListResponse;
  late Future<BreedImageUrlsResponse> _futureBreedImageUrlsResponse;
  String? _dropdownBreedValue;
  bool _showRandomImage = false;
  bool _showBreedImages = false;

  final ScrollController _controller = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureBreedListResponse = getBreedListResponse();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dogs API',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Dogs API')),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    disabledForegroundColor: Colors.yellow.withOpacity(0.38),
                  ),
                  onPressed: () {
                    setState(() {
                      _futureRandomResponse = getRandomImageResponse();
                      _showRandomImage = true;
                      _showBreedImages = false;
                    });
                  },
                  child: const Text('Get Random Image'),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('Select a breed:'),
                const SizedBox(
                  width: 5,
                ),

                // Load Breed List
                FutureBuilder<BreedListResponse>(
                  future: _futureBreedListResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButton<String>(
                        hint: const Text('Select a breed'),
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        value: _dropdownBreedValue,
                        onChanged: (String? value) {
                          setState(() {
                            _dropdownBreedValue = value!;
                            _futureBreedImageUrlsResponse =
                                getBreedImageUrlsResponse(value);
                            _showBreedImages = true;
                            _showRandomImage = false;
                          });
                        },
                        items: snapshot.data?.message
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),

            // Show Random Image
            const SizedBox(
              height: 10,
            ),
            _showRandomImage
                ? FutureBuilder<RandomResponse>(
                    future: _futureRandomResponse,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: Image.network(
                            snapshot.data!.message,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  )
                : const SizedBox(
                    height: 0,
                  ),

            // Show Breed Images
            const SizedBox(
              height: 10,
            ),
            _showBreedImages
                ? FutureBuilder<BreedImageUrlsResponse>(
                    future: _futureBreedImageUrlsResponse,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: Shortcuts(
                              shortcuts: const <ShortcutActivator, Intent>{
                                SingleActivator(LogicalKeyboardKey.arrowUp):
                                    ScrollUpArrowIntent(),
                                SingleActivator(LogicalKeyboardKey.arrowDown):
                                    ScrollDownArrowIntent(),
                                SingleActivator(LogicalKeyboardKey.pageUp):
                                    ScrollPageUpIntent(),
                                SingleActivator(LogicalKeyboardKey.pageDown):
                                    ScrollPageDownIntent(),
                                SingleActivator(LogicalKeyboardKey.home):
                                    ScrollHomeIntent(),
                                SingleActivator(LogicalKeyboardKey.end):
                                    ScrollEndIntent(),
                              },
                              child: Actions(
                                  actions: <Type, Action<Intent>>{
                                    ScrollUpArrowIntent:
                                        CallbackAction<ScrollUpArrowIntent>(
                                      onInvoke: (ScrollUpArrowIntent intent) =>
                                          setState(() {
                                        _controller.animateTo(
                                            _controller.offset - 100,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                    ScrollDownArrowIntent:
                                        CallbackAction<ScrollDownArrowIntent>(
                                      onInvoke:
                                          (ScrollDownArrowIntent intent) =>
                                              setState(() {
                                        _controller.animateTo(
                                            _controller.offset + 100,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                    ScrollPageUpIntent:
                                        CallbackAction<ScrollPageUpIntent>(
                                      onInvoke: (ScrollPageUpIntent intent) =>
                                          setState(() {
                                        _controller.animateTo(
                                            _controller.offset - 250,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                    ScrollPageDownIntent:
                                        CallbackAction<ScrollPageDownIntent>(
                                      onInvoke: (ScrollPageDownIntent intent) =>
                                          setState(() {
                                        _controller.animateTo(
                                            _controller.offset + 250,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                    ScrollHomeIntent:
                                        CallbackAction<ScrollHomeIntent>(
                                      onInvoke: (ScrollHomeIntent intent) =>
                                          setState(() {
                                        _controller.animateTo(
                                            _controller
                                                .position.minScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                    ScrollEndIntent:
                                        CallbackAction<ScrollEndIntent>(
                                      onInvoke: (ScrollEndIntent intent) =>
                                          setState(() {
                                        _controller.animateTo(
                                            _controller
                                                .position.maxScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 30),
                                            curve: Curves.ease);
                                      }),
                                    ),
                                  },
                                  child: Focus(
                                    autofocus: true,
                                    child: GridView.builder(
                                        controller: _controller,
                                        padding: const EdgeInsets.all(10),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5.0,
                                          mainAxisSpacing: 5.0,
                                        ),
                                        itemCount:
                                            snapshot.data?.message.length,
                                        itemBuilder: (context, index) {
                                          return Column(children: [
                                            Expanded(
                                              child: Image.network(
                                                snapshot.data!.message[index],
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  );
                                                },
                                              ),
                                            )
                                          ]);
                                        }),
                                    // ),
                                  ))),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  )
                : const SizedBox(
                    height: 0,
                  ),
          ]),
        ),
      ),
    );
  }
}
