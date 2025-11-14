#!/usr/bin/env python3
import os         
import pyfiglet
import sys
import subprocess
import signal
import psutil
import time
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner

class gestion_certif:
    def menu_certif(self):
        os.system("clear")
        f = pyfiglet.figlet_format("G.Cert", font="starwars")
        print(f)
        print("Gestion certif OK!")
        from main import main 
        main()

if __name__ == "__main__":
    g = gestion_certif()
    g.menu_certif()        