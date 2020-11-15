#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# This whole file has become very hacky, I am sure there is a better way to do all of this, but for now, this works.


BTENABLED=$(get_ee_setting ee_bluetooth.enabled)

if [[ "$BTENABLED" == "1" ]]; then
	# We don't need the BT agent while running games
	NPID=$(pgrep -f batocera-bluetooth-agent)

	if [[ ! -z "$NPID" ]]; then
		kill "$NPID"
	fi
fi 

# clear terminal window
	clear > /dev/tty
	clear > /dev/tty0
	clear > /dev/tty1

arguments="$@"

# Is userland 32bit or 64bit?
TEST=$(ldd /usr/bin/emulationstation | grep 64)
if [ $? == 0 ]
then
  MYARCH="aarch64"
else
  MYARCH="arm"
fi

#set audio device out according to emuelec.conf
AUDIO_DEVICE="hw:$(get_ee_setting ee_audio_device)"
[ $AUDIO_DEVICE = "hw:" ] &&  AUDIO_DEVICE="hw:0,0"
sed -i "s|pcm \"hw:.*|pcm \"${AUDIO_DEVICE}\"|" /storage/.config/asound.conf

# set audio to alsa
set_audio alsa

# Set the variables
CFG="/storage/.emulationstation/es_settings.cfg"
LOGEMU="No"
VERBOSE=""
LOGSDIR="/emuelec/logs"
TBASH="/usr/bin/bash"
JSLISTENCONF="/emuelec/configs/jslisten.cfg"
RATMPCONF="/tmp/retroarch/ee_retroarch.cfg"
RATMPCONF="/storage/.config/retroarch/retroarch.cfg"
NETPLAY="No"


if [ $(get_es_setting string LogLevel) == "minimal" ]; then 
    EMUELECLOG="/dev/null"
    echo "Logging has been dissabled, enable it in Main Menu > System Settings > Developer > Log Level"
else
    EMUELECLOG="$LOGSDIR/emuelec.log"
fi

set_kill_keys() {
	
# If jslisten is running we kill it first so that it can reload the config file. 
killall jslisten

	KILLTHIS=${1}
	sed -i "2s|program=.*|program=\"/usr/bin/killall ${1}\"|" ${JSLISTENCONF}
	
	}

# Make sure the /emuelec/logs directory exists
if [[ ! -d "$LOGSDIR" ]]; then
mkdir -p "$LOGSDIR"
fi

# Extract the platform name from the arguments
PLATFORM="${arguments##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found

CORE="${arguments##*--core=}"  # read from --core= onwards
CORE="${CORE%% *}"  # until a space is found
EMULATOR="${arguments##*--emulator=}"  # read from --emulator= onwards
EMULATOR="${EMULATOR%% *}"  # until a space is found

