#!/usr/bin/env python3

"""
=> Depuis gestion_menu.py

    Menu des différentes options de gestion mot de passe et clé GPG.
"""


import os
import pyfiglet
import sys
import subprocess
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, WAN, LAN, GESTION, CERTIF, LOGS, show_banner
   

class gestion_pass_menu:

    def show_banner(self):
        show_banner()   

    def menu_pass(self):
        while True:
            self.show_banner()

            result = subprocess.run([
                "gum", "choose",
                "--header", "Veuillez choisir ...",
                "--limit", "1",
                "--height", "10",
                "Modification Mot de Passe",
                "Activer / Désactiver Mot de Passe",
                "Réactiver une clé expirée",
                "Supprimer clé GPG",
                "Retour",
                "Menu Principale",
                "Quitter"
            ], text=True, stdout=subprocess.PIPE)

            choix = result.stdout.strip()

            # Redirection => Modification Mot de Passe
            if choix == "Modification Mot de Passe":
                from my_package.Gestion.Pass.modif_mdp import menu
                menu()

            elif choix == "Activer / Désactiver Mot de Passe":
                from my_package.Gestion.Pass.etat_mdp import activ_desactiv    
                activ_desactiv()

            elif choix == "Réactiver une clé expirée":
                pass

            elif choix == "Supprimer clé GPG":
                from my_package.Gestion.Key.delete_key import erase   
                erase()

            elif choix == "Retour":
                from my_package.Gestion.gestion_menu import GestionMenu
                g = GestionMenu()
                g.menu_gest()

            elif choix == "Menu Principale":
                import main
                main.main()

            elif choix == "Quitter":
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--border-foreground", COLOR_BORDER,
                    "--border", "double",
                    "--margin", "0 0",
                    "--padding", "0 2 0 2",
                    "Au revoir..."
                ])
                sys.exit()

            # Spin
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", f"Chargement Menu {choix}",
                "--", "bash", "-c", "sleep 1",
            ])


if __name__ == "__main__":
    g = gestion_pass()
    g.show_banner()
    g.menu_pass()
