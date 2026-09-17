import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/widgets/custom_network_image.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageCard({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 180,
            borderRadius: 12, // Match card top corners
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: context.text.titleLarge?.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
