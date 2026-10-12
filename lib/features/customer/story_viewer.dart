import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../app_state.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import 'customer_home.dart';
import 'customer_shell.dart';
import 'restaurant_page.dart';

/// Stories d'un restaurant (regroupées comme sur Facebook).
class StoryGroup {
  StoryGroup(this.branchId, this.brandName, this.logoPath, this.posts);
  final String branchId;
  final String brandName;
  final String? logoPath;
  final List<FeedPost> posts;
}

/// Regroupe les contenus par restaurant, dans l'ordre d'arrivée.
List<StoryGroup> groupStories(List<FeedPost> posts) {
  final map = <String, StoryGroup>{};
  for (final p in posts) {
    map.putIfAbsent(p.branchId, () => StoryGroup(p.branchId, p.brandName, p.logoPath, [])).posts.add(p);
  }
  return map.values.toList();
}

/// Une « page » de story : une photo, une vidéo, ou une annonce texte.
class _Segment {
  _Segment(this.post, {this.image, this.dishImage, this.video});
  final FeedPost post;
  final String? image;
  final String? dishImage;
  final String? video;
}

List<_Segment> _segmentsFor(FeedPost p) {
  if (p.video != null) return [_Segment(p, video: p.video!.$1)];
  if (p.images.isNotEmpty) return [for (final i in p.images) _Segment(p, image: i)];
  final dishes = [
    for (final i in p.items)
      if (i.$3 != null) i.$3!,
  ];
  if (dishes.isNotEmpty) return [for (final d in dishes) _Segment(p, dishImage: d)];
  return [_Segment(p)];
}

/// Lecteur plein écran : un restaurant par page (glisser pour changer), ses
/// stories l'une après l'autre avec les barres de progression en haut.
class StoryGroupViewer extends StatefulWidget {
  const StoryGroupViewer({super.key, required this.groups, required this.initial, this.onSeen});
  final List<StoryGroup> groups;
  final int initial;
  final ValueChanged<String>? onSeen;

  @override
  State<StoryGroupViewer> createState() => _StoryGroupViewerState();
}

class _StoryGroupViewerState extends State<StoryGroupViewer> {
  late final PageController _page = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < widget.groups.length - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _previous() {
    if (_index > 0) _page.previousPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Glisser vers le bas pour fermer.
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 400) Navigator.pop(context);
        },
        child: PageView.builder(
          controller: _page,
          itemCount: widget.groups.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => _StoryPlayer(
            key: ValueKey(widget.groups[i].branchId),
            group: widget.groups[i],
            active: i == _index,
            onDone: _next,
            onBeforeStart: _previous,
            onSeen: widget.onSeen,
          ),
        ),
      ),
    );
  }
}

class _StoryPlayer extends StatefulWidget {
  const _StoryPlayer({
    super.key,
    required this.group,
    required this.active,
    required this.onDone,
    required this.onBeforeStart,
    this.onSeen,
  });
  final StoryGroup group;
  final bool active;
  final VoidCallback onDone;
  final VoidCallback onBeforeStart;
  final ValueChanged<String>? onSeen;

