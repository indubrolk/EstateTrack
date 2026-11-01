import 'package:flutter/material.dart';

import '../../attendance/presentation/attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF12633B);
  static const Color dark = Color(0xFF142338);
  static const Color background = Color(0xFFF7F9FF);

  int _selectedIndex = 0;
  String _language = 'EN';

  // Development-only mock data.
  final int totalCrew = 48;
  final int presentWorkers = 42;
  final int absentWorkers = 6;
  final double totalWeight = 845.5;
  final int pendingRecords = 32;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFCCEBD9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_done_outlined, size: 16, color: green),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: green,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: green, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'EstateTrack · Home',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                initialValue: _language,
                onSelected: (value) {
                  setState(() => _language = value);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'EN', child: Text('English')),
                  PopupMenuItem(value: 'SI', child: Text('සිංහල')),
                  PopupMenuItem(value: 'TA', child: Text('தமிழ்')),
                ],
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EDFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _language,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: dark),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const CircleAvatar(
                backgroundColor: Color(0xFFCDEAD9),
                child: Icon(Icons.person, color: green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusChip('Offline Preview'),
              const Text(
                'DIV 04 · PEDRO',
                style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: dark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: green, size: 19),
              SizedBox(width: 8),
              Text(
                'MORNING MUSTER · SHIFT 1',
                style: TextStyle(
                  color: green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Good Morning, Supervisor!',
            style: TextStyle(
              color: dark,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            MaterialLocalizations.of(context).formatMediumDate(DateTime.now()),
            style: const TextStyle(color: Color(0xFF455249), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on_outlined, color: green, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Assignment',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5A665E),
                        ),
                      ),
                      Text(
                        'Highland Valley · Pedro Div 04B',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFCDEAD9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, size: 11, color: green),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Offline Preview · Demo data only',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: green,
              ),
            ),
          ),
          Icon(Icons.info_outline, size: 20, color: green),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconBackground,
    required Color valueColor,
    required String footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEBEEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: dark,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: iconBackground,
                child: Icon(icon, color: valueColor, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(color: dark, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            footer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF5B7061), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statistics() {
    final cards = [
      _statCard(
        label: 'TOTAL CREW',
        value: '$totalCrew',
        unit: 'plucking',
        icon: Icons.groups_outlined,
        iconBackground: const Color(0xFFE4EDFF),
        valueColor: dark,
        footer: 'Assigned Block 4B',
      ),
      _statCard(
        label: 'PRESENT',
        value: '$presentWorkers',
        unit: 'workers',
        icon: Icons.check_circle_outline,
        iconBackground: const Color(0xFFCDEAD9),
        valueColor: green,
        footer: '91% Turnout · Demo',
      ),
      _statCard(
        label: 'ABSENT',
        value: '$absentWorkers',
        unit: 'workers',
        icon: Icons.person_off_outlined,
        iconBackground: const Color(0xFFFFDDDA),
        valueColor: const Color(0xFFC62525),
        footer: '4 Medical · 2 Leave',
      ),
      _statCard(
        label: 'PLUCK WEIGHT',
        value: totalWeight.toStringAsFixed(1),
        unit: 'KG',
        icon: Icons.scale_outlined,
        iconBackground: const Color(0xFFFFDDB9),
        valueColor: dark,
        footer: '+12% Target · Demo',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;

        // Let cards grow vertically to fit their content on narrow screens.
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  Widget _syncBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF986000),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sync_problem, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingRecords Weighments Pending',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: dark,
                  ),
                ),
                const Text(
                  'Sample records · Not connected',
                  style: TextStyle(fontSize: 11, color: Color(0xFF56616B)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                _showDemoMessage('Synchronization is not connected yet.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: dark, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF647067),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFE5EDFF),
                child: Icon(Icons.chevron_right, color: dark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dailyActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Daily Field Actions',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
        ),
        _actionTile(
          icon: Icons.how_to_reg_outlined,
          title: 'Mark Attendance',
          subtitle: 'Record daily morning muster',
          iconBackground: const Color(0xFFCDEAD9),
          onTap: () => _selectTab(1),
        ),
        _actionTile(
          icon: Icons.scale_outlined,
          title: 'Record Tea Weight',
          subtitle: 'Session 2 weighment',
          iconBackground: const Color(0xFFFFDDB9),
          onTap: () => _showDemoMessage('Tea collection module coming next.'),
        ),
        _actionTile(
          icon: Icons.badge_outlined,
          title: 'View Workers',
          subtitle: 'Worker directory and details',
          iconBackground: const Color(0xFFDCE7FF),
          onTap: () => _selectTab(2),
        ),
        _actionTile(
          icon: Icons.cloud_upload_outlined,
          title: 'Sync Records',
          subtitle: '$pendingRecords sample items',
          iconBackground: const Color(0xFFCDEAD9),
          onTap: () =>
              _showDemoMessage('Synchronization is not connected yet.'),
        ),
      ],
    );
  }

  Widget _fieldConditions() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field Conditions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 135,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF407C52), Color(0xFF95BE74)],
              ),
            ),
            child: const Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 18,
                  child: Icon(Icons.eco, color: Colors.white70, size: 58),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  right: 14,
                  child: Text(
                    'Weather integration not configured',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _musterLog() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Muster Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(height: 12),
          _logTile(
            icon: Icons.check_circle_outline,
            title: 'Block 4B Morning Muster',
            subtitle: 'Demo: 42 present, 6 absent',
            time: '07:30 AM',
            color: const Color(0xFFCDEAD9),
          ),
          const SizedBox(height: 8),
          _logTile(
            icon: Icons.scale_outlined,
            title: 'Session 1 Weighment',
            subtitle: 'Demo: 412.0 kg recorded',
            time: '09:45 AM',
            color: const Color(0xFFFFDDB9),
          ),
        ],
      ),
    );
  }

  Widget _logTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: dark, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Color(0xFF647067)),
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
      children: [
        _welcomeCard(),
        _offlineBanner(),
        _statistics(),
        _syncBanner(),
        _dailyActions(),
        _fieldConditions(),
        _musterLog(),
      ],
    );
  }

  Widget _placeholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_outlined, size: 55, color: green),
          const SizedBox(height: 12),
          Text(
            '$title Module',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const Text('Coming soon'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _homeContent(),
      const AttendanceScreen(),
      _placeholder('Workers'),
      _placeholder('Profile'),
    ];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0) _header(),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        indicatorColor: const Color(0xFFCDEAD9),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Workers',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
