import 'package:flutter/material.dart';

import '../../core/error/app_exception.dart';

String formatDateTime(DateTime dt) {
  final l = dt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(l.day)}.${two(l.month)}.${l.year} ${two(l.hour)}:${two(l.minute)}';
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            if (message != null) ...[const SizedBox(height: 12), Text(message!)],
          ]),
        ),
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry, this.compact = false});

  final AppException error;
  final VoidCallback? onRetry;
  final bool compact;

  IconData get _icon => switch (error) {
        NoConnectionException() => Icons.wifi_off,
        TimeoutException() => Icons.timer_off_outlined,
        ServerException() => Icons.dns_outlined,
        ParsingException() => Icons.data_object,
        _ => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    final content = Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(_icon, size: compact ? 28 : 48, color: color),
      const SizedBox(height: 8),
      Text(error.userMessage, textAlign: TextAlign.center),
      if (onRetry != null) ...[
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить'),
        ),
      ],
    ]);
    return Center(child: Padding(padding: EdgeInsets.all(compact ? 12 : 24), child: content));
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined, this.action});

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 8), action!],
          ]),
        ),
      );
}

/// Плашка «показаны кэшированные данные».
class CachedBanner extends StatelessWidget {
  const CachedBanner({super.key, required this.cachedAt, this.refreshing = false, this.error});

  final DateTime? cachedAt;
  final bool refreshing;
  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final when = cachedAt == null ? '' : ' от ${formatDateTime(cachedAt!)}';
    final offline = error != null;
    return Material(
      color: offline ? scheme.errorContainer : scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          if (refreshing)
            const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(offline ? Icons.cloud_off : Icons.history, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              offline
                  ? 'Сохранённые данные$when. ${error!.userMessage}'
                  : 'Сохранённые данные$when. Обновляем…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]),
      ),
    );
  }
}
