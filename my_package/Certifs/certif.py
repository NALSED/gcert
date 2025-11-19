#!/usr/bin/env python3
import os         
import pyfiglet
import sys
import subprocess
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner

# Test pour Menu Certif
class Certif:
    def show_banner(self):
        show_banner()
    
    def menu_certif(self):
        # Clean Shell
        os.system('clear')
        # Message en Text to ASCII
        f = pyfiglet.figlet_format("G.Cert", font="starwars")
        print(f)
        print("certif ok!")
        from main import main 
        main()


if __name__ == "__main__":
    g = certif()
    g.menu_certif()
