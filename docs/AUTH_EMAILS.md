# Resto — E-mails d'authentification (Supabase)

L'application demande des **codes** reçus par e-mail (pas de liens à
ouvrir) : confirmation d'inscription et mot de passe oublié. La langue du
message suit la langue du compte (métadonnée `locale`, mise à jour par
l'application à l'inscription et à chaque changement de langue).

## Réglages à faire une seule fois (tableau de bord Supabase du projet Resto)

1. Authentication → Emails → Templates → **Confirm signup**
   - Sujet : `Resto – Code d'activation / Activation code`
   - Corps : contenu de `docs/email_confirm_signup.html`
2. Authentication → Emails → Templates → **Reset password**
   - Sujet : `Resto – Code de réinitialisation / Reset code`
   - Corps : contenu de `docs/email_reset_password.html`
3. Authentication → Sign In / Providers → Email : **Confirm email** activé ;
   *Email OTP Expiration* : 3600 s. L'application accepte les codes de 6 à
   10 chiffres. Tant que « Confirm email » est désactivé, le modèle
   « Confirm sign up » apparaît grisé.

   **Obligatoire pour la sécurité** : sans confirmation, Supabase marque
   toute adresse comme confirmée dès l'inscription ; quelqu'un pourrait alors
   s'inscrire avec l'adresse d'un autre et accepter une invitation qui lui est
   destinée (`accept_invitation` exige une adresse confirmée).

## Envoi des e-mails

**État (2026-10-10)** : SMTP Brevo branché sur le projet Resto, modèles « Confirm sign up » et « Reset password » en place, « Confirm email » activé ; inscription et mot de passe oublié par code vérifiés par l'utilisateur.

Sur un projet récent, les modèles restent grisés tant que le service intégré est utilisé. Le service d'e-mail intégré de Supabase n'envoie qu'aux adresses des membres
de l'équipe du projet Supabase, avec un très faible débit : suffisant pour
vos propres essais. Pour inscrire d'autres personnes (employés, clients),
configurer un SMTP (Authentication → Emails → SMTP Settings), par exemple le
même compte Brevo qu'Immo : hôte `smtp-relay.brevo.com`, port 587,
identifiant `xxxx@smtp-brevo.com`, mot de passe = clé SMTP `xsmtpsib-…`
(une clé API `xkeysib-…` est refusée). Ne jamais coller ces clés dans le code
ni dans une conversation.
