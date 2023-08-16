import 'package:flutter/material.dart';

import './dogs_api.dart';

void main() => runApp(
      MaterialApp(
        title: 'Dogs API',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const DogsApiApp(),
      ),
    );
