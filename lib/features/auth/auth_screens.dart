import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException, OtpType;

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../ui/common.dart';
import '../../ui/neu.dart';
import '../../ui/theme.dart';

/// Mise en page des écrans de compte : surface porcelaine, carte en relief
/// (« soft UI »), médaillon, champs creusés. Sur grand écran, la vitrine de
/// la marque occupe la moitié gauche.
class _AuthFrame extends StatelessWidget {
  const _AuthFrame({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
    this.ghostLabel,
    this.onGhost,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;

  /// Carte « Créer un compte » qui dépasse derrière (écran de connexion).
  final String? ghostLabel;
  final VoidCallback? onGhost;

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final card = NeuCard(
      padding: const EdgeInsets.fromLTRB(30, 34, 30, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: NeuCircle(icon: icon)),
        const SizedBox(height: 26),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(color: p.text)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: p.muted)),
        ],
        const SizedBox(height: 28),
        ...children,
        if (footer != null) ...[const SizedBox(height: 22), footer!],
      ]),
    );
    final stacked = ghostLabel == null
        ? card
        : Stack(clipBehavior: Clip.none, children: [
            Positioned(
              top: 34,
              bottom: 34,
              right: -34,
              width: 120,
              child: GestureDetector(
                onTap: onGhost,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(30), boxShadow: p.raised(8)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(ghostLabel!, style: TextStyle(color: p.muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                ),
              ),
            ),
            card,
          ]);
    final form = Container(
      color: p.base,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(padding: EdgeInsets.only(right: ghostLabel == null ? 0 : 26), child: stacked),
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: p.base,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: wide ? null : p.text,
        shape: const Border(),
        actions: const [LanguageMenuButton(), SizedBox(width: 8)],
      ),
      body: wide ? Row(children: [const Expanded(child: _BrandPanel()), Expanded(child: form)]) : form,
    );
  }
}

/// Vitrine de la marque (grand écran) : bordeaux nuit, or champagne.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB08A25), RestoColors.primary, RestoColors.primaryBright],
        ),
      ),
      padding: const EdgeInsets.all(56),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text('R', style: theme.textTheme.displaySmall?.copyWith(color: RestoColors.onPrimary)),
        ),
        const SizedBox(height: 28),
        Text(t.appName, style: theme.textTheme.displayMedium?.copyWith(color: RestoColors.onPrimary)),
        const SizedBox(height: 12),
        Text(t.brandTagline, style: theme.textTheme.titleLarge?.copyWith(color: RestoColors.onPrimary.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
        const SizedBox(height: 36),
        for (final (icon, text) in [
          (Icons.receipt_long_rounded, t.brandPoint1),
          (Icons.soup_kitchen_rounded, t.brandPoint2),
          (Icons.point_of_sale_rounded, t.brandPoint3),
          (Icons.insights_rounded, t.brandPoint4),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Icon(icon, color: RestoColors.onPrimary),
              const SizedBox(width: 14),
              Expanded(child: Text(text, style: const TextStyle(color: RestoColors.onPrimary, fontSize: 16))),
            ]),
          ),
      ]),
    );
  }
}

