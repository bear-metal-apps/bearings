import 'package:beariscope/pages/team_lookup/tabs/media_save_helper.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaTab extends ConsumerStatefulWidget {
  final int teamNumber;

  const MediaTab({super.key, required this.teamNumber});

  @override
  ConsumerState<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends ConsumerState<MediaTab> {
  late final ValueNotifier<String?> _activeUrlNotifier;

  @override
  void initState() {
    super.initState();
    _activeUrlNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _activeUrlNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(teamMediaProvider(widget.teamNumber));

    return mediaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (media) {
        final imgurPhotos = media
            .where(
              (record) =>
                  record.isImgurPhoto &&
                  (record.directUrl?.isNotEmpty ?? false),
            )
            .toList();

        if (imgurPhotos.isEmpty) {
          return const Center(child: Text('No media recorded for this team.'));
        }

        final urls = imgurPhotos.map((e) => e.directUrl!).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: imgurPhotos.length,
              itemBuilder: (context, index) {
                final url = urls[index];

                return ValueListenableBuilder<String?>(
                  valueListenable: _activeUrlNotifier,
                  builder: (context, activeUrl, _) {
                    final isViewerOpen = activeUrl != null;
                    final isViewingThis = activeUrl == url;
                    final shouldBeHero = !isViewerOpen || isViewingThis;

                    Widget imageContent = ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: _NetworkImageWithSkeleton(
                        url: url,
                        fit: BoxFit.cover,
                      ),
                    );

                    if (shouldBeHero) {
                      imageContent = Hero(tag: url, child: imageContent);
                    }

                    return GestureDetector(
                      onTap: () async {
                        _activeUrlNotifier.value = url;
                        await Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    _FullscreenImageViewer(
                                      urls: urls,
                                      initialIndex: index,
                                      activeUrlNotifier: _activeUrlNotifier,
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                          ),
                        );
                        _activeUrlNotifier.value = null;
                      },
                      child: Opacity(
                        opacity: isViewingThis ? 0.0 : 1.0,
                        child: imageContent,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FullscreenImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final ValueNotifier<String?> activeUrlNotifier;

  const _FullscreenImageViewer({
    required this.urls,
    required this.initialIndex,
    required this.activeUrlNotifier,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta.dy);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100 ||
        (details.primaryVelocity?.abs() ?? 0) > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dragFraction = (_dragOffset.abs() / 300).clamp(0.0, 1.0);
    final backgroundOpacity = 1.0 - dragFraction;
    final scale = 1.0 - (dragFraction * 0.15);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white.withValues(alpha: backgroundOpacity),
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${_currentIndex + 1} / ${widget.urls.length}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: backgroundOpacity),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'share') {
                await _shareCurrentImage(widget.urls[_currentIndex]);
              } else if (value == 'open') {
                final uri = Uri.parse(widget.urls[_currentIndex]);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open image')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: const [
                    Icon(Icons.ios_share_rounded),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'open',
                child: Row(
                  children: const [
                    Icon(Icons.open_in_new_rounded),
                    SizedBox(width: 12),
                    Text('Open in Browser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                widget.activeUrlNotifier.value = widget.urls[i];
              },
              itemBuilder: (context, index) {
                final url = widget.urls[index];
                final image = _NetworkImageWithSkeleton(
                  url: url,
                  fit: BoxFit.contain,
                );

                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5.0,
                  child: Center(
                    child: index == _currentIndex
                        ? Hero(tag: url, child: image)
                        : image,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareCurrentImage(String url) async {
    final imgurId = url.split('/').last.split('.').first;
    final filename = '$imgurId.jpg';
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final bytes = await _fetchImageBytes(url);
    await shareOrSaveImage(shareOrigin, bytes, filename);
  }

  Future<Uint8List> _fetchImageBytes(String url) async {
    final bundle = NetworkAssetBundle(Uri.parse(url));
    final data = await bundle.load(url);
    return data.buffer.asUint8List();
  }
}

class _NetworkImageWithSkeleton extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const _NetworkImageWithSkeleton({required this.url, required this.fit});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _PulseSkeleton();
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PulseSkeleton extends StatefulWidget {
  const _PulseSkeleton();

  @override
  State<_PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<_PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5 + (_controller.value * 0.2),
        ),
      ),
    );
  }
}
