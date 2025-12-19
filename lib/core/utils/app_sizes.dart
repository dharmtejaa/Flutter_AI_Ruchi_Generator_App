// lib/core/services/app_sizes.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  // ============================================================================
  // FONT SIZES
  // ============================================================================
  static double fontUxs = 10.sp;
  static double fontXs = 12.sp;
  static double fontSm = 14.sp;
  static double fontMd = 16.sp;
  static double fontLg = 18.sp;
  static double fontXl = 20.sp;
  static double fontXxl = 24.sp;
  static double fontDisplay = 32.sp;

  // ============================================================================
  // ICON SIZES
  // ============================================================================
  static double iconsUxs = 14.sp;
  static double iconXs = 16.sp;
  static double iconSm = 20.sp;
  static double iconMd = 24.sp;
  static double iconLg = 32.sp;
  static double iconXl = 48.sp;

  // ============================================================================
  // PADDING SIZES
  // ============================================================================
  // Horizontal Padding
  static double paddingXs = 8.w;
  static double paddingSm = 12.w;
  static double paddingMd = 16.w;
  static double paddingLg = 20.w;
  static double paddingXl = 24.w;
  static double paddingXxl = 32.w;

  // Vertical Padding
  static double vPaddingXs = 8.h;
  static double vPaddingSm = 12.h;
  static double vPaddingMd = 16.h;
  static double vPaddingLg = 20.h;
  static double vPaddingXl = 24.h;
  static double vPaddingXxl = 32.h;

  // ============================================================================
  // MARGIN SIZES
  // ============================================================================
  // Horizontal Margin
  static double marginXs = 8.w;
  static double marginSm = 12.w;
  static double marginMd = 16.w;
  static double marginLg = 20.w;
  static double marginXl = 24.w;
  static double marginXxl = 32.w;

  // Vertical Margin
  static double vMarginXs = 8.h;
  static double vMarginSm = 12.h;
  static double vMarginMd = 16.h;
  static double vMarginLg = 20.h;
  static double vMarginXl = 24.h;
  static double vMarginXxl = 32.h;

  // ============================================================================
  // BORDER RADIUS SIZES
  // ============================================================================
  static double radiusXs = 4.r;
  static double radiusSm = 8.r;
  static double radiusMd = 12.r;
  static double radiusLg = 16.r;
  static double radiusXl = 20.r;
  static double radiusXxl = 24.r;
  static double radiusXxxl = 28.r;
  static double radiusCircular = 50.r;

  // ============================================================================
  // SPACING SIZES
  // ============================================================================
  static double spaceXs = 4.w;
  static double spaceSm = 8.w;
  static double spaceMd = 16.w;
  static double spaceLg = 24.w;
  static double spaceXl = 32.w;
  static double spaceXxl = 48.w;

  // Vertical Spacing
  static double spaceHeightXs = 4.h;
  static double spaceHeightSm = 8.h;
  static double spaceHeightMd = 16.h;
  static double spaceHeightLg = 24.h;
  static double spaceHeightXl = 32.h;
  static double spaceHeightXxl = 48.h;

  // ============================================================================
  // PADDING - EDGEINSETS CONSTANTS
  // ============================================================================
  static EdgeInsets paddingAllXs = EdgeInsets.all(paddingXs);
  static EdgeInsets paddingAllSm = EdgeInsets.all(paddingSm);
  static EdgeInsets paddingAllMd = EdgeInsets.all(paddingMd);
  static EdgeInsets paddingAllLg = EdgeInsets.all(paddingLg);
  static EdgeInsets paddingAllXl = EdgeInsets.all(paddingXl);
  static EdgeInsets paddingAllXxl = EdgeInsets.all(paddingXxl);

  static EdgeInsets paddingSymmetricXs = EdgeInsets.symmetric(
    horizontal: paddingXs,
    vertical: vPaddingXs,
  );
  static EdgeInsets paddingSymmetricSm = EdgeInsets.symmetric(
    horizontal: paddingSm,
    vertical: vPaddingSm,
  );
  static EdgeInsets paddingSymmetricMd = EdgeInsets.symmetric(
    horizontal: paddingMd,
    vertical: vPaddingMd,
  );
  static EdgeInsets paddingSymmetricLg = EdgeInsets.symmetric(
    horizontal: paddingLg,
    vertical: vPaddingLg,
  );
  static EdgeInsets paddingSymmetricXl = EdgeInsets.symmetric(
    horizontal: paddingXl,
    vertical: vPaddingXl,
  );
  static EdgeInsets paddingSymmetricXxl = EdgeInsets.symmetric(
    horizontal: paddingXxl,
    vertical: vPaddingXxl,
  );

  // ============================================================================
  // MARGIN - EDGEINSETS CONSTANTS
  // ============================================================================
  static EdgeInsets marginAllXs = EdgeInsets.all(marginXs);
  static EdgeInsets marginAllSm = EdgeInsets.all(marginSm);
  static EdgeInsets marginAllMd = EdgeInsets.all(marginMd);
  static EdgeInsets marginAllLg = EdgeInsets.all(marginLg);
  static EdgeInsets marginAllXl = EdgeInsets.all(marginXl);
  static EdgeInsets marginAllXxl = EdgeInsets.all(marginXxl);

  static EdgeInsets marginSymmetricXs = EdgeInsets.symmetric(
    horizontal: marginXs,
    vertical: vMarginXs,
  );
  static EdgeInsets marginSymmetricSm = EdgeInsets.symmetric(
    horizontal: marginSm,
    vertical: vMarginSm,
  );
  static EdgeInsets marginSymmetricMd = EdgeInsets.symmetric(
    horizontal: marginMd,
    vertical: vMarginMd,
  );
  static EdgeInsets marginSymmetricLg = EdgeInsets.symmetric(
    horizontal: marginLg,
    vertical: vMarginLg,
  );
  static EdgeInsets marginSymmetricXl = EdgeInsets.symmetric(
    horizontal: marginXl,
    vertical: vMarginXl,
  );
  static EdgeInsets marginSymmetricXxl = EdgeInsets.symmetric(
    horizontal: marginXxl,
    vertical: vMarginXxl,
  );

  static double? get spaceWidthMd => null;
}