/// Lien discret (« Mot de passe oublié ? », « Déjà un compte ? »).
class _Link extends StatelessWidget {
  const _Link(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: NeuPalette.of(context).accent),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

String? _vRequired(BuildContext context, String? v) => (v == null || v.trim().isEmpty) ? context.t.fieldRequired : null;

String? _vEmail(BuildContext context, String? v) {
  if (v == null || v.trim().isEmpty) return context.t.fieldRequired;
  return emailPattern.hasMatch(v.trim()) ? null : context.t.errorInvalidEmail;
}

String? _vNewPassword(BuildContext context, String? v) =>
    (v == null || v.length < 8) ? context.t.passwordTooShort : null;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final api = AppScope.read(context).api!;
    final email = _email.text.trim();
    try {
      await api.signIn(email, _password.text);
    } on AuthException catch (e) {
      if (e.code == 'email_not_confirmed') {
        // Adresse jamais confirmée : nouveau code puis saisie du code.
        try {
          await api.resendSignupCode(email);
        } catch (_) {}
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email, type: OtpType.signup)));
        return;
      }
      if (mounted) showError(context, e);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _signUp() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SignUpScreen(initialType: AppScope.read(context).customerMode ? 'customer' : null)),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = NeuPalette.of(context);
    return _AuthFrame(
      icon: Icons.lock_rounded,
      title: t.authWelcome,
      subtitle: t.authWelcomeSub,
      ghostLabel: t.createAccount.toUpperCase(),
      onGhost: _signUp,
      footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(child: Text(t.noAccountYet, style: TextStyle(color: p.muted))),
        const SizedBox(width: 14),
        NeuCircle(icon: Icons.add_rounded, size: 50, onTap: _signUp, tooltip: t.createAccount),
      ]),
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              NeuField(
                controller: _email,
                hint: t.email,
                icon: Icons.alternate_email_rounded,
                keyboard: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: (v) => _vEmail(context, v),
              ),
              const SizedBox(height: 18),
              NeuField(
                controller: _password,
                hint: t.password,
                icon: Icons.key_rounded,
                obscure: true,
                autofill: const [AutofillHints.password],
                validator: (v) => _vRequired(context, v),
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _Link(t.forgotPassword,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()))),
              ),
              const SizedBox(height: 10),
              NeuButton(label: t.signIn, onPressed: _submit, filled: true),
            ]),
          ),
        ),
      ],
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.initialType});

  /// Type proposé d'avance (« customer » depuis l'espace client).
  final String? initialType;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late String? _type = widget.initialType;
  bool _typeMissing = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _typeMissing = _type == null);
    if (!_form.currentState!.validate() || _type == null) return;
    final state = AppScope.read(context);
    final api = state.api!;
    final email = _email.text.trim();
    try {
      await api.signUp(
        email: email,
        password: _password.text,
        name: _name.text.trim(),
        locale: refLocaleCode(Localizations.localeOf(context)),
        accountType: _type!,
      );
      // L'interface suit le type choisi une fois connecté (adresse confirmée) :
      // voir OrganizationGate.
      if (!mounted) return;
      // Sans session ouverte : l'adresse doit être confirmée par code.
      if (api.auth.currentSession == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email, type: OtpType.signup)));
      } else {
        Navigator.popUntil(context, (r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = NeuPalette.of(context);
    return _AuthFrame(
      icon: Icons.person_add_alt_1_rounded,
      title: t.createAccount,
      subtitle: t.authSignUpSub,
      footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(child: Text(t.alreadyAccount, style: TextStyle(color: p.muted))),
        _Link(t.signIn, () => Navigator.pop(context)),
      ]),
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              AccountTypePicker(value: _type, onChanged: (v) => setState(() {
                    _type = v;
                    _typeMissing = false;
                  })),
              if (_typeMissing)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t.accountTypeRequired, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5)),
                ),
              const SizedBox(height: 18),
              NeuField(
                controller: _name,
                hint: t.displayName,
                icon: Icons.person_outline_rounded,
                autofill: const [AutofillHints.name],
                maxLength: 120,
                validator: (v) => _vRequired(context, v),
              ),
              const SizedBox(height: 18),
              NeuField(
                controller: _email,
                hint: t.email,
                icon: Icons.alternate_email_rounded,
                keyboard: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: (v) => _vEmail(context, v),
              ),
              const SizedBox(height: 18),
              NeuField(
                controller: _password,
                hint: t.password,
                icon: Icons.key_rounded,
                obscure: true,
                autofill: const [AutofillHints.newPassword],
                validator: (v) => _vNewPassword(context, v),
              ),
              const SizedBox(height: 18),
              NeuField(
                controller: _confirm,
                hint: t.passwordConfirm,
                icon: Icons.key_rounded,
                obscure: true,
                validator: (v) => v != _password.text ? t.passwordsDiffer : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 26),
              NeuButton(label: t.createAccount, onPressed: _submit),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Saisie du code reçu par e-mail (confirmation d'inscription ou
/// réinitialisation du mot de passe).
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.email, required this.type});
  final String email;
  final OtpType type;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{6,10}$').hasMatch(code)) {
      showInfo(context, context.t.authCodeInvalid);
      return;
    }
    try {
      await AppScope.read(context).api!.verifyCode(widget.email, code, widget.type);
      if (!mounted) return;
      if (widget.type == OtpType.recovery) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
      } else {
        Navigator.popUntil(context, (r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _resend() async {
    final api = AppScope.read(context).api!;
    try {
      if (widget.type == OtpType.recovery) {
        await api.sendPasswordReset(widget.email);
      } else {
        await api.resendSignupCode(widget.email);
      }
      if (mounted) showInfo(context, context.t.codeResent);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _AuthFrame(
      icon: Icons.mark_email_read_rounded,
      title: widget.type == OtpType.recovery ? t.forgotPassword : t.verifyEmailTitle,
      subtitle: t.codeSentTo(widget.email),
      footer: Center(child: _Link(t.resendCode, _resend)),
      children: [
        NeuField(
          controller: _code,
          hint: t.code,
          autofocus: true,
          keyboard: TextInputType.number,
          autofill: const [AutofillHints.oneTimeCode],
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 8, color: NeuPalette.of(context).text),
          onSubmitted: (_) => _verify(),
        ),
        const SizedBox(height: 26),
        NeuButton(label: t.verify, onPressed: _verify),
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final email = _email.text.trim();
    try {
      await AppScope.read(context).api!.sendPasswordReset(email);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email, type: OtpType.recovery)));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _AuthFrame(
      icon: Icons.key_rounded,
      title: t.forgotPassword,
      subtitle: t.authForgotSub,
      children: [
        Form(
          key: _form,
          child: NeuField(
            controller: _email,
            hint: t.email,
            icon: Icons.alternate_email_rounded,
            keyboard: TextInputType.emailAddress,
            validator: (v) => _vEmail(context, v),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(height: 26),
        NeuButton(label: t.sendCode, onPressed: _send),
      ],
    );
  }
}

/// Nouveau mot de passe (après le code de réinitialisation, ou depuis « Compte »).
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    try {
      await AppScope.read(context).api!.setPassword(_password.text);
      if (!mounted) return;
      showInfo(context, context.t.passwordChanged);
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _AuthFrame(
      icon: Icons.lock_reset_rounded,
      title: t.newPasswordTitle,
      subtitle: t.authNewPasswordSub,
      children: [
        Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            NeuField(
              controller: _password,
              hint: t.password,
              icon: Icons.key_rounded,
              obscure: true,
              autofill: const [AutofillHints.newPassword],
              validator: (v) => _vNewPassword(context, v),
            ),
            const SizedBox(height: 18),
            NeuField(
              controller: _confirm,
              hint: t.passwordConfirm,
              icon: Icons.key_rounded,
              obscure: true,
              validator: (v) => v != _password.text ? t.passwordsDiffer : null,
              onSubmitted: (_) => _save(),
            ),
          ]),
        ),
        const SizedBox(height: 26),
        NeuButton(label: t.save, onPressed: _save),
      ],
    );
  }
}

