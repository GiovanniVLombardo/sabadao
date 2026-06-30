import 'package:flutter/material.dart';
import 'package:sabadao/components/matches/info_chip.dart';
import 'package:sabadao/components/matches/rsvp_button.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/services/attendance_service.dart';

class MatchCard extends StatefulWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.rsvp,
    this.onRsvp,
    required this.currentPlayerId,
    this.onTap,
    this.showButtons = false
  });

  final Match match;
  final bool? rsvp;
  final ValueChanged<bool>? onRsvp;
  final String currentPlayerId;
  final VoidCallback? onTap;
  final bool? showButtons;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  String _formatDate(DateTime date) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool? _rsvp;
  bool _loadingRsvp = true;
  final _attendanceService = AttendanceService();
  int _availableSpots = 18;

  @override
  void initState() {
    super.initState();
    _rsvp = widget.rsvp; // usa o valor já carregado pelo pai, se disponível
    _loadingRsvp = widget.rsvp == null; // só busca se o pai não passou
    if (_loadingRsvp) _loadRsvp();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    final spots = await _attendanceService.getAvailableSpots(widget.match.id!);
    if (mounted) setState(() => _availableSpots = spots);
  }

  Future<void> _loadRsvp() async {
    try {
      final rsvp = await _attendanceService.getPlayerRsvp(
        matchId: widget.match.id!,
        playerId: widget.currentPlayerId,
      );
      if (mounted) {
        setState(() {
          _rsvp = rsvp;
          _loadingRsvp = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRsvp = false);
    }
  }

  Future<void> _handleRsvp(bool isConfirmed) async {
    final previous = _rsvp;
    setState(() => _rsvp = isConfirmed);

    try {
      await _attendanceService.confirmPresence(
        matchId: widget.match.id!,
        playerId: widget.currentPlayerId,
        isConfirmed: isConfirmed,
      );
      _refreshSpots();
    } catch (e) {
      if (mounted) {
        setState(() => _rsvp = previous); // reverte para o valor anterior
      }
    }
  }

  void _refreshSpots() async {
    final spots = await _attendanceService.getAvailableSpots(widget.match.id!);
    if (mounted) setState(() => _availableSpots = spots);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Grupo / título ──────────────────────────────────────────────
            Text(
              'México vs EUA',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
      
            const SizedBox(height: 12),
      
            // ── Linha de informações ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(widget.match.matchDate),
                  ),
                  InfoChip(
                    icon: Icons.access_time_outlined,
                    label: _formatTime(widget.match.matchDate),
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 6),
      
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoChip(
                    icon: Icons.group_outlined,
                    label: '$_availableSpots vagas',
                  ),
                  InfoChip(
                    icon: Icons.pin_drop_outlined,
                    label: widget.match.location,
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 14),

            if(widget.showButtons!)
            Row(
              children: [
                Expanded(
                  child: RsvpButton(
                    label: 'Dentro',
                    selected: !_loadingRsvp && _rsvp == true,
                    selectedColor: const Color(0xFF34C759),
                    onTap: _loadingRsvp || _availableSpots <= 0 || _rsvp == true
                        ? () {}
                        : () => _handleRsvp(true),
                    disabled: _availableSpots <= 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RsvpButton(
                    label: 'Fora',
                    selected: !_loadingRsvp && _rsvp == false,
                    selectedColor: const Color(0xFFFF3B30),
                    onTap: _loadingRsvp || _rsvp == false
                        ? () { }
                        : () => _handleRsvp(false),
                    disabled: _availableSpots <= 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
