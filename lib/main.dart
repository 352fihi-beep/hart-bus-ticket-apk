import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const HartApp());
}

class HartApp extends StatelessWidget {
  const HartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HART Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const TicketScreen(),
    );
  }
}

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late DateTime _displayedTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Expand / Contract pulse matching original HART recording
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start at 9:37:59 AM (matches original video)
    final now = DateTime.now();
    _displayedTime = DateTime(now.year, now.month, now.day, 9, 37, 59);

    // Sequential continuous ticking
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _displayedTime = _displayedTime.add(const Duration(seconds: 1));
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  void _openTimeDialog() {
    int currentHour = _displayedTime.hour % 12;
    if (currentHour == 0) currentHour = 12;
    int currentMin = _displayedTime.minute;
    int currentSec = _displayedTime.second;
    bool isPm = _displayedTime.hour >= 12;

    final hCtrl = TextEditingController(text: currentHour.toString());
    final mCtrl = TextEditingController(text: currentMin.toString().padLeft(2, '0'));
    final sCtrl = TextEditingController(text: currentSec.toString().padLeft(2, '0'));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2229),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Set Ticket Clock',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _timeInput(hCtrl, 'HH'),
                      const Text(' : ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      _timeInput(mCtrl, 'MM'),
                      const Text(' : ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      _timeInput(sCtrl, 'SS'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('AM'),
                        selected: !isPm,
                        selectedColor: const Color(0xFF1F3A60),
                        labelStyle: TextStyle(
                            color: !isPm ? Colors.white : Colors.grey),
                        onSelected: (selected) {
                          if (selected) setDialogState(() => isPm = false);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('PM'),
                        selected: isPm,
                        selectedColor: const Color(0xFF1F3A60),
                        labelStyle: TextStyle(
                            color: isPm ? Colors.white : Colors.grey),
                        onSelected: (selected) {
                          if (selected) setDialogState(() => isPm = true);
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3A60),
                  ),
                  onPressed: () {
                    int h = int.tryParse(hCtrl.text) ?? 12;
                    int m = int.tryParse(mCtrl.text) ?? 0;
                    int s = int.tryParse(sCtrl.text) ?? 0;
                    if (h > 12) h = 12;
                    if (h < 1) h = 1;
                    if (m > 59) m = 59;
                    if (s > 59) s = 59;

                    int finalHour =
                        isPm ? (h == 12 ? 12 : h + 12) : (h == 12 ? 0 : h);

                    final now = DateTime.now();
                    setState(() {
                      _displayedTime = DateTime(
                          now.year, now.month, now.day, finalHour, m, s);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Set Time',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _timeInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 52,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 2,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1F3A60)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top White Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HART',
                                style: TextStyle(
                                  color: Color(0xFFD0D0D0),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Show operator your ticket',
                                style: TextStyle(
                                  color: Color(0xFFC0C0C0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings,
                                color: Color(0xFFD0D0D0), size: 24),
                            onPressed: _openTimeDialog,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Animating Expand/Contract Donut Ring
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: CustomPaint(
                                size: const Size(210, 210),
                                painter: RingPainter(),
                              ),
                            ),
                            // Center logo
                            Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D3F72),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'HART',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Live Clock
                      Text(
                        _formatTime(_displayedTime),
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Local Bus button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Local Bus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom Dark Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23262B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tampa, FL',
                        style: TextStyle(
                          color: Color(0xFFA0A5B1),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Adult Local 1 Day',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Expires tomorrow, 3:00 AM',
                        style: TextStyle(
                          color: Color(0xFFC0C5D0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 22;

    final ringPaint = Paint()
      ..color = const Color(0xFF1D3F72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38.0;

    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
