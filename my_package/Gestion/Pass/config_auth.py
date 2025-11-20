"""
Gestion des autorisations par service avec un fichier JSON => auth_config.json

Ce script fonctionne avec etat_mdp.py :  * Lit fichier de config (si inexistant il es créé ET True par defaut donc Mot de passe activé)
                                         * change l'état pour activer / désactiver

"""



#!/usr/bin/env python3
import os
import json
import shutil
import importlib.resources as resources

# === CHEMINS ===

# Vers le dossie gcert qui contient tous les mot de passe
CONFIG_DIR = os.path.expanduser("~/.config/gcert")

# Vers le fichier de configuration => auth_config.json
CONFIG_FILE = os.path.join(CONFIG_DIR, "auth_config.json")

# === INITIALISATION ===
def init_config():
    """Cette fonction initialise la configuration 
        elle garantit que l'environnement de config est prêt avant toute lecture/écriture.
    """
    
    # Crée le dossier de configuration si nécessaire
    os.makedirs(CONFIG_DIR, exist_ok=True)
    
    # Vérifie si le fichier de config existe
    if not os.path.exists(CONFIG_FILE):
        
        # Copier le modèle depuis le package
        with resources.path('my_package.script', 'auth_config.json') as src:
            shutil.copy(src, CONFIG_FILE)


# === STATUT ACTUEL === 
def get_auth_status(service):
    init_config() # S'assure que le fichier de config existe
    with open(CONFIG_FILE, 'r') as f: # Ouvre le fichier en lecture
        config = json.load(f) # Charge le JSON dans un dictionnaire Python
    return config.get(service, True)
    # Récupère la valeur pour le service donné
    # Par défaut True si le service n'existe pas dans le JSON


def toggle_auth(service):
    init_config() # S'assure que le fichier de config existe
    with open(CONFIG_FILE, 'r') as f: # Lecture du fichier JSON
        config = json.load(f)
    
    # Inverse le booléen (True -> False, False -> True)
    config[service] = not config[service]
    
    with open(CONFIG_FILE, 'w') as f: # Écrit la nouvelle config dans le fichier
        json.dump(config, f, indent=4) # Formaté avec indent pour être lisible
    return config[service] # Retourne le nouveau statut

def get_all_status():
    init_config() # S'assure que le fichier existe
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)  # Retourne le dictionnaire complet
