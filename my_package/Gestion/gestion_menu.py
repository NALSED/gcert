#!/usr/bin/env python3
import os         
import pyfiglet
import sys
import subprocess
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner


class GestionMenu:
    def show_banner(self):
        show_banner() 
    
    def menu_gest(self):
        while True:
            # Nettoyer le terminal
            os.system('clear')

            # Afficher le texte en ASCII art
            self.show_banner()

            # Afficher le message Bienvenue stylisé avec gum
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_TEXT,
                "--border-foreground", COLOR_BORDER,
                "--border", "double",
                "--margin", "0 0",
                "--padding", "0 2 0 2",
                "Bienvenue Le menu de Gestion"
            ])

            # Liste à choix multiple
            result = subprocess.run([
                "gum", "choose",
                "--header", "\n\nVeuillez choisir ...",
                "--limit", "1",
                "--height", "10",
                "Gestion Mot de passe",
                "Gestion Certificats",
                "Retour",
                "Quitter"
            ], text=True, stdout=subprocess.PIPE)

            choix = result.stdout.strip()

            # ============================= REDIRECTION =============================
            if choix == "Gestion Mot de passe":
                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                mon_pass = gestion_pass()
                mon_pass.menu_pass()  

            elif choix == "Gestion Certificats":
                from my_package.Gestion.Certif.gestion_certif import gestion_certif
                mon_certif = gestion_certif()
                mon_certif.show_banner() 

            elif choix == "Retour":
                import main
                main.main()  # retourne au menu précédent

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

            # Spin pour l’animation
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Quitter",
                "--", "bash", "-c", "sleep 1",
            ])
            time.sleep(2)


# Exécution script 
if __name__ == "__main__":
    menu = GestionMenu()
    menu.main()
