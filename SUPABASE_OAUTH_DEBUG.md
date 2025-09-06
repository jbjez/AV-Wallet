# Debug OAuth Google - Erreur 400 Validation Failed

## Problème
Erreur "code 400 validation failed" lors de la connexion Google OAuth.

## Solutions à vérifier dans Supabase Dashboard

### 1. Configuration OAuth Google
Dans Supabase Dashboard > Authentication > Providers > Google :

**Vérifiez que :**
- ✅ **Provider est activé** : Google OAuth doit être "Enabled"
- ✅ **Client ID** : Doit correspondre à votre projet Google Cloud
- ✅ **Client Secret** : Doit être correctement configuré
- ✅ **Redirect URL** : `io.supabase.avwallet://login-callback/`

### 2. Configuration Google Cloud Console
Dans Google Cloud Console > APIs & Services > Credentials :

**Vérifiez que :**
- ✅ **OAuth 2.0 Client ID** est configuré pour "iOS"
- ✅ **Bundle ID** : `io.supabase.avwallet` (doit correspondre au scheme)
- ✅ **Authorized redirect URIs** : `io.supabase.avwallet://login-callback/`

### 3. Configuration Supabase URL Configuration
Dans Supabase Dashboard > Authentication > URL Configuration :

**Vérifiez que :**
- ✅ **Site URL** : `io.supabase.avwallet://login-callback/`
- ✅ **Redirect URLs** : `io.supabase.avwallet://login-callback/`

### 4. Test de configuration
1. Allez dans Supabase Dashboard > Authentication > Users
2. Vérifiez que l'utilisateur `jabimov@gmail.com` est bien confirmé
3. Testez la connexion avec l'email/mot de passe d'abord
4. Puis testez Google OAuth

### 5. Logs de debug
L'application affichera maintenant des logs détaillés :
- Ouvrez la console Flutter : `flutter logs`
- Tentez la connexion Google
- Regardez les logs pour l'erreur exacte

### 6. Solutions communes

**Si l'erreur persiste :**
1. **Réinitialiser la configuration OAuth** dans Supabase
2. **Vérifier les URLs de redirection** (sans slash final parfois)
3. **Tester avec un autre compte Google**
4. **Vérifier que le bundle ID iOS correspond**

## Configuration actuelle de l'app
- **Scheme** : `io.supabase.avwallet`
- **Redirect URL** : `io.supabase.avwallet://login-callback/`
- **Supabase URL** : `https://sjwaoemczpzwlijljozk.supabase.co`

## Prochaines étapes
1. Testez la connexion avec l'email/mot de passe
2. Si ça marche, le problème est spécifique à Google OAuth
3. Vérifiez la configuration Google Cloud Console
4. Regardez les logs détaillés dans la console Flutter
