#!/usr/bin/env python3
import os         
import pyfiglet
import subprocess
  

# === Constantes ===
COLOR_OK = "48"
COLOR_NOK = "160"
COLOR_BORDER = "32"
COLOR_TEXT = "85"

GREEN = "\033[32m"
YELLOW = "\033[33m"
WHITE = "\033[37m"
NC = "\033[0m"
RED = '\033[0;31m'

CHECK = "√"

# === Fonctions partagées ===
def show_banner():
    os.system("clear")
    f = pyfiglet.figlet_format("G.Cert", font="starwars")
    print(f)

def passphrase():
    subprocess.run(
            ["pass", "show", "gcert/wan"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True
        )