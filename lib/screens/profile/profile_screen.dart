import 'package:ai_ruchi/core/services/tutorial_service.dart';
import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:ai_ruchi/providers/app_settings_provider.dart';
import 'package:ai_ruchi/providers/theme_provider.dart';
import 'package:ai_ruchi/shared/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // Title
              Text(
                'Profile',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24.h),

              // Avatar
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 48.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),

              // Name
              Text(
                'Alex Doe',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),

              // Email
              Text(
                'alex.doe@pantrypal.com',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.h),

              // Settings Section
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Account Details',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSettingsTile(
                        context,
                        icon: _getThemeIcon(themeProvider.themeMode),
                        title: 'Theme',
                        trailing: Text(
                          _getThemeDisplayName(themeProvider.themeMode),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => _showThemeSelector(context),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Feature Settings Section
              _buildSectionHeader(context, 'Feature Settings'),
              SizedBox(height: 8.h),
              Consumer<AppSettingsProvider>(
                builder: (context, appSettings, child) {
                  return _buildSettingsCard(
                    context,
                    children: [
                      _buildCompactSettingsTile(
                        context,
                        icon: Icons.record_voice_over_outlined,
                        title: 'Text-to-Speech',
                        value: appSettings.ttsEnabled,
                        onChanged: (value) => appSettings.setTtsEnabled(value),
                      ),
                      _buildDivider(context),
                      _buildCompactSettingsTile(
                        context,
                        icon: Icons.vibration,
                        title: 'Shake to Scan',
                        value: appSettings.shakeToScanEnabled,
                        onChanged: (value) =>
                            appSettings.setShakeToScanEnabled(value),
                      ),
                      _buildDivider(context),
                      _buildSettingsTile(
                        context,
                        icon: Icons.speed,
                        title: 'Speech Speed',
                        trailing: Text(
                          '${(appSettings.ttsSpeed * 2).toStringAsFixed(1)}x',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => _showSpeedSelector(context, appSettings),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Storage & Privacy Section
              _buildSectionHeader(context, 'Storage & Privacy'),
              SizedBox(height: 8.h),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'Export to PDF',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Clear History',
                    titleColor: Colors.red,
                    iconColor: Colors.red,
                    showChevron: false,
                    onTap: () => _showClearHistoryDialog(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Help Section
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.play_circle_outline,
                    title: 'Replay Tutorial',
                    onTap: () => _showReplayTutorialDialog(context),
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  color: titleColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 22.sp,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact settings tile with smaller switch for toggle options
  Widget _buildCompactSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: colorScheme.onSurfaceVariant),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: colorScheme.primary,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                return null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52.w,
      color: colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _showSpeedSelector(
    BuildContext context,
    AppSettingsProvider appSettings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('Speech Speed', style: textTheme.titleLarge),
                    SizedBox(height: 24.h),
                    // Speed slider
                    Row(
                      children: [
                        Icon(
                          Icons.slow_motion_video,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        Expanded(
                          child: Slider(
                            value: appSettings.ttsSpeed,
                            min: 0.25,
                            max: 1.0,
                            divisions: 6,
                            label:
                                '${(appSettings.ttsSpeed * 2).toStringAsFixed(1)}x',
                            onChanged: (value) {
                              setSheetState(() {});
                              appSettings.setTtsSpeed(value);
                            },
                          ),
                        ),
                        Icon(
                          Icons.fast_forward,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(appSettings.ttsSpeed * 2).toStringAsFixed(1)}x speed',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Select Theme', style: textTheme.titleLarge),
                SizedBox(height: 16.h),
                ...['System', 'Light', 'Dark'].map((theme) {
                  final isSelected =
                      themeProvider.themeMode == _getThemeModeFromString(theme);
                  return ListTile(
                    leading: Icon(
                      theme == 'System'
                          ? Icons.brightness_auto
                          : theme == 'Light'
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                    title: Text(
                      theme,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : null,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      themeProvider.setThemeMode(
                        _getThemeModeFromString(theme),
                      );
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all your history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('History cleared')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // code
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showReplayTutorialDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              color: colorScheme.primary,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text('Replay Tutorial', style: textTheme.titleLarge),
          ],
        ),
        content: Text(
          'Would you like to replay the app tutorial? This will reset all tutorial progress and show the guides again on each screen.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await TutorialService.resetAllTutorials();
              if (context.mounted) {
                CustomSnackBar.showSuccess(
                  context,
                  'Tutorial reset! Navigate to Home to start.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Text('Reset & Replay'),
          ),
        ],
      ),
    );
  }
}
