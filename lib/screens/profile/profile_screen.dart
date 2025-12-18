import 'package:ai_ruchi/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _syncToCloud = true;
  String _selectedTheme = 'System';

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
                  _buildSettingsTile(
                    context,
                    icon: Icons.contrast,
                    title: 'Theme',
                    trailing: Text(
                      _selectedTheme,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => _showThemeSelector(context),
                  ),
                ],
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
                    icon: Icons.cloud_sync_outlined,
                    title: 'Sync to Cloud',
                    trailing: Switch(
                      value: _syncToCloud,
                      onChanged: (value) {
                        setState(() => _syncToCloud = value);
                      },
                      activeTrackColor: colorScheme.primary,
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.onPrimary;
                        }
                        return null;
                      }),
                    ),
                    showChevron: false,
                  ),
                  _buildDivider(context),
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

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52.w,
      color: colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Theme',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                ...['System', 'Light', 'Dark'].map((theme) {
                  return ListTile(
                    leading: Icon(
                      theme == 'System'
                          ? Icons.brightness_auto
                          : theme == 'Light'
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    title: Text(theme),
                    trailing: _selectedTheme == theme
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedTheme = theme);
                      Navigator.pop(context);
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
              // TODO: Implement logout logic
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
