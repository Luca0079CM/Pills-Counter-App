import 'package:flutter/material.dart';
import '../controllers/cpe_vib_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/capsule_view.dart';
import '../widgets/common/app_section_card.dart';
import '../widgets/common/app_section_header.dart';


class ChannelsCapsuleContent extends StatelessWidget {
  final CpeVibController controller;
  final bool showModeSelector;
  final String title;
  final String subtitle;

  const ChannelsCapsuleContent({
    super.key,
    required this.controller,
    this.showModeSelector = false,
    this.title = 'Canali capsule',
    this.subtitle = 'Pillole residue per canale',
  });

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: title,
          subtitle: subtitle,
          icon: Icons.view_module,
        ),
        if (showModeSelector) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ChannelsModeToggle(
              isSixChannels: state.settings.sixChannelsMode,
              onChanged: (_) => controller.toggleSixChannelsMode(),
            ),
          ),
        ],
        const SizedBox(height: 18),
        CapsuleView(
          values: state.params.capsules,
          showSix: state.settings.sixChannelsMode,
        ),
      ],
    );
  }
}

class ChannelsCapsuleCard extends StatelessWidget {
  final CpeVibController controller;
  final bool showModeSelector;
  final String title;
  final String subtitle;

  const ChannelsCapsuleCard({
    super.key,
    required this.controller,
    this.showModeSelector = false,
    this.title = 'Canali capsule',
    this.subtitle = 'Pillole residue per canale',
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: ChannelsCapsuleContent(
        controller: controller,
        showModeSelector: showModeSelector,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

class ChannelsDisplayModeCard extends StatelessWidget {
  final CpeVibController controller;

  const ChannelsDisplayModeCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Visualizzazione canali',
            subtitle: state.settings.sixChannelsMode
                ? 'Attualmente impostata su 6 canali'
                : 'Attualmente impostata su 3 canali',
            icon: Icons.tune,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ChannelsModeToggle(
              isSixChannels: state.settings.sixChannelsMode,
              onChanged: (_) => controller.toggleSixChannelsMode(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelsModeToggle extends StatelessWidget {
  final bool isSixChannels;
  final ValueChanged<bool> onChanged;

  const ChannelsModeToggle({
    super.key,
    required this.isSixChannels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    Widget segment({
      required bool selected,
      required String label,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x220D47A1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 14,
                  vertical: compact ? 11 : 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: compact ? 16 : 18,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 12 : 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 170 : 190,
        maxWidth: compact ? 210 : 230,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            selected: !isSixChannels,
            label: '3 CH',
            icon: Icons.view_week_outlined,
            onTap: () {
              if (isSixChannels) onChanged(false);
            },
          ),
          const SizedBox(width: 4),
          segment(
            selected: isSixChannels,
            label: '6 CH',
            icon: Icons.grid_view_rounded,
            onTap: () {
              if (!isSixChannels) onChanged(true);
            },
          ),
        ],
      ),
    );
  }
}
