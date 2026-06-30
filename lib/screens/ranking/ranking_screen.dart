import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/components/main_drawer.dart';
import 'package:sabadao/components/ranking/build_ranking_header.dart';
import 'package:sabadao/components/ranking/build_ranking_top_three.dart';
import 'package:sabadao/components/ranking/ranking_list.dart';
import 'package:sabadao/components/ranking_export_widget.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/models/player_ranking.dart';
import 'package:share_plus/share_plus.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  Future<void> _exportAsImage(List<PlayerRanking> ranking) async {
    const double exportPixelRatio = 5.0;

    final exportWidget = MediaQuery(
      data: MediaQueryData.fromView(View.of(context)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: RankingExportWidget(ranking: ranking),
      ),
    );

    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: View.of(context),
      child: RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: const BoxConstraints(maxWidth: 800),
        devicePixelRatio: exportPixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    final buildOwner = BuildOwner(focusManager: FocusManager());
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: exportWidget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(element);
    renderView.prepareInitialFrame();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: exportPixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ranking.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Ranking de artilheiros 🏆');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoutController>().loadRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
        actions: [
          Consumer<ScoutController>(
            builder: (_, ctrl, _) => IconButton(
              icon: const Icon(Icons.share_rounded, color: Color(0xFF008CFF)),
              onPressed: ctrl.isLoading || ctrl.ranking.isEmpty
                  ? null
                  : () => _exportAsImage(ctrl.ranking.toList()),
            ),
          ),
          Consumer<ScoutController>(
            builder: (_, ctrl, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF008CFF)),
              onPressed: ctrl.isLoading ? null : ctrl.loadRanking,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MainDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildRankingHeader(),
            const SizedBox(height: 8),
            BuildRankingTopThree(),
            const SizedBox(height: 12),
            RankingList(),
          ],
        ),
      ),
    );
  }
}
