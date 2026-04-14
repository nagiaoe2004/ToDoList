import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _registerMode = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submitByMode() {
    if (_busy) return Future<void>.value();
    return _registerMode ? _submitRegister() : _submitLogin();
  }

  Future<void> _submitLogin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final AppController app = context.read<AppController>();
    final String? err = await app.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  Future<void> _submitRegister() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final AppController app = context.read<AppController>();
    final String? err = await app.signUp(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 760;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const HelioGradientHero(
              title: 'Helio Todo',
              subtitle: 'Đăng nhập hoặc đăng ký để đồng bộ công việc',
            ),
            const SizedBox(height: 14),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 520 : 640),
                child: HelioSheet(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SegmentedButton<bool>(
                          segments: const <ButtonSegment<bool>>[
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Đăng nhập'),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Đăng ký'),
                            ),
                          ],
                          selected: <bool>{_registerMode},
                          onSelectionChanged: (Set<bool> val) {
                            setState(() {
                              _registerMode = val.first;
                              _error = null;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        if (_registerMode) ...<Widget>[
                          TextField(
                            controller: _name,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_phoneFocus),
                            decoration: const InputDecoration(
                              hintText: 'Họ và tên',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phone,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_emailFocus),
                            decoration: const InputDecoration(
                              hintText: 'Số điện thoại',
                              prefixIcon: Icon(Icons.phone_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _email,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_passwordFocus),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitByMode(),
                          decoration: const InputDecoration(
                            hintText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _busy ? null : _submitByMode,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _registerMode ? 'Tạo tài khoản' : 'Đăng nhập',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
