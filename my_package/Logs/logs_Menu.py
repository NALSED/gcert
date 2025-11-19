#!/usr/bin/env python3
import os
import sys
import subprocess
from my_package.Logs.logs_Arch import Config, PATH_LOGS
from my_package.utils import COLOR_BORDER, COLOR_TEXT , show_banner


# Classe principale pour le menu des logs
class Choix_Logs(Config):
    
    # Affiche le banner en haut
    def show_banner(self):
        show_banner() 
    
    def __init__(self):
        super().__init__()  # Initialise le logger Config
        self.COLOR_TEXT = COLOR_TEXT    # Couleur texte pour gum
        self.COLOR_BORDER = COLOR_BORDER # Couleur bordure pour gum
        self.choix_logs = None     # Stocke le choix de l'utilisateur

    # Affiche le menu principal
    def menu(self):
        # Titre du menu avec bordure
        subprocess.run([
            "gum", "style",
            "--foreground", self.COLOR_TEXT,
            "--border-foreground", self.COLOR_BORDER,
            "--border", "double",
            "--margin", "0 0",
            "--padding", "0 2 0 2",
            "Bienvenue dans le menu de gestion des logs de G.Cert\n"
        ])
        
       
        subprocess.run([
            "gum", "style",
            "--foreground", self.COLOR_TEXT,
            "--margin", "0 0",
            "--padding", "0 2 0 2",
            "Vous pouvez sélectionner un niveau de log ci-dessous\n"
        ])

        
        result = subprocess.run(
            [
                "gum", "choose",
                "--header", "Veuillez choisir ...",
                "--limit", "1",
                "--height", "10",
                "Info",
                "Warning",
                "Error",
                "Critical",
                "Retour",
                "Quitter"
            ],
            text=True,
            stdout=subprocess.PIPE
        )
        self.choix_logs = result.stdout.strip()
        
        # Logger le choix de l'utilisateur
        self.logger.info(f"Choix utilisateur : {self.choix_logs}")
        os.system('clear') 

    
    def afficher_menu(self):
        self.menu()
        if self.choix_logs not in ("Retour", "Quitter"):
            subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", f"Chargement Menu {self.choix_logs}",
                "--", "bash", "-c", "sleep 1",
            ])
        os.system('clear')  

# Fonction principale pour afficher le menu des logs
def menu_choix_logs():
    menu = Choix_Logs() 
    while True:
        menu.show_banner()     
        menu.afficher_menu()   # Affiche le menu et récupère le choix
        choix = menu.choix_logs

        # Si l'utilisateur choisit un niveau de log
        if choix in ("Info", "Warning", "Error", "Critical"):
            # Nom
            file_name = f"{choix.lower()}.log"
            # Chemin
            file_path = os.path.join(PATH_LOGS, file_name)
            if os.path.exists(file_path):
                # Affiche le contenu du fichier en lecture seul
                with open(file_path, "r") as f:
                    print(f.read())
            
            # Sinon message erreur
            else:
                print(f"Fichier {file_name} introuvable.")
            input("\nAppuyez sur Entrée pour revenir au menu...")

        # Retour au menu précédent
        elif choix == "Retour":
            from main import main 
            main()
        
        # Quitter l'application
        elif choix == "Quitter":
            subprocess.run([
                "gum", "style",
                "--foreground", "196",
                "--border-foreground", menu.COLOR_BORDER,
                "--border", "double",
                "--margin", "0 0",
                "--padding", "0 2 0 2",
                "Au revoir..."
            ])
            sys.exit()


# Point d'entrée si exécuté directement
if __name__ == "__main__":
    menu_choix_logs()
