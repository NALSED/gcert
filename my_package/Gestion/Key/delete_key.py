#!/usr/bin/env python3

"""
Depuis gestion_pass.py

    Ce script permet de gérer les clé GPG: lister ,supprimmer.
        
        Test si la clé GPG est celle de pass pour la gestion de mot de passe,
        Si c'est le cas Message alerte, possiblité de supprimmer quand même. 
    
    => redirection vers modif_mdp_gpg.py

        
        modif_mdp_gpg.py : * Suppression de Password store.(Lié à l'ancienne clé)
                           * Création ou utilisation d'une clé existante pour la création de Password store       
        
        => redirection vers changement_mdp.py
            changement_mdp.py : Création nouveau Mot de Passe.
"""

import subprocess
import time
import datetime
from tabulate import tabulate
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_TEXT, GREEN, RED, YELLOW, WHITE, NC, show_banner
from pathlib import Path

def erase():
    
    # Lister les clés
    result = subprocess.run(
        ["gpg", "--list-keys", "--with-colons", "--fingerprint"],
        text=True,
        stdout=subprocess.PIPE
    )

    """Le bloc suivant a pour but :
            D'extraire :    -Les donnés utilisateur fourni par GNUPG
                            - Le Fingerprint
                            - UID
                            - L'algo de chiffrement de GnuPG
                            - Si existante, la date d’expiration de la clé GPG

        Pour réaliser un tableau couleur à l'utilisateur, afin de choisir laquelle supprimer                   
    """

# ============================= INFO CLE GPG ET CREATION TABLEAU =============================  
    
    lines = result.stdout.splitlines() # Divise la sortie en une liste de lignes
    current_uid = ""                   # Stocke l'UID 
    current_fingerprint = ""           # Stocke fingerprint
    keys_data = []                     # Liste informations complètes de toutes les clés
    fingerprints_list = []             # Liste pour stocker uniquement les empreintes des clés
    key_ids = {}                       # Dictionnaire pour associer les IDs de clés aux autres informations

    after_pub = False                  # Flag pour savoir si on vient de traiter une ligne "pub" 
    current_key_id = ""                # Stocke l'ID de la clé actuelle

    # Analyse des lignes pour détecter les clés publiques, récupérer leur ID et leur algorithme.
    for line in lines:
        
        # Sépare la ligne en parties à chaque ":"
        parts = line.split(":")
        # Si la ligne décrit une clé pub
        if parts[0] == "pub":
            
            #  Activation du flag si lecture clé publique
            after_pub = True
            
            # identifie ID index 4
            key_id = parts[4]
            current_key_id = key_id
            algo = parts[3]
            
            # Source Algo => GGnupg
            algo_map = {
                "1": "RSA",
                "2": "DSA et Elgamal",
                "3": "DSA (sign only)",
                "4": "RSA (sign only)",
                "9": "ECC (sign and encrypt)",
                "10": "ECC (sign only)",
                "22": "EdDSA"
            }
            algo = algo_map.get(algo, f"Code {algo}")
            expire_ts = parts[6]
            
            # Si la ligne contient une date d'expiration
            if expire_ts:
                expire_date = datetime.datetime.fromtimestamp(int(expire_ts))  # Format date "YYYY-MM-DD"
                expire_str = expire_date.strftime("%Y-%m-%d")
            else:
                expire_str = "Jamais"
        
        # === FINGERPRINT ===
        # Si la ligne contient un fingerprint
        elif parts[0] == "fpr":
            current_fingerprint = parts[9] # On récupère le fingerprint à la 10ème position

            if after_pub:
                fingerprints_list.append(current_fingerprint) # On ajoute le fingerprint à la liste
                key_ids[current_fingerprint] = current_key_id # On associe le fingerprint à l'ID de la clé
                after_pub = False                             #  Réinitialise le flag après traitement
        
        # === UID ===
        # Si la ligne contient un UID
        elif parts[0] == "uid":
            current_uid = parts[9]  # On récupère l'UID à la 10ème position
            
            # On ajoute une entrée complète dans keys_data : fingerprint, UID, algo et date d'expiration
            keys_data.append([current_fingerprint, current_uid, algo, expire_str])
    
    # Si clés détectées ET stockées dans keys_data
    if keys_data:
        
        # couleurs
        colored_headers = [
            f"{WHITE}Fingerprint (40 hex){NC}", 
            f"{WHITE}Utilisateur{NC}",
            f"{WHITE}Algorithme{NC}",
            f"{WHITE}Expiration{NC}"
        ]
        
        # Prépare les données colorées pour l'affichage
        colored_data = []
        for row in keys_data:
            colored_data.append([
                f"{GREEN}{row[0]}{NC}",      # Fingerprint en vert
                f"{WHITE}{row[1]}{NC}",      # Utilisateur en blanc
                f"{COLOR_TEXT}{row[2]}{NC}", # Algorithme avec couleur définie par COLOR_TEXT
                f"{YELLOW}{row[3]}{NC}"      # Date d'expiration en jaune
            ])
        show_banner()
        print(tabulate(colored_data, headers=colored_headers, tablefmt="rounded_grid"))
        print(f"\n{WHITE}Voici les clés GPG présentes sur votre machine, laquelle voulez-vous écraser ?{NC}")
    
    else:
        # Message erreur
        print(f"{RED}Aucune clé GPG trouvée.{NC}")
        time.sleep(2)
        
        # retour menu de gestion des mots de passe et clé GPG
        from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
        g = gestion_pass_menu()
        g.menu_pass()
        return

    # La liste des fingerprints 40 caractères Hexa est affiché via GUM
    result = subprocess.run(
        ["gum", "choose", "--header", "\n\nVeuillez choisir ...", "--limit", "1", "--height", "10"] + fingerprints_list,
        text=True,
        stdout=subprocess.PIPE
    )
    choix_sup = result.stdout.strip()

    # Stockage de la clé GPG utilisée par pass pour vérification avant suppression
    result = subprocess.run(
        f"cat {Path.home()}/.password-store/.gpg-id",
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        shell=True
    )
    cle_pass = result.stdout.strip()


