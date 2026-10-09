import 'package:example/external_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final launchSucceeds in [true, false]) {
    testWidgets('email can be copied when launch returns $launchSucceeds', (
      tester,
    ) async {
      const address = 'pixelarticons@libsrc.dev';
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      String? launched;
      String? copied;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        launched = (call.arguments as Map)['url'] as String;
        return launchSucceeds;
      });
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(channel, null);
        messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    openExternalLink(context, Uri.parse('mailto:$address')),
                child: const Text(address),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text(address));
      await tester.pumpAndSettle();
      expect(launched, 'mailto:$address');
      expect(find.textContaining(address), findsNWidgets(2));
      await tester.tap(find.text('Copy email'));
      await tester.pumpAndSettle();
      expect(copied, address);
      expect(find.text('Email address copied'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
