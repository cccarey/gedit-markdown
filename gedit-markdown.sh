#!/bin/bash

# The gedit-markdown.sh file is part of gedit-markdown.
# Auteur: Jean-Philippe Fleury <contact@jpfleury.net>
# Copyright © Jean-Philippe Fleury, 2009.
# Copyright © Frédéric Bertolus, 2010.

# This program is free software: you can redistribute it or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See Public License
# GNU General for more details.

# You should have received a copy of the GNU General Public License along with
# this program if it is not the case, see
# <http://www.gnu.org/licenses/>.

# Localization
export TEXTDOMAINDIR=`dirname "$0"`/locale
export TEXTDOMAIN=gedit-markdown
. gettext.sh

# Variables
rep_language_specs=~/.local/share/gtksourceview-2.0/language-specs
rep_mime=~/.local/share/mime
rep_mime_packages=~/.local/share/mime/packages
rep_plugins=~/.gnome2/gedit/plugins
rep_snippets=~/.gnome2/gedit/snippets
ficPrecompil=( "$rep_plugins/markdown.pyc" "$rep_plugins/markdownpreview.pyc" )
ficSupp=( "${ficPrecompil[@]}" "$rep_language_specs/markdown.lang" "$rep_mime_packages/x-markdown.xml" "$rep_plugins/markdown.py" "$rep_plugins/markdownpreview.gedit-plugin" "$rep_plugins/markdownpreview.py" "$rep_snippets/markdown.xml" )
# Fin des variables

redemarrer_nautilus ()
{
	echo -en $(gettext ""\
"Nautilus must be restarted for the changes to the base\n"\
"data MIME types are taken into account. NOTE: windows\n"\
"Nautilus already open tabs will be lost.\n"\
"\n"\
"\t1 Restart Nautilus now.\n"\
"\t2 Do not restart Nautilus now. Wait for next session or computer restart\n"\
"\n"\
"Enter your choice [1/2] (2 default):")
	echo -n " "
	read choix
	
	echo ""
	if [[ $choix == 1 ]]; then
		echo $(gettext "Restart Nautilus")
		killall nautilus
		nautilus &> /tmp/gedit-markdown_redemarrer_nautilus.log &
		sleep 4
	
	else
		echo -e $(gettext "Nautilus will not be restarted now ")
	fi
}

cd `dirname "$0"`

if [[ $1 == "install" ]]; then
	echo -en "\033[1m"
	echo -en "#########################\n##\n## "
	echo $(gettext "Installation of gedit-markdown")
	echo -e "##\n#########################\n"
	echo -n $(gettext "Step 1")
	echo -n ": "
	echo $(gettext "Copy files")
	echo -en "\033[22m"
	
	# Create directories if they do not already exist
	mkdir -p $rep_language_specs
	mkdir -p $rep_mime_packages
	mkdir -p $rep_plugins
	mkdir -p $rep_snippets
	
	# Removing precompiled python files
	for i in "${ficPrecompil[@]}"; do
		if [ -f $i ]; then
			rm $i
		fi
	done
	
	link=""
	if [[ $2 == "dev" ]]; then
		link="-s"
	fi
	# Copie des fichiers
	current_path=$(pwd)
	cd $rep_plugins
	
	cp -a $link $current_path/language-specs/* $rep_language_specs
	cp -a $link $current_path/mime-packages/* $rep_mime_packages
	cp -a $link $current_path/plugins/* $rep_plugins
	cp -a $link $current_path/snippets/* $rep_snippets
	
	echo -en "\033[1m"
	echo ""
	echo -n $(gettext "Step 2")
	echo -n ": "
	echo $(gettext "Update the MIME database")
	echo -en "\033[22m"
	# Update the MIME database
	update-mime-database $rep_mime
	redemarrer_nautilus
	
	echo -en "\033[1m"
	echo ""
	echo $(gettext "Installation is complete. Please restart gedit if it is open.")
	echo -en "\033[22m"
	exit 0

elif [[ $1 == "uninstall" ]]; then
	echo -en "\033[1m"
	echo -en "#########################\n##\n## "
	echo $(gettext "Uninstall of gedit-markdown")
	echo -e "##\n#########################\n"
	echo -n $(gettext "Step 1")
	echo -n ": "
	echo $(gettext "Deleting files")
	echo -en "\033[22m"
	# Deleting files
	for i in "${ficSupp[@]}"; do
		if [ -f $i ]; then
			rm $i
		fi
	done
	
	echo -en "\033[1m"
	echo ""
	echo -n $(gettext "Step 2")
	echo -n ": "
	echo $(gettext "Update the MIME database")
	echo -en "\033[22m"
	# Update the MIME database
	update-mime-database $rep_mime
	redemarrer_nautilus
	
	echo -en "\033[1m"
	echo ""
	echo $(gettext "Uninstall complete. Please restart gedit if it is open.")
	echo -en "\033[22m"
	exit 0

else
	echo -en "\033[1m"
	echo -n $(gettext "Usage")
	echo ": $0 [install | uninstall]"
	echo -en "\033[22m"
	exit 1
fi