/// Choix du type de compte : Client (commander, réserver, découvrir) ou
/// Entreprise (gérer son restaurant).
class AccountTypePicker extends StatelessWidget {
  const AccountTypePicker({super.key, required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget card(String type, IconData icon, String title, String subtitle) {
      final on = value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            decoration: BoxDecoration(
              gradient: on ? RestoColors.brandGradient : null,
              color: on ? null : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: on ? Colors.transparent : RestoColors.primary.withValues(alpha: 0.45), width: 1.4),
              boxShadow: on ? RestoColors.softShadow(10) : null,
            ),
            child: Column(children: [
              Icon(icon, size: 32, color: on ? Colors.white : RestoColors.primaryDeep),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: on ? Colors.white : RestoColors.ink)),
              const SizedBox(height: 2),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, height: 1.25, color: on ? Colors.white.withValues(alpha: 0.9) : RestoColors.muted)),
            ]),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(t.accountTypeQuestion, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Row(children: [
        card('customer', Icons.restaurant_menu_rounded, t.accountTypeCustomer, t.accountTypeCustomerHint),
        const SizedBox(width: 12),
        card('business', Icons.storefront_rounded, t.accountTypeBusiness, t.accountTypeBusinessHint),
      ]),
    ]);
  }
}

/// Compte existant sans type (créé avant ce choix) : on le demande une fois.
class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  String? _type;

  Future<void> _continue() async {
    if (_type == null) return;
    final state = AppScope.read(context);
    try {
      await state.api!.setAccountType(_type!);
      state.setCustomerMode(_type == 'customer');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _AuthFrame(
      icon: Icons.how_to_reg_rounded,
      title: t.accountTypeTitle,
      subtitle: t.accountTypeSub,
      footer: Center(child: _Link(t.signOut, () => AppScope.read(context).api!.signOut())),
      children: [
        AccountTypePicker(value: _type, onChanged: (v) => setState(() => _type = v)),
        const SizedBox(height: 26),
        NeuButton(label: t.continueAction, onPressed: _type == null ? null : _continue, filled: true),
      ],
    );
  }
}