#!/usr/bin/env python3

"""
Depuis Pass/modif.py / Key/modif_mdp_gpg.py
    Création de mots de passe et redirection vers main.py
    """

import os
import sys
import subprocess
import time
from my_package.utils import COLOR_OK, COLOR_NOK, GREEN, YELLOW, WHITE, NC, CHECK, WAN, LAN, GESTION, CERTIF, LOGS, show_banner

# === CHEMIN VERIF MDP ===
Wan = os.path.expanduser("~/.password-store/gcert/wan.gpg")
Lan = os.path.expanduser("~/.password-store/gcert/lan.gpg")
Gestion = os.path.expanduser("~/.password-store/gcert/gestion.gpg")
Certif = os.path.expanduser("~/.password-store/gcert/certif.gpg")
Log = os.path.expanduser("~/.password-store/gcert/logs.gpg")


# =============================== CHANGEMENT MDP ==============================
def chang_mdp():
    # ==================== WAN ====================
    while True:
        # Suppression dossier pass des mots de passe
        subprocess.run(["rm", "-rf", Wan, Lan, Gestion, Certif, Log], check=True)
        show_banner()
        # nouveau mdp
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {YELLOW}[2]gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {WHITE}[3]wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe =>{WAN} : "],
            text=True, stdout=subprocess.PIPE
        )
        choix_wan = result.stdout.strip()

        # confirmation
        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {YELLOW}[2]gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {WHITE}[3]wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe =>{WAN} : "],
            text=True, stdout=subprocess.PIPE
        )
        confirm_choix_wan = result.stdout.strip()

        # Test nouveau mdp = confirmation
        if choix_wan == confirm_choix_wan:
            pw = choix_wan + "\n" + confirm_choix_wan + "\n"
            subprocess.run(["pass", "insert", "-f", "gcert/wan"], input=pw, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, text=True)

            # Test existence
            if os.path.exists(Wan):
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {WHITE}[3]wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    "Création du dossier gcert OK"
                ])
                time.sleep(2)

                # récap
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")

                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Création du Mot de Passe => {WAN} OK"
                ])
                time.sleep(3)

                break
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probléme lors de la Création du Mot de passe => {WAN}"
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
                "Veuillez entrer deux Mots de Passe identique..."
            ])
            time.sleep(3)

    # ==================== LAN ====================
    while True:
        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {LAN} : "],
            text=True, stdout=subprocess.PIPE
        )
        choix_lan = result.stdout.strip()

        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {LAN} : "],
            text=True, stdout=subprocess.PIPE
        )
        confirm_choix_lan = result.stdout.strip()

        if choix_lan == confirm_choix_lan:
            pw = choix_lan + "\n" + choix_lan + "\n"
            subprocess.run(["pass", "insert", "-f", "gcert/lan"], input=pw, text=True)

            if os.path.exists(Lan):
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Création du Mot de Passe => {LAN} OK"
                ])
                time.sleep(2)
                break
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probléme lors de la Création du Mot de passe => {LAN}..."
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
                "Veuillez entrer deux Mots de Passe identique..."
            ])
            time.sleep(3)

    # ==================== GESTION ====================
    while True:
        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {GESTION} : "],
            text=True, stdout=subprocess.PIPE
        )
        choix_gestion = result.stdout.strip()

        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")

        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {GESTION} : "],
            text=True, stdout=subprocess.PIPE
        )
        confirm_choix_gestion = result.stdout.strip()

        if choix_gestion == confirm_choix_gestion:
            pw = choix_gestion + "\n" + choix_gestion + "\n"
            subprocess.run(["pass", "insert", "-f", "gcert/gestion"], input=pw, text=True)

            if os.path.exists(Gestion):
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Création du Mot de => {GESTION} OK"
                ])
                time.sleep(2)
                break
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probléme lors de la Création du Mot de passe => {GESTION}"
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
                "Veuillez entrer deux Mots de Passe identique..."
            ])
            time.sleep(3)

    # ==================== CERTIF ====================
    while True:
        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {CERTIF} : "],
            text=True, stdout=subprocess.PIPE
        )
        choix_certif = result.stdout.strip()

        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {CERTIF} : "],
            text=True, stdout=subprocess.PIPE
        )
        confirm_choix_certif = result.stdout.strip()

        if choix_certif == confirm_choix_certif:
            pw = choix_certif + "\n" + choix_certif + "\n"
            subprocess.run(["pass", "insert", "-f", "gcert/certif"], input=pw, text=True)

            if os.path.exists(Certif):
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Création du Mot => {CERTIF} OK"
                ])
                time.sleep(2)
                break
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probléme lors de la Création du Mot de passe => {CERTIF}"
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
                "Veuillez entrer deux Mots de Passe identique..."
            ])
            time.sleep(3)

    # ==================== LOGS ====================
    while True:
        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez entrer un nouveau mot de passe => {LOGS} : "],
            text=True, stdout=subprocess.PIPE
        )
        choix_logs = result.stdout.strip()

        show_banner()
        print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
        print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
        print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}certif{NC}   - Mot de passe pour le service Certificats")
        print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
        
        result = subprocess.run(
            ["gum", "input", "--password", "--prompt", f"Veuillez confirmer le nouveau mot de passe => {LOGS} : "],
            text=True, stdout=subprocess.PIPE
        )
        confirm_choix_logs = result.stdout.strip()

        if choix_logs == confirm_choix_logs:
            pw = choix_logs + "\n" + choix_logs + "\n"
            subprocess.run(["pass", "insert", "-f", "gcert/logs"], input=pw, text=True)

            if os.path.exists(Log):
                
                show_banner()
                print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                print(f"└── {GREEN}[{CHECK}]{NC}{WHITE}gcert{NC}       - Dossier contenant les Mots de passe")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}wan{NC}      - Mot de passe pour le service WAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}lan{NC}      - Mot de passe pour le service LAN")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}gestion{NC}  - Mot de passe pour le service Gestion")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}certif{NC}   - Mot de passe pour le service Certificats")
                print(f"    └── {GREEN}[{CHECK}]{NC}{WHITE}logs{NC}     - Mot de passe pour le service Logs\n")
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Création du Mot de => {LOGS} OK"
                ])
                time.sleep(2)

                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    "Mots de Passes Réinitialisés avec succès. Redirection vers Menu Principal"
                ])
                time.sleep(3)

                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Retour Menu Principal",
                    "--", "bash", "-c", "sleep 1",
                ])
                from main import main
                main()
                break
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probléme lors du changement du mot de passe de => {LOGS}"
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
                "Veuillez entrer deux Mots de Passe identique..."
            ])
            time.sleep(3)


if __name__ == "__main__":
    changement_mdp()
