#!/bin/bash
PIDFILE=/tmp/usb-dmenu.pid
# ....Ante la ausencia de argumento "manual" comprobamos PID del daemon....
if [ "$1" != "manual" ]; then
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") >/dev/null 2>&1; then
        echo "usb-dmenu ya está en ejecución."
        exit 1
    fi
    echo $$ > "$PIDFILE"
    trap "rm -f $PIDFILE" EXIT
fi

export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# ....Aquí puedes cambiar la apariencia de tu usb-dmenu....
dmenu_cmd() {
    dmenu -b -p "󱊞 USB menu" -i -fn "HackNerdFontMono-21" \
    -nb '#240041' -nf '#c79bff' -sf '#00ffb7' -sb '#900048'
}

_notify() {
    notify-send "󱊞 USB dmenu:" "$1"
}

_eject() {
    dev=$1

    # Obtener el dispositivo físico padre si se pasó una partición
    if lsblk -no TYPE "$dev" | grep -q "part"; then
        parent="/dev/$(lsblk -no PKNAME "$dev")"
    else
        parent="$dev"
    fi

    # Nombre legible del dispositivo
    model=$(lsblk -dn -o VENDOR,MODEL "$parent" | tr -s ' ')

    # Intentar expulsar el disco primero
    if !udisksctl unmount -b "$dev" &>/dev/null; then
	udisksctl power-off -b "$parent" &>/dev/null
    else
        udisksctl unmount -b "$dev" &>/dev/null
        udisksctl power-off -b "$parent" &>/dev/null
    fi

    _notify "Dispositivo USB $model expulsado con éxito"
}

_mount() {
    dev=$1
    mountpoint=$(udisksctl mount -b "$dev" | awk '/Mounted/ {print $4}')
    [ -n "$mountpoint" ] && _notify "Dispositivo USB montado en $mountpoint"
}

# ....Función principal del menú....
usb_menu() {

# Buscar discos con transporte USB
    for disk in $(lsblk -pn -o NAME,TYPE,TRAN | awk '$2=="disk" && $3=="usb" {print $1}'); do
        # Particiones de ese disco
        parts=($(lsblk -pn -o NAME,TYPE "$disk" | awk '$2=="part"{print $1}'))
        if [ ${#parts[@]} -gt 0 ]; then
            devices+=("${parts[@]}")
        else
            devices+=("$disk")
        fi
    done

   [ ${#devices[@]} -eq 0 ] && { _notify "No hay USBs conectados"; return; }

    # Quitar duplicados (por si el mismo disco aparece en dos eventos)
    devices=($(printf "%s\n" "${devices[@]}" | sort -u))
    dev=$(printf "%s\n" "${devices[@]}" | dmenu_cmd)
    clean_dev=$(echo "$dev" | sed 's/^[^/]*\//\//')
    [ -n "$dev" ] || return

    action=$(echo -e "Montar\nExpulsar\nCancelar" | dmenu_cmd)
    case "$action" in
        Montar) _mount "$clean_dev" ;;
        Expulsar) _eject "$clean_dev" ;;
        *) return ;;
    esac
}

# ....Lanzar menú manual si se pasa el argumento....
if [ "$1" = "manual" ]; then
    usb_menu
    exit
fi

# ....Monitoreo automático....
seen_devices=()
udisksctl monitor | while read -r line; do
    if echo "$line" | grep -q 'Added /org/freedesktop/UDisks2/block_devices/'; then
	devices=()
	# Buscar discos con transporte USB
	for disk in $(lsblk -pn -o NAME,TYPE,TRAN | awk '$2=="disk" && $3=="usb" {print $1}'); do
	    # Particiones de ese disco
	    parts=($(lsblk -pn -o NAME,TYPE "$disk" | awk '$2=="part"{print $1}'))
	    if [ ${#parts[@]} -gt 0 ]; then
	        devices+=("${parts[@]}")
	    else
	        devices+=("$disk")
	    fi
	done

        # Filtrar solo los nuevos
        new_devices=()
        for d in "${devices[@]}"; do
            if [[ ! " ${seen_devices[*]} " =~ " $d " ]]; then
                new_devices+=("$d")
		seen_devices+=("$d")
            fi
        done
	seen_devices=("${new_devices[@]}")
        if [ ${#new_devices[@]} -gt 0 ]; then
            usb_menu
        fi
    fi
done
