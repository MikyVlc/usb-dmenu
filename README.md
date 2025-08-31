# usb-dmenu

Script sencillo escrito en el shell para gestionar dispositivos USB desde un gestor de ventanas ligero (como bspwm o i3) utilizando dmenu.  
La idea es poder acceder rápidamente a tus memorias USB sin necesidad de comandos de montaje ni de depender de gestores de archivos.

---

⚠️ Dependencias:

Para que el script funcione correctamente necesitas tener instaladas las siguientes herramientas en tu sistema:

- [dmenu](https://tools.suckless.org/dmenu/) → menú gráfico minimalista  
- `udisks2` → para manejar dispositivos de almacenamiento  
- `udiskctl` → interfaz de línea de comandos para udisks2  
- `bash` → (cualquier shell compatible debería funcionar)  


📥 Instalación

Clona el repositorio y entra en él:

    git clone https://github.com/MikyVlc/usb-dmenu.git
    cd usb-dmenu

Dale permisos de ejecución al script:

    chmod +x usb-dmenu.sh


▶️ Uso

Ejecuta el script desde tu terminal y/o lánzalo con un atajo de teclado añadiendo el argumento "manual":

Para ejecutarlo en el shell (daemon):

    /path/to/usb-dmenu.sh
    
Para ejecutarlo con un atajo manualmente desde sxhkd o similar:

    /path/to/usb-dmenu.sh manual
    
El menú de dmenu mostrará los dispositivos USB disponibles.
Desde allí podrás seleccionar:

    Montar el dispositivo

    Expulsar el dispositivo de forma segura

📸 Captura de pantalla

Así se ve en funcionamiento en EndeavourOS con dmenu:
<img width="1920" height="1080" alt="imagen" src="https://github.com/user-attachments/assets/2e73ad4e-288b-44a8-88d3-5c3728de7b38" />
<img width="1920" height="1080" alt="imagen" src="https://github.com/user-attachments/assets/b65e5a84-2949-44d7-9162-65cb3a54d032" />


📌 Notas

    Necesitas permisos para montar, así que si tu usuario no tiene permisos podrías necesitar udisks2 configurado correctamente o usar sudo.

    El script está pensado para un entorno gráfico con X11 y dmenu instalado.

    Este software viene sin ninguna garantía.


📜 Licencia

Este proyecto se distribuye bajo la licencia MIT.
¡Siéntete libre de modificarlo, mejorarlo o adaptarlo a tus necesidades!
