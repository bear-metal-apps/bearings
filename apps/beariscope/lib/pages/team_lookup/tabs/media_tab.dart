import 'dart:async';

import 'package:beariscope/pages/team_lookup/tabs/media_save_helper.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:flutter/gestures.dart';
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
                                (context,
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

class _FullscreenImageViewerState extends State<_FullscreenImageViewer>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0;
  double _currentScale = 1.0;

  late final AnimationController _snapController;
  late Animation<double> _snapAnimation;

  static const double _dismissScaleThreshold = 1.02;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _snapAnimation = const AlwaysStoppedAnimation(0);
    _snapController.addListener(() {
      setState(() {
        _dragOffset = _snapAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_snapController.isAnimating) _snapController.stop();
    setState(() => _dragOffset += details.delta.dy);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100 ||
        (details.primaryVelocity?.abs() ?? 0) > 500) {
      Navigator.of(context).pop();
    } else {
      _animateDragOffsetToZero();
    }
  }

  void _animateDragOffsetToZero() {
    _snapAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0);
  }

  void _handleScaleChanged(double scale) {
    if (_currentScale == scale) return;
    setState(() => _currentScale = scale);
  }

  void _handleVerticalOverscroll(double delta) {
    if (_snapController.isAnimating) _snapController.stop();
    setState(() => _dragOffset += delta);
  }

  void _handleHorizontalOverscroll(double delta) {
    if (_pageController.hasClients) {
      _pageController.position.jumpTo(_pageController.position.pixels - delta);
    }
  }

  void _handleOverscrollEnd(Offset velocity) {
    // Vertical check (already handles trackpad 0-velocity drops well via distance > 100)
    if (_dragOffset.abs() > 0) {
      if (_dragOffset.abs() > 100 || velocity.dy.abs() > 500) {
        Navigator.of(context).pop();
      } else {
        _animateDragOffsetToZero();
      }
    }

    // Horizontal check
    if (_pageController.hasClients) {
      final double currentPage = _pageController.page ??
          _currentIndex.toDouble();
      int targetPage = currentPage.round();

      if (velocity.dx < -500 && currentPage < widget.urls.length - 1) {
        targetPage = currentPage.ceil();
      } else if (velocity.dx > 500 && currentPage > 0) {
        targetPage = currentPage.floor();
      } else {
        // Trackpad Fallback: If velocity is 0 but user dragged more than 20%
        if (currentPage > _currentIndex + 0.2) {
          targetPage = _currentIndex + 1;
        } else if (currentPage < _currentIndex - 0.2) {
          targetPage = _currentIndex - 1;
        }
      }

      targetPage = targetPage.clamp(0, widget.urls.length - 1);

      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dragFraction = (_dragOffset.abs() / 300).clamp(0.0, 1.0);
    final backgroundOpacity = 1.0 - dragFraction;
    final scale = 1.0 - (dragFraction * 0.15);
    final canDismiss = _currentScale <= _dismissScaleThreshold;

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
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: canDismiss ? _handleDragUpdate : null,
        onVerticalDragEnd: canDismiss ? _handleDragEnd : null,
        child: Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: PageView.builder(
              controller: _pageController,
              physics: canDismiss
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: widget.urls.length,
              onPageChanged: (i) {
                setState(() {
                  _currentIndex = i;
                  _dragOffset = 0;
                  _currentScale = 1.0;
                });
                widget.activeUrlNotifier.value = widget.urls[i];
              },
              itemBuilder: (context, index) {
                final url = widget.urls[index];
                final image = _NetworkImageWithSkeleton(
                  url: url,
                  fit: BoxFit.contain,
                );

                return _ZoomablePhotoPage(
                  url: url,
                  image: image,
                  isCurrent: index == _currentIndex,
                  onScaleChanged: index == _currentIndex
                      ? _handleScaleChanged
                      : null,
                  onVerticalOverscroll: index == _currentIndex
                      ? _handleVerticalOverscroll
                      : null,
                  onHorizontalOverscroll: index == _currentIndex
                      ? _handleHorizontalOverscroll
                      : null,
                  onOverscrollEnd: index == _currentIndex
                      ? _handleOverscrollEnd
                      : null,
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

class _ZoomablePhotoPage extends StatefulWidget {
  final String url;
  final Widget image;
  final bool isCurrent;
  final ValueChanged<double>? onScaleChanged;
  final ValueChanged<double>? onVerticalOverscroll;
  final ValueChanged<double>? onHorizontalOverscroll;
  final ValueChanged<Offset>? onOverscrollEnd;

  const _ZoomablePhotoPage({
    required this.url,
    required this.image,
    required this.isCurrent,
    this.onScaleChanged,
    this.onVerticalOverscroll,
    this.onHorizontalOverscroll,
    this.onOverscrollEnd,
  });

  @override
  State<_ZoomablePhotoPage> createState() => _ZoomablePhotoPageState();
}

class _ZoomablePhotoPageState extends State<_ZoomablePhotoPage> {
  late final TransformationController _controller;
  double _lastScale = 1.0;
  Matrix4 _previousMatrix = Matrix4.identity();
  Axis? _overscrollAxis;
  Timer? _scrollEndTimer; // Debouncer for raw trackpad scrolls

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleInteractionStart(ScaleStartDetails details) {
    _previousMatrix = _controller.value.clone();
    _overscrollAxis = null;
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _controller.value.getMaxScaleOnAxis();
    if ((scale - _lastScale).abs() >= 0.001) {
      _lastScale = scale;
      widget.onScaleChanged?.call(scale);
    }

    if (details.scale != 1.0 || scale <= 1.0) {
      _previousMatrix = _controller.value.clone();
      return;
    }

    _processDeltaBridge(details.focalPointDelta);
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    final scale = _controller.value.getMaxScaleOnAxis();
    if (scale <= 1.01) {
      _controller.value = Matrix4.identity();
      _lastScale = 1.0;
      widget.onScaleChanged?.call(1.0);
    }

    if (_overscrollAxis != null) {
      widget.onOverscrollEnd?.call(details.velocity.pixelsPerSecond);
      _overscrollAxis = null;
    }
  }

  // Bridging logic for discrete trackpad/mouse scroll signals
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final scale = _controller.value.getMaxScaleOnAxis();
      if (scale <= 1.0) return; // Unzoomed state is handled by PageView

      // Scroll delta implies direction content is moving, which is inverted from finger delta
      final trackpadFocalDelta = Offset(
          -event.scrollDelta.dx, -event.scrollDelta.dy);
      _processDeltaBridge(trackpadFocalDelta);

      // Raw scroll events don't have an "end", so we debounce one.
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
        if (_overscrollAxis != null) {
          widget.onOverscrollEnd?.call(Offset.zero);
          _overscrollAxis = null;
        }
      });
    }
  }

  void _processDeltaBridge(Offset fingerDelta) {
    final currentMatrix = _controller.value;
    final double dx = currentMatrix.row0[3] - _previousMatrix.row0[3];
    final double dy = currentMatrix.row1[3] - _previousMatrix.row1[3];

    if (_overscrollAxis == null) {
      final hitX = fingerDelta.dx.abs() > 0.5 && dx.abs() < 0.1;
      final hitY = fingerDelta.dy.abs() > 0.5 && dy.abs() < 0.1;

      if (hitX && hitY) {
        _overscrollAxis =
        fingerDelta.dx.abs() > fingerDelta.dy.abs() ? Axis.horizontal : Axis
            .vertical;
      } else if (hitX) {
        _overscrollAxis = Axis.horizontal;
      } else if (hitY) {
        _overscrollAxis = Axis.vertical;
      }
    }

    if (_overscrollAxis == Axis.vertical && fingerDelta.dy.abs() > 0.5 &&
        dy.abs() < 0.1) {
      widget.onVerticalOverscroll?.call(fingerDelta.dy);
    } else
    if (_overscrollAxis == Axis.horizontal && fingerDelta.dx.abs() > 0.5 &&
        dx.abs() < 0.1) {
      widget.onHorizontalOverscroll?.call(fingerDelta.dx);
    }

    _previousMatrix = currentMatrix.clone();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // The secret sauce to catch PC trackpads and mice that bypass GestureDetector
      onPointerSignal: _handlePointerSignal,
      child: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1.0,
          maxScale: 5.0,
          panEnabled: widget.isCurrent,
          scaleEnabled: true,
          clipBehavior: Clip.none,
          onInteractionStart: _handleInteractionStart,
          onInteractionUpdate: _handleInteractionUpdate,
          onInteractionEnd: _handleInteractionEnd,
          child: widget.isCurrent
              ? Hero(tag: widget.url, child: widget.image)
              : widget.image,
        ),
      ),
    );
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