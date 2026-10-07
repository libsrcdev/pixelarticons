import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pixelarticons_tool/src/github_api.dart';
import 'package:test/test.dart';

void main() {
  test('archive download uses the exact inspected commit', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/repos/halfmage/pixelarticons/zipball/abc123');
      return http.Response('archive', 200);
    });
    addTearDown(client.close);
    expect(await downloadZipball(client, commitSha: 'abc123'), isNotEmpty);
  });
}
