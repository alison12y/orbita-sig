# Guía: Cómo Probar Órbita en Dispositivos Móviles

Para probar la app móvil Órbita (Flutter) junto al Backend (NestJS) conectando celulares reales, no puedes usar `localhost`, ya que para un celular `localhost` es el propio teléfono, no tu computadora.

Debes utilizar la **IP Local (IPv4)** de tu computadora (ej: `192.168.1.X`).

Sigue estos pasos detallados:

## 1. Obtener la IP de tu Computadora

1. Abre la terminal de **PowerShell** o **Símbolo del sistema (cmd)**.
2. Ejecuta el comando:
   ```bash
   ipconfig
   ```
3. Busca la sección que dice **"Adaptador de LAN inalámbrica Wi-Fi"** o **"Adaptador de Ethernet"**.
4. Anota el número que aparece en **"Dirección IPv4"** (por ejemplo: `192.168.1.100`).

## 2. Iniciar el Backend

El backend se conecta a la base de datos y provee la API y WebSockets a través del puerto 3000.

1. Abre una terminal y ve a la carpeta del backend:
   ```bash
   cd safesteps-backend
   ```
2. Levanta los contenedores con Docker Compose:
   ```bash
   docker compose up -d --build
   ```
3. *(Asegúrate de que tu PC y los celulares estén conectados a la misma red Wi-Fi).*

## 3. Configurar la App Flutter con tu IP

1. Ve a la carpeta de Flutter:
   ```bash
   cd flutter_sig
   ```
2. Abre el archivo `.env` (si no existe, cópialo de `.env.example`).
3. Reemplaza las URLs para que apunten a la IP que obtuviste en el Paso 1:
   ```env
   API_URL=http://TUP_IP_AQUI:3000
   SOCKET_URL=http://TUP_IP_AQUI:3000
   ```
   *Ejemplo: `API_URL=http://192.168.1.100:3000`*

## 4. Generar el Archivo Instalable (APK)

Tienes dos opciones rápidas para generar el APK sin tener que escribir todos los comandos:

**En Git Bash / WSL / Linux / Mac:**
Ejecuta el script:
```bash
./build_apk.sh
```

**En Windows PowerShell:**
Ejecuta el script:
```powershell
.\build_apk.ps1
```

*(Si prefieres hacerlo a mano, los comandos son: `flutter clean`, `flutter pub get` y `flutter build apk --debug`).*

## 5. Instalar y Probar en los Celulares

Una vez que termine de compilar, el instalable `.apk` se generará en la siguiente ruta:
`flutter_sig/build/app/outputs/flutter-apk/app-debug.apk`

1. **Pasa ese archivo a tus dos celulares** (puedes usar un cable USB, enviarlo por Telegram, Google Drive, WhatsApp, etc.).
2. En cada celular, **instala la app** abriendo el archivo `app-debug.apk`. 
   *(Si el celular te pide permiso para "Instalar aplicaciones de fuentes desconocidas", acéptalo).*

### Celular 1 (Modo Tutor):
- Abre la app Órbita.
- Inicia sesión con tu correo y contraseña registrados (o regístrate si no tienes cuenta).
- Ve a la sección **Mi Perfil** -> **Hijos Registrados**.
- Dale al botón **"+" (Agregar)** para generar un **Código de Vinculación**. Anota ese código.

### Celular 2 (Modo Hijo):
- Abre la app Órbita.
- En la pantalla principal, presiona el botón turquesa **"Soy un Hijo"**.
- Ingresa el **Código de Vinculación** generado en el celular del tutor.
- Otorga los permisos de ubicación cuando la app lo solicite.
- Verás que el estado cambia a "Compartiendo ubicación".

¡Listo! Ya puedes ir al **Mapa** en el Celular 1 (Tutor) y ver la ubicación en tiempo real del Celular 2 (Hijo).
