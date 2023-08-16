import 'dart:convert';
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
