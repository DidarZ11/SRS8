import 'package:flutter/material.dart';

import '../../data/models/stored_match.dart';
import 'state_views.dart';

class MatchTile extends StatelessWidget {
  const MatchTile({super.key, required this.match, required this.onTap});

  final StoredMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = match.stats;
    final win = match.isWin;
    final scheme = Theme.of(context).colorScheme;
    final resultColor = switch (win) {
      true => Colors.green.shade600,
      false => scheme.error,
      null => scheme.outline,
    };
    final myScore = s.team.toLowerCase() == 'red' ? match.teams.red : match.teams.blue;
    final theirScore = s.team.toLowerCase() == 'red' ? match.teams.blue : match.teams.red;
    final hs = s.headshotPercent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          Container(width: 6, height: 76, color: resultColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      '${match.meta.map.name} · ${s.character.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('$myScore : $theirScore',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: resultColor)),
                ]),
                const SizedBox(height: 4),
                Text(
                  'K/D/A ${s.kills}/${s.deaths}/${s.assists}'
                  '${hs != null ? ' · HS ${hs.toStringAsFixed(0)}%' : ''}'
                  ' · ${match.meta.mode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(formatDateTime(match.meta.startedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline)),
              ]),
            ),
          ),
          const Icon(Icons.chevron_right),
          const SizedBox(width: 4),
        ]),
      ),
    );
  }
}
