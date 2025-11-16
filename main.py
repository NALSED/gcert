#!/usr/bin/env python3

"""
Ce script teste la présence des prérequis à l'exécution du programme. 
Le cas échéant, il installe les dépendances. 
Enfin, il met en place un menu à choix multiples et redirige vers les autres scripts présents dans my_package.
"""
import os         
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner, passphrase
from my_package.Gestion.Pass.acces import Wan_Pass, Lan_Pass, Gestion_Pass, Certif_Pass, Log_Pass

# Chemin documentation:
chemin_doc = os.path.join(os.path.dirname(__file__), "script", "doc.md")

# Permet à entry_points de lancer ce script avec la commande gcert, et avec le Menu gpg en premier puis main.
def cli():
    gpg()
    main()


def gpg():
 
        
        # Afficher le texte en ASCII art
        show_banner()

        subprocess.run([
            "gum", "style",
            "--foreground", COLOR_TEXT,
            "--padding", "1 2",
            "\n+++ Gestion des mots de passe G.Cert +++\n",
            "Pour accéder aux différents services de G.cert, vous devez utiliser",
            "les mots de passe créés via le gestionnaire => pass.",
            "",
            "Vous devez disposer de la passphrase associée à votre clé GPG.",
            "Si vous la possédez, elle vous sera demandée maintenant.",
            "",
            "Sinon, vous pouvez relancer la procédure de création de clé GPG,",
            "ainsi que la configuration des mots de passe via pass.",
        ])



        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "Continuer",
            "Réinitialiser Clé GPG et Mot De Passe",
            "Quitter"
        ], text=True, stdout=subprocess.PIPE)

        choix = result.stdout.strip()

        # Redirection => Continuer
        if choix == "Continuer":
            return

        # Redirection => GPG MDP
        elif choix == "Réinitialiser Clé GPG et Mot De Passe":
            from my_package.Gestion.Pass.modif  import Modif
            m = Modif()
            m.gpg_mdp()
            # === EN COURS DE CREATION ===   

        # Quitter menu
        elif choix == "Quitter":
            os.system('clear')

            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--border-foreground", COLOR_BORDER,
                "--border", "double",
                "--margin", "0 0",
                "--padding", "0 2 0 2",
                "Au revoir..."
            ])

            # Ferme le script g_cert.sh si enchaîné
            subprocess.run(["pkill", "-f", "g_cert.sh"])
            sys.exit()


######## choix gpg
def main():
    
        # Afficher le texte en ASCII art
        show_banner()

        # Afficher le message Bienvene stylisé avec gum
        subprocess.run([
            "gum", "style",
            "--foreground", COLOR_TEXT,
            "--border-foreground", COLOR_BORDER,
            "--border", "double",
            "--margin", "0 0",
            "--padding", "0 2 0 2",
            "Bienvenue dans G.cert, votre gestionnaire de Certificat"
        ])
        
        # Pour le déclanchement des mots de passe :
        # Si la passphrase est déjà dans le cache de gpg-agent, rien ne se passe → silencieux. 
        # Et la sortie de la commande pass show est récupéré pour tester les MDP
        # ===
        # Si elle n’est pas dans le cache, gpg demandera la passphrase au moment de l’appel
        
        passphrase()
        
        # Liste à choix multiple
        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "Gestion Certificats",
            "Quitter"
        ], text=True, stdout=subprocess.PIPE)

        choix = result.stdout.strip()

        if choix == "Gestion Certificats":
            # Spin GUM
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", f"Chargement Menu {choix}",
                "--", "bash", "-c", "sleep 1",
            ])

            # ============================= CHOIX =============================
            os.system('clear')
            show_banner()

            # Liste à choix multiple secondaire
            result = subprocess.run([
                "gum", "choose",
                "--header", "Veuillez choisir ...",
                "--limit", "1",
                "--height", "10",
                "Certificat WAN",
                "Certificat LAN",
                "Gestion",
                "Certificats",
                "Logs",
                "Doc",
                "Quitter"
            ], text=True, stdout=subprocess.PIPE)

            choix = result.stdout.strip()

            # Redirection => WAN
            if choix == "Certificat WAN":
                Wan_Pass()

            # Redirection => LAN
            elif choix == "Certificat LAN":
                Lan_Pass()

            # Redirection => Gestion
            elif choix == "Gestion":
                Gestion_Pass()

            # Redirection => Certificats
            elif choix == "Certificats":
                Certif_Pass()

            # Redirection => Logs
            elif choix == "Logs":
                Log_Pass()

            # Redirection => Doc
            elif choix == "Doc":
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_TEXT,
                    "--border-foreground", COLOR_BORDER,
                    "--border", "double",
                    "--margin", "0 0",
                    "--padding", "0 2 0 2",
                    "pour sortir de la doc tappez : q"
                ])
                time.sleep(3)
                os.system(f"less {chemin_doc}")
               
            # Quitter menu gestion
            elif choix == "Quitter":
                os.system('clear')

                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_TEXT,
                    "--margin", "0 0",
                    "--padding", "0 2 0 2",
                    "Quitter"
                ])

                time.sleep(1)
                sys.exit()
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
                # Ferme le script g_cert.sh si enchaîné
                subprocess.run(["pkill", "-f", "g_cert.sh"])
                sys.exit()


# Exécution principale
if __name__ == "__main__":
    gpg()
    main()

