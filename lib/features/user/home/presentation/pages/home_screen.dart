import 'package:hogga/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/home/presentation/widgets/home_main_banner.dart';
import 'package:hogga/features/user/home/presentation/widgets/home_services_section.dart';
import 'package:hogga/features/user/home/presentation/widgets/header.dart';
import 'package:hogga/features/user/home/presentation/widgets/home_shimmer_widget.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<HomeCubit>();
      if (cubit.state.banners.isEmpty) {
        cubit.loadHomeData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) => previous.banners.length != current.banners.length && current.banners.isNotEmpty,
      listener: (context, state) {
        for (var banner in state.banners) {
          precacheImage(CachedNetworkImageProvider(banner.imageUrl), context);
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) => 
            previous.isLoadingCategories != current.isLoadingCategories || 
            previous.banners.length != current.banners.length,
        builder: (context, state) {
          if (state.isLoadingCategories && state.banners.isEmpty) {
            return const HomeShimmerWidget();
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHomeData(),
              color: context.accentGolden,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ─── 1. Header ─────────────────────────────────
                  const SliverToBoxAdapter(child: Header()),

                  // ─── 2. Main promotional card slider ───────────
                  const SliverToBoxAdapter(child: HomeMainBanner()),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // ─── 3. Services section ────────────────────────
                  const HomeServicesSection(),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
