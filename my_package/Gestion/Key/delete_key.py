#!/usr/bin/env python3
import sys
import subprocess
import signal
import psutil
import time
import datetime
import io
from contextlib import redirect_stdout
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner
from my_package.Gestion.Pass.gestion_menu import GestionMenu


def erase():
    # lister les clés 
    result = subprocess.run(
        ["gpg", "--list-keys", "--with-colons"], # Sortie brute pour la boucle for
        text=True,
        stdout=subprocess.PIPE
    )

    lines = result.stdout.splitlines()
    current_uid = ""  # Variable pour stocker l'utilisateur associé à la clé
    key_ids = []      # Liste pour stocker tous les key_id à proposer à gum

    for line in lines:
        parts = line.split(":")

        if parts[0] == "uid":
            current_uid = parts[9]

        elif parts[0] == "pub":
            key_id = parts[4][-8:]
            algo = parts[3]

            if algo == "1":
                algo = "RSA"
            elif algo == "2":
                algo = "DSA et Elgamal"
            elif algo == "3":
                algo = "DSA (sign only)"
            elif algo == "4":
                algo = "RSA (sign only)"
            elif algo == "9":
                algo = "ECC (sign and encrypt)"
            elif algo == "10":
                algo = "ECC (sign only)"
            else:
                algo = f"Code {algo}"

            expire_ts = parts[6]
            if expire_ts:
                expire_date = datetime.datetime.fromtimestamp(int(expire_ts))
                expire_str = expire_date.strftime("%Y-%m-%d")
            else:
                expire_str = "Jamais"

            show_banner()
            print(f"\nClé publique : {GREEN}{key_id}{NC} | Expire : {YELLOW}{expire_str}{NC} | Algo : {algo} | Utilisateur : {current_uid}")

            key_ids.append(key_id)

    show_banner()
    subprocess.run([
        "gum", "style",
        "--foreground", COLOR_TEXT,
        "--padding", "1 2",
        "Voici les clés GPG présentes sur votre machine, laquelle voulez-vous écraser?\n"
    ])

    result = subprocess.run(
        ["gum", "choose", "--header", "\n\nVeuillez choisir ...", "--limit", "1", "--height", "10"] + key_ids,
        text=True,
        stdout=subprocess.PIPE
    )

    choix_sup = result.stdout.strip()

    result = subprocess.run(
        ["cat", "~/.password-store/.gpg-id"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        shell=True
    )

    cle_pass = result.stdout.strip()

    if choix_sup == cle_pass:
        subprocess.run([
            "gum", "style",
            "--foreground", COLOR_NOK,
            "--padding", "1 2",
            "!!! Attention vous allez supprimer la clé GPG de pass qui gére les Mot de pass de G.cert !!!",
            "Si vous continuez, vous devez refaire la phase de création de clé ET mot de passe, sinon vous ne pourrez plus accéder aux services G.Cert...\n"
        ])
        time.sleep(4)

        result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "Yes",
            "No"
        ], text=True, stdout=subprocess.PIPE)

        choix_erase = result.stdout.strip()

        if choix_erase == "Yes":
            subprocess.run(["gpg", "--batch", "--yes", "--delete-key", key_id])
            subprocess.run(["gpg", "--batch", "--yes", "--delete-secret-key", key_id])

            buf = io.StringIO()
            with redirect_stdout(buf):
                print(key_id)
            captured_output = buf.getvalue().strip()
            print(captured_output)

            if key_id in captured_output:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Probleme lors de la suppression de la clé : {key_id}"
                ])
                time.sleep(2)

                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_NOK,
                    "--padding", "1 2",
                    f"Nouvelle tentative de suppression de la clé : {key_id}"
                ])
                time.sleep(2)
                    
                    show_banner()
                    result = subprocess.run([
                        "gum", "choose",
                        "--header", "\n\nVeuillez choisir ...",
                        "--limit", "1",
                        "--height", "10",
                        "Essayer à nouveau une suppression",
                        "Retour menu principal"
                    ], text=True, stdout=subprocess.PIPE)

                    choix = result.stdout.strip()
                    # Redirection => effcement
                    if choix == "Essayer à nouveau une suppression":
                        erase()

                    # Redirection => menu principale
                    elif choix == "Retour menu principal":
                        from main import main 
                        main()

            else:
                show_banner()
                subprocess.run([
                    "gum", "style",
                    "--foreground", COLOR_OK,
                    "--padding", "1 2",
                    f"Suppression de la clé : {key_id} effectuée"
                ])
                time.sleep(2)
                show_banner()
                subprocess.run([
                    "gum", "spin",
                    "--spinner", "dot",
                    "--title", "Retour Menu Gestion Mots de Passe et clé GPG...",
                    "--", "bash", "-c", "sleep 2",
                ])
                g = GestionMenu()
                g.menu_gest()

        elif choix_erase == "No":
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Retour Menu Gestion Mots de Passe et clé GPG...",
                "--", "bash", "-c", "sleep 2",
            ])
            g = GestionMenu()
            g.menu_gest()

    else:
        subprocess.run(["gpg", "--batch", "--yes", "--delete-key", key_id])
        subprocess.run(["gpg", "--batch", "--yes", "--delete-secret-key", key_id])

        buf = io.StringIO()
        with redirect_stdout(buf):
            print(key_id)
        captured_output = buf.getvalue().strip()
        print(captured_output)

        if key_id in captured_output:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                f"Probleme lors de la suppression de la clé : {key_id}"
            ])
            time.sleep(2)

            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_NOK,
                "--padding", "1 2",
                f"Nouvelle tentative de suppression de la clé : {key_id}"
            ])
            time.sleep(2)

            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Lancement de la suppression",
                "--", "bash", "-c", "sleep 2",
            ])
            erase()

        else:
            show_banner()
            subprocess.run([
                "gum", "style",
                "--foreground", COLOR_OK,
                "--padding", "1 2",
                f"Suppression de la clé : {key_id} effectuée"
            ])
            time.sleep(2)
            show_banner()
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "Retour Menu Gestion Mots de Passe et clé GPG...",
                "--", "bash", "-c", "sleep 2",
            ])
            g = GestionMenu()
            g.menu_gest()


if __name__ == "__main__":
    erase()
