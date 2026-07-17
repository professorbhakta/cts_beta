import 'package:cts/appManager/colors.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OfflineOutputTab extends StatelessWidget {
  const OfflineOutputTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<OfflineTempProvider>(
      builder: (context, provider, _) {
        if (provider.errorMessage != null && !provider.isLoading) {
          return StatusMessage.error(
            title: 'Failed to load report',
            message: provider.errorMessage,
            onRetry: provider.refreshAll,
          );
        }

        final text = provider.exportText;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${provider.allCommuters.length} commuter(s) in report',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: text.isEmpty
                        ? null
                        : () => _copy(context, text),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: text.isEmpty
                        ? null
                        : () => SharePlus.instance.share(
                              ShareParams(text: text),
                            ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.acBlack.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: text.isEmpty
                    ? const Center(
                        child: Text(
                          'Apply filters on the Commuters tab,\nthen preview the report here.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          text,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report copied to clipboard')),
      );
    }
  }
}
