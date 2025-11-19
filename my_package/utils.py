#!/usr/bin/env python3

# Import Universel
import os         
import pyfiglet
import subprocess
  

# === COULEURS GUM ===
COLOR_OK = "48"
COLOR_NOK = "160"
COLOR_BORDER = "32"
COLOR_TEXT = "85"


# === COULEURS PYTHON ===
GREEN = "\033[32m"
YELLOW = "\033[33m"
WHITE = "\033[37m"
NC = "\033[0m"
RED = '\033[0;31m'

# === ANIMATION AVANCEMENT ===
CHECK = "√"

# === NOM SERVICES ===
WAN = "Wan"
LAN = "Lan"
GESTION = "Gestion Certificats et Mot de passe"
CERTIF = "Coffre fort Certificat"
LOGS = "Logs"

# === Fonctions partagées ===

# BANNIERE
def show_banner():
    os.system("clear")
    f = pyfiglet.figlet_format("G.Cert", font="starwars")
    print(f)

# DEMMANDE DE PASSPHRASE
# afin de mettre la passphrase en cache
def passphrase():
    subprocess.run(
            ["pass", "show", "gcert/wan"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True
        )