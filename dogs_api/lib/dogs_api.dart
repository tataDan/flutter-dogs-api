import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dogs_api_http.dart';

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

  final ScrollController _scrollController = ScrollController();
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
    return Scaffold(
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
                        child: CallbackShortcuts(
                          bindings: <ShortcutActivator, VoidCallback>{
                            const SingleActivator(LogicalKeyboardKey.arrowUp):
                                () {
                              _scrollController.animateTo(
                                  _scrollController.offset - 100,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                            const SingleActivator(LogicalKeyboardKey.arrowDown):
                                () {
                              _scrollController.animateTo(
                                  _scrollController.offset + 100,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                            const SingleActivator(LogicalKeyboardKey.pageUp):
                                () {
                              _scrollController.animateTo(
                                  _scrollController.offset - 250,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                            const SingleActivator(LogicalKeyboardKey.pageDown):
                                () {
                              _scrollController.animateTo(
                                  _scrollController.offset + 250,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                            const SingleActivator(LogicalKeyboardKey.home): () {
                              _scrollController.animateTo(
                                  _scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                            const SingleActivator(LogicalKeyboardKey.end): () {
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 30),
                                  curve: Curves.ease);
                            },
                          },
                          child: Focus(
                            autofocus: true,
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(10),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                              ),
                              itemCount: snapshot.data?.message.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        snapshot.data!.message[index],
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const SizedBox(
                                            height: 0,
                                            width: 0,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
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
        ]),
      ),
    );
  }
}
