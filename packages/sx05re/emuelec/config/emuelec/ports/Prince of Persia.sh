#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

PORT="prince"
# init_port binary audio(alsa. pulseaudio, default)
init_port ${PORT} alsa

[[ ! -f "/storage/.config/emuelec/configs/SDLPoP/SDLPoP.cfg" ]] && touch "/storage/.config/emuelec/configs/SDLPoP/SDLPoP.cfg"

# SDLPop will complain about a missing data and config files by showing a nice blank screen after the intro

cd /storage/.config/emuelec/configs/SDLPoP

${PORT}

ret_error=$?

end_port

exit $ret_error