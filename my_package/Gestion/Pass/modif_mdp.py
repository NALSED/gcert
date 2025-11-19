#!/usr/bin/env python3
import os
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, WAN, LAN, GESTION, CERTIF, LOGS, show_banner

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
                    WAN,
                    LAN,
                    CERTIF,
                    GESTION,
                    LOGS,
                    "Annuler"
                ], text=True, stdout=subprocess.PIPE)

                choix_2 = result.stdout.strip()

                if choix_2 == WAN:
                    wan()
                elif choix_2 == LAN:
                    lan()
                elif choix_2 == CERTIF:
                    certif()
                elif choix_2 == GESTION:
                    gestion()
                elif choix_2 == LOGS:
                    log()
                elif choix_2 == "Annuler":
                    from my_package.Gestion.Pass.gestion_pass import gestion_pass
                    g = gestion_pass()
                    g.menu_pass()

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

# =============================== WAN ==============================

    def wan():
        while True:
            show_banner()
            result1 = subprocess.run(
                ["pass", "show", "gcert/wan"],
                stdout=subprocess.PIPE, text=True, check=True
            )
            old_wan = result1.stdout.strip()

            result2 = subprocess.run(
                ["gum", "input", "--password", "--prompt", f"Veuillez entrer l'ancien mot de passe => {WAN} : "],
                stdout=subprocess.PIPE, stderr=None, text=True, check=True
            )
            user_old_wan = result2.stdout.strip()

            if old_wan == user_old_wan:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Ancien Mot de passe => {WAN} Correct\n"
                ])
                time.sleep(2)
                
                subprocess.run(["rm", "-rf", Wan], check=True)
                show_banner()

                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {WAN} :"],
                    text=True, stdout=subprocess.PIPE
                )
                choix_wan = result.stdout.strip()

                show_banner()
                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {WAN} :"],
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
                            f"Changement du Mot de Passe => {WAN} OK"
                        ])
                        time.sleep(2)

                        break
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            f"Problème lors du Changement du Mot de passe => {WAN}..."
                        ])
                        time.sleep(3)
                        from my_package.Gestion.Pass.gestion_pass import gestion_pass
                        g = gestion_pass()
                        g.menu_pass()
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Veuillez entrer deux Mots de Passe identiques..."
                    ])
                    time.sleep(3)
                continue
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Mot de passe Incorrect\n"
                ])
                time.sleep(2)

                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                g = gestion_pass()
                g.menu_pass()

    
 # =============================== LAN ==============================
   
    
    def lan():
        while True:
            show_banner()
            result1 = subprocess.run(
                ["pass", "show", "gcert/lan"],
                stdout=subprocess.PIPE, text=True, check=True
            )
            old_lan = result1.stdout.strip()

            result2 = subprocess.run(
                ["gum", "input", "--password", "--prompt", f"Veuillez entrer l'ancien mot de passe => {LAN} : "],
                stdout=subprocess.PIPE, stderr=None, text=True, check=True
            )
            user_old_lan = result2.stdout.strip()

            if old_lan == user_old_lan:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Ancien Mot de passe => {LAN} Correct\n"
                ])
                time.sleep(2)
                
                subprocess.run(["rm", "-rf", Lan], check=True)
                show_banner()

                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {LAN} :"],
                    text=True, stdout=subprocess.PIPE
                )
                choix_lan = result.stdout.strip()

                show_banner()
                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {LAN} :"],
                    text=True, stdout=subprocess.PIPE
                )
                confirm_choix_lan = result.stdout.strip()

                if choix_lan == confirm_choix_lan:
                    pw = choix_lan + "\n" + confirm_choix_lan + "\n"
                    subprocess.run(["pass", "insert", "-f", "gcert/lan"], input=pw, text=True)

                    if os.path.exists(Lan):
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
                            f"Changement du Mot de Passe => {LAN} OK"
                        ])
                        time.sleep(2)

                        break
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            f"Problème lors du Changement du Mot de passe => {LAN}..."
                        ])
                        time.sleep(3)
                        from my_package.Gestion.Pass.gestion_pass import gestion_pass
                        g = gestion_pass()
                        g.menu_pass()
                
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Veuillez entrer deux Mots de Passe identiques..."
                    ])
                    time.sleep(3)
                continue
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Mot de passe Incorrect\n"
                ])
                time.sleep(2)

                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                g = gestion_pass()
                g.menu_pass()


# =============================== GESTION ==============================

    def gestion():
        while True:
            show_banner()
            result1 = subprocess.run(
                ["pass", "show", "gcert/gestion"],
                stdout=subprocess.PIPE, text=True, check=True
            )
            old_gestion = result1.stdout.strip()

            result2 = subprocess.run(
                ["gum", "input", "--password", "--prompt", f"Veuillez entrer l'ancien mot de passe => {GESTION} : "],
                stdout=subprocess.PIPE, stderr=None, text=True, check=True
            )
            user_old_gestion = result2.stdout.strip()

            if old_gestion == user_old_gestion:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Ancien Mot de passe => {GESTION} Correct\n"
                ])
                time.sleep(2)
                
                subprocess.run(["rm", "-rf", Gestion], check=True)
                show_banner()

                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {GESTION} :"],
                    text=True, stdout=subprocess.PIPE
                )
                choix_gestion = result.stdout.strip()

                show_banner()
                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {GESTION} :"],
                    text=True, stdout=subprocess.PIPE
                )
                confirm_choix_gestion = result.stdout.strip()

                if choix_gestion == confirm_choix_gestion:
                    pw = choix_gestion + "\n" + confirm_choix_gestion + "\n"
                    subprocess.run(["pass", "insert", "-f", "gcert/gestion"], input=pw, text=True)

                    if os.path.exists(Gestion):
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
                            f"Changement du Mot de Passe => {GESTION} OK"
                        ])
                        time.sleep(2)

                        break
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            f"Problème lors du Changement du Mot de passe => {GESTION}..."
                        ])
                        time.sleep(3)
                        
                        from my_package.Gestion.Pass.gestion_pass import gestion_pass
                        g = gestion_pass()
                        g.menu_pass()
                
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Veuillez entrer deux Mots de Passe identiques..."
                    ])
                    time.sleep(3)
                continue
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Mot de passe Incorrect\n"
                ])
                time.sleep(2)

                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                g = gestion_pass()
                g.menu_pass()

# =============================== CERTIF ==============================

    def certif():
        while True:
            show_banner()
            result1 = subprocess.run(
                ["pass", "show", "gcert/certif"],
                stdout=subprocess.PIPE, text=True, check=True
            )
            old_certif = result1.stdout.strip()

            result2 = subprocess.run(
                ["gum", "input", "--password", "--prompt", f"Veuillez entrer l'ancien mot de passe => {CERTIF} : "],
                stdout=subprocess.PIPE, stderr=None, text=True, check=True
            )
            user_old_certif = result2.stdout.strip()

            if old_certif == user_old_certif:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Ancien Mot de passe => {CERTIF} Correct\n"
                ])
                time.sleep(2)
                
                subprocess.run(["rm", "-rf", Certif], check=True)
                show_banner()

                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {CERTIF} :"],
                    text=True, stdout=subprocess.PIPE
                )
                choix_certif = result.stdout.strip()

                show_banner()
                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {CERTIF} :"],
                    text=True, stdout=subprocess.PIPE
                )
                confirm_choix_certif = result.stdout.strip()

                if choix_certif == confirm_choix_certif:
                    pw = choix_certif + "\n" + confirm_choix_certif + "\n"
                    subprocess.run(["pass", "insert", "-f", "gcert/certif"], input=pw, text=True)

                    if os.path.exists(Certif):
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
                            f"Changement du Mot de Passe => {CERTIF} OK"
                        ])
                        time.sleep(2)

                        break
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            f"Problème lors du Changement du Mot de passe => {CERTIF}..."
                        ])
                        time.sleep(3)
                        
                        from my_package.Gestion.Pass.gestion_pass import gestion_pass
                        g = gestion_pass()
                        g.menu_pass()
                
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Veuillez entrer deux Mots de Passe identiques..."
                    ])
                    time.sleep(3)
                continue
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Mot de passe Incorrect\n"
                ])
                time.sleep(2)

                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                g = gestion_pass()
                g.menu_pass()

# =============================== LOGS ==============================

    def log():
        while True:
            show_banner()
            result1 = subprocess.run(
                ["pass", "show", "gcert/logs"],
                stdout=subprocess.PIPE, text=True, check=True
            )
            old_logs = result1.stdout.strip()

            result2 = subprocess.run(
                ["gum", "input", "--password", "--prompt", f"Veuillez entrer l'ancien mot de passe => {LOGS} : "],
                stdout=subprocess.PIPE, stderr=None, text=True, check=True
            )
            user_old_logs = result2.stdout.strip()

            if old_logs == user_old_logs:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Ancien Mot de passe => {LOGS} Correct\n"
                ])
                time.sleep(2)
                
                subprocess.run(["rm", "-rf", Log], check=True)
                show_banner()

                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {LOGS} :"],
                    text=True, stdout=subprocess.PIPE
                )
                choix_log = result.stdout.strip()

                show_banner()
                result = subprocess.run(
                    ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {LOGS} :"],
                    text=True, stdout=subprocess.PIPE
                )
                confirm_choix_log = result.stdout.strip()

                if choix_log == confirm_choix_log:
                    pw = choix_log + "\n" + confirm_choix_log + "\n"
                    subprocess.run(["pass", "insert", "-f", "gcert/logs"], input=pw, text=True)

                    if os.path.exists(Log):
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
                            f"Changement du Mot de Passe => {LOGS} OK"
                        ])
                        time.sleep(2)

                        break
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            f"Problème lors du Changement du Mot de passe => {LOGS}..."
                        ])
                        time.sleep(3)
                        
                        from my_package.Gestion.Pass.gestion_pass import gestion_pass
                        g = gestion_pass()
                        g.menu_pass()
                
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Veuillez entrer deux Mots de Passe identiques..."
                    ])
                    time.sleep(3)
                continue
            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Mot de passe Incorrect\n"
                ])
                time.sleep(2)

                from my_package.Gestion.Pass.gestion_pass import gestion_pass
                g = gestion_pass()
                g.menu_pass()

    if __name__ == "__main__":
        menu()

except KeyboardInterrupt:
    pass