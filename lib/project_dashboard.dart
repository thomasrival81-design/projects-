import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDashboardPage extends StatefulWidget {
  const ProjectDashboardPage({super.key});

  @override
  State<ProjectDashboardPage> createState() => _ProjectDashboardPageState();
}

class _ProjectDashboardPageState extends State<ProjectDashboardPage> {
  static const _bg = Color(0xFF070707);
  static const _panel = Color(0xFF0D0D0D);
  static const _line = Color(0xFF272727);
  static const _muted = Color(0xFF858585);
  bool _depth = false;

  void _goLogin() => Navigator.pushNamed(context, '/login');

  Future<void> _open(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _DashboardGridPainter())),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _panel,
                        border: Border.all(color: _line),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, color: Color(0xFF20C878), size: 10),
                        SizedBox(width: 10),
                        Text('v7.5.0  ·  ONLINE',
                          style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2.2)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Center(
                    child: Container(
                      width: 190, height: 190, padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.white.withOpacity(.08), blurRadius: 28)],
                      ),
                      child: ClipOval(child: Image.asset(
                        'assets/images/pinzx_rat_bug.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white, size: 80),
                      )),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('PINZX PROJECT', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w700, letterSpacing: .6)),
                  const SizedBox(height: 18),
                  Center(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.3), borderRadius: BorderRadius.circular(28)),
                    child: const Text('✦  PREMIUM TOOLS EDITION',
                      style: TextStyle(color: Colors.white, letterSpacing: 1.6, fontSize: 12)),
                  )),
                  const SizedBox(height: 24),
                  const Text('Advanced toolkit untuk profesional.\nAll-in-one di satu aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 15, height: 1.7, letterSpacing: 1.0, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 28),
                  const Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: [
                    _Pill(icon: Icons.bolt, label: 'Fast', color: Color(0xFFFFB21A)),
                    _Pill(icon: Icons.shield, label: 'Secure', color: Color(0xFF20C878)),
                    _Pill(icon: Icons.verified, label: 'Trusted', color: Color(0xFF3D8BFF)),
                  ]),
                  const SizedBox(height: 48),
                  const _SectionTitle('FITUR UNGGULAN', accent: Color(0xFFEF4655)),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .98,
                    children: const [
                      _FeatureCard(icon: Icons.bug_report, number: '01', title: 'WhatsApp\nCrash', subtitle: 'Advanced payload', color: Color(0xFFEF4655)),
                      _FeatureCard(icon: Icons.phone_android, number: '02', title: 'RAT\nControl', subtitle: 'Remote access', color: Color(0xFFB05BEB)),
                      _FeatureCard(icon: Icons.search, number: '03', title: 'OSINT\nTools', subtitle: 'Deep investigation', color: Color(0xFF438CFF)),
                      _FeatureCard(icon: Icons.bolt, number: '04', title: 'DDoS\nPanel', subtitle: 'Network tools', color: Color(0xFFFFB21A)),
                    ],
                  ),
                  const SizedBox(height: 42),
                  Row(children: const [
                    _SectionTitle('OUR TEAM', accent: Color(0xFFB05BEB)),
                    SizedBox(width: 12),
                    _OutlinedLabel('OFFICIAL', color: Color(0xFFB05BEB)),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Kenali tim di balik PINZX PROJECTS',
                    style: TextStyle(color: _muted, letterSpacing: .8, fontSize: 13)),
                  const SizedBox(height: 20),
                  const _TeamCard(name: 'herstore', role: 'DEVELOPER', handle: '@herstore188', color: Color(0xFFB05BEB), icon: Icons.code),
                  const SizedBox(height: 14),
                  const _TeamCard(name: 'iqbal', role: 'PEMILIK', handle: '@policelrzo', color: Color(0xFFEF4655), icon: Icons.workspace_premium),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.3), borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _Stat(value: '10.0K+', label: 'USERS'),
                      _Stat(value: '30+', label: 'TOOLS'),
                      _Stat(value: '99%', label: 'UPTIME'),
                      _Stat(value: '5.0', label: 'RATING'),
                    ]),
                  ),
                  const SizedBox(height: 50),
                  const _SectionTitle('KENAPA PILIH KAMI', accent: Color(0xFFEF4655)),
                  const SizedBox(height: 18),
                  const _ReasonCard(icon: Icons.speed, title: 'Blazing Fast', subtitle: 'Server dengan latensi rendah, respons instan', color: Color(0xFFEF4655)),
                  const SizedBox(height: 14),
                  const _ReasonCard(icon: Icons.security, title: 'Secure & Private', subtitle: 'Data terenkripsi, sesi terkontrol per device', color: Color(0xFF20C878)),
                  const SizedBox(height: 14),
                  const _ReasonCard(icon: Icons.update, title: 'Regular Updates', subtitle: 'Fitur baru dan perbaikan rutin setiap minggu', color: Color(0xFF438CFF)),
                  const SizedBox(height: 14),
                  const _ReasonCard(icon: Icons.support_agent, title: '24/7 Support', subtitle: 'Tim support siap membantu kapan saja', color: Color(0xFFB05BEB)),
                  const SizedBox(height: 34),
                  SizedBox(height: 66, child: _StartButton(onPressed: _goLogin)),
                  const SizedBox(height: 14),
                  SizedBox(height: 58, child: OutlinedButton.icon(
                    onPressed: () => _open('https://t.me/'),
                    icon: const Icon(Icons.headset_mic_outlined),
                    label: const Text('CONTACT SUPPORT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _line, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(letterSpacing: 1.5, fontSize: 13),
                    ),
                  )),
                  const SizedBox(height: 14),
                  Center(child: OutlinedButton.icon(
                    onPressed: () => setState(() => _depth = !_depth),
                    icon: const Icon(Icons.view_in_ar_outlined, size: 18),
                    label: Text(_depth ? '3D DEPTH: ON' : 'TOGGLE 3D DEPTH'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _depth ? const Color(0xFF202020) : _panel,
                      side: const BorderSide(color: _line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                  )),
                  const SizedBox(height: 38),
                  Row(children: const [
                    Expanded(child: Divider(color: _line)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('SECURED BY', style: TextStyle(color: _muted, letterSpacing: 2.5))),
                    Expanded(child: Divider(color: _line)),
                  ]),
                  const SizedBox(height: 22),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text('PINZX PROJECT SECURITY', style: TextStyle(color: Colors.white, letterSpacing: 1.4, fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),
                  const Text('© 2026 PINZX PROJECT. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF666666), fontSize: 11, letterSpacing: .8)),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.rocket_launch, color: Colors.black),
    label: const Text('GET STARTED NOW'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 8,
      shadowColor: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      textStyle: const TextStyle(fontSize: 15, letterSpacing: 2.0, fontWeight: FontWeight.w600),
    ),
  );
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
    decoration: BoxDecoration(color: _panel, border: Border.all(color: _line), borderRadius: BorderRadius.circular(28)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 17), const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1)),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color accent;
  const _SectionTitle(this.title, {required this.accent});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 5, height: 29, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(5))),
    const SizedBox(width: 12),
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 1.6)),
  ]);
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String number, title, subtitle;
  final Color color;
  const _FeatureCard({required this.icon, required this.number, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: _panel, border: Border.all(color: _line, width: 1.3), borderRadius: BorderRadius.circular(19)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(border: Border.all(color: color.withOpacity(.7), width: 1.5), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF151515), border: Border.all(color: _line), borderRadius: BorderRadius.circular(7)), child: Text(number, style: const TextStyle(color: _muted, fontSize: 10))),
      ]),
      const Spacer(),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.15)),
      const SizedBox(height: 7),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11, height: 1.4)),
    ]),
  );
}

