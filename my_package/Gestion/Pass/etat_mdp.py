#!/usr/bin/env python3

"""
=> Depuis gestion_pass.py

    Permet d'activer ou désactiver l'accées aux services par mot de passe
"""

import os
import sys
import subprocess
import time
from tabulate import tabulate

from my_package.utils import (
    COLOR_OK, COLOR_NOK, COLOR_BORDER,
    GREEN, YELLOW, RED, WHITE, NC,
    WAN, LAN, GESTION, CERTIF, LOGS,
    show_banner
)
from my_package.Gestion.Pass.config_auth import toggle_auth, get_all_status

def afficher_etat_services():
    """Affiche le tableau des états des services"""
    
    # Récupère tous les statuts des services depuis le JSON
    config = get_all_status() 
    services = ["wan", "lan", "gestion", "coffre", "logs"] # Liste des services à afficher
    colored_data = [] # tableau couleur

    for service in services:
        etat = config[service] # True/False pour le service
        etat_txt = f"{GREEN}Activé{NC}" if etat else f"{RED}Désactivé{NC}" # Texte coloré
        colored_data.append([f"{YELLOW}{service.upper()}{NC}", etat_txt]) # Ligne du tableau
    
    # En-têtes colorés
    colored_headers = [f"{WHITE}Service{NC}", f"{WHITE}État{NC}"]
    # Affiche le tableau en utilisant 'tabulate' avec un format esthétique
    print(tabulate(colored_data, headers=colored_headers, tablefmt="rounded_grid"))


def activ_desactiv():
    """Boucle principale pour gérer l'activation/désactivation des services"""
   
    while True:
       
        show_banner()
        afficher_etat_services()  # Tableau sous le menu

        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nChanger l'activation ou la désactivation d'un service :",
            "--limit", "1",
            "--height", "10",
            f"{WAN}", f"{LAN}", f"{GESTION}", f"{CERTIF}", f"{LOGS}",
            "Retour", "Quitter"
        ], text=True, stdout=subprocess.PIPE)

        choix_etat = result.stdout.strip()

        # Selon le service choisi, bascule son état et affiche un message coloré
        
        # === MENU Mot De Passe === 
        if choix_etat == f"{WAN}":
            new_state = toggle_auth("wan")
            subprocess.run(["gum", "style", "--foreground", COLOR_OK, f"WAN: {'Activé' if new_state else 'Désactivé'}"])
            time.sleep(1)
        
        elif choix_etat == f"{LAN}":
            new_state = toggle_auth("lan")
            subprocess.run(["gum", "style", "--foreground", COLOR_OK, f"LAN: {'Activé' if new_state else 'Désactivé'}"])
            time.sleep(1)
        
        elif choix_etat == f"{GESTION}":
            new_state = toggle_auth("gestion")
            subprocess.run(["gum", "style", "--foreground", COLOR_OK, f"GESTION: {'Activé' if new_state else 'Désactivé'}"])
            time.sleep(1)
        
        elif choix_etat == f"{CERTIF}":
            new_state = toggle_auth("certif")
            subprocess.run(["gum", "style", "--foreground", COLOR_OK, f"CERTIF: {'Activé' if new_state else 'Désactivé'}"])
            time.sleep(1)
        
        elif choix_etat == f"{LOGS}":
            new_state = toggle_auth("logs")
            subprocess.run(["gum", "style", "--foreground", COLOR_OK, f"LOGS: {'Activé' if new_state else 'Désactivé'}"])
            time.sleep(1)
        
        # === RETOUR === 
        elif choix_etat == "Retour":
            from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
            g = gestion_pass_menu()
            g.menu_pass()
        
        # === QUITTER === 
        elif choix_etat == "Quitter":
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--border-foreground", COLOR_BORDER,
                "--border", "double",
                "--margin", "0 0",
                "--padding", "0 2 0 2",
                "Au revoir..."
            ])
            os.system('clear')
            subprocess.run(["pkill", "-f", "g_cert.sh"])
            sys.exit()
