import 'package:ai_ruchi/core/services/ad_service.dart';
import 'package:ai_ruchi/core/services/my_custom_cache_manager.dart';
import 'package:ai_ruchi/core/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ingredients_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/saved_recipes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads
  await AdService().initialize();

  // Initialize SharedPreferences and check onboarding status
  final prefs = await SharedPreferences.getInstance();
  AppRouter.isOnboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  // Lock orientation to portrait only - must await this before runApp
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure screen size is initialized for ScreenUtil (fixes release mode blank screen)
  await ScreenUtil.ensureScreenSize();

  // Prune old cache entries on app start for better memory management
  MyCustomCacheManager.pruneCache();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => IngredientsProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => SavedRecipesProvider()),
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider()..loadSettings(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: false,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'AI Ruchi',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
