# DOCUMENTATION G.Cert

## === SOMMAIRE ===

1. Prérequis et Dépendances
    1.1 Prérequis
    1.2 Dépendances Python

2. Détails Logiciels
    2.1 **gocryptfs**
    2.2 **gnupg**
    2.3 **tmux**
    2.4 **pass**
    

3. Aide Création et Gestion Certificats 
    3.1**Création**
    3.2 **Gestion** 
---

## I) Prérequis et Dépendances

### 1.1) Prérequis

Les logiciels suivants doivent être installés sur votre système avant de commencer l'installation :


| Outil | Description |
|-------|------------|
| **curl** | Outil pour transférer des données via des protocoles réseau (HTTP, FTP, etc.). |
| **gnupg** | Implémentation de OpenPGP pour le chiffrement et la signature de données. |
| **gum** | Interface en ligne de commande pour créer des interfaces utilisateur interactives (menus, prompts, etc.). |
| **gocryptfs** | Système de chiffrement transparent pour sécuriser des répertoires. |
| **python3** | Langage de programmation Python version 3.x. |
| **python3-pip** | Outil pour installer et gérer des bibliothèques Python. |
| **python3-venv** | Outil pour créer des environnements virtuels Python. |
| **tmux** | Multiplexeur de terminaux, permettant de gérer plusieurs sessions dans une seule fenêtre. |
| **pass** | Gestionnaire de mots de passe basé sur GPG pour stocker et organiser les mots de passe. |

### 1.2) Dépendances Python

Les bibliothèques Python suivantes sont nécessaires pour exécuter certaines fonctionnalités :

- **colorama** : Module permettant de faciliter l'utilisation des couleurs dans les applications terminal.
- **pycparser** : Analyseur de code C écrit en Python.
- **pyfiglet** : Générateur de texte ASCII art dans le terminal.
- **pygum** : Bibliothèque Python pour l'interaction avec Gum.
- **pyOpenSSL** : Interface Python pour OpenSSL, permettant de travailler avec SSL et TLS.
- **python-nmap** : Interface Python pour interagir avec Nmap, un outil de scan réseau.

---

## II) Détails Logiciels

## 2.1 **gocryptfs**
**Documentation** : [https://github.com/rfjakob/gocryptfs/blob/master/Documentation/MANPAGE.md](https://github.com/rfjakob/gocryptfs/blob/master/Documentation/MANPAGE.md)


Ce logiciel servira au stockage sécurisé des certificats.
**RAPPEL DES COMMANDES**     

---

### 2.2 **GNUPG (GPG)**
**Documentation** : [https://www.gnupg.org/documentation/manuals/gnupg/](https://www.gnupg.org/documentation/manuals/gnupg/)

**GNUPG** (GNU Privacy Guard) permet de **créer, gérer et utiliser des clés GPG**.  
Ces clés sont indispensables pour le fonctionnement de **pass** (gestion des mots de passe) et **OpenSSL** (administration des certificats SSL/TLS).

GNUPG permet de :
- Chiffrer et déchiffrer des fichiers ou messages.  
- Signer et vérifier des données (signature numérique).  
- Gérer des paires de clés (publique / privée).  
- Importer, exporter, révoquer ou sauvegarder des clés. 

**Rappel des commandes principales :**
```bash
# Générer une clé GPG
# (Rappel : pass ne prend en charge que les clés RSA capables de chiffrer)
gpg --full-generate-key

# Lister les clés publiques
gpg --list-keys

# Lister les clés privées
gpg --list-secret-keys

# Exporter une clé publique
gpg --export -a [IDENTIFIANT] > ma_cle_publique.asc

# Exporter une clé privée
gpg --export-secret-keys -a [IDENTIFIANT] > ma_cle_privee.asc

# Importer une clé
gpg --import [FICHIER_CLE.asc]

# Supprimer une clé
gpg --delete-key [IDENTIFIANT]
gpg --delete-secret-key [IDENTIFIANT]
```
---

### 2.3 **tmux**

**Documentation** : [https://github.com/tmux/tmux/wiki/Getting-Started](https://github.com/tmux/tmux/wiki/Getting-Started)

**tmux** permet de scinder l’écran de terminal en plusieurs volets afin de faciliter la gestion simultanée des certificats et des opérations associées.  
C’est un outil utile pour le multitâche ou les environnements serveur sans interface graphique.  

---

### 2.4 **pass**

**Documentation** : [https://www.passwordstore.org/](https://www.passwordstore.org/)

**pass** est utilisé pour créer et gérer les **mots de passe** des différents menus de **G.Cert**, afin d’améliorer la sécurité globale du système.  

Après la création des mots de passe, l’architecture suivante est utilisée (visible avec la commande `pass list`) :

```
Password Store
└── gcert
    ├── certif
    ├── gestion
    ├── lan
    ├── logs
    ├── master
    └── wan
```

Il est possible d’administrer, créer ou supprimer des mots de passe directement via **pass**, en dehors du programme **G.Cert**.  

⚠️ **Attention :** pour le bon fonctionnement de **G.Cert**, il est impératif de conserver les **noms** et **l’architecture du répertoire de mots de passe**.

**Rappel des commandes principales :**
```bash
# Voir un mot de passe
pass [ARBORESCENCE_DOSSIER]
pass gcert/certif
```

**Exemple de message affiché :**
```
┌───────────────────────────────────────────────────────────────┐
│ Please enter the passphrase to unlock the OpenPGP secret key: │
│ "y (y) <y>"                                                   │
| 3072-bit RSA key, ID 2395A330F3EE2742,                        │
| created 2025-11-10 (main key ID F9ECA41454B0B125).            │
│                                                               │
│ Passphrase: _________________________________________________ │
│                                                               │
│         <OK>                                   <Cancel>       │
└───────────────────────────────────────────────────────────────┘
```

```bash
# Modifier un mot de passe
pass insert [ARBORESCENCE_DOSSIER]
pass insert gcert/certif

# Si le mot de passe existe déjà
An entry already exists for gcert/certif. Overwrite it? [y/N]
```


💡 **Remarque :**!!!  G.Cert ne prend **PAS** en charge la génération automatique de mots de passe aléatoires.!!! 