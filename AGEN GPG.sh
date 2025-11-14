# Teste si la passphrase est encore dans le cache
echo test | gpg --sign --dry-run >/dev/null 2>&1 && echo OK || echo NO

# Vide le cache (tue gpg-agent pour forcer la prochaine demande de passphrase)
gpgconf --kill gpg-agent

# Force la demande de passphrase (comme le cache vient d’être vidé)
echo test | gpg --sign --dry-run

# Crée un fichier de configuration pour gpg-agent avec un TTL personnalisé
cat >~/.gnupg/gpg-agent.conf <<EOF
default-cache-ttl 1800   # 30 min après dernière utilisation
max-cache-ttl 14400      # 4 h max en cache
EOF

# Recharge l’agent pour appliquer la nouvelle configuration
gpgconf --reload gpg-agent

# (Optionnel) Démarre un nouvel agent dans la session actuelle
eval "$(gpg-agent --daemon)"
