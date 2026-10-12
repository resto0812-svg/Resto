import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/image_compress.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'customer_shell.dart';

/// Étoiles (demi-étoiles comprises).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        Icon(
          rating >= i ? Icons.star_rounded : (rating >= i - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
          size: size,
          color: RestoColors.primary,
        ),
    ],
  );
}

/// Un avis vérifié : auteur, note, date, commentaire, photos, « utile », signaler.
class ReviewTile extends StatefulWidget {
  const ReviewTile({super.key, required this.review});
  final ItemReview review;

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  ItemReview get r => widget.review;

  Future<void> _helpful() async {
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    try {
      final count = await AppScope.read(context).api!.customer.voteReview(r.id, !r.voted);
      if (mounted) {
        setState(() {
          r.voted = !r.voted;
          r.helpful = count;
        });
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _report() async {
    final t = context.t;
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.reportReview),
        content: TextField(
          controller: reason,
          maxLength: 300,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.reportReason),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.send)),
        ],
      ),
    );
    if (ok != true || reason.text.trim().length < 3 || !mounted) return;
    try {
      await AppScope.read(context).api!.customer.reportReview(r.id, reason.text.trim());
      if (mounted) showInfo(context, t.reportSent);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _openPhoto(String url) => showDialog<void>(
    context: context,
    builder: (d) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(r.createdAt.toLocal());
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: RestoColors.primarySoft,
                child: Text(
                  r.author.isEmpty ? '?' : r.author.characters.first.toUpperCase(),
                  style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(date, style: const TextStyle(color: RestoColors.muted, fontSize: 11.5)),
                  ],
                ),
              ),
              StatusPill(label: t.verifiedPurchase, color: const Color(0xFF2E9E5B), icon: Icons.verified_rounded, dense: true),
            ],
          ),
          const SizedBox(height: 8),
          StarRow(rating: r.rating.toDouble()),
          if ((r.comment ?? '').isNotEmpty) ...[const SizedBox(height: 6), Text('« ${r.comment} »', style: const TextStyle(height: 1.35))],
          if (r.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in r.photos)
                  GestureDetector(
                    onTap: () => _openPhoto(api.reviewPhotoUrl(p)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        api.reviewPhotoUrl(p),
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(width: 74, height: 74),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: r.mine ? null : _helpful,
                icon: Icon(r.voted ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined, size: 17),
                label: Text(t.helpfulCount(r.helpful)),
              ),
              const Spacer(),
              if (!r.mine)
                TextButton.icon(
                  onPressed: _report,
                  icon: const Icon(Icons.flag_outlined, size: 17),
                  label: Text(t.reportReview),
                  style: TextButton.styleFrom(foregroundColor: RestoColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tous les avis d'un plat : synthèse, tri, chargement progressif.
class ItemReviewsPage extends StatefulWidget {
  const ItemReviewsPage({super.key, required this.item, this.rating});
  final PublicItem item;
  final ItemRating? rating;

  @override
  State<ItemReviewsPage> createState() => _ItemReviewsPageState();
}

class _ItemReviewsPageState extends State<ItemReviewsPage> {
  String _sort = 'recent';
  final List<ItemReview> _reviews = [];
  bool _loading = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _more());
  }

  Future<void> _more({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      _reviews.clear();
      _done = false;
    }
    if (_done) return;
    setState(() => _loading = true);
    try {
      final page = await AppScope.read(context).api!.customer.itemReviews(widget.item.id, sort: _sort, offset: _reviews.length);
      if (!mounted) return;
      setState(() {
        _reviews.addAll(page);
        _done = page.length < 20;
      });
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final r = widget.rating;
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name, style: serifTitle(context, size: 22))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              if (r != null)
                SoftCard(
                  child: Row(
                    children: [
                      Text('${r.average}', style: serifTitle(context, size: 46)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRow(rating: r.average, size: 20),
                            Text(t.reviewsCount(r.count), style: const TextStyle(color: RestoColors.muted)),
                            const SizedBox(height: 4),
                            StatusPill(label: t.satisfiedPercent(r.satisfied), color: const Color(0xFF2E9E5B), dense: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              PillBar<String>(
                dense: true,
                items: [
                  PillItem('recent', t.sortRecent),
                  PillItem('helpful', t.sortHelpful),
                  PillItem('best', t.sortBestRated),
                  PillItem('worst', t.sortWorstRated),
                ],
                selected: _sort,
                onSelected: (v) {
                  setState(() => _sort = v);
                  _more(reset: true);
                },
              ),
              const SizedBox(height: 10),
              if (_reviews.isEmpty && !_loading) EmptyState(icon: Icons.rate_review_outlined, title: t.noReviewsYet),
              for (final rev in _reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReviewTile(review: rev),
                ),
              if (_loading)
                const Center(
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                ),
              if (!_done && !_loading && _reviews.isNotEmpty)
                Center(
                  child: TextButton(onPressed: _more, child: Text(t.loadMore)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Noter un plat reçu : étoiles, commentaire, jusqu'à 4 photos.
Future<bool> writeItemReview(BuildContext context, {required String orderItemId, required String itemName, int? current}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReviewSheet(orderItemId: orderItemId, itemName: itemName, current: current),
  );
  return ok == true;
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.orderItemId, required this.itemName, this.current});
  final String orderItemId;
  final String itemName;
  final int? current;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late int _rating = widget.current ?? 5;
  final _comment = TextEditingController();
  final List<PickedDocument> _photos = [];

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final t = context.t;
    final picked = await pickMedia(videos: false);
    final files = [for (final f in picked) await compressPhoto(f)];
    if (!mounted) return;
    setState(() {
      for (final f in files) {
        if (_photos.length >= 4) break;
        if (f.bytes.length > maxPhotoBytes) {
          showInfo(context, t.fileTooBig(f.name));
          continue;
        }
        _photos.add(f);
      }
    });
  }

  Future<void> _send() async {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    try {
      final paths = [for (final p in _photos) await api.uploadReviewPhoto(p.bytes, p.extension)];
      await api.submitItemReview(widget.orderItemId, _rating, _comment.text.trim().isEmpty ? null : _comment.text.trim(), paths);
      if (!mounted) return;
      showInfo(context, t.thanksForReview);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.rateDish(widget.itemName), style: serifTitle(context, size: 24)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var s = 1; s <= 5; s++)
                IconButton(
                  iconSize: 38,
                  onPressed: () => setState(() => _rating = s),
                  icon: Icon(s <= _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: RestoColors.primary),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            maxLength: 1000,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(labelText: t.reviewComment, hintText: t.reviewCommentHint),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _photos)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(p.bytes, width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.remove(p)),
                        child: const CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close_rounded, size: 14)),
                      ),
                    ),
                  ],
                ),
              if (_photos.length < 4)
                SizedBox(
                  width: 70,
                  height: 70,
                  child: DashedBox(
                    padding: EdgeInsets.zero,
                    onTap: _addPhotos,
                    child: const Center(child: Icon(Icons.add_a_photo_outlined, color: RestoColors.primaryDeep)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(t.verifiedReviewNote, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
          const SizedBox(height: 14),
          GoldButton(label: t.publishReview, icon: Icons.send_rounded, onPressed: _send),
        ],
      ),
    );
  }
}