class _TeamCard extends StatelessWidget {
  final String name, role, handle;
  final Color color;
  final IconData icon;
  const _TeamCard({required this.name, required this.role, required this.handle, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: _panel, border: Border.all(color: _line, width: 1.3), borderRadius: BorderRadius.circular(19)),
    child: Row(children: [
      Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)), child: Icon(icon, color: color, size: 28)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 21)),
        const SizedBox(height: 8),
        Wrap(spacing: 9, runSpacing: 5, crossAxisAlignment: WrapCrossAlignment.center, children: [
          _OutlinedLabel(role, color: color),
          Text(handle, style: const TextStyle(color: _muted, fontSize: 12)),
        ]),
      ])),
      Icon(Icons.arrow_forward, color: color),
    ]),
  );
}

class _OutlinedLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _OutlinedLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(border: Border.all(color: color.withOpacity(.8)), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1.2)),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Text(label, style: const TextStyle(color: _muted, fontSize: 8, letterSpacing: 1.6)),
  ]);
}

class _ReasonCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _ReasonCard({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: _panel, border: Border.all(color: _line, width: 1.3), borderRadius: BorderRadius.circular(19)),
    child: Row(children: [
      Container(width: 58, height: 58, decoration: BoxDecoration(border: Border.all(color: color.withOpacity(.65), width: 1.5), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 25)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 17)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
      ])),
    ]),
  );
}

class _DashboardGridPainter extends CustomPainter {
  const _DashboardGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF202020)..strokeWidth = .65;
    const step = 48.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
