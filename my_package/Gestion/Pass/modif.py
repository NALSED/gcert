#!/usr/bin/env python3
import os         
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
from my_package.Gestion.Pass.changement_mdp import chang_mdp
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, RED, NC, CHECK, WAN, LAN, GESTION, CERTIF, LOGS, show_banner


# === CHEMIN VERIF MDP ===
Pass_Store = os.path.expanduser("~/.password-store")

# =============================== SCRIPT ==============================
class Modif:
    # Bannière
    def show_banner(self):
        show_banner() 

    # Récupération du dernier fingerprint de clé GPG
    def fingerprint(self):
        out = subprocess.run(
            ["gpg", "--with-colons", "--list-keys"],
            text=True, capture_output=True
        ).stdout

        for line in out.splitlines():
            if line.startswith("fpr:"):
                parts = line.split(":")
                if len(parts) > 9 and parts[9]:
                    self.last_fp = parts[9]
        return getattr(self, "last_fp", None)

    # =============================== CREATION MDP + GPG ==============================
    def gpg_mdp(self):
        # Affiche la bannière
        self.show_banner()

        try:
            # Demande le mot de passe sudo, car modofication de données sensibles
            subprocess.run(["sudo", "-k", "-v"], check=True)
            
            self.show_banner()
            # Message de succès
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                "\nMot de passe sudo correct\n\nAccès autorisé\n"
            ])
            time.sleep(2)

            # Explications / choix 
            self.show_banner()
            subprocess.run(["rm", "-rf", Pass_Store], check=True)
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_TEXT,
                "--padding", "1 2",
                "\n1) Création nouvelle clé GPG via Gnupg\n\n"
                "2) Création des Mots de Passe pour les différents services de G.cert\n\n"
                "Arborescence prévue :\n"
                "Password Store\n"
                "└── gcert\n"
                "    ├── certif\n"
                "    ├── gestion\n"
                "    ├── lan\n"
                "    ├── logs\n"
                "    └── wan\n"
            ])
            input("Appuyez sur Entrée pour continuer...")

            self.show_banner()
            print(f"{YELLOW}================================================================================================={NC}")
            print(f"{WHITE}INFORMATION : Clé GPG pour le gestionnaire de mots de passe 'pass'{NC}")
            print(f"{YELLOW}================================================================================================={NC}")
            print(f"Pour utiliser {GREEN}pass{NC}, seule une clé {GREEN}RSA capable de signer et chiffrer{NC} est compatible.")
            print("\nLes options disponibles lors de la création d'une clé GPG :")
            print(f"  (1) {GREEN}RSA and RSA{NC}           => signature et chiffrement compatible avec pass")
            print(f"  (2) DSA and Elgamal                  => non compatible")
            print(f"  (3) DSA (sign only)                  => non compatible")
            print(f"  (4) RSA (sign only)                  => non compatible")
            print(f"  (9) ECC (sign and encrypt)           => non compatible (Attention par défaut)")
            print(f" (10) ECC (sign only)                  => non compatible")
            print(f" (14) Existing key from card           => Clé RSA existante ET RSA chiffrante")
            print(f"\n{YELLOW}============================================================================================={NC}\n")

            input("Appuyez sur Entrée pour continuer...")

            self.show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Création nouvelle clé GPG...",
                "--", "bash", "-c", "sleep 2",
            ])

            # génération de la clé GPG
            self.show_banner()
            print(f" {RED}=> !!! RAPPEL: !!!{NC}  (1) {GREEN}RSA and RSA{NC}  => compatible avec pass\n\n")
            subprocess.run(["gpg", "--full-generate-key"])

            # Dernier fingerprint
            self.fingerprint()
            show_fp = getattr(self, "last_fp", None)

            if show_fp:
                

                self.show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_TEXT,
                    "--padding", "1 2",
                    f"Création Password Store...\n\nAvec le fingerprint {show_fp}"
                ])
                time.sleep(2)
                self.show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Veuillez patienter...",
                    "--", "bash", "-c", "sleep 3",
                ])

                # Création du passtore
                self.show_banner()
                subprocess.run(["pass", "init", show_fp], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

                # Test présence passtore
                self.show_banner()
                if os.path.isdir(Pass_Store):
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_OK,
                        "--padding", "1 2",
                        "Création de Password Store OK"
                    ])
                    time.sleep(2)

                    self.show_banner()
                    print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
                    print(f"└── {YELLOW}[2]gcert{NC}       - Dossier contenant les Mots de passe")
                    print(f"    └── {WHITE}[3]wan{NC}      - Mot de passe pour le service WAN")
                    print(f"    └── {WHITE}[4]lan{NC}      - Mot de passe pour le service LAN")
                    print(f"    └── {WHITE}[5]gestion{NC}  - Mot de passe pour le service Gestion")
                    print(f"    └── {WHITE}[6]certif{NC}   - Mot de passe pour le service Certificats")
                    print(f"    └── {WHITE}[7]logs{NC}     - Mot de passe pour le service Logs\n")
                    time.sleep(2)
                
                    chang_mdp()
                
                else:
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_NOK,
                        "--padding", "1 2",
                        "Probléme lors de la création de Password Store..."
                    ])
                    time.sleep(3)
                    os.system('clear')
                    subprocess.run(["pkill", "-f", "g_cert.sh"])
                    sys.exit()

                    self.show_banner()
                    subprocess.run([
                        "gum", "spin",
                        "--spinner", "dot",
                        "--title", "Veuillez patienter, lancement de la réinitialisation du mot de passe.",
                        "--", "bash", "-c", "sleep 3",
                    ])

                    

            else:
                self.show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Probléme avec la passphrase de la clé GPG, veuillez consulter les logs de G.Cert..."
                ])
                time.sleep(3)
                os.system('clear')
                subprocess.run(["pkill", "-f", "g_cert.sh"])
                sys.exit()

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
    m = Modif()
    m.fingerprint()
    m.gpg_mdp()
