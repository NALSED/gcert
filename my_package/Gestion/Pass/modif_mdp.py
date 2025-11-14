#!/usr/bin/env python3
import os
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
#from main import main
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner

Wan = os.path.expanduser("~/.password-store/gcert/wan.gpg")
Lan = os.path.expanduser("~/.password-store/gcert/lan.gpg")
Gestion = os.path.expanduser("~/.password-store/gcert/gestion.gpg")
Certif = os.path.expanduser("~/.password-store/gcert/certif.gpg")
Log = os.path.expanduser("~/.password-store/gcert/logs.gpg")

try:
    subprocess.run(["sudo", "-v"], check=True)

    def menu():
        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "Changer tous les mots de passe",
            "Choisir mot de passe à changer",
            "Menu Principale",
            "Retour",
            "Quitter"
        ], text=True, stdout=subprocess.PIPE)

        choix_1 = result.stdout.strip()

        if choix_1 == "Changer tous les mots de passe":
            all_mdp()

        elif choix_1 == "Choisir mot de passe à changer":
            while True:
                result = subprocess.run([
                    "gum", "choose",
                    "--header", "\n\nVeuillez choisir ...",
                    "--limit", "1",
                    "--height", "10",
                    "Wan",
                    "Lan",
                    "Certif",
                    "Gestion",
                    "Logs",
                    "Annuler"
                ], text=True, stdout=subprocess.PIPE)

                choix_2 = result.stdout.strip()

                if choix_2 == "Wan":
                    wan()
                elif choix_2 == "Lan":
                    lan()
                elif choix_2 == "Certif":
                    certif()
                elif choix_2 == "Gestion":
                    gestion()
                elif choix_2 == "Logs":
                    log()
                elif choix_2 == "Annuler":
                    menu()

        elif choix_1 == "Menu Principale":
            from main import main
            main()

        elif choix_1 == "Retour":
            return

        elif choix_1 == "Quitter":
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

        subprocess.run([
            "gum", "spin",
            "--spinner", "dot",
            "--title", "Quitter",
            "--", "bash", "-c", "sleep 1",
        ])
        time.sleep(2)

    def all_mdp():
        wan()
        lan()
        gestion()
        certif()
        log()

    def wan():
        while True:
            subprocess.run(["rm", "-rf", Wan], check=True)
            show_banner()

            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez entrer un nouveau mot de passe Wan :"],
                text=True, stdout=subprocess.PIPE
            )
            choix_wan = result.stdout.strip()

            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez confirmer le nouveau mot de passe Wan :"],
                text=True, stdout=subprocess.PIPE
            )
            confirm_choix_wan = result.stdout.strip()

            if choix_wan == confirm_choix_wan:
                pw = choix_wan + "\n" + confirm_choix_wan + "\n"
                subprocess.run(["pass", "insert", "-f", "gcert/wan"], input=pw, text=True)

                if os.path.exists(Wan):
                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Création du dossier gcert OK"
                    ])
                    time.sleep(2)

                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Changement du Mot de Passe Wan OK"
                    ])
                    time.sleep(2)

                    break
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Problème lors du Changement du Mot de passe Wan..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Veuillez entrer deux Mots de Passe identiques..."
                ])
                time.sleep(3)

    def lan():
        subprocess.run(["rm", "-rf", Lan], check=True)
        while True:
            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez entrer un nouveau mot de passe Lan :"],
                text=True, stdout=subprocess.PIPE
            )
            choix_lan = result.stdout.strip()

            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez confirmer le nouveau mot de passe Lan :"],
                text=True, stdout=subprocess.PIPE
            )
            confirm_choix_lan = result.stdout.strip()

            if choix_lan == confirm_choix_lan:
                pw = choix_lan + "\n" + choix_lan + "\n"
                subprocess.run(["pass", "insert", "-f", "gcert/lan"], input=pw, text=True)

                if os.path.exists(Lan):
                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Changement du Mot de Passe Lan OK"
                    ])
                    time.sleep(2)
                    break
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Problème lors du changement du Mot de passe Lan..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Veuillez entrer deux Mots de Passe identiques..."
                ])
                time.sleep(3)

    def gestion():
        subprocess.run(["rm", "-rf", Gestion], check=True)
        while True:
            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez entrer un nouveau mot de passe Gestion :"],
                text=True, stdout=subprocess.PIPE
            )
            choix_gestion = result.stdout.strip()

            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez confirmer le nouveau mot de passe Gestion :"],
                text=True, stdout=subprocess.PIPE
            )
            confirm_choix_gestion = result.stdout.strip()

            if choix_gestion == confirm_choix_gestion:
                pw = choix_gestion + "\n" + choix_gestion + "\n"
                subprocess.run(["pass", "insert", "-f", "gcert/gestion"], input=pw, text=True)

                if os.path.exists(Gestion):
                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Changement du Mot de Gestion OK"
                    ])
                    time.sleep(2)
                    break
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Problème lors du changement du Mot de passe Gestion..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Veuillez entrer deux Mots de Passe identiques..."
                ])
                time.sleep(3)

    def certif():
        subprocess.run(["rm", "-rf", Certif], check=True)
        while True:
            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez entrer un nouveau mot de passe Certif :"],
                text=True, stdout=subprocess.PIPE
            )
            choix_certif = result.stdout.strip()

            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez confirmer le nouveau mot de passe Certif :"],
                text=True, stdout=subprocess.PIPE
            )
            confirm_choix_certif = result.stdout.strip()

            if choix_certif == confirm_choix_certif:
                pw = choix_certif + "\n" + choix_certif + "\n"
                subprocess.run(["pass", "insert", "-f", "gcert/certif"], input=pw, text=True)

                if os.path.exists(Certif):
                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Changement du Mot Certif OK"
                    ])
                    time.sleep(3)
                    break
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Problème lors du changement du Mot de passe Certif..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Veuillez entrer deux Mots de Passe identiques..."
                ])
                time.sleep(3)

    def log():
        subprocess.run(["rm", "-rf", Log], check=True)
        while True:
            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez entrer un nouveau mot de passe Logs :"],
                text=True, stdout=subprocess.PIPE
            )
            choix_logs = result.stdout.strip()

            show_banner()
            result = subprocess.run(
                ["gum", "input", "--password", "--prompt", "Veuillez confirmer le nouveau mot de passe Logs :"],
                text=True, stdout=subprocess.PIPE
            )
            confirm_choix_logs = result.stdout.strip()

            if choix_logs == confirm_choix_logs:
                pw = choix_logs + "\n" + choix_logs + "\n"
                subprocess.run(["pass", "insert", "-f", "gcert/logs"], input=pw, text=True)

                if os.path.exists(Log):
                    show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Changement du Mot de Log OK"
                    ])
                    time.sleep(2)

                    # Manquait → boucle infinie
                    break
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Problème lors du changement du mot de passe de Log..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Veuillez entrer deux Mots de Passe identiques..."
                ])
                time.sleep(3)

except subprocess.CalledProcessError:
    subprocess.run([
        "gum", "style",
        "--foreground", COLOR_NOK,
        "--padding", "1 2",
        "\nMot de passe incorrect\nVous ne disposez pas des droits nécessaires\n"
    ])
    time.sleep(3)
    os.system('clear')
    subprocess.run(["pkill", "-f", "g_cert.sh"])
    sys.exit()

if __name__ == "__main__":
    menu()
