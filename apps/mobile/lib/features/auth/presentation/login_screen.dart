import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

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
  bool _submitted = false;
  String _division = 'upper';
  Locale? _lastLocale;

  static const green = Color(0xFF12633B);
  static const dark = Color(0xFF142338);
  static const background = Color(0xFFF7F9FF);
  static const fieldBackground = Color(0xFFEDF2FE);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_submitted && _lastLocale != locale) {
      // Wait until the fields have received their translated validators.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.validate();
      });
    }
    _lastLocale = locale;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    // UI demo only. No real authentication yet.
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginDemo)),
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

  Widget _languageButton(String code, String language) {
    final selected = Localizations.localeOf(context).languageCode == code;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? green : Colors.transparent,
          animationDuration: const Duration(milliseconds: 220),
          borderRadius: BorderRadius.circular(15),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('language-$code'),
            onTap: () {
              changeLanguage(code);
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
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
        ),
      ),
    );
  }

  Widget _divisionButton(String division, String label) {
    final selected = _division == division;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          key: ValueKey('division-$division'),
          onTap: () => setState(() {
            _division = division;
          }),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE1F1E8) : fieldBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  // Give each language enough room for its native script.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDEAD9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_done_outlined,
                          color: green,
                          size: 21,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            l10n.localStorage,
                            style: const TextStyle(
                              color: Color(0xFF416853),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEE9FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _languageButton('en', 'English'),
                        _languageButton('si', 'සිංහල'),
                        _languageButton('ta', 'தமிழ்'),
                      ],
                    ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.eco, size: 52, color: green),
                          Text(
                            l10n.appName,
                            style: const TextStyle(
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

                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: dark,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    l10n.appSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.landscape_outlined,
                          color: green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.regionName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          color: Color(0xFF70450B),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.fieldMode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34210C),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                l10n.offlineMessage,
                                style: const TextStyle(
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
                      autovalidateMode: _submitted
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionLabel(Icons.badge_outlined, l10n.username),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const ValueKey('username'),
                            controller: _usernameController,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                            decoration: InputDecoration(
                              errorMaxLines: 3,
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
                                return l10n.usernameRequired;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          _sectionLabel(Icons.key_outlined, l10n.pin),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const ValueKey('pin'),
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
                              hintText: l10n.pinHint,
                              hintMaxLines: 2,
                              hintStyle: const TextStyle(
                                color: Color(0xFFABB6AA),
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                              errorMaxLines: 3,
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
                                tooltip: _showPin ? l10n.hidePin : l10n.showPin,
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
                                return l10n.pinInvalid;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.secureVault,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.pinResetUnavailable),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n.resetPin,
                                  style: const TextStyle(
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
                            l10n.assignedDivision,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _divisionButton('upper', l10n.upperDivision),
                              const SizedBox(width: 9),
                              _divisionButton('valley', l10n.valleyDivision),
                            ],
                          ),

                          const SizedBox(height: 24),

                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 65),
                            child: ElevatedButton.icon(
                              onPressed: _login,
                              icon: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              label: Text(
                                l10n.login,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.bluetoothScales,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: dark,
                                ),
                              ),
                              Text(
                                l10n.connectionNotChecked,
                                style: const TextStyle(
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

                  Text(
                    l10n.helpline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF566157),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.developmentPreview,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