  @override
  State<_StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<_StoryPlayer> with SingleTickerProviderStateMixin {
  late final List<_Segment> _segments = [for (final p in widget.group.posts) ..._segmentsFor(p)];
  late final AnimationController _progress = AnimationController(vsync: this, duration: const Duration(seconds: 5))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _forward();
    });
  int _current = 0;
  VideoPlayerController? _video;
  final Set<String> _viewed = {};

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(_StoryPlayer old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _start();
    } else if (!widget.active && old.active) {
      _progress.stop();
      _video?.pause();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _video?.dispose();
    super.dispose();
  }

  _Segment get _seg => _segments[_current];

  Future<void> _start() async {
    final seg = _seg;
    final p = seg.post;
    if (!p.isDish && _viewed.add(p.id)) AppScope.read(context).api!.customer.recordFeedView(p.id);
    widget.onSeen?.call(widget.group.branchId);
    _progress.stop();
    _progress.value = 0;
    final old = _video;
    _video = null;
    old?.dispose();
    if (seg.video != null) {
      final c = VideoPlayerController.networkUrl(Uri.parse(AppScope.read(context).api!.customer.adMediaUrl(seg.video!)));
      setState(() => _video = c);
      try {
        await c.initialize();
        if (!mounted || _video != c) return;
        final d = c.value.duration;
        _progress.duration = d.inMilliseconds > 0 ? d : const Duration(seconds: 15);
        await c.play();
        setState(() {});
        _progress.forward(from: 0);
      } catch (_) {
        _progress.duration = const Duration(seconds: 5);
        _progress.forward(from: 0);
      }
    } else {
      _progress.duration = const Duration(seconds: 5);
      setState(() {});
      _progress.forward(from: 0);
    }
  }

  void _forward() {
    if (_current < _segments.length - 1) {
      setState(() => _current++);
      _start();
    } else {
      widget.onDone();
    }
  }

  void _back() {
    if (_current > 0) {
      setState(() => _current--);
      _start();
    } else {
      widget.onBeforeStart();
    }
  }

  void _pause() {
    _progress.stop();
    _video?.pause();
  }

  void _resume() {
    _progress.forward();
    _video?.play();
  }

  void _openRestaurant({String? itemId}) {
    final p = _seg.post;
    final api = AppScope.read(context).api!.customer;
    if (!p.isDish) {
      api.recordAd(p.id, 'click');
      CustomerScope.cart(context).adSource[p.branchId] = p.id;
    }
    final scope = CustomerScope.of(context);
    _pause();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(
          cart: scope.notifier!,
          openTab: scope.openTab,
          child: RestaurantPage(branchId: p.branchId, openItemId: itemId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final seg = _seg;
    final p = seg.post;
    Widget media;
    if (seg.video != null) {
      final c = _video;
      media = c == null || !c.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: RestoColors.primaryBright))
          : Center(
              child: AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)),
            );
    } else if (seg.image != null) {
      media = NetImage(api.adMediaUrl(seg.image!), fit: BoxFit.contain);
    } else if (seg.dishImage != null) {
      media = NetImage(api.imageUrl(seg.dishImage!), fit: BoxFit.contain);
    } else {
      media = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2B2014), Color(0xFF5A4318)]),
        ),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign_rounded, color: RestoColors.primaryBright, size: 44),
            const SizedBox(height: 16),
            Text(
              p.title,
              textAlign: TextAlign.center,
              style: serifTitle(context, size: 34, color: RestoColors.primaryBright),
            ),
            if (p.body != null && p.body!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                p.body!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
              ),
            ],
          ],
        ),
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black, child: media),
        // Toucher à gauche / à droite, appui long pour mettre en pause.
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (d) => d.localPosition.dx < width / 3 ? _back() : _forward(),
          onLongPressStart: (_) => _pause(),
          onLongPressEnd: (_) => _resume(),
        ),
        // Dégradés haut et bas pour la lisibilité.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.18, 0.7, 1],
                colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xCC000000)],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // Barres de progression.
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, _) => Row(
                    children: [
                      for (var i = 0; i < _segments.length; i++)
                        Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)),
                            child: FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: i < _current ? 1 : (i == _current ? _progress.value : 0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Restaurant, mention sponsorisée, fermeture.
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 0),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: RestoColors.primaryBright, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.group.logoPath == null
                          ? const Icon(Icons.restaurant_rounded, size: 18, color: RestoColors.primaryDeep)
                          : NetImage(api.logoUrl(widget.group.logoPath!), fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.group.brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          if (p.sponsored) Text(t.adSponsored, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Texte et bouton d'action.
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (seg.video != null || seg.image != null || seg.dishImage != null) ...[
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: serifTitle(context, size: 24, color: Colors.white),
                      ),
                      if (p.body != null && p.body!.trim().isNotEmpty)
                        Text(
                          p.body!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                        ),
                      const SizedBox(height: 12),
                    ],
                    Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: RestoColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _openRestaurant(itemId: p.items.length == 1 ? p.items.first.$1 : null),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: Text(p.ctaLabel ?? t.feedOrder, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
