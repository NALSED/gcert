#!/usr/bin/env python3
import os         
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
import re
from my_package.Gestion.Pass.changement_mdp import chang_mdp
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN,RED, YELLOW, WHITE, NC, CHECK, WAN, LAN, GESTION, CERTIF, LOGS, show_banner, RED


# === CHEMIN VERIF MDP ===
Pass_Store = os.path.expanduser("~/.password-store")


# =============================== SCRIPT ==============================
class Modif_mdp:
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

    # ============================= NOUVELLE CLE =============================
    def new(self):        
        self.show_banner()
        subprocess.run([
            "gum", "spin",
            "--spinner", "dot",
            "--title", "Création nouvelle clé GPG...",
            "--", "bash", "-c", "sleep 2",
        ])

        # génération de la clé GPG
        self.show_banner()
        print(f" {RED}=> !!! RAPPEL : !!!{NC}  (1) {GREEN}RSA and RSA{NC}  => compatible avec pass\n\n")
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
                f"=== Création Password Store ===\n\nAvec le fingerprint {show_fp}"
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
            result_pass = subprocess.run(
                ["pass", "init", show_fp], 
                stdout=subprocess.DEVNULL, 
                stderr=subprocess.DEVNULL
            )
            
            if result_pass.returncode != 0:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Erreur lors de l'initialisation de pass. Vérifiez votre clé GPG."
                ])
                time.sleep(3)
                self.show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Veuillez patienter, lancement de la réinitialisation.",
                    "--", "bash", "-c", "sleep 3",
                ])
                self.gpg_mdp()
                return

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
                
                self.show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Veuillez patienter, lancement de la réinitialisation des Mots de Passe.",
                    "--", "bash", "-c", "sleep 3",
                ])
                chang_mdp()
            
            else:
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    "Problème lors de la création de Password Store...",
                    "Un processus complet de clé GPG et Mots de passe va être initialisé..."
                ])
                time.sleep(3)
                self.show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Veuillez patienter, lancement de la réinitialisation.",
                    "--", "bash", "-c", "sleep 3",
                ])
                
                self.gpg_mdp()

        else:
            self.show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "Problème avec la génération de la clé GPG, veuillez consulter les logs de G.Cert..."
            ])
            
            time.sleep(3)
            os.system('clear')
            subprocess.run(["pkill", "-f", "g_cert.sh"])
            sys.exit()

    # ============================= CLE EXISTANTE =============================
    def exist(self):           
        count = 0
        
        while True:
            self.show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                "!!! Vous devez être en possession de la passphrase de votre clé !!!\n"
            ])
            time.sleep(2)

            result2 = subprocess.run(
                ["gum", "input", "--prompt", "Veuillez entrer la clé GPG : "],
                stdout=subprocess.PIPE,  
                text=True
            )
            
            if result2.returncode != 0:
                continue
                
            gpg_key = result2.stdout.strip()
            
            # Test format
            format_valide = re.match(r'^[0-9A-F]{40}$', gpg_key) is not None
            
            if format_valide:
                self.show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    "Format OK"
                ])
                time.sleep(2)
                
                # Test existence clé
                result_test = subprocess.run(
                    ["gpg", "--list-keys", gpg_key],
                    capture_output=True,
                    text=True
                )
                
                if result_test.returncode != 0:
                    self.show_banner()
                    print(f"{RED}Cette clé n'existe pas dans votre trousseau GPG\n{NC}")
                    time.sleep(2)
                    
                    result = subprocess.run([
                        "gum", "choose",
                        "--header", "\n\nVeuillez choisir ...",
                        "--limit", "1",
                        "--height", "10",
                        "Créer une nouvelle clé GPG",
                        "Nouvelle tentative"
                    ], text=True, stdout=subprocess.PIPE)

                    choix = result.stdout.strip()
    
                    if choix == "Créer une nouvelle clé GPG":
                        self.new()
                        return
                    
                    elif choix == "Nouvelle tentative":
                        continue
                
                else:
                    # Clé existe, création password store
                    self.show_banner()
                    subprocess.run([
                        "gum", "style",
                        "--foreground", COLOR_TEXT,
                        "--padding", "1 2",
                        f"Création Password Store...\n\nAvec le fingerprint {gpg_key}"
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
                    result_pass = subprocess.run(
                        ["pass", "init", gpg_key], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL
                    )
                    
                    if result_pass.returncode != 0:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            "Erreur lors de l'initialisation de pass. Vérifiez votre clé GPG."
                        ])
                        time.sleep(3)
                        continue

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
                        return
                    
                    else:
                        subprocess.run([
                            "gum", "style",
                            "--foreground", COLOR_NOK,
                            "--padding", "1 2",
                            "Problème lors de la création de Password Store...",
                            "Un processus complet de clé GPG et Mots de passe va être initialisé..."
                        ])
                        time.sleep(3)
                        self.show_banner()
                        subprocess.run([
                            "gum", "spin",
                            "--spinner", "dot",
                            "--title", "Veuillez patienter, lancement de la réinitialisation.",
                            "--", "bash", "-c", "sleep 3",
                        ])
                        
                        
                        chang_mdp()
                        return
            
            else: 
                # Format incorrect
                count += 1
                self.show_banner()
                print(f"{RED}Format incorrect...\n{NC}")
                print(f"{RED}Vous disposez de trois essais pour entrer une clé valide...\n{NC}")
                print(f"{YELLOW}Passés ces essais une clé et des nouveaux mots de passe seront créés automatiquement\n{NC}") 
                
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nombre d'essais restants : {3 - count}"
                ])
                time.sleep(3)
                
                if count >= 3:
                    self.show_banner()
                    print(f"{YELLOW}Création nouvelle Clé GPG et Mot de passe...\n{NC}")
                    subprocess.run([
                        "gum", "spin",
                        "--spinner", "dot",
                        "--title", "Veuillez patienter, lancement de la réinitialisation.",
                        "--", "bash", "-c", "sleep 3",
                    ])
                    
                    self.new()
                    return

    # =============================== CREATION GPG + MDP ==============================
    def gpg_mdp(self):
        # Affiche la bannière
        self.show_banner()

        try:
            # Demande le mot de passe sudo, car modification de données sensibles
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
            subprocess.run(["rm", "-rf", Pass_Store])
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
            result = subprocess.run([
                "gum", "choose",
                "--header", "\n\nVeuillez choisir ...",
                "--limit", "1",
                "--height", "10",
                "Créer une nouvelle clé GPG",
                "Utiliser une clé existante"
            ], text=True, stdout=subprocess.PIPE)

            choix_gpg = result.stdout.strip()

            if choix_gpg == "Créer une nouvelle clé GPG":
                self.new()
            
            elif choix_gpg == "Utiliser une clé existante":
                self.exist()

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
    m = Modif_mdp()
    m.gpg_mdp()