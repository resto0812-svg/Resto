import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../branches/online_tab.dart' show branchPublicUrl;
import 'customer_home.dart';
import 'customer_shell.dart';
import 'reservation_sheet.dart';
import 'story_viewer.dart';

/// Lien à partager pour un contenu du fil (page publique du restaurant ou lien du contenu).
String feedShareUrl(FeedPost p) => p.ctaUrl ?? branchPublicUrl(p.branchId);

/// Fil « Découvrir » : vidéos, carrousels, stories, plats mis en avant et
/// annonces des restaurants, en plein écran, à faire défiler verticalement.
class CustomerDiscover extends StatefulWidget {
  const CustomerDiscover({super.key, required this.visible});

  /// Onglet affiché : les vidéos ne jouent que lorsqu'il est visible.
  final bool visible;

  @override
  State<CustomerDiscover> createState() => _CustomerDiscoverState();
}

class _CustomerDiscoverState extends State<CustomerDiscover> {
  final _page = PageController();
  final List<FeedPost> _posts = [];
  final Set<String> _seen = {};
  bool _loading = true;
  bool _done = false;
  bool _failed = false;
  int _index = 0;
  int _adOffset = 0;
  String? _city;

  @override
  void initState() {
    super.initState();
    _city = customerCity.value;
    customerCity.addListener(_cityChanged);
    _more();
  }

  @override
  void dispose() {
    customerCity.removeListener(_cityChanged);
    _page.dispose();
    super.dispose();
  }

  void _cityChanged() {
    if (customerCity.value == _city) return;
    _city = customerCity.value;
    _reload();
  }

  void _reload() {
    setState(() {
      _posts.clear();
      _adOffset = 0;
      _done = false;
      _index = 0;
    });
    if (_page.hasClients) _page.jumpToPage(0);
    _more();
  }

  Future<void> _more() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final api = AppScope.read(context).api!.customer;
      final list = await api.feed(city: _city, offset: _adOffset);
      // Plats des restaurants (photos) mêlés aux contenus publicitaires : le fil n'est jamais vide.
      final dishes = <FeedPost>[];
      if (_adOffset == 0) {
        final home = await api.home(city: _city).catchError((_) => PublicHome.fromJson(const {}));
        final seen = <String>{};
        for (final i in [...home.popular, ...home.newItems]) {
          if (i.imagePath != null && seen.add(i.itemId)) dishes.add(FeedPost.dish(i));
        }
      }
      if (!mounted) return;
      setState(() {
        _adOffset += list.length;
        final fresh = list.where((p) => !_posts.any((x) => x.id == p.id)).toList();
        // Deux contenus, un plat, deux contenus, un plat…
        var d = 0;
        for (var i = 0; i < fresh.length; i++) {
          _posts.add(fresh[i]);
          if (i % 2 == 1 && d < dishes.length) _posts.add(dishes[d++]);
        }
        _posts.addAll(dishes.skip(d));
        _done = list.length < 12;
        _loading = false;
      });
      if (_posts.isNotEmpty) _view(_index);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _view(int i) {
    if (!widget.visible || i >= _posts.length) return;
    final p = _posts[i];
    if (!p.isDish && _seen.add(p.id)) AppScope.read(context).api!.customer.recordFeedView(p.id);
  }

  @override
  void didUpdateWidget(CustomerDiscover old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _view(_index);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 700;
    Widget body;
    if (_posts.isEmpty && _loading) {
      body = const Center(child: CircularProgressIndicator(color: RestoColors.primaryBright));
    } else if (_posts.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoldIcon(Icons.play_circle_outline_rounded, size: 72, filled: true),
              const SizedBox(height: 16),
              Text(
                t.feedEmpty,
                textAlign: TextAlign.center,
                style: serifTitle(context, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 6),
              if (!_failed)
                Text(
                  t.feedEmptyHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 16),
              GoldButton(label: t.retry, icon: Icons.refresh_rounded, expand: false, onPressed: () async => _reload()),
            ],
          ),
        ),
      );
    } else {
      body = PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        onPageChanged: (i) {
          setState(() => _index = i);
          _view(i);
          if (!_done && !_loading && i >= _posts.length - 3) _more();
        },
        itemBuilder: (context, i) => FeedPostView(post: _posts[i], active: widget.visible && i == _index),
      );
    }
    final frame = Stack(
      fit: StackFit.expand,
      children: [
        body,
        // En-tête : titre, ville, actualiser.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 8, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xAA000000), Color(0x00000000)],
              ),
            ),
            child: Row(
              children: [
                Text(t.customerDiscover, style: serifTitle(context, size: 26, color: Colors.white)),
                const SizedBox(width: 10),
                if (_city != null)
                  Flexible(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: RestoColors.primaryBright),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _city!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (_city != null) const Spacer(),
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return ColoredBox(
      color: wide ? RestoColors.base : const Color(0xFF14100B),
      child: wide
          ? Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14100B),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: RestoColors.softShadow(18),
                    ),
                    child: frame,
                  ),
                ),
              ),
            )
          : frame,
    );
  }
}

