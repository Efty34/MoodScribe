import 'package:diary/notification/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationTestTile extends StatefulWidget {
  final ThemeData theme;
  final bool isDark;

  const NotificationTestTile({
    Key? key,
    required this.theme,
    required this.isDark,
  }) : super(key: key);

  @override
  State<NotificationTestTile> createState() => _NotificationTestTileState();
}

class _NotificationTestTileState extends State<NotificationTestTile> {
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? widget.theme.colorScheme.surfaceContainerHigh
            : widget.theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isTesting ? null : _sendTestNotification,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: widget.theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Send a test notification to verify your device settings',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: widget.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isTesting)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.theme.colorScheme.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    if (_isTesting) return;

    setState(() {
      _isTesting = true;
    });

    try {
      // First check permissions
      final hasPermission = await NotificationUtils.checkPermissions();
      if (!hasPermission) {
        await NotificationUtils.requestPermissions();
      }

      // Schedule a test notification for 5 seconds from now
      final scheduledDate = DateTime.now().add(const Duration(seconds: 5));

      final result = await NotificationUtils.scheduleTestNotification(
        scheduledDate: scheduledDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Test notification scheduled for 5 seconds from now'
                  : 'Failed to schedule test notification',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: result ? Colors.green[700] : Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }
}
