import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';

Map<String, String> get _headers {
  final token = Platform.environment['GITHUB_TOKEN'];
  return {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'token $token',
  };
}

Future<Map<String, dynamic>> fetchLatestCommit(http.Client client) async {
  final response = await client.get(
    Uri.parse(commitsEndpoint),
    headers: _headers,
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to fetch latest commit: ${response.statusCode} ${response.body}',
    );
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<String> fetchLatestCommitSha(http.Client client) async {
  final data = await fetchLatestCommit(client);
  return data['sha'] as String;
}

Future<String> fetchLatestCommitMessage(http.Client client) async {
  final data = await fetchLatestCommit(client);
  final commit = data['commit'] as Map<String, dynamic>;
  return commit['message'] as String;
}

Future<String> fetchLatestCommitDate(http.Client client) async {
  final data = await fetchLatestCommit(client);
  final commit = data['commit'] as Map<String, dynamic>;
  final committer = commit['committer'] as Map<String, dynamic>;
  return committer['date'] as String;
}

Future<List<int>> downloadZipball(http.Client client) async {
  final response = await client.get(
    Uri.parse(zipballEndpoint),
    headers: {
      ..._headers,
      'Accept': 'application/vnd.github+json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to download zipball: ${response.statusCode}',
    );
  }

  return response.bodyBytes;
}
