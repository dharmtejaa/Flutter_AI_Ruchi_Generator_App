import 'package:ai_ruchi/models/recipe.dart';
import 'package:ai_ruchi/screens/entry/entry_screen.dart';
import 'package:ai_ruchi/screens/nutrition/nutrition_detail_screen.dart';
import 'package:ai_ruchi/screens/recipe/adjust_ingredients_screen.dart';
import 'package:ai_ruchi/screens/recipe/recipe_generated_screen.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => router.go('/'),
              child: Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'Entry',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EntryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/adjust',
        name: 'Adjust',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AdjustIngredientsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/recipe',
        name: 'Recipe',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RecipeGeneratedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'Nutrition',
        pageBuilder: (context, state) {
          final nutrition = state.extra as PerServingNutrition;
          return CustomTransitionPage(
            key: state.pageKey,
            child: NutritionDetailScreen(nutrition: nutrition),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
          );
        },
      ),
      // GoRoute(
      //   path: '/add',
      //   name: 'add',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: const AddEditLeadScreen(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return SharedAxisTransition(
      //         animation: animation,
      //         secondaryAnimation: secondaryAnimation,
      //         transitionType: SharedAxisTransitionType.horizontal,
      //         child: child,
      //       );
      //     },
      //   ),
      // ),
      // GoRoute(
      //   path: '/edit/:id',
      //   name: 'edit',
      //   pageBuilder: (context, state) {
      //     final id = int.parse(state.pathParameters['id']!);
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: AddEditLeadScreen(leadId: id),
      //       transitionsBuilder:
      //           (context, animation, secondaryAnimation, child) {
      //             return SharedAxisTransition(
      //               animation: animation,
      //               secondaryAnimation: secondaryAnimation,
      //               transitionType: SharedAxisTransitionType.horizontal,
      //               child: child,
      //             );
      //           },
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: '/details/:id',
      //   name: 'details',
      //   pageBuilder: (context, state) {
      //     final id = int.parse(state.pathParameters['id']!);
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: LeadDetailScreen(leadId: id),
      //       transitionsBuilder:
      //           (context, animation, secondaryAnimation, child) {
      //             return SharedAxisTransition(
      //               animation: animation,
      //               secondaryAnimation: secondaryAnimation,
      //               transitionType: SharedAxisTransitionType.horizontal,
      //               child: child,
      //             );
      //           },
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: '/search',
      //   name: 'search',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: const SearchScreen(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return SharedAxisTransition(
      //         animation: animation,
      //         secondaryAnimation: secondaryAnimation,
      //         transitionType: SharedAxisTransitionType.horizontal,
      //         child: child,
      //       );
      //     },
      //   ),
      // ),
    ],
  );
}
