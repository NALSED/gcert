#!/usr/bin/env python3
"""
Ce module a pour but de créer la base des différents logs utilisés par les autres modules.
Un logger sera appliqué à chaque module et les messages seront enregistrés dans les fichiers correspondants.

"""
import os         
import logging
from logging.handlers import RotatingFileHandler # Utilisé pour la rotation des fichiers logs
import colorlog
from my_package.utils import show_banner


# Nom fichier logs
DEBUG_FILE = "debug.log"
INFO_FILE = "info.log"
WARNING_FILE = "warning.log"
ERROR_FILE = "error.log"
CRITICAL_FILE = "critical.log"
ROTATE_FILE = "app_rotated.log"

# Chemin logs
PATH_LOGS = os.path.join(os.path.dirname(__file__), 'LOGS')
# Créé les fichier logs, si non existant
os.makedirs(PATH_LOGS, exist_ok=True)


class Config:
    def show_banner(self):
        show_banner() 
    
    #Constructeur
    
    def __init__(self):
        # Crée (ou récupère s’il existe déjà) un logger nommé "GCertLogger"
        self.logger = logging.getLogger("GCertLogger")
        # definit le niveau des logs
        self.logger.setLevel(logging.DEBUG)
        
        self.setup_loggers()

    def setup_loggers(self):
        # Empêche les doublons d’handlers si on recrée plusieurs fois Config()
        if self.logger.handlers:
            return
        
        # Format Logs = jour/heure + niveau + message
        formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

        # Associe chaque niveau de log à un fichier séparé (Dictionnaire)
        fichiers = {
            logging.DEBUG: DEBUG_FILE,
            logging.INFO: INFO_FILE,
            logging.WARNING: WARNING_FILE,
            logging.ERROR: ERROR_FILE,
            logging.CRITICAL: CRITICAL_FILE,
        }

        for level, filename in fichiers.items():
            # écrit dans le fichier correspondant avec rotation automatique
            handler = RotatingFileHandler(
                os.path.join(PATH_LOGS, filename),
                maxBytes=10_000_000,  # Taille max avant rotation (10 Mo)
                backupCount=0,        # 0 = écrase le fichier quand la taille est dépassée
                encoding="utf-8"
            )
            # définit le niveau du log pour ce fichier
            handler.setLevel(level)
            # Format
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)

        # Handler coloré pour la console
        color_formatter = colorlog.ColoredFormatter(
            "%(log_color)s%(levelname)-8s%(reset)s | %(asctime)s | %(message)s",
            datefmt="%H:%M:%S",
            log_colors={
                "DEBUG": "cyan",
                "INFO": "green",
                "WARNING": "yellow",
                "ERROR": "red",
                "CRITICAL": "bold_red",
            },
        )

        console_handler = colorlog.StreamHandler()
        console_handler.setLevel(logging.DEBUG)
        console_handler.setFormatter(color_formatter)
        self.logger.addHandler(console_handler)

    # ========== Méthodes de flags ==========
    
    # Création format Flags avec tag + msg + niveau
    def flag(self, tag: str, message: str, level=logging.INFO):
       
        """
        La valeur par défaut du niveau est INFO. 
        Pour utiliser un autre niveau ("level"), il faut le préciser avec l'argument `level` :

        Exemple avec `flag` :
            self.flag("FILE", "Impossible de créer le fichier", level=logging.ERROR)
            self.flag("SYSTEM", "Base de données inaccessible !", level=logging.CRITICAL)

        Exemple avec les raccourcis :
            self.error_flag("FILE", "Impossible de créer le fichier")
            self.critical_flag("SYSTEM", "Base de données inaccessible !")
        """
        
        """Ajoute un flag [TAG] coloré et unifié à chaque log"""
        
        tag_str = f"[{tag.upper()}]"
        self.logger.log(level, f"{tag_str} {message}")

    def info_flag(self, tag: str, message: str):
        self.flag(tag, message, level=logging.INFO)

    def debug_flag(self, tag: str, message: str):
        self.flag(tag, message, level=logging.DEBUG)

    def warning_flag(self, tag: str, message: str):
        self.flag(tag, message, level=logging.WARNING)

    def error_flag(self, tag: str, message: str):
        self.flag(tag, message, level=logging.ERROR)

    def critical_flag(self, tag: str, message: str):
        self.flag(tag, message, level=logging.CRITICAL)


#Logger global réutilisable dans tout le projet
logger = Config().logger

if __name__ == "__main__":
    # Crée une instance du logger global pour test ou usage direct
    config = Config()
    logger = config.logger

    # Exemple de test de log
    config.info_flag("TEST", "Logger opérationnel depuis l'exécution directe du module")




"""
COMMENT UTILISER LES FLAGS:

# 1) Récupérer le choix utilisateur (ou tout message à logger)
self.choix_logs = result.stdout.strip()

# 2) Logger le message avec le niveau INFO
#    - Redirige automatiquement vers le fichier info.log et la console
#    - Format uniforme : [TAG] message
self.logger.info(f"Choix utilisateur : {self.choix_logs}")
self.logger.info(f"GUM Output: {result.stdout.strip()}") <============ IMPORTANT DE RECUPERER LA SORTIE
# 3) Pour des messages normaux, DEBUG, WARNING, ERROR ou CRITICAL,
#    utiliser les raccourcis *_flag pour ajouter un tag et le niveau automatiquement :
#    Exemple :
#       self.info_flag("MENU", "Utilisateur a choisi Info")
#       self.debug_flag("CHECK", "Valeur de x = 42")
#       self.warning_flag("NETWORK", "Connexion instable")
#       self.error_flag("FILE", "Impossible de créer le fichier")
#       self.critical_flag("SYSTEM", "Panne critique détectée")

# 4) Effacer l'écran si nécessaire (optionnel)
os.system('clear')

utiliser ça pour capturer les exeption
!!!!!!!!!!!!
except Exception as e:
                        console.print(f"[red]Erreur lors du chargement de la documentation: {e}[/red]")
                        input("\nAppuyez sur Entrée pour continuer...")
!!!!!!!!!!!!

"""
