import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/theme/app_theme.dart';
import '../../data/models/banners_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeMainBanner extends StatefulWidget {
  const HomeMainBanner({super.key});

  @override
  State<HomeMainBanner> createState() => _HomeMainBannerState();
}

class _HomeMainBannerState extends State<HomeMainBanner> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;
  int _lastBannerCount = 0;

  @override
  void initState() {
    super.initState();
    final banners = context.read<HomeCubit>().state.banners;
    if (banners.isNotEmpty) {
      _startAutoScroll(banners.length);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _lastBannerCount = count;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % count;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (previous, current) => previous.banners != current.banners,
      listener: (context, state) {
        if (state.banners.length != _lastBannerCount) {
          _startAutoScroll(state.banners.length);
        }
      },
      buildWhen: (previous, current) => previous.banners != current.banners,
      builder: (context, state) {
        final banners = state.banners;
        if (banners.isEmpty) return const SizedBox.shrink();

        if (_timer == null && banners.length > 1) {
          _startAutoScroll(banners.length);
        }

        return Column(
          children: [
            SizedBox(
              height: 160.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) =>
                    _BannerCard(banner: banners[index]),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == i ? 20.w : 7.w,
                  height: 7.h,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentIndex == i
                        ? AppColors.golden
                        : AppColors.golden.withValues(alpha: 0.25),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: context.cardBg,
          child: CachedNetworkImage(
            imageUrl: banner.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            placeholder: (context, url) => Container(
              color: context.cardBg,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: context.cardBg,
              child: Icon(
                Icons.error_outline_rounded,
                color: context.colors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
