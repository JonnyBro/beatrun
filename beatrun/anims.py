import os
import sys
import shutil

files_new = [ file for file in os.listdir("_new") ]
files_old = [ file for file in os.listdir("_old") ]
i = input("Type \"y\" for new animations or \"n\" for old animations to be installed: ")

if i == "y":
	for file in files_new:
		shutil.copy2("_new/" + file, "gamemodes/beatrun/content/models")
	print("New animations installed successfully")
else:
	for file in files_old:
		shutil.copy2("_old/" + file, "gamemodes/beatrun/content/models")
	print("Old animations installed successfully")

print("i hate python")

os.system("pause")