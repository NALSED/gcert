#!/usr/bin/env python3

"""
=> Depuis main.py
    Permet un accées par mot de passe aux différent service.

        Couplé à etat_mdp.py et config_auth.py , activation /désactivation possibles des mots de passe.

    """

import os         
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner
from my_package.Gestion.Pass.config_auth import get_auth_status

# Utiliser pour conter les tentatives d’essai de mot de passe
count = 0

# ============================= WAN =============================
def Wan_Pass():
    
    # Test True False du fichier .json
    if not get_auth_status("wan"):
        # Accès direct sans mot de passe
        from my_package.Wan.wan import Wan
        w = Wan()
        w.menu_wan()
        return
    
    global count
    # 3 essair pour le mdp
    while count < 3:
        show_banner()
        result1 = subprocess.run(
            ["pass", "show", "gcert/wan"],
            stdout=subprocess.PIPE, text=True, check=True
        )
        wan_pass = result1.stdout.strip()

        result2 = subprocess.run(
            ["gum", "input", "--password", "--prompt", "Veuillez entrer le mot de passe du service SSL => Wan :"],
            stdout=subprocess.PIPE, stderr=None, text=True, check=True
        )
        user_pass_wan = result2.stdout.strip()

        if wan_pass == user_pass_wan:
            show_banner()
            # mot de passe ok
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "Mot de passe Correct"
            ])
            time.sleep(2)
           
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Accés service Wan...",
                "--", "bash", "-c", "sleep 2",
            ])
            from my_package.Wan.wan import Wan
            w = Wan()
            w.menu_wan()
            break
        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Mot de passe Incorrect"
            ])
            time.sleep(2)
            count += 1
            if count < 3:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restant : {3 - count}"
                ])
                time.sleep(2)
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Accès refusé"
                ])
                break

# ============================= LAN =============================
def Lan_Pass():
    
    if not get_auth_status("lan"):
        # Accès direct sans mot de passe
        from my_package.Lan.lan import Lan
        l = Lan()
        l.menu_lan()
        return
    
    global count
    while count < 3:
        show_banner()
        result1 = subprocess.run(
            ["pass", "show", "gcert/lan"],
            stdout=subprocess.PIPE, text=True, check=True
        )
        lan_pass = result1.stdout.strip()

        result2 = subprocess.run(
            ["gum", "input", "--password", "--prompt", "Veuillez entrer le mot de passe du service SSL => Lan :"],
            stdout=subprocess.PIPE, stderr=None, text=True, check=True
        )
        user_pass_lan = result2.stdout.strip()

        if lan_pass == user_pass_lan:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "Mot de passe Correct"
            ])
            time.sleep(2)
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Accés service Lan...",
                "--", "bash", "-c", "sleep 2",
            ])
            from my_package.Lan.lan import Lan
            l = Lan()
            l.menu_lan()
            break
        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Mot de passe Incorrect"
            ])
            time.sleep(2)
            count += 1
            if count < 3:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restant : {3 - count}"
                ])
                time.sleep(2)
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Accès refusé"
                ])
                break

# ============================= GESTION =============================
def Gestion_Pass():
    
    if not get_auth_status("gestion"):
        # Accès direct sans mot de passe
        from my_package.Gestion.gestion_menu import GestionMenu
        g = GestionMenu()
        g.menu_gest()
        return
    
    global count
    while count < 3:
        show_banner()
        result1 = subprocess.run(
            ["pass", "show", "gcert/gestion"],
            stdout=subprocess.PIPE, text=True, check=True
        )
        gestion_pass = result1.stdout.strip()

        result2 = subprocess.run(
            ["gum", "input", "--password", "--prompt", "Veuillez entrer le mot de passe du Gestionnaire de certificats SSL et de Mot de Passe :"],
            stdout=subprocess.PIPE, stderr=None, text=True, check=True
        )
        user_pass_gestion = result2.stdout.strip()

        if gestion_pass == user_pass_gestion:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "Mot de passe Correct"
            ])
            time.sleep(2)
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Accés service Gestionnaire SSL et Mot de Passe...",
                "--", "bash", "-c", "sleep 2",
            ])
            from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
            g = gestion_pass_menu()
            g.menu_pass()
            break
        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Mot de passe Incorrect"
            ])
            time.sleep(2)
            count += 1
            if count < 3:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restant : {3 - count}"
                ])
                time.sleep(2)
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Accès refusé"
                ])
                break

# ============================= CERTIF =============================
def Certif_Pass():
    
    if not get_auth_status("coffre"):
        # Accès direct sans mot de passe
        from my_package.Certif.certif import Certif
        c = Certif()
        c.menu_certif()
        return
    
    global count
    while count < 3:
        show_banner()
        result1 = subprocess.run(
            ["pass", "show", "gcert/certif"],
            stdout=subprocess.PIPE, text=True, check=True
        )
        certif_pass = result1.stdout.strip()

        result2 = subprocess.run(
            ["gum", "input", "--password", "--prompt", "Veuillez entrer le mot de passe du Stockage Certificats SSL :"],
            stdout=subprocess.PIPE, stderr=None, text=True, check=True
        )
        user_pass_certif = result2.stdout.strip()

        if certif_pass == user_pass_certif:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "Mot de passe Correct"
            ])
            time.sleep(2)
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Accès au service Stockage Certificats",
                "--", "bash", "-c", "sleep 2",
            ])
            from my_package.Certifs.certif import Certif
            c = Certif()
            c.menu_certif()
            break
        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Mot de passe Incorrect"
            ])
            time.sleep(2)
            count += 1
            if count < 3:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restant : {3 - count}"
                ])
                time.sleep(2)
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Accès refusé"
                ])
                break

# ============================= LOG =============================
def Log_Pass():
    
    if not get_auth_status("logs"):
        # Accès direct sans mot de passe
        from my_package.Logs.logs_Menu import Choix_Logs
        c = Choix_Logs()
        c.menu()
        return
    
    global count
    while count < 3:
        show_banner()
        result1 = subprocess.run(
            ["pass", "show", "gcert/logs"],
            stdout=subprocess.PIPE, text=True, check=True
        )
        log_pass = result1.stdout.strip()

        result2 = subprocess.run(
            ["gum", "input", "--password", "--prompt", "Veuillez entrer le mot de passe du service des Logs :"],
            stdout=subprocess.PIPE, stderr=None, text=True, check=True
        )
        user_pass_log = result2.stdout.strip()

        if log_pass == user_pass_log:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "Mot de passe Correct"
            ])
            time.sleep(2)
            from my_package.Logs.logs_Menu import Choix_Logs
            c = Choix_Logs()
            c.menu()
            
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Accés service des Logs",
                "--", "bash", "-c", "sleep 2",
            ])
            break
        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Mot de passe Incorrect"
            ])
            time.sleep(2)
            count += 1
            if count < 3:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restant : {3 - count}"
                ])
                time.sleep(2)
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Accès refusé"
                ])
                break

if __name__ == "__main__":
    Wan_Pass()
    Lan_Pass()
    Gestion_Pass()
    Certif_Pass()
    Log_Pass()