/// Un contenu du fil en plein écran.
class FeedPostView extends StatefulWidget {
  const FeedPostView({super.key, required this.post, required this.active});
  final FeedPost post;
  final bool active;

  @override
  State<FeedPostView> createState() => _FeedPostViewState();
}

class _FeedPostViewState extends State<FeedPostView> with SingleTickerProviderStateMixin {
  FeedPost get p => widget.post;
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  int _slide = 0;

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  Future<void> _like({bool fromDoubleTap = false}) async {
    if (p.isDish) return;
    if (fromDoubleTap) _burst.forward(from: 0);
    if (fromDoubleTap && p.liked) return;
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    final before = (p.liked, p.likes);
    setState(() {
      p.liked = !p.liked;
      p.likes += p.liked ? 1 : -1;
    });
    try {
      final (liked, likes) = await AppScope.read(context).api!.customer.toggleFeedLike(p.id);
      if (mounted) {
        setState(() {
          p.liked = liked;
          p.likes = likes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        p.liked = before.$1;
        p.likes = before.$2;
      });
      showError(context, e);
    }
  }

  Future<void> _save() async {
    final t = context.t;
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    try {
      final (saved, saves) = await AppScope.read(context).api!.customer.toggleFeedSave(p.id);
      if (!mounted) return;
      setState(() {
        p.saved = saved;
        p.saves = saves;
      });
      showInfo(context, saved ? t.feedSaved : t.feedUnsaved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _share() async {
    final t = context.t;
    await Clipboard.setData(ClipboardData(text: feedShareUrl(p)));
    if (!mounted) return;
    if (!p.isDish) {
      AppScope.read(context).api!.customer.recordFeedShare(p.id);
      setState(() => p.shares++);
    }
    showInfo(context, t.feedLinkCopied);
  }

  Future<void> _comments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FeedCommentsSheet(
        post: p,
        onCount: (n) {
          if (mounted) setState(() => p.comments = n);
        },
      ),
    );
  }

  /// Action vers le restaurant : comptée comme un clic, et la commande éventuelle est rattachée au contenu.
  void _go({String? itemId}) {
    final api = AppScope.read(context).api!.customer;
    if (!p.isDish) {
      api.recordAd(p.id, 'click');
      CustomerScope.cart(context).adSource[p.branchId] = p.id;
    }
    openRestaurant(context, p.branchId, itemId: itemId);
  }

  Future<void> _reserve() async {
    if (!p.isDish) AppScope.read(context).api!.customer.recordAd(p.id, 'click');
    await requestTableReservation(context, branchId: p.branchId, restaurantName: p.brandName);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final video = p.video;
    final images = p.images;
    Widget background;
    if (p.isDish) {
      background = NetImage(p.media.isEmpty ? null : api.imageUrl(p.media.first.$1));
    } else if (video != null) {
      background = _FeedVideo(
        url: api.adMediaUrl(video.$1),
        active: widget.active,
        poster: images.firstOrNull == null ? null : api.adMediaUrl(images.first),
      );
    } else if (images.isNotEmpty) {
      background = PageView.builder(
        itemCount: images.length,
        onPageChanged: (i) => setState(() => _slide = i),
        itemBuilder: (_, i) => NetImage(api.adMediaUrl(images[i])),
      );
    } else if (p.items.any((i) => i.$3 != null)) {
      final withPhoto = p.items.where((i) => i.$3 != null).toList();
      background = PageView.builder(
        itemCount: withPhoto.length,
        onPageChanged: (i) => setState(() => _slide = i),
        itemBuilder: (_, i) => NetImage(api.imageUrl(withPhoto[i].$3!)),
      );
    } else {
      background = _ClassifiedBackground(post: p);
    }
    final slides = p.isDish || video != null ? 0 : (images.isNotEmpty ? images.length : p.items.where((i) => i.$3 != null).length);
    final hasCover = p.isDish || video != null || slides > 0;

    return GestureDetector(
      onDoubleTap: () => _like(fromDoubleTap: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: const Color(0xFF14100B), child: background),
          // Dégradé pour la lisibilité du texte.
          if (hasCover)
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.45, 1],
                    colors: [Color(0x00000000), Color(0x22000000), Color(0xDD000000)],
                  ),
                ),
              ),
            ),
          // Barres de progression du carrousel.
          if (slides > 1)
            Positioned(
              left: 14,
              right: 14,
              top: 64,
              child: Row(
                children: [
                  for (var i = 0; i < slides; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i == _slide ? RestoColors.primaryBright : Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Cœur au double appui.
          Center(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _burst,
                builder: (_, _) {
                  final v = _burst.value;
                  if (v == 0 || v == 1) return const SizedBox.shrink();
                  final scale = v < 0.3 ? v / 0.3 * 1.2 : 1.2 - (v - 0.3) * 0.3;
                  return Opacity(
                    opacity: v < 0.7 ? 1 : (1 - v) / 0.3,
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 120,
                        color: RestoColors.primaryBright,
                        shadows: [Shadow(blurRadius: 24)],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Actions à droite.
          PositionedDirectional(
            end: 10,
            bottom: 190,
            child: Column(
              children: [
                if (!p.isDish) ...[
                  if (p.views > 0)
                    _RailButton(icon: Icons.visibility_outlined, label: _compact(context, p.views), tooltip: t.adViews(p.views)),
                  _RailButton(
                    icon: p.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: p.liked ? RestoColors.primaryBright : Colors.white,
                    label: _compact(context, p.likes),
                    tooltip: t.feedLike,
                    onTap: _like,
                  ),
                  _RailButton(
                    icon: Icons.mode_comment_outlined,
                    label: _compact(context, p.comments),
                    tooltip: t.commentsTitle,
                    onTap: _comments,
                  ),
                  _RailButton(
                    icon: p.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: p.saved ? RestoColors.primaryBright : Colors.white,
                    label: _compact(context, p.saves),
                    tooltip: t.feedSave,
                    onTap: _save,
                  ),
                ],
                _RailButton(icon: Icons.reply_rounded, flip: true, label: _compact(context, p.shares), tooltip: t.feedShare, onTap: _share),
              ],
            ),
          ),
          // Restaurant, texte et boutons.
          PositionedDirectional(
            start: 16,
            end: 76,
            bottom: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _go,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        child: p.logoPath == null
                            ? const Icon(Icons.restaurant_rounded, size: 18, color: RestoColors.primaryDeep)
                            : NetImage(api.logoUrl(p.logoPath!), fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          p.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      if (p.sponsored) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: RestoColors.primary, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            t.adSponsored,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasCover) ...[
                  const SizedBox(height: 10),
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: serifTitle(context, size: 26, color: RestoColors.primaryBright),
                  ),
                  if (p.isDish && p.priceMinor != null && p.currency != null)
                    Text(
                      Money(p.priceMinor!, p.currency!).format(Localizations.localeOf(context).toString(), minorUnitOf(p.currency!)),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  if (p.body != null && p.body!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      p.body!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.35),
                    ),
                  ],
                ],
                if (p.items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: p.items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => _GlassChip(
                        icon: Icons.restaurant_menu_rounded,
                        label: p.items[i].$2,
                        onTap: () => _go(itemId: p.items[i].$1),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FeedAction(
                      label: p.ctaLabel ?? t.feedOrder,
                      icon: Icons.shopping_bag_outlined,
                      primary: true,
                      onTap: () {
                        if (p.ctaUrl != null && p.items.isEmpty) {
                          api.recordAd(p.id, 'click');
                          openLink(p.ctaUrl!);
                        } else {
                          _go(itemId: p.items.length == 1 ? p.items.first.$1 : null);
                        }
                      },
                    ),
                    if (p.items.length == 1)
                      _FeedAction(
                        label: t.feedViewDish,
                        icon: Icons.ramen_dining_outlined,
                        onTap: () => _go(itemId: p.items.first.$1),
                      ),
                    _FeedAction(label: t.feedViewRestaurant, icon: Icons.storefront_outlined, onTap: _go),
                    if (p.acceptsReservations) _FeedAction(label: t.reserveTable, icon: Icons.event_seat_outlined, onTap: _reserve),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _compact(BuildContext context, int n) =>
    n == 0 ? '' : NumberFormat.compact(locale: Localizations.localeOf(context).toString()).format(n);

/// Fond d'une petite annonce sans média : grand titre or sur fond sombre.
class _ClassifiedBackground extends StatelessWidget {
  const _ClassifiedBackground({required this.post});
  final FeedPost post;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2B2014), Color(0xFF14100B), Color(0xFF3A2A12)],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(28, 90, 80, 260),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.campaign_rounded, color: RestoColors.primaryBright, size: 40),
        const SizedBox(height: 14),
        Container(width: 54, height: 3, color: RestoColors.primary),
        const SizedBox(height: 18),
        Text(post.title, style: serifTitle(context, size: 38, color: RestoColors.primaryBright)),
        if (post.body != null && post.body!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            post.body!,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
          ),
        ],
      ],
    ),
  );
}

/// Vidéo en boucle : joue quand le contenu est à l'écran, muette par défaut (lecture automatique autorisée partout).
class _FeedVideo extends StatefulWidget {
  const _FeedVideo({required this.url, required this.active, this.poster});
  final String url;
  final bool active;
  final String? poster;

  @override
  State<_FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<_FeedVideo> {
  late final VideoPlayerController _c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  bool _ready = false;
  bool _muted = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _c
        .initialize()
        .then((_) async {
          if (!mounted) return;
          await _c.setLooping(true);
          await _c.setVolume(0);
          setState(() => _ready = true);
          _sync();
        })
        .catchError((_) {
          if (mounted) setState(() => _failed = true);
        });
  }

  @override
  void didUpdateWidget(_FeedVideo old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    if (!_ready) return;
    widget.active ? _c.play() : _c.pause();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poster = widget.poster == null ? const SizedBox.shrink() : NetImage(widget.poster);
    if (_failed) return poster;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_ready) ...[poster, const Center(child: CircularProgressIndicator(color: RestoColors.primaryBright))],
        if (_ready)
          GestureDetector(
            onTap: () => setState(() => _c.value.isPlaying ? _c.pause() : _c.play()),
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(width: _c.value.size.width, height: _c.value.size.height, child: VideoPlayer(_c)),
            ),
          ),
        if (_ready)
          Positioned(
            right: 12,
            top: 104,
            child: Material(
              color: Colors.black38,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () async {
                  await _c.setVolume(_muted ? 1 : 0);
                  if (mounted) setState(() => _muted = !_muted);
                },
                icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        if (_ready)
          ValueListenableBuilder(
            valueListenable: _c,
            builder: (_, v, _) => v.isPlaying || !widget.active
                ? const SizedBox.shrink()
                : const Center(
                    child: IgnorePointer(child: Icon(Icons.play_arrow_rounded, size: 84, color: Colors.white70)),
                  ),
          ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.onTap,
    this.color = Colors.white,
    this.flip = false,
  });
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,
      color: color,
      size: 30,
      shadows: const [Shadow(blurRadius: 12, color: Colors.black54)],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 30,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: flip ? Transform.flip(flipX: true, child: glyph) : glyph,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 8)]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedAction extends StatelessWidget {
  const _FeedAction({required this.label, required this.icon, required this.onTap, this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: primary ? RestoColors.brandGradient : null,
          color: primary ? null : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(17)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: RestoColors.primaryBright),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

/// Commentaires d'un contenu (ou avis libres d'un plat avec [load] et
/// [send]) : lecture pour tous, écriture avec un compte.
class FeedCommentsSheet extends StatefulWidget {
  const FeedCommentsSheet({super.key, this.post, required this.onCount, this.load, this.send, this.title, this.header});
  final FeedPost? post;
  final ValueChanged<int> onCount;
  final Future<List<FeedComment>> Function()? load;
  final Future<void> Function(String body)? send;
  final String? title;

  /// Bloc affiché au-dessus de la liste (ex. : avis notés vérifiés d'un plat).
  final Widget? header;

  @override
  State<FeedCommentsSheet> createState() => _FeedCommentsSheetState();
}

class _FeedCommentsSheetState extends State<FeedCommentsSheet> {
  late Future<List<FeedComment>> _list = _load();
  final _text = TextEditingController();
  bool _sending = false;

  Future<List<FeedComment>> _load() => widget.load?.call() ?? AppScope.read(context).api!.customer.feedComments(widget.post!.id);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    setState(() => _sending = true);
    try {
      final api = AppScope.read(context).api!.customer;
      if (widget.send != null) {
        await widget.send!(body);
      } else {
        await api.addFeedComment(widget.post!.id, body);
      }
      _text.clear();
      final list = await _load();
      if (!mounted) return;
      widget.onCount(list.length);
      setState(() => _list = Future.value(list));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final h = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: h * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 6),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title ?? t.commentsTitle, style: serifTitle(context, size: 24))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(height: 1, color: RestoColors.line),
            ?widget.header,
            Expanded(
              child: FutureBuilder(
                future: _list,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: TextButton(onPressed: () => setState(() => _list = _load()), child: Text(t.retry)),
                    );
                  }
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final list = snap.data!;
                  if (list.isEmpty) return EmptyState(icon: Icons.mode_comment_outlined, title: t.noCommentsYet);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: c.mine ? RestoColors.primary : RestoColors.primarySoft,
                            child: Text(
                              c.author.isEmpty ? '?' : c.author.characters.first.toUpperCase(),
                              style: TextStyle(color: c.mine ? Colors.white : RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(c.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat.MMMd(locale).add_Hm().format(c.createdAt.toLocal()),
                                      style: const TextStyle(color: RestoColors.muted, fontSize: 11.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(c.body),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        maxLength: 500,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(hintText: t.writeComment, counterText: '', fillColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: RestoColors.primary),
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petites annonces flottantes de l'accueil : une à la fois, fermables pour la
/// session ou masquées définitivement (« Ne plus afficher », gardé dans le profil).
class FloatingClassifieds extends StatefulWidget {
  const FloatingClassifieds({super.key});

  @override
  State<FloatingClassifieds> createState() => _FloatingClassifiedsState();
}

class _FloatingClassifiedsState extends State<FloatingClassifieds> {
  /// Fermées pendant cette session.
  static final Set<String> _closed = {};
  List<FeedPost> _ads = const [];
  int _index = 0;
  Timer? _timer;
  final Set<String> _seen = {};

  @override
  void initState() {
    super.initState();
    _load();
    customerCity.addListener(_load);
  }

  @override
  void dispose() {
    customerCity.removeListener(_load);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final api = AppScope.read(context).api!.customer;
    try {
      final all = await api.feed(city: customerCity.value, limit: 50);
      final hidden = <String>{};
      if (api.user != null) {
        final p = await api.profile().catchError((_) => CustomerProfile());
        hidden.addAll(((p.prefs['hidden_ads'] as List?) ?? const []).cast<String>());
      }
      if (!mounted) return;
      setState(() {
        _ads = [
          for (final a in all)
            if (a.format == 'classified' && !hidden.contains(a.id) && !_closed.contains(a.id)) a,
        ];
        _index = 0;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 9), (_) {
        if (mounted && _ads.length > 1) setState(() => _index = (_index + 1) % _ads.length);
      });
    } catch (_) {}
  }

  void _close(FeedPost a) => setState(() {
    _closed.add(a.id);
    _ads = [..._ads]..remove(a);
    if (_index >= _ads.length) _index = 0;
  });

  Future<void> _never(FeedPost a) async {
    final api = AppScope.read(context).api!.customer;
    _close(a);
    if (api.user == null) return;
    try {
      final p = await api.profile();
      final list = {...((p.prefs['hidden_ads'] as List?) ?? const []).cast<String>(), a.id}.toList();
      // Les 30 plus récentes seulement (taille des préférences limitée côté serveur).
      p.prefs['hidden_ads'] = list.length > 30 ? list.sublist(list.length - 30) : list;
      await api.saveProfile(p);
    } catch (_) {}
  }

  void _open(FeedPost a) {
    final api = AppScope.read(context).api!.customer;
    api.recordAd(a.id, 'click');
    if (a.ctaUrl != null && a.items.isEmpty) {
      openLink(a.ctaUrl!);
      return;
    }
    CustomerScope.cart(context).adSource[a.branchId] = a.id;
    openRestaurant(context, a.branchId, itemId: a.items.length == 1 ? a.items.first.$1 : null);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (_ads.isEmpty) return const SizedBox.shrink();
    final a = _ads[_index.clamp(0, _ads.length - 1)];
    if (_seen.add(a.id)) AppScope.read(context).api!.customer.recordFeedView(a.id);
    final api = AppScope.read(context).api!.customer;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Container(
        key: ValueKey(a.id),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: RestoColors.primary.withValues(alpha: 0.45)),
          boxShadow: RestoColors.softShadow(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _open(a),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: RestoColors.primary, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: a.logoPath == null
                        ? const GoldIcon(Icons.campaign_rounded, size: 46)
                        : NetImage(api.logoUrl(a.logoPath!), fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                a.brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('· ${t.adSponsored}', style: const TextStyle(color: RestoColors.muted, fontSize: 11)),
                          ],
                        ),
                        Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: serifTitle(context, size: 18)),
                        if (a.body != null && a.body!.trim().isNotEmpty)
                          Text(
                            a.body!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: RestoColors.muted, fontSize: 12.5),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.close_rounded, size: 20, color: RestoColors.muted),
                    tooltip: t.close,
                    onSelected: (v) => v == 'never' ? _never(a) : _close(a),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'close', child: Text(t.close)),
                      PopupMenuItem(value: 'never', child: Text(t.adHideForever)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stories de l'accueil, comme sur Facebook : un cercle par restaurant
/// (anneau doré tant qu'il reste des stories à voir) ; un appui ouvre toutes
/// ses stories en plein écran, puis celles des restaurants suivants.
class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  List<StoryGroup> _groups = const [];

  /// Restaurants dont les stories ont été vues pendant cette session.
  static final Set<String> _seen = {};

  @override
  void initState() {
    super.initState();
    _load();
    customerCity.addListener(_load);
  }

  @override
  void dispose() {
    customerCity.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = await AppScope.read(context).api!.customer.feed(city: customerCity.value, limit: 50);
      if (!mounted) return;
      final stories = [
        for (final p in all)
          if (p.format != 'push') p,
      ];
      setState(() => _groups = groupStories(stories));
    } catch (_) {}
  }

  Future<void> _open(int index) async {
    final scope = CustomerScope.of(context);
    // Les restaurants pas encore vus d'abord, comme sur Facebook.
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => CustomerScope(
          cart: scope.notifier!,
          openTab: scope.openTab,
          child: StoryGroupViewer(groups: _groups, initial: index, onSeen: (id) => _seen.add(id)),
        ),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(anim), child: child),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_groups.isEmpty) return const SizedBox.shrink();
    final api = AppScope.read(context).api!.customer;
    final ordered = [..._groups.where((g) => !_seen.contains(g.branchId)), ..._groups.where((g) => _seen.contains(g.branchId))];
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ordered.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final g = ordered[i];
            final seen = _seen.contains(g.branchId);
            final first = g.posts.first;
            final image = first.images.firstOrNull;
            final dish = first.items.where((x) => x.$3 != null).firstOrNull?.$3;
            final url = g.logoPath != null
                ? api.logoUrl(g.logoPath!)
                : image != null
                ? api.adMediaUrl(image)
                : (dish != null ? api.imageUrl(dish) : null);
            return GestureDetector(
              onTap: () => _open(_groups.indexOf(g)),
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: seen ? null : RestoColors.brandGradient,
                        color: seen ? RestoColors.line : null,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: ClipOval(child: NetImage(url, fit: g.logoPath != null ? BoxFit.contain : BoxFit.cover)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      g.brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: seen ? FontWeight.w500 : FontWeight.w700,
                        color: seen ? RestoColors.muted : RestoColors.ink,
                      ),
                    ),
                    if (g.posts.length > 1)
                      Text(
                        '${g.posts.length}',
                        style: const TextStyle(fontSize: 10, color: RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compteurs publics d'une publicité (vues, j'aime, commentaires) : pastille
/// sombre et discrète posée sur la photo, pour montrer ce qui plaît.
class AdSocialStats extends StatelessWidget {
  const AdSocialStats({super.key, required this.views, required this.likes, required this.comments});
  final int views;
  final int likes;
  final int comments;

  @override
  Widget build(BuildContext context) {
    Widget stat(IconData icon, int n, Color color) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            NumberFormat.compact(locale: Localizations.localeOf(context).toString()).format(n),
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 4, 1, 4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (views > 0) stat(Icons.visibility_outlined, views, Colors.white),
          if (likes > 0) stat(Icons.favorite_rounded, likes, const Color(0xFFFF6B81)),
          if (comments > 0) stat(Icons.mode_comment_rounded, comments, RestoColors.primaryBright),
        ],
      ),
    );
  }
}
