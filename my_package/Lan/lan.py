#!/usr/bin/env python3
import os
import pyfiglet
import sys
import subprocess
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner

# Test pour Menu Lan

class Lan:
    def show_banner(self):
        show_banner()

    def menu_lan(self):
        # Nettoyer le terminal
        os.system('clear')

        # Affichage du titre en ASCII
        f = pyfiglet.figlet_format("G.Cert", font="starwars")
        print(f)

        print("lan ok!")

        # Retour au menu principal
        from main import main
        main()


if __name__ == "__main__":
    l = Lan()
    l.menu_lan()
