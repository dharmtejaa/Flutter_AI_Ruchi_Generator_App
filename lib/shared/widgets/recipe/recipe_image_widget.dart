import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String recipeName;

  const RecipeImageWidget({
    super.key,
    this.imageUrl,
    required this.recipeName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 250.h,
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}


