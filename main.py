#!/usr/bin/env python3

"""
Script principale:  * Suppression Clé GPG et Mot De Passe Si oubli 
                    * Menu des différents service
"""     
import os
import sys
import subprocess
import time

# Rich = Doc.md
from rich.console import Console
from rich.markdown import Markdown
console = Console()

# Utils.py
from my_package.utils import COLOR_NOK, COLOR_BORDER, COLOR_TEXT, WAN, LAN, GESTION, CERTIF, LOGS, show_banner, passphrase
# gestion MDP
from my_package.Gestion.Pass.acces import Wan_Pass, Lan_Pass, Gestion_Pass, Certif_Pass, Log_Pass

# Permet à entry_points (setup.py) de lancer ce script avec la commande gcert, et avec le Menu gpg en premier puis main.
def cli():
    gpg()
    main()

# gpg () gpg() permet, en cas d’oubli de la phrase secrète de la clé GPG, de réinitialiser celle‑ci ainsi que les mots de passe
def gpg():

    # show_banner(): => utils.py
    show_banner()

    # explication menu
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

    # Menu pour Continuer Réinitialiser Clé GPG et Mot De Passe / Quitter
    result = subprocess.run([
        "gum", "choose",
        "--header", "\n\nVeuillez choisir ...",
        "--limit", "1",
        "--height", "10",
        "Continuer",
        "Réinitialiser Clé GPG et Mot De Passe",
        "Quitter"
    ], text=True, stdout=subprocess.PIPE)
    # met le choix dans la variable choix
    choix = result.stdout.strip()

    # redirection en fonction de {choix}
    if choix == "Continuer":
        # Arrête la fonction et passe à main()
        return

    elif choix == "Réinitialiser Clé GPG et Mot De Passe":
        from my_package.Gestion.Pass.modif import Modif
        m = Modif()
        m.gpg_mdp()

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

        # ["pkill", "-f", "g_cert.sh"] => sort du script d'installation g_cert.sh si besoin,
        # sinon, après une installation, g_cert quitte et revient dans le menu de g_cert...
        # si g_cert.sh n'existe pas alors
        subprocess.run(["pkill", "-f", "g_cert.sh"])

        # Termine immédiatement le programme
        sys.exit()


def main():
    while True:
        show_banner()

        # Demande la passphrase de la clé GPG afin de la mettre en cache et de pouvoir gérer les mots de passe via pass
        # def passphrase(): => utils.py
        passphrase()

        # Bandeau
        subprocess.run([
            "gum", "style",
            "--foreground", COLOR_TEXT,
            "--border-foreground", COLOR_BORDER,
            "--border", "double",
            "--margin", "0 0",
            "--padding", "0 2 0 2",
            "Bienvenue dans G.cert, votre gestionnaire de Certificat"
        ])

        # Menu Principal Gestion Certificats / Quitter
        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "Gestion Certificats",
            "Quitter"
        ], text=True, stdout=subprocess.PIPE)
        # lit resultat
        choix = result.stdout.strip()

        # redirection en fonction de {choix}
        if choix == "Gestion Certificats":
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", f"Chargement Menu {choix}",
                "--", "bash", "-c", "sleep 1",
            ])

            # Boucle interne pour le sous-menu
            while True:
                show_banner()

                result = subprocess.run([
                    "gum", "choose",
                    "--header", "Veuillez choisir ...",
                    "--limit", "1",
                    "--height", "10",
                    f"{WAN}",
                    f"{LAN}",
                    f"{GESTION}",
                    f"{CERTIF}",
                    f"{LOGS}",
                    "Doc",
                    "Quitter"
                ], text=True, stdout=subprocess.PIPE)

                choix = result.stdout.strip()

                if choix == WAN:
                    Wan_Pass()
                elif choix == LAN:
                    Lan_Pass()
                elif choix == GESTION:
                    Gestion_Pass()
                elif choix == CERTIF:
                    Certif_Pass()
                elif choix == LOGS:
                    Log_Pass()
                elif choix == "Doc":
                    try:
                        # Pour Python 3.9+ (incluant Python 3.13)
                        """
                        ===> from importlib.resources import files
                        (permet d’accéder aux fichiers contenus dans un package Python, 
                        de manière sûre et portable, sans se soucier de leur emplacement exact sur le système de fichiers)
                        """
                        # Permet d’accéder aux fichiers d’un package Python
                        from importlib.resources import files
                        # chemin => my_package/script/doc.md dans doc_content
                        doc_content = files('my_package.script').joinpath('doc.md').read_text(encoding='utf-8')

                        """
                        Affichage avec pager Rich
                        """    
                        # Crée un objet Markdown à partir du contenu textuel
                        md = Markdown(doc_content)
                        # Affiche le contenu Markdown dans un pager pour défiler facilement
                        with console.pager():
                            console.print(md)

                    # Gestion des erreurs : affiche l’erreur et attend que l’utilisateur appuie sur Entrée
                    except Exception as e:
                        console.print(f"[red]Erreur lors du chargement de la documentation: {e}[/red]")
                        input("\nAppuyez sur Entrée pour continuer...")

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

        elif choix == "Quitter":
            os.system('clear')
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_TEXT,
                "--margin", "0 0",
                "--padding", "0 2 0 2",
                "Au revoir..."
            ])
            time.sleep(1)
            sys.exit()


"""
if __name__ == "__main__": est une condition spéciale en Python qui vérifie si le fichier est exécuté directement, 
et non importé comme module dans un autre script.
"""
# Point d’entrée du script : exécute gpg() puis main() si le fichier est lancé directement
if __name__ == "__main__":
    gpg()
    main()
