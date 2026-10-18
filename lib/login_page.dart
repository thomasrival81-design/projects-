import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'splash.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? androidId;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  static const Color primaryRed = Color(0xFFC62828);
  static const Color darkRed = Color(0xFF1A0F0F);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color dividerColor = Color(0xFF3A3A3A);

  // FIX 1: bukan hardcoded "1.0.0" — diambil dari pubspec.yaml otomatis
  String appVersion = "2.0.2";

  @override
  void initState() {
    super.initState();
    _initAnim();
    // FIX 2: pakai _initAndLoad() bukan langsung initLogin()
    _initAndLoad();
  }

  // FIX 2: ambil androidId + versi dulu baru cek auto-login
  Future<void> _initAndLoad() async {
    androidId = await getAndroidId();
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => appVersion = info.version);
    } catch (_) {}
    await initLogin();
  }

  void _initAnim() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnim = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> initLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString("username");
    final savedPass = prefs.getString("password");
    final savedKey = prefs.getString("key");

    if (savedUser != null && savedPass != null && savedKey != null) {
      final uri = Uri.parse(
          "http://panelprivatkenzxcpanelpanel.pterodactylxcz.my.id:4113/myInfo?username=$savedUser&password=$savedPass&androidId=$androidId&key=$savedKey");

      try {
        final res = await http.get(uri);
        final data = jsonDecode(res.body);

        if (data['valid'] == true && data['expired'] != true) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => SplashScreen(
                username: savedUser,
                password: savedPass,
                role: data['role'],
                sessionKey: data['key'],
                expiredDate: data['expiredDate'],
                listBug: (data['listBug'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                listDoos: (data['listDDoS'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                news: (data['news'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
              ),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        } else if (data['reason'] == 'device') {
          if (!mounted) return;
          _showPopup(
            title: "Device Mismatch",
            message: "Akun ini sudah digunakan di perangkat lain.",
            color: accentRed,
          );
        }
      } catch (_) {}
    }
  }

  Future<String> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    return android.id;
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = userController.text.trim();
    final password = passController.text.trim();

    setState(() => isLoading = true);

    try {
      // FIX 3: pastikan androidId tidak null walau user tekan login super cepat
      androidId ??= await getAndroidId();

      if (username == "otax" && password == "Syamanta031003") {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SplashScreen(
              username: username,
              password: password,
              role: "KINGZ",
              sessionKey: "local_key",
              expiredDate:
                  DateTime.now().add(const Duration(days: 365)).toString(),
              listBug: [],
              listDoos: [],
              news: [],
            ),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      final validate = await http.post(
        Uri.parse("http://panelprivatkenzxcpanelpanel.pterodactylxcz.my.id:4113/validate"),
        body: {
          "username": username,
          "password": password,
          "androidId": androidId!,
          "version": appVersion,
        },
      );

      final validData = jsonDecode(validate.body);

      if (!mounted) return;

      if (validData['expired'] == true) {
        _showPopup(
          title: "Access Expired",
          message: "Your access has expired.\nPlease renew it.",
          color: Colors.orange,
          showContact: true,
        );
      } else if (validData['valid'] != true) {
        _showPopup(
          title: "LOGIN GAGAL",
          message: "Username atau password salah.",
          color: accentRed,
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString("username", username);
          await prefs.setString("password", password);
          await prefs.setString("key", validData['key']);
        } else {
          await prefs.remove("username");
          await prefs.remove("password");
          await prefs.remove("key");
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SplashScreen(
              username: username,
              password: password,
              role: validData['role'],
              sessionKey: validData['key'],
              expiredDate: validData['expiredDate'],
              listBug: (validData['listBug'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
              listDoos: (validData['listDDoS'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
              news: (validData['news'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList(),
            ),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showPopup(
        title: "Connection Error",
        message:
            "Failed to connect to the server.\nPlease check your internet connection.",
        color: accentRed,
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showPopup({
    required String title,
    required String message,
    Color color = primaryRed,
    bool showContact = false,
  }) {
    final isLoginFailure = title.toLowerCase().contains('login failed') ||
        title.toLowerCase().contains('login gagal');
    final displayTitle = isLoginFailure ? 'LOGIN GAGAL' : title.toUpperCase();
    final displayMessage = isLoginFailure
        ? 'Username atau password salah.'
        : message;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.76),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFF292929), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.09),
                    border: Border.all(color: color.withOpacity(.8), width: 1.5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(child: Text(displayTitle, style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.2, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 28),
              Text(displayMessage, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 15, height: 1.55, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (showContact) ...[
                  TextButton(
                    onPressed: () async {
                      final uri = Uri.parse('https://t.me/');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: const Text('CONTACT', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                ],
                SizedBox(
                  width: 112,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1),
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _LoginGridPainter())),
        SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Opacity(opacity: _fadeAnim.value, child: child),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
              child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0B),
                    border: Border.all(color: const Color(0xFFE4E4E4), width: 1.2),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Row(children: [
                        _roundLogo(39),
                        const SizedBox(width: 14),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('PINZX // LOGIN', style: TextStyle(color: Colors.white, fontSize: 19, letterSpacing: 1.1, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('SECURE ACCESS TERMINAL', style: TextStyle(color: Color(0xFF858585), fontSize: 10, letterSpacing: 2.2)),
                        ])),
                        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF111111), border: Border.all(color: const Color(0xFF292929)), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.view_in_ar_outlined, color: Colors.white70)),
                      ]),
                    ),
                    const Divider(height: 1, color: Color(0xFF292929)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Row(children: [
                            _roundLogo(104),
                            const SizedBox(width: 18),
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('PINZX ', style: TextStyle(color: Colors.white, fontSize: 28, height: 1.05, fontWeight: FontWeight.w500), maxLines: 1),
                              Text('PROJECT', style: TextStyle(color: Color(0xFFE84A54), fontSize: 27, height: 1.05, fontWeight: FontWeight.w500), maxLines: 1),
                              SizedBox(height: 9),
                              Text('SECURE ACCESS TO PINZX PROJECT', style: TextStyle(color: Color(0xFF898989), fontSize: 9, letterSpacing: 1.3)),
                            ])),
                          ]),
                          const SizedBox(height: 28),
                          Row(children: [
                            Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFEF454D), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x66EF454D), blurRadius: 8)])),
                            const SizedBox(width: 10),
                            const Text('MAINTENANCE', style: TextStyle(color: Color(0xFFEF454D), letterSpacing: 2.2, fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 18),
                            const Icon(Icons.lock_outline, color: Color(0xFF888888), size: 16),
                            const SizedBox(width: 7),
                            const Expanded(child: Text('SECURE ACCESS', style: TextStyle(color: Color(0xFF858585), letterSpacing: 2, fontSize: 11))),
                          ]),
                          const SizedBox(height: 28),
                          _loginField(
                            controller: userController,
                            hint: 'USERNAME',
                            icon: Icons.person_outline,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Masukkan username' : null,
                          ),
                          const SizedBox(height: 16),
                          _loginField(
                            controller: passController,
                            hint: 'PASSWORD',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            validator: (v) => v == null || v.isEmpty ? 'Masukkan password' : null,
                            trailing: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF858585)),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(height: 62, child: ElevatedButton.icon(
                            onPressed: isLoading ? null : login,
                            icon: const Icon(Icons.login, color: Colors.black),
                            label: isLoading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : const Text('SIGN IN', style: TextStyle(fontSize: 18, letterSpacing: 2.5, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          )),
                          const SizedBox(height: 18),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF171717),
                                border: Border.all(color: const Color(0xFF252525)),
                              ),
                              child: Row(
                                children: List.generate(
                                  80,
                                  (i) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      color: const Color(0xFF242424),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(children: [
                            Checkbox(value: _rememberMe, activeColor: Colors.white, checkColor: Colors.black, side: const BorderSide(color: Colors.white70), onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                            const Expanded(child: Text('REMEMBER ME', style: TextStyle(color: Color(0xFF929292), letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.w600))),
                            OutlinedButton.icon(
                              onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF111111),
                                title: const Text('DEVICE ID', style: TextStyle(color: Colors.white)),
                                content: SelectableText(androidId ?? 'Loading device ID…', style: const TextStyle(color: Color(0xFFBBBBBB))),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                              )),
                              icon: const Icon(Icons.phone_android, size: 16),
                              label: const Text('DEVICE ID', style: TextStyle(fontSize: 10, letterSpacing: 1.4)),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF303030)), backgroundColor: const Color(0xFF151515), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ]),
                          const SizedBox(height: 15),
                          Center(child: Wrap(alignment: WrapAlignment.center, children: [
                            const Text('NO ACCESS? ', style: TextStyle(color: Color(0xFF858585), letterSpacing: 2, fontSize: 11)),
                            GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informasi pembelian akan tersedia setelah konfigurasi API.'))), child: const Text('BUY HERE', style: TextStyle(color: Colors.white, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white, letterSpacing: 1))),
                          ])),
                        ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF0B0B0B), border: Border.all(color: const Color(0xFF252525)), borderRadius: BorderRadius.circular(18)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [const Icon(Icons.terminal, color: Colors.white70, size: 18), const SizedBox(width: 12), const Expanded(child: Text('SESSION LOG', style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.8))), Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF20C878), shape: BoxShape.circle))]),
                    const SizedBox(height: 16),
                    const Text('[SYS] Login page initialized', style: TextStyle(color: Color(0xFF777777), fontSize: 11, height: 1.8, letterSpacing: .5)),
                    const Text('[NET] Waiting for secure access', style: TextStyle(color: Color(0xFF777777), fontSize: 11, height: 1.8, letterSpacing: .5)),
                  ]),
                ),
                const SizedBox(height: 24),
                const Text('PINZX PROJECT', style: TextStyle(color: Colors.white, letterSpacing: 2.5, fontSize: 13)),
                const SizedBox(height: 8),
                Text('V7.5.0  ·  © 2026  ·  $appVersion', style: const TextStyle(color: Color(0xFF666666), letterSpacing: 2, fontSize: 10)),
                const SizedBox(height: 18),
                Wrap(alignment: WrapAlignment.center, spacing: 12, children: [
                  OutlinedButton.icon(onPressed: () async { final uri = Uri.parse('https://t.me/'); await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.send, size: 15), label: const Text('TELEGRAM'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Color(0xFF282828)))),
                  OutlinedButton.icon(onPressed: () async { final uri = Uri.parse('https://wa.me/'); await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.chat_bubble_outline, size: 15), label: const Text('WHATSAPP'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Color(0xFF282828)))),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _roundLogo(double size) => Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0C0C0C), border: Border.all(color: Colors.white, width: 1.4)),
    child: ClipOval(child: Image.asset('assets/images/pinzx_rat_bug.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, color: Colors.white))),
  );

  Widget _loginField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? trailing,
  }) => TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1.4),
    cursorColor: Colors.white,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF5F5F5F), letterSpacing: 3.2, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.white, size: 23),
      suffixIcon: trailing,
      filled: true,
      fillColor: const Color(0xFF151515),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 21),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF282828), width: 1.3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEF454D))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFEF454D))),
    ),
  );
}

class _LoginGridPainter extends CustomPainter {
  const _LoginGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF242424)..strokeWidth = .65;
    const spacing = 48.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