ROMNAME="$1"
BASEROMNAME=${ROMNAME##*/}
GAMEFOLDER="${ROMNAME//${BASEROMNAME}}"

if [[ $EMULATOR = "libretro" ]]; then
	EMU="${CORE}_libretro"
	LIBRETRO="yes"
else
	EMU="${CORE}"
fi

# check if we started as host for a game
if [[ "$arguments" == *"--host"* ]]; then
NETPLAY="${arguments##*--host}"  # read from --host onwards
NETPLAY="${NETPLAY%%--nick*}"  # until --nick is found
NETPLAY="--host $NETPLAY --nick"
fi

# check if we are trying to connect to a client on netplay
if [[ "$arguments" == *"--connect"* ]]; then
NETPLAY="${arguments##*--connect}"  # read from --connect onwards
NETPLAY="${NETPLAY%%--nick*}"  # until --nick is found
NETPLAY="--connect $NETPLAY --nick"
fi


[[ ${PLATFORM} = "ports" ]] && LIBRETRO="yes"

# JSLISTEN setup so that we can kill running ALL emulators using hotkey+start
/storage/.emulationstation/scripts/configscripts/z_getkillkeys.sh
. ${JSLISTENCONF}

KILLDEV=${ee_evdev}
KILLTHIS="none"

# if there wasn't a --NOLOG included in the arguments, enable the emulator log output. TODO: this should be handled in ES menu
if [[ $arguments != *"--NOLOG"* ]]; then
LOGEMU="Yes"
VERBOSE="-v"
fi

# Show splash screen if enabled
SPL=$(get_ee_setting ee_splash.enabled)
[ "$SPL" -eq "1" ] && ${TBASH} /emuelec/scripts/show_splash.sh "$PLATFORM" "${ROMNAME}"


if [ -z ${LIBRETRO} ]; then

# Read the first argument in order to set the right emulator
case ${PLATFORM} in
	"atari2600")
		if [ "$EMU" = "STELLASA" ]; then
		set_kill_keys "stella"
		RUNTHIS='${TBASH} /usr/bin/stella.sh "${ROMNAME}"'
		fi
		;;
	"atarist")
		if [ "$EMU" = "HATARISA" ]; then
		set_kill_keys "hatari"
		RUNTHIS='${TBASH} /usr/bin/hatari.start "${ROMNAME}"'
		fi
		;;
	"openbor")
		set_kill_keys "OpenBOR"
		RUNTHIS='${TBASH} /usr/bin/openbor.sh "${ROMNAME}"'
		;;
	"setup")
	[[ "$EE_DEVICE" == "RG351P" ]] && set_kill_keys "kmscon" || set_kill_keys "fbterm"
		RUNTHIS='${TBASH} /emuelec/scripts/fbterm.sh "${ROMNAME}"'
		EMUELECLOG="$LOGSDIR/ee_script.log"
		;;
	"ereamcast")
		if [ "$EMU" = "REICASTSA" ]; then
		set_kill_keys "reicast"
		sed -i "s|REICASTBIN=.*|REICASTBIN=\"/usr/bin/reicast\"|" /emuelec/bin/reicast.sh
		RUNTHIS='${TBASH} /emuelec/bin/reicast.sh "${ROMNAME}"'
		LOGEMU="No" # ReicastSA outputs a LOT of text, only enable for debugging.
		cp -rf /storage/.config/reicast/emu_new.cfg /storage/.config/reicast/emu.cfg
		fi
		if [ "$EMU" = "REICASTSA_OLD" ]; then
		set_kill_keys "reicast_old"
		sed -i "s|REICASTBIN=.*|REICASTBIN=\"/usr/bin/reicast_old\"|" /emuelec/bin/reicast.sh
		RUNTHIS='${TBASH} /emuelec/bin/reicast.sh "${ROMNAME}"'
		LOGEMU="No" # ReicastSA outputs a LOT of text, only enable for debugging.
		cp -rf /storage/.config/reicast/emu_old.cfg /storage/.config/reicast/emu.cfg
		fi
		;;
	"mame"|"arcade"|"capcom"|"cps1"|"cps2"|"cps3")
		if [ "$EMU" = "AdvanceMame" ]; then
		set_kill_keys "advmame"
		RUNTHIS='${TBASH} /usr/bin/advmame.sh "${ROMNAME}"'
		fi
		;;
	"nds")
		set_kill_keys "drastic"
		RUNTHIS='${TBASH} /storage/.emulationstation/scripts/drastic.sh "${ROMNAME}"'
			;;
	"n64")
		if [ "$EMU" = "M64P" ]; then
		set_kill_keys "mupen64plus"
		RUNTHIS='${TBASH} /usr/bin/m64p.sh "${ROMNAME}"'
		fi
		;;
	"amiga"|"amigacd32")
		if [ "$EMU" = "AMIBERRY" ]; then
		RUNTHIS='${TBASH} /usr/bin/amiberry.start "${ROMNAME}"'
		fi
		;;
	"residualvm")
		if [[ "${ROMNAME}" == *".sh" ]]; then
		set_kill_keys "fbterm"
		RUNTHIS='${TBASH} /emuelec/scripts/fbterm.sh "${ROMNAME}"'
		EMUELECLOG="$LOGSDIR/ee_script.log"
		else
		set_kill_keys "residualvm"
		RUNTHIS='${TBASH} /usr/bin/residualvm.sh sa "${ROMNAME}"'
		fi
		;;
	"scummvm")
		if [[ "${ROMNAME}" == *".sh" ]]; then
		set_kill_keys "fbterm"
		RUNTHIS='${TBASH} /emuelec/scripts/fbterm.sh "${ROMNAME}"'
		EMUELECLOG="$LOGSDIR/ee_script.log"
		else
		if [ "$EMU" = "SCUMMVMSA" ]; then
		set_kill_keys "scummvm"
		RUNTHIS='${TBASH} /usr/bin/scummvm.start sa "${ROMNAME}"'
		else
		RUNTHIS='${TBASH} /usr/bin/scummvm.start libretro'
		fi
		fi
		;;
	"daphne")
		if [ "$EMU" = "HYPSEUS" ]; then
		set_kill_keys "hypseus"
		RUNTHIS='${TBASH} /storage/.config/emuelec/scripts/hypseus.start.sh "${ROMNAME}"'
		fi
		;;
	"wii"|"gamecube")
		if [ "$EMU" = "dolphin" ]; then
		set_kill_keys "dolphin-emu-nogui"
		RUNTHIS='${TBASH} /storage/.config/emuelec/bin/dolphin.sh "${ROMNAME}"'
		fi
		;;
	"pc")
		if [ "$EMU" = "DOSBOXSDL2" ]; then
		set_kill_keys "dosbox"
		RUNTHIS='${TBASH} /usr/bin/dosbox.start -conf "${GAMEFOLDER}dosbox-SDL2.conf"'
		fi
		if [ "$EMU" = "DOSBOX-X" ]; then
		set_kill_keys "dosbox-x"
		RUNTHIS='${TBASH} /usr/bin/dosbox-x.start -conf "${GAMEFOLDER}dosbox-SDL2.conf"'
		fi
		;;		
	"psp"|"pspminis")
		if [ "$EMU" = "PPSSPPSDL" ]; then
		#PPSSPP can run at 32BPP but only with buffered rendering, some games need non-buffered and the only way they work is if I set it to 16BPP
		# /emuelec/scripts/setres.sh 16 # This was only needed for S912, but PPSSPP does not work on S912 
		set_kill_keys "PPSSPPSDL"
		RUNTHIS='${TBASH} /usr/bin/ppsspp.sh "${ROMNAME}"'
		fi
		;;
	"neocd")
		if [ "$EMU" = "fbneo" ]; then
		RUNTHIS='/usr/bin/retroarch $VERBOSE -L /tmp/cores/fbneo_libretro.so --subsystem neocd --config ${RATMPCONF} "${ROMNAME}"'
		fi
		;;
	"mplayer")
		set_kill_keys "${EMU}"
		RUNTHIS='${TBASH} /emuelec/scripts/fbterm.sh mplayer_video "${ROMNAME}" "${EMU}"'
		;;
	"pico8")
		set_kill_keys "pico8_dyn"
		RUNTHIS='${TBASH} /emuelec/scripts/pico8.sh "${ROMNAME}"'
			;;
	esac
else
# We are running a Libretro emulator set all the settings that we chose on ES

# Workaround for Atomiswave
if [[ ${PLATFORM} == "atomiswave" ]]; then
	rm ${ROMNAME}.nvmem*
fi

if [[ ${PLATFORM} == "ports" ]]; then
	PORTCORE="${arguments##*-C}"  # read from -C onwards
	EMU="${PORTCORE%% *}_libretro"  # until a space is found
	PORTSCRIPT="${arguments##*-SC}"  # read from -SC onwards
fi

# Check if we need retroarch 32 bits or 64 bits
RABIN="retroarch"
if [[ "${PLATFORM}" == "psx" ]] || [[ "${PLATFORM}" == "n64" ]]; then
    if [[ "$CORE" == "pcsx_rearmed" ]] || [[ "$CORE" == "parallel_n64" ]]; then
	if [ "${MYARCH}" == "arm" ]
	then
          RABIN="retroarch"
	else
	  RABIN="retroarch32"
	fi
    fi
fi

RUNTHIS='/usr/bin/${RABIN} $VERBOSE -L /tmp/cores/${EMU}.so --config ${RATMPCONF} "${ROMNAME}"'
CONTROLLERCONFIG="${arguments#*--controllers=*}"
CONTROLLERCONFIG="${CONTROLLERCONFIG%% --*}"  # until a -- is found
CORE=${EMU%%_*}


# Netplay

# make sure the ip and port are blank
set_ee_setting "netplay.client.ip" "disable"
set_ee_setting "netplay.client.port" "disable"

if [[ ${NETPLAY} != "No" ]]; then
  NETPLAY_NICK=$(get_ee_setting netplay.nickname)
  [[ -z "$NETPLAY_NICK" ]] && NETPLAY_NICK="Anonymous"
  NETPLAY="$(echo ${NETPLAY} | sed "s|--nick|--nick \"${NETPLAY_NICK}\"|")"

  RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${NETPLAY} --config|")

    if [[ "${NETPLAY}" == *"connect"* ]]; then
	NETPLAY_PORT="${arguments##*--port }"  # read from -netplayport  onwards
	NETPLAY_PORT="${NETPLAY_PORT%% *}"  # until a space is found
	NETPLAY_IP="${arguments##*--connect }"  # read from -netplayip  onwards
	NETPLAY_IP="${NETPLAY_IP%% *}"  # until a space is found
	set_ee_setting "netplay.client.ip" "${NETPLAY_IP}"
	set_ee_setting "netplay.client.port" "${NETPLAY_PORT}"
    fi

  fi
# End netplay
fi

if [[ ${PLATFORM} == "ports" ]]; then
  SHADERSET=$(/storage/.config/emuelec/scripts/setsettings.sh "${PLATFORM}" "${PORTSCRIPT}" "${CORE}" --controllers="${CONTROLLERCONFIG}")
else
  SHADERSET=$(/storage/.config/emuelec/scripts/setsettings.sh "${PLATFORM}" "${ROMNAME}" "${CORE}" --controllers="${CONTROLLERCONFIG}")
fi

echo $SHADERSET

if [[ ${SHADERSET} != 0 ]]; then
  RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${SHADERSET} --config|")
fi

# we check is maxperf is set 
if [ $(get_ee_setting "maxperf" "${PLATFORM}" "${ROMNAME##*/}") == "0" ]; then
  normperf
else
  maxperf
fi


# Clear the log file
echo "EmuELEC Run Log" > $EMUELECLOG
cat /etc/motd >> $EMUELECLOG

[[ "${NETPLAY}" == *"connect"* ]] && echo "Netplay client!" >> $EMUELECLOG

# Write the command to the log file.
echo "PLATFORM: $PLATFORM" >> $EMUELECLOG
echo "ROM NAME: ${ROMNAME}" >> $EMUELECLOG
echo "BASE ROM NAME: ${ROMNAME##*/}" >> $EMUELECLOG
echo "USING CONFIG: ${RATMPCONF}" >> $EMUELECLOG
echo "1st Argument: $1" >> $EMUELECLOG 
echo "2nd Argument: $2" >> $EMUELECLOG
echo "3rd Argument: $3" >> $EMUELECLOG 
echo "4th Argument: $4" >> $EMUELECLOG 
echo "Full Arguments: $arguments" >> $EMUELECLOG 
echo "Run Command is:" >> $EMUELECLOG 
echo "My Architecture: $MYARCH" >> $EMUELECLOG
echo "My Retroarch: $RABIN" >> $EMUELECLOG
eval echo ${RUNTHIS} >> $EMUELECLOG 

