import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalLink(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    // Launch directly from the user gesture; awaiting a preflight check can
    // lose the browser's permission to open a new tab.
    opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: uri.scheme == 'mailto' ? '_self' : '_blank',
    );
  } on PlatformException {
    opened = false;
  }
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (uri.scheme == 'mailto') {
    // Browsers cannot report whether a mail handler actually opened. Always
    // offer the address and a copy action, even when launchUrl reports success.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 15),
        content: Text(
          opened
              ? 'If your mail app didn’t open, copy ${uri.path}.'
              : 'Could not open a mail app. Contact ${uri.path}.',
        ),
        action: SnackBarAction(
          label: 'Copy email',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: uri.path));
            if (!context.mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Email address copied')),
            );
          },
        ),
      ),
    );
  } else if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open the link.')),
    );
  }
}
