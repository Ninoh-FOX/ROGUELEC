#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

source /emuelec/scripts/env.sh
source "$scriptdir/scriptmodules/supplementary/esthemes.sh"
rp_registerAllModules

#joy2keyStart

function drastic_confirm() {
ES_FOLDER="/storage/.emulationstation"
JUDGMENT="$ES_FOLDER/scripts/drastic/drastic"
[[ -f $JUDGMENT ]] && systemctl reboot
[[ -f $JUDGMENT ]] && dialog --ascii-lines --msgbox "Drastic installation already done! will automatically reboot" 22 76 >/dev/tty
[[ ! -f $JUDGMENT ]] && drastic_install 
 }

function drastic_install() {
ES_FOLDER="/storage/.emulationstation"
LINKDEST="/usr/bin/drastic.tar.gz"
JUDGMENT="$ES_FOLDER/scripts/drastic/drastic"
CFG="$ES_FOLDER/es_systems.cfg"
EXE="/usr/bin/emuelecRunEmu.sh"

mkdir -p "$ES_FOLDER/scripts/"
tar xvf $LINKDEST -C "$ES_FOLDER/scripts"
#rm $LINKDEST

if grep -q '<name>nds</name>' "$CFG"
then
	echo 'Drastic is already setup in your es_systems.cfg file'
	echo 'deleting...nd from es_system.cfg'
	xmlstarlet ed -L -P -d "/systemList/system[name='nds']" $CFG
fi

	echo 'Adding Drastic to systems list'
	xmlstarlet ed --omit-decl --inplace \
		-s '//systemList' -t elem -n 'system' \
		-s '//systemList/system[last()]' -t elem -n 'name' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'fullname' -v 'Nintendo DS'\
		-s '//systemList/system[last()]' -t elem -n 'path' -v '/storage/roms/nds'\
		-s '//systemList/system[last()]' -t elem -n 'extension' -v '.nds .zip .NDS .ZIP'\
		-s '//systemList/system[last()]' -t elem -n 'command' -v "$EXE %ROM% -P%SYSTEM% --controllers=\"%CONTROLLERSCONFIG%\""\
		-s '//systemList/system[last()]' -t elem -n 'platform' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'theme' -v 'nds'\
		$CFG

read -d '' content <<EOF
#!/bin/sh

# Only run pixel if it exists, mainly for N2
if [ -f "/storage/.emulationstation/scripts/pixel.sh" ]; then
/storage/.emulationstation/scripts/pixel.sh
fi

cd /storage/.emulationstation/scripts/drastic/
./drastic "\$1"

EOF
echo "$content" > $ES_FOLDER/scripts/drastic.sh
chmod +x $ES_FOLDER/scripts/drastic.sh

echo "Done, restart ES"
[[ -f $JUDGMENT ]] && systemctl reboot
[[ -f $JUDGMENT ]] && dialog --ascii-lines --msgbox "Drastic installation is done! will automatically reboot" 22 76 >/dev/tty
return 0
}

drastic_confirm