# ============================= SUPPRESSION PASS =============================
    
    choix_key_id = key_ids.get(choix_sup, "")
    
    # Vérifie si la clé choisie par l'utilisateur correspond à celle de pass
    if (choix_sup == cle_pass or            #=> exactement la clé principale
        choix_key_id == cle_pass or         # L'ID de la clé correspond à la clé principale
        choix_sup.endswith(cle_pass) or     # La saisie se termine par la clé principale
        cle_pass in [row[1] for row in keys_data if row[0] == choix_sup]):
        
        show_banner()
        
        # === MESSAGE AVERTISSEMENT ===
        print(
            f"{RED}!!! Attention !!!{NC}  "
            f"{YELLOW}Vous allez supprimer la {WHITE}clé GPG de pass{NC}{YELLOW}, qui gère les Mots de Passe de{NC} {WHITE}G.cert{NC}\n"
            f"{YELLOW}Si vous continuez, vous devrez refaire la phase de création de {WHITE}clé GPG{NC} {YELLOW}ET{NC} {WHITE}mot de passe,{NC}\n"
            f"{YELLOW}sinon vous ne pourrez plus accéder aux services{NC} {WHITE}G.Cert...{NC}"
        )

        time.sleep(5)

        show_banner()
        
        # === CHOIX SUPPRESSION ===
        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nSouhaitez vous poursuivre l'opération de suppression?",
            "--limit", "1",
            "--height", "10",
            "Oui",
            "Non"
        ], text=True, stdout=subprocess.PIPE)
        choix_erase = result.stdout.strip()

        if choix_erase == "Oui":
            # Suppression clé secrète puis clé publique
            subprocess.run(["gpg", "--batch", "--yes", "--delete-secret-key", choix_sup])
            subprocess.run(["gpg", "--batch", "--yes", "--delete-key", choix_sup])

            # === TEST SUPPRESSION ===
            result_chk = subprocess.run(
                ["gpg", "--list-keys", choix_sup],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            if result_chk.returncode == 0:
                # Si problème retour menu gestion mot de passe et clé GPG
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Erreur : Problème lors de la suppression de la clé : {choix_sup}"
                ])
                time.sleep(2)
                
                # === MENU GESTION MDP GPG ===
                from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
                g = gestion_pass_menu()
                g.menu_pass()
                return
            
            else:
                # Si OK, redirection création de mot de passe, car les services de "gcert" sont accessibles via mot de passe
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Suppression de la clé : {choix_sup} effectuée"
                ])
                time.sleep(2)
                
                show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Redirection Création PassStore et Mot de passe pour G.Cert...",
                    "--", "bash", "-c", "sleep 2",
                ])
                
                # Redirection création mot de passe propre à la suppression de clé :
                
                # === CREATION MDP APRES SUP GPG ===
                from my_package.Gestion.Key.modif_mdp_gpg import Modif_mdp
                m = Modif_mdp()
                m.gpg_mdp()
                return
        
        elif choix_erase == "Non":
            show_banner()
            
            # Si "NON" retour menu gestion mot de passe et clé GPG
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Retour Menu Gestion Mots de Passe et clé GPG...",
                "--", "bash", "-c", "sleep 2",
            ])
            
            # === MENU GESTION MDP GPG ===
            from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
            g = gestion_pass_menu()
            g.menu_pass()
            return

    # ============================= SUPPRESSION NORMALE =============================
    
    else:
        # Suppression clé secrète puis clé publique
        subprocess.run(["gpg", "--batch", "--yes", "--delete-secret-key", choix_sup])
        subprocess.run(["gpg", "--batch", "--yes", "--delete-key", choix_sup])

        # test suppression
        result_chk = subprocess.run(
            ["gpg", "--list-keys", choix_sup],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        if result_chk.returncode == 0:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                f"Erreur : Problème lors de la suppression de la clé : {choix_sup}"
            ])
            time.sleep(2)
            
            from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
            g = gestion_pass_menu()
            g.menu_pass()
            return
        
        else:
            show_banner()
            #  Si OK, redirection retour menu gestion mot de passe et clé GPG
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                f"Suppression de la clé : {choix_sup} effectuée"
            ])
            time.sleep(2)
            
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Retour Menu Gestion Mots de Passe et clé GPG...",
                "--", "bash", "-c", "sleep 2",
            ])
            
            # === MENU GESTION MDP GPG ===
            from my_package.Gestion.Pass.gestion_pass import gestion_pass_menu
            g = gestion_pass_menu()
            g.menu_pass()
            return

if __name__ == "__main__":
    erase()