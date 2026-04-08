#!/bin/bash

if [ ! -x /opt/Synergy/synergy-core ]; then
    echo "Error: /opt/Synergy/synergy-core does not exist or is not executable."
    exit 1
fi


if ! command -v ffplay &>/dev/null; then
    echo "Error: ffplay is not installed."
    exit 1
fi

/opt/Synergy/synergy-core server --no-daemon -f --no-tray --config ~/.config/Synergy/synergy.conf --name minisforum-66f53bad --enable-crypto --tls-cert ~/.config/Synergy/synergyCert.pem  --debug INFO --address 0.0.0.0:24800 &

SDL_RENDER_VSYNC=0 nice -n -20 ffplay -f v4l2 -input_format yuyv422 -i /dev/video0 -fflags nobuffer -flags low_delay -sync ext -vf "setpts=0" -window_title "Magewell Video4"

pkill -f synergy-core