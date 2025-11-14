# TEMPLATE


#choose 

result = subprocess.run([
            "gum", "choose",
            "--header", "\n\nVeuillez choisir ...",
            "--limit", "1",
            "--height", "10",
            "TEXTE",
            
        ], text=True, stdout=subprocess.PIPE)

        choix = result.stdout.strip()







Test GUM

### style


subprocess.run([
            "gum", "style",
            "--foreground", COLOR_TEXT,
            "--padding", "1 2",
            "",
            ""
        ])

### spin


subprocess.run([
                "gum", "spin",
                "--spinner", "dot",
                "--title", "TEXTE",
                "--", "bash", "-c", "sleep 2",
            ])
time.sleep(2)
# python gcert 


    print(f"{GREEN}[{CHECK}]{NC}{WHITE} Password Store{NC}   - Répertoire local où pass stocke tous les mots de passe")
    print(f"└── {YELLOW}[2]gcert{NC}       - Dossier contenant les Mots de passe")
    print(f"    ├── {WHITE}[3]master{NC}   - Mot de passe maître pour accéder à tous les services")
    print(f"    └── {WHITE}[4]wan{NC}      - Mot de passe pour le service WAN")
    print(f"    └── {WHITE}[5]lan{NC}      - Mot de passe pour le service LAN")
    print(f"    └── {WHITE}[6]gestion{NC}  - Mot de passe pour le service Gestion")
    print(f"    └── {WHITE}[7]certif{NC}   - Mot de passe pour le service Certificats")
    print(f"    └── {WHITE}[8]logs{NC}     - Mot de passe pour le service Logs\n")


# Import clé GPG 

from my_package.Gestion.Pass.modif import Modif

# Création de l'objet
m = Modif()

# Récupération de la dernière fingerprint
m.fingerprint()
show_fp = m.last_fp         

print(f"Dernière fingerprint : {show_fp}")



# Baniere
#juste def
from my_package.utils import  show_banner
show_banner()

# Avec class 
from my_package.utils import  show_banner

def show_banner(self):
        show_banner() 

self.show_banner()


time.sleep(3)

#!/usr/bin/env python3
import sys
import subprocess
import signal
import psutil
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner


# reour menu principale 

import main
main.main()



#sans classe 
if __name__ == "__main__":
    
   changement_mdp()

# avec classe 
if __name__ == "__main__":
    m = Modif()
    fingerprint()    
    gpg_mdp()