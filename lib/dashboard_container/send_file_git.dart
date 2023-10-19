import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> uploadPdfToGitHub(
    String token, String owner, String repo, String filePath) async {
  final File file = File("C:/Users/goku1/Downloads/cash.png");
  if (!file.existsSync()) {
    print('File does not exist');
    return;
  }

  final List<int> fileBytes = await file.readAsBytes();

  final response = await http.put(
    Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$filePath'),
    headers: {
      'Authorization': 'token $token', // Replace with your GitHub token
    },
    body: jsonEncode({
      'message': 'Upload PDF',
      'content': base64Encode(fileBytes),
    }),
  );

  if (response.statusCode == 201) {
    print('File successfully uploaded');
  } else {
    // Handle errors
    print('Failed to upload PDF. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
