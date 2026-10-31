import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLogin});

  final VoidCallback? onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'SUP-4029');
  final _pinController = TextEditingController();

  bool _showPin = false;
  String _language = 'English';
  String _division = 'Upper Div #04';

  static const green = Color(0xFF12633B);
  static const dark = Color(0xFF142338);
  static const background = Color(0xFFF7F9FF);
  static const fieldBackground = Color(0xFFEDF2FE);

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    // UI demo only. No real authentication yet.
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login UI ready. Connect authentication next.'),
        ),
      );
    }
  }

  OutlineInputBorder _fieldBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _sectionLabel(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 21, color: green),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: dark,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _languageButton(String language) {
    final selected = _language == language;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _language = language);
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            language,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? Colors.white : dark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _divisionButton(String division) {
    final selected = _division == division;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _division = division;
        }),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE1F1E8) : fieldBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  division,
                  style: TextStyle(
                    color: selected ? green : dark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: selected ? green : Colors.grey,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top status and language selection
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDEAD9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.cloud_done_outlined,
                                color: green,
                                size: 21,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'LOCAL STORAGE\nACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFF416853),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDEE9FE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _languageButton('English'),
                              _languageButton('සිංහල'),
                              _languageButton('தமிழ்'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // EstateTrack logo
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.09),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 52, color: green),
                          Text(
                            'EstateTrack',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'EstateTrack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: dark,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Smart Plantation Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF465148),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EDFF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.landscape_outlined, color: green, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Nuwara Eliya Regional Plantations',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Offline information
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDDB6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: Color(0xFF70450B),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Field Mode Enabled',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34210C),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Offline-ready: Sign in with your saved supervisor PIN without internet connectivity.',
                                style: TextStyle(
                                  height: 1.5,
                                  fontSize: 13,
                                  color: Color(0xFF684009),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionLabel(
                            Icons.badge_outlined,
                            'Username or Field Supervisor ID',
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fieldBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              border: _fieldBorder(const Color(0xFFDCE5EF)),
                              enabledBorder: _fieldBorder(
                                const Color(0xFFDCE5EF),
                              ),
                              focusedBorder: _fieldBorder(green, 1.5),
                              errorBorder: _fieldBorder(
                                Theme.of(context).colorScheme.error,
                              ),
                              focusedErrorBorder: _fieldBorder(
                                Theme.of(context).colorScheme.error,
                                1.5,
                              ),
                              suffixIcon: const Icon(
                                Icons.manage_accounts_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your supervisor ID';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _sectionLabel(Icons.key_outlined, 'Password / PIN'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pinController,
                            obscureText: !_showPin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(
                              fontSize: 19,
                              letterSpacing: 4,
                              color: dark,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Enter 4-6 digit PIN',
                              hintStyle: const TextStyle(
                                color: Color(0xFFABB6AA),
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                              filled: true,
                              fillColor: fieldBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              border: _fieldBorder(const Color(0xFFDCE5EF)),
                              enabledBorder: _fieldBorder(
                                const Color(0xFFDCE5EF),
                              ),
                              focusedBorder: _fieldBorder(green, 1.5),
                              errorBorder: _fieldBorder(
                                Theme.of(context).colorScheme.error,
                              ),
                              focusedErrorBorder: _fieldBorder(
                                Theme.of(context).colorScheme.error,
                                1.5,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPin = !_showPin;
                                  });
                                },
                                icon: Icon(
                                  _showPin
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  !RegExp(r'^\d{4,6}$').hasMatch(value)) {
                                return 'Enter a valid 4-6 digit PIN';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Stored in secure offline vault',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'PIN reset is not connected yet.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Quick PIN Reset',
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _sectionLabel(
                            Icons.hub_outlined,
                            'Assigned Muster Division',
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _divisionButton('Upper Div #04'),
                              const SizedBox(width: 9),
                              _divisionButton('Valley West #02'),
                            ],
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 65,
                            child: ElevatedButton.icon(
                              onPressed: _login,
                              icon: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'LOGIN TO ESTATETRACK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                animationDuration: const Duration(
                                  milliseconds: 220,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bluetooth scales info
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8E8D7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bluetooth,
                            color: green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bluetooth Scales',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: dark,
                                ),
                              ),
                              Text(
                                'Connection not checked',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF546056),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.info_outline, color: green),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Estate Office Helpline',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF566157), fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'EstateTrack • Development Preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
