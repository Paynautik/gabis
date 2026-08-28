filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Overwrite _installmentRow Sarah Okafor action handler to trigger a highly interactive simulated Robot Call!
old_sarah_on_tap = """          _installmentRow(
            name: 'Sarah Okafor',
            service: 'E-commerce Audit',
            amountPaid: '₦50,000',
            amountRemaining: '₦50,000',
            deadline: 'OVERDUE (1d)',
            color: Colors.redAccent,
            actionText: 'Review Service Status',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Review Service Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const Text(
                    'Sarah Okafor\\'s installment deadline has passed. Review the customer\\'s service status.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Restrict Client Access', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Extend Deadline', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),"""

new_sarah_on_tap = """          _installmentRow(
            name: 'Sarah Okafor',
            service: 'E-commerce Audit',
            amountPaid: '₦50,000',
            amountRemaining: '₦50,000',
            deadline: 'OVERDUE (1d)',
            color: Colors.redAccent,
            actionText: 'Trigger AI Voice Call',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const _RobotCallSimulatorDialog(
                  customerName: 'Sarah Okafor',
                  phoneNumber: '+234 803 241 8902',
                  debtAmount: '₦50,000',
                  serviceName: 'E-commerce Audit',
                ),
              );
            },
          ),"""

content = content.replace(old_sarah_on_tap, new_sarah_on_tap)

# Append _RobotCallSimulatorDialog class at the end of the file
robot_dialog_class = """
// ============================================================
// AI VOICE REMINDER / ROBOT CALL SIMULATOR DIALOG
// ============================================================
class _RobotCallSimulatorDialog extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  final String debtAmount;
  final String serviceName;

  const _RobotCallSimulatorDialog({
    required this.customerName,
    required this.phoneNumber,
    required this.debtAmount,
    required this.serviceName,
  });

  @override
  State<_RobotCallSimulatorDialog> createState() => _RobotCallSimulatorDialogState();
}

class _RobotCallSimulatorDialogState extends State<_RobotCallSimulatorDialog> {
  int _callStep = 0; // 0: Preview, 1: Connecting, 2: Ringing, 3: Answered, 4: Recited, 5: Completed
  bool _isMuted = false;

  void _startRobotCall() async {
    setState(() => _callStep = 1);
    await Future.delayed(const Duration(seconds: 1.5));
    if (!mounted) return;
    setState(() => _callStep = 2);
    await Future.delayed(const Duration(seconds: 1.5));
    if (!mounted) return;
    setState(() => _callStep = 3);
    await Future.delayed(const Duration(seconds: 2.0));
    if (!mounted) return;
    setState(() => _callStep = 4);
    await Future.delayed(const Duration(seconds: 2.0));
    if (!mounted) return;
    setState(() => _callStep = 5);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 400,
        child: _callStep == 0 ? _buildCallPreview() : _buildActiveCallSimulator(),
      ),
    );
  }

  Widget _buildCallPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.ring_volume_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Voice Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Send an automated robot call reminder to ${widget.customerName} regarding their overdue balance of ${widget.debtAmount}.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        const Text('VOICE CALL SCRIPT PREVIEW:', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
          child: Text(
            '"Hello ${widget.customerName}, this is an automated voice reminder from Adebayo Retail. Your installment payment of ${widget.debtAmount} for ${widget.serviceName} is overdue. Please settle this balance via elumo.to/p/sarah-59. Thank you."',
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, fontStyle: FontStyle.italic, height: 1.45),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _startRobotCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.phone_forwarded_rounded, size: 14),
              label: const Text('Initiate Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveCallSimulator() {
    String callStatusText = 'Connecting...';
    Color pulseColor = Colors.amber;
    IconData stepIcon = Icons.phone_callback_rounded;

    if (_callStep == 1) {
      callStatusText = 'Dialing ${widget.phoneNumber}...';
      pulseColor = Colors.amber;
    } else if (_callStep == 2) {
      callStatusText = 'Ringing...';
      pulseColor = Colors.cyan;
    } else if (_callStep == 3) {
      callStatusText = 'Customer Answered • Reciting Script';
      pulseColor = const Color(0xFF10B981);
    } else if (_callStep == 4) {
      callStatusText = 'Reading Script... (80% read)';
      pulseColor = const Color(0xFF10B981);
    } else if (_callStep == 5) {
      callStatusText = 'Call Finished • Status: Acknowledged';
      pulseColor = const Color(0xFF10B981);
      stepIcon = Icons.check_circle_rounded;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Pulsing phone animation
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, val, child) {
            return Transform.scale(scale: _callStep == 5 ? 1.0 : val, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: pulseColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(stepIcon, color: pulseColor, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        Text(widget.customerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(widget.phoneNumber, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 16),
        Text(callStatusText, style: TextStyle(color: pulseColor, fontSize: 13.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        // Checklist progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _stepItem('[✓] Dialing recipient', _callStep >= 1),
              const SizedBox(height: 6),
              _stepItem('[✓] Ringing', _callStep >= 2),
              const SizedBox(height: 6),
              _stepItem('[✓] Answered by customer', _callStep >= 3),
              const SizedBox(height: 6),
              _stepItem('[✓] AI Voice reciting script', _callStep >= 4),
              const SizedBox(height: 6),
              _stepItem('[✓] Call finished & logged', _callStep >= 5),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(_isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white60),
              onPressed: () => setState(() => _isMuted = !_isMuted),
            ),
            if (_callStep == 5)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hang Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepItem(String text, bool active) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: active ? const Color(0xFF10B981) : const Color(0xFF475569),
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          text.substring(4),
          style: TextStyle(
            color: active ? Colors.white70 : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
"""

content = content + "\n\n" + robot_dialog_class

with open(filepath, 'w') as f:
    f.write(content)

print("AI Voice Reminder Simulator class successfully appended.")
