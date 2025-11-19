#!/usr/bin/env python3
import os
import json
import shutil
import importlib.resources as resources

# Répertoire utilisateur pour le vrai fichier de config
CONFIG_DIR = os.path.expanduser("~/.config/gcert")
CONFIG_FILE = os.path.join(CONFIG_DIR, "auth_config.json")

def init_config():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if not os.path.exists(CONFIG_FILE):
        # Copier le modèle depuis le package
        with resources.path('my_package.script', 'auth_config.json') as src:
            shutil.copy(src, CONFIG_FILE)

def get_auth_status(service):
    init_config()
    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)
    return config.get(service, True)

def toggle_auth(service):
    init_config()
    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)
    config[service] = not config[service]
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=4)
    return config[service]

def get_all_status():
    init_config()
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)