if [[ "$KILLTHIS" != "none" ]]; then

# We need to make sure there are at least 2 buttons setup (hotkey plus another) if not then do not load jslisten
	KKBUTTON1=$(sed -n "3s|^button1=\(.*\)|\1|p" "${JSLISTENCONF}")
	KKBUTTON2=$(sed -n "4s|^button2=\(.*\)|\1|p" "${JSLISTENCONF}")
	if [ ! -z $KKBUTTON1 ] && [ ! -z $KKBUTTON2 ]; then
		if [ ${KILLDEV} == "auto" ]; then
			/emuelec/bin/jslisten --mode hold &>> ${EMUELECLOG} &
		else
			/emuelec/bin/jslisten --mode hold --device /dev/input/${KILLDEV} &>> ${EMUELECLOG} &
		fi
	fi
fi

# Only run fbfix on N2
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && /storage/.config/emuelec/bin/fbfix

# Execute the command and try to output the results to the log file if it was not disabled.
if [[ $LOGEMU == "Yes" ]]; then
   echo "Emulator Output is:" >> $EMUELECLOG
   eval ${RUNTHIS} >> $EMUELECLOG 2>&1
   ret_error=$?
else
   echo "Emulator log was dissabled" >> $EMUELECLOG
   eval ${RUNTHIS}
   ret_error=$?
fi 

# Only run fbfix on N2
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && /storage/.config/emuelec/bin/fbfix

# Show exit splash
${TBASH} /emuelec/scripts/show_splash.sh exit

# Kill jslisten, we don't need to but just to make sure, dot not kill if using OdroidGoAdvance
[[ "$EE_DEVICE" != "RG351P" ]] && killall jslisten

# Just for good measure lets make a symlink to Retroarch logs if it exists
if [[ -f "/storage/.config/retroarch/retroarch.log" ]] && [[ ! -e "${LOGSDIR}/retroarch.log" ]]; then
	ln -sf /storage/.config/retroarch/retroarch.log ${LOGSDIR}/retroarch.log
fi

#{log_addon}#

# Return to default mode
${TBASH} /emuelec/scripts/setres.sh

# Return to the default performance scaling
normperf

# reset audio to default
set_audio default

# remove emu.cfg if platform was reicast
[ -f /storage/.config/reicast/emu.cfg ] && rm /storage/.config/reicast/emu.cfg

if [[ "$BTENABLED" == "1" ]]; then
	# Restart the bluetooth agent
	NPID=$(pgrep -f batocera-bluetooth-agent)
	if [[ -z "$NPID" ]]; then
	(systemd-run batocera-bluetooth-agent) || :
	fi
fi

if [[ "$ret_error" != "0" ]]; then
echo "exit $ret_error" >> $EMUELECLOG

# Check for missing bios if needed
REQUIRESBIOS=(atari5200 atari800 atari7800 atarilynx colecovision amiga amigacd32 o2em intellivision pcengine pcenginecd pcfx fds segacd saturn dreamcast naomi atomiswave x68000 neogeo neogeocd msx msx2 sc-3000)

(for e in "${REQUIRESBIOS[@]}"; do [[ "${e}" == "${PLATFORM}" ]] && exit 0; done) && RB=0 || RB=1	
if [ $RB == 0 ]; then

CBPLATFORM="${PLATFORM}"
[[ "${CBPLATFORM}" == "msx2" ]] && CBPLATFORM="msx"
[[ "${CBPLATFORM}" == "pcenginecd" ]] && CBPLATFORM="pcengine"
[[ "${CBPLATFORM}" == "amigacd32" ]] && CBPLATFORM="amiga"

ee_check_bios "${CBPLATFORM}" "${CORE}" "${EMULATOR}" "${ROMNAME}" "${EMUELECLOG}"

fi #require bios ends

	exit 1
else
echo "exit 0" >> $EMUELECLOG
	exit 0
fi
