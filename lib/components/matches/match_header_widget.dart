import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sabadao/utils/globals.dart';
import 'package:sabadao/models/match.dart';

Widget matchHeaderWidget(BuildContext context, Match match) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  Globals.statusLabel(match.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Globals.statusColor(match.status),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat("EEEE, dd/MM/yyyy", 'pt_BR').format(match.matchDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                DateFormat("HH:mm", 'pt_BR').format(match.matchDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  match.location,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }