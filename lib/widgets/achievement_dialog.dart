import 'dart:math';
import 'package:flutter/material.dart';
import '../services/app_localizations.dart';
import 'widget_support.dart';

/// Hộp thoại chúc mừng cao cấp khi mở khóa thành tựu ẩn "Kẻ bóc lột người nghèo"
/// Tích hợp hiệu ứng thiết kế chuyển động (motion design) chuẩn chuyên nghiệp:
/// - Staggered entrance: Card trượt lên mượt mà, Badge bật nảy đàn hồi (elastic spring pop), Vương miện rơi từ trên cao xuống đầu Pio.
/// - Loop idle: Badge và vương miện bay bồng bềnh tự nhiên không đồng pha, quầng sáng xung quanh thở nhẹ (pulsing ambient glow).
/// - Sunburst: Các tia sáng mảnh mai tỏa ra mịn màng, chuyển động xoay chậm rãi thanh lịch kết hợp cùng Radial Gradient chuyển tiếp mờ ảo.
/// - Confetti: Mô phỏng vật lý chân thực (lực cản không khí, lắc lư trước gió, xoay lật 3D đổi hướng lật mặt đổ bóng tinh tế), rơi chậm rãi thanh tao.
class AchievementDialog extends StatefulWidget {
  const AchievementDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AchievementDialog(),
    );
  }

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> with TickerProviderStateMixin {
  // Hoạt ảnh xuất hiện phân tầng (Entrance Staggered Animations)
  late AnimationController _entranceController;
  late Animation<double> _cardOpacity;
  late Animation<double> _cardSlide;
  late Animation<double> _badgeScale;
  late Animation<double> _crownSlide;
  late Animation<double> _contentFade;

  // Hoạt ảnh bồng bềnh & thở nhẹ (Idle Floating & Pulsing Glow)
  late AnimationController _idleController;

  // Hoạt ảnh hào quang xoay tinh tế (Slow Majestic Rotation)
  late AnimationController _rotationController;

  // Hoạt ảnh điều phối chu kỳ hạt rơi (Confetti Simulation Tick)
  late AnimationController _confettiController;

  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Phân cảnh entrance tổng quát (1300ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _cardOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack), // overshoot trượt lên
    );

    _badgeScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.8, curve: Curves.elasticOut), // pop đàn hồi
    );

    _crownSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 0.85, curve: Curves.elasticOut), // rơi nhẹ lên đầu
    );

    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut), // nội dung & nút hiện sau
    );

    // 2. Chu kỳ bồng bềnh (Idle) của badge/crown & nhịp thở glow (4 giây)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 3. Chu kỳ hào quang xoay rất chậm rãi, sang trọng (24 giây một vòng)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // 4. Chu kỳ đồng bộ mô phỏng rơi hoa giấy
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _initializeParticles();

    // Kích hoạt chuỗi hoạt ảnh
    _entranceController.forward();
  }

  void _initializeParticles() {
    // 35 hạt là con số lý tưởng để tạo cảm giác sang trọng, thanh tao, tránh rối rắm
    for (int i = 0; i < 35; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          // Bắt đầu rải rác từ phía trên viewport
          y: -0.1 - _random.nextDouble() * 0.5,
          vx: (_random.nextDouble() - 0.5) * 0.003,
          vy: 0.0015 + _random.nextDouble() * 0.0025, // tốc độ rơi cực kỳ chậm rãi, bay bổng
          color: _getRandomColor(),
          size: 6.0 + _random.nextDouble() * 7.0,
          angle: _random.nextDouble() * 2 * pi, // góc xoay 3D lật
          rotationSpeed: 0.015 + _random.nextDouble() * 0.045, // xoay lật chậm
          yaw: _random.nextDouble() * 2 * pi, // góc quay trong mặt phẳng 2D
          yawSpeed: 0.01 + _random.nextDouble() * 0.03,
          swaySpeed: 1.2 + _random.nextDouble() * 1.8,
          swayWidth: 0.0008 + _random.nextDouble() * 0.0015,
          phase: _random.nextDouble() * 2 * pi,
          isCircle: _random.nextInt(3) == 0, // 30% hình tròn, 70% hình chữ nhật
        ),
      );
    }
  }

  Color _getRandomColor() {
    // Bảng màu metallic & neon cao cấp, không dùng màu gốc thô
    final colors = [
      const Color(0xFFFFD700), // Vàng hoàng kim
      const Color(0xFFFF6B6B), // Hồng san hô ấm
      const Color(0xFFFF007F), // Hồng cánh sen neon
      const Color(0xFF00F0FF), // Xanh băng cực quang
      const Color(0xFF9D00FF), // Tím vũ trụ thẫm
      const Color(0xFF39FF14), // Xanh lá lấp lánh
      const Color(0xFFFF9F0A), // Cam hoàng hôn rực rỡ
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _idleController.dispose();
    _rotationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isDark = AppWidget.isDark;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final double opacity = _cardOpacity.value;
        final double slideY = (1.0 - _cardSlide.value) * 90;
        
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideY),
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ----- Lớp phủ pháo giấy Confetti vật lý bay bổng tự nhiên -----
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    _updateParticles();
                    return CustomPaint(
                      painter: _ConfettiPainter(particles: _particles),
                    );
                  },
                ),
              ),
            ),

            // ----- Khung Dialog chính dạng Glassmorphism cao cấp -----
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.only(top: 48, bottom: 28, left: 24, right: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131526).withValues(alpha: 0.88) : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFD200).withValues(alpha: 0.28),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8008).withValues(alpha: 0.22),
                    blurRadius: 36,
                    spreadRadius: 1,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ----- Khu vực huy hiệu thiết kế động sinh động -----
                  _buildBadgeSection(),
                  const SizedBox(height: 18),

                  // ----- Khối thông tin văn bản trễ nhẹ sau hoạt ảnh badge -----
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _contentFade.value,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.t('badge.unlockedTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFF9000),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.t('badge.exploitTitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppWidget.primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.t('badge.exploitDesc'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppWidget.secondaryText,
                            fontSize: 13.5,
                            height: 1.55,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                        const SizedBox(height: 26),
                        
                        // Nút đóng sang trọng phản hồi tốt
                        _buildCloseButton(s),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng cụm huy hiệu kết hợp Rotating Sunburst mượt mà và Ambient Glow pulsing tự nhiên
  Widget _buildBadgeSection() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Quầng hào quang Sunburst mờ nhạt tỏa ra biên mềm mại (Xoay cực chậm)
          RotationTransition(
            turns: _rotationController,
            child: CustomPaint(
              size: const Size(176, 176),
              painter: _SunburstPainter(
                color: const Color(0xFFFFD200).withValues(alpha: 0.14),
                rayCount: 22, // Nhiều tia mảnh hơn
              ),
            ),
          ),

          // 2. Nhịp thở ambient glow tỏa ánh sáng ấm áp
          AnimatedBuilder(
            animation: _idleController,
            builder: (context, child) {
              final scale = 1.0 + sin(_idleController.value * 2 * pi) * 0.05;
              final opacity = 0.45 + sin(_idleController.value * 2 * pi) * 0.15;
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: 132 * scale,
                  height: 132 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF8008).withValues(alpha: 0.28),
                        const Color(0xFFFFD200).withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Thân chính của Badge (bật nhảy lúc đầu, trôi bồng bềnh lúc sau)
          AnimatedBuilder(
            animation: Listenable.merge([_entranceController, _idleController]),
            builder: (context, child) {
              final scale = _badgeScale.value;
              // Chuyển động bồng bềnh theo phương đứng (Sine wave)
              final idleOffset = sin(_idleController.value * 2 * pi) * 4.0;
              
              return Transform.scale(
                scale: scale,
                child: Transform.translate(
                  offset: Offset(0, idleOffset),
                  child: child,
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Viền vàng kim loại dạng lấp lánh (Shining Border)
                Container(
                  width: 114,
                  height: 114,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                        Color(0xFFFF8C00),
                        Color(0xFFFFD700),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8008).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF14172C),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/pio_poor.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Lớp mặt thủy tinh phản chiếu ánh sáng quét qua (Shimmer Sweep)
                AnimatedBuilder(
                  animation: _idleController,
                  builder: (context, child) {
                    // Quét luồng sáng ngang từ trái sang phải
                    final alignX = -2.5 + (_idleController.value * 5.0);
                    return ClipOval(
                      child: Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.16),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.38, 0.5, 0.62],
                            begin: Alignment(alignX - 0.4, -1.0),
                            end: Alignment(alignX + 0.4, 1.0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Vương miện hoàng gia rơi nhẹ và bồng bềnh lệch pha (Tạo cảm giác 3D tự nhiên)
          AnimatedBuilder(
            animation: Listenable.merge([_entranceController, _idleController]),
            builder: (context, child) {
              final scale = _badgeScale.value;
              final entranceY = (1.0 - _crownSlide.value) * -38.0;
              // Nhịp trôi bồng bềnh lệch pha với Badge 60 độ (pi/3) để trông lỏng lẻo chân thực hơn
              final idleY = sin((_idleController.value * 2 * pi) + (pi / 3)) * 2.0;

              return Positioned(
                top: 6,
                child: Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, entranceY + idleY),
                    child: const Text(
                      '👑',
                      style: TextStyle(
                        fontSize: 26,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(AppStrings s) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD200), Color(0xFFFF8008)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8008).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          s.t('badge.closeBtn'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro',
          ),
        ),
      ),
    );
  }

  void _updateParticles() {
    for (var p in _particles) {
      // Tích lũy trọng lực nhẹ nhàng
      p.vy += 0.00008;
      // Giới hạn tốc độ tối đa để tạo cảm giác trôi lững lờ
      if (p.vy > 0.008) p.vy = 0.008;

      // Độ dao động ngang tự nhiên theo chiều gió
      double sway = sin(_confettiController.value * p.swaySpeed * 2 * pi + p.phase) * p.swayWidth;
      
      p.x += p.vx + sway;
      p.y += p.vy;

      // Cập nhật góc lật 3D và quay phẳng 2D
      p.angle += p.rotationSpeed;
      p.yaw += p.yawSpeed;

      // Đưa hạt về đỉnh để lặp lại khi chìm dưới đáy
      if (p.y > 1.15) {
        p.y = -0.05;
        p.x = _random.nextDouble();
        p.vx = (_random.nextDouble() - 0.5) * 0.003;
        p.vy = 0.0012 + _random.nextDouble() * 0.002;
      }
      
      // Khóa tọa độ x tuần hoàn
      if (p.x < 0.0) p.x += 1.0;
      if (p.x > 1.0) p.x -= 1.0;
    }
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  final double size;
  double angle;          // Góc lật 3D quanh trục X
  final double rotationSpeed;
  double yaw;            // Góc quay 2D quanh tâm
  final double yawSpeed;
  final double swaySpeed;
  final double swayWidth;
  final double phase;
  final bool isCircle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.angle,
    required this.rotationSpeed,
    required this.yaw,
    required this.yawSpeed,
    required this.swaySpeed,
    required this.swayWidth,
    required this.phase,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      final offset = Offset(p.x * size.width, p.y * size.height);
      canvas.translate(offset.dx, offset.dy);
      
      // Xoay trong mặt phẳng 2D
      canvas.rotate(p.yaw);
      
      // Mô phỏng lật 3D bằng cách nén tỉ lệ chiều ngang theo Cosine góc quay
      final scaleX = cos(p.angle);
      canvas.scale(scaleX.abs(), 1.0);

      // Nếu hạt quay mặt sau (cos âm) thì làm đậm màu đi 25% để tạo hiệu ứng đổ bóng chiều sâu
      if (scaleX < 0) {
        paint.color = _darkenColor(p.color);
      }

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Vẽ dải ruy-băng bo tròn cạnh mảnh khảnh
        final rect = Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.45);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(p.size * 0.1)), paint);
      }
      canvas.restore();
    }
  }

  Color _darkenColor(Color c) {
    return Color.fromARGB(
      c.alpha,
      (c.red * 0.72).round(),
      (c.green * 0.72).round(),
      (c.blue * 0.72).round(),
    );
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Lớp vẽ hào quang Sunburst dạng tia thanh mảnh
/// Tích hợp mịn màng với Radial Gradient để các tia sáng biến mất mềm mại khi lan tỏa rộng
class _SunburstPainter extends CustomPainter {
  final Color color;
  final int rayCount;

  _SunburstPainter({required this.color, this.rayCount = 22});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = max(size.width, size.height) * 0.85;

    // Shader chuyển đổi mịn màng từ tâm ra biên
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final angleStep = 2 * pi / rayCount;

    for (int i = 0; i < rayCount; i++) {
      final startAngle = i * angleStep;
      // Chiếm khoảng 30% góc quạt, tạo ra tia sáng vô cùng mảnh dẻ, không thô thiển
      final sweepAngle = angleStep * 0.3;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rayCount != rayCount;
  }
}
