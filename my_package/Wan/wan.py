import sys
import subprocess
from my_package.utils import COLOR_OK, COLOR_NOK, COLOR_BORDER, COLOR_TEXT, GREEN, YELLOW, WHITE, NC, CHECK, show_banner
import os         
import pyfiglet

# Test Pour menu wan
class Wan:
    def show_banner(self):
        show_banner()
    
    def menu_wan(self):
        # Clean Shell
        os.system('clear')
        # Message en Text to ASCII
        f = pyfiglet.figlet_format("G.Cert", font="starwars")
        print(f)

        print('ok')
        from main import main
        main()


if __name__ == "__main__":
    w = Wan()
    w.menu_wan()