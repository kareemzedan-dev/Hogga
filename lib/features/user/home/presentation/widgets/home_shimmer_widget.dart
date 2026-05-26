import 'package:flutter/material.dart';
import 'package:hogga/core/widgets/custom_shimmer.dart';

import '../../../../../core/utils/app_colors.dart';

class HomeShimmerWidget extends StatelessWidget {
  const HomeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const CustomShimmer.rectangular(
              height: 150, 
              width: double.infinity,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Categories Shimmer (Horizontal)
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const CustomShimmer.rectangular(
                 height: 40, 
                 width: 80, 
                 shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const CustomShimmer.rectangular(
              height: 50,
              width: double.infinity,
               shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),

          const SizedBox(height: 24),

          // Service List Shimmer (Cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(4, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Image
                      const CustomShimmer.rectangular(
                        height: 150, 
                        width: double.infinity,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text Lines
                      Row(
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: const [
                               CustomShimmer.rectangular(height: 14, width: 150),
                               SizedBox(height: 8),
                               CustomShimmer.rectangular(height: 10, width: 100),
                             ],
                           ),
                         ],
                      )
                    ],
                  ),
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
