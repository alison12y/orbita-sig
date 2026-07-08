# SafeSteps Mobile 📱

Aplicación móvil Flutter para el seguimiento y seguridad de niños mediante geolocalización en tiempo real y zonas seguras con polígonos.

## 🌟 Características

### ✅ Autenticación y Roles
- **Login de Tutores**: Acceso completo para gestionar hijos y zonas.
- **Login de Hijos**: Acceso simplificado mediante código de vinculación.
- **Roles Diferenciados**: Interfaces adaptadas para Tutor (Mapa, Gestión) e Hijo (Botón de Pánico, Estado).
- **Gestión de Sesiones**: Persistencia segura de tokens JWT.

### 📍 Seguimiento en Tiempo Real
- **Rastreo GPS**: Envío constante de la ubicación del niño al backend.
- **WebSockets**: Actualización en tiempo real en el mapa del tutor.
- **Estado del Dispositivo**: Monitoreo de nivel de batería y estado (En movimiento, Quieto).
- **Mapa Interactivo**: Visualización precisa con `flutter_map` y OpenStreetMap.

### 🛡️ Zonas Seguras Avanzadas
- **Geofencing Poligonal**: Creación de zonas seguras con formas personalizadas (no solo círculos).
- **Detección Automática**: El backend (PostGIS) detecta automáticamente entradas y salidas.
- **Gestión Visual**: Dibujado de zonas directamente sobre el mapa.

### 🔔 Notificaciones Inteligentes
- **Alertas Push**: Notificaciones inmediatas vía Firebase Cloud Messaging (FCM).
- **Eventos Críticos**: Entrada/Salida de zonas seguras, batería baja, botón de pánico.
- **Feedback Visual**: SnackBars en primer plano y notificaciones en segundo plano.

## 🛠️ Tecnologías

- **Frontend**: Flutter 3.9+ (Dart)
- **Gestión de Estado**: Riverpod 3.0 (AsyncNotifier)
- **Mapas**: flutter_map, latlong2, OpenStreetMap
- **Backend Communication**: 
  - **HTTP**: Dio / http
  - **Real-time**: Socket.IO Client
- **Servicios**:
  - **Firebase**: Cloud Messaging (FCM), Core
  - **Geolocalización**: Geolocator
  - **Almacenamiento**: Flutter Secure Storage

## 📋 Requisitos Previos

- Flutter SDK 3.9.2 o superior
- Dart SDK 3.9.2 o superior
- Cuenta de Firebase configurada
- Backend de SafeSteps (NestJS + PostGIS) en ejecución

## 🚀 Instalación

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd safe_steps_mobile
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto:
```env
API_URL=http://<TU_IP_LOCAL>:3000
```
*Nota: Para emulador Android usa `10.0.2.2`, para dispositivo físico usa la IP de tu PC.*

### 4. Configurar Firebase
1. Coloca el archivo `google-services.json` en `android/app/`.
2. Asegúrate de que el package name coincida: `com.safesteps.safe_steps_mobile`.

### 5. Ejecutar la aplicación
```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada y configuración global
├── src/
│   ├── app_router.dart               # Rutas (GoRouter)
│   ├── core/
│   │   ├── providers/                # Providers globales (Location, Socket)
│   │   ├── services/                 # Servicios base (Storage, API)
│   │   └── theme/                    # Estilos y temas
│   └── features/
│       ├── auth/                     # Login, Registro, Roles
│       ├── child/                    # Pantalla y lógica modo Hijo
│       ├── map/                      # Mapa principal, marcadores
│       ├── zones/                    # Gestión de zonas seguras
│       ├── notifications/            # Servicio FCM y lista de alertas
│       └── profile/                  # Perfil de usuario y gestión de hijos
```

## 🧪 Testing

### Probar Rastreo en Tiempo Real
1. Inicia sesión como **Hijo** en un dispositivo (o emulador A).
2. Inicia sesión como **Tutor** en otro dispositivo (o emulador B).
3. En el dispositivo Hijo, asegúrate de que el GPS esté activo.
4. En el dispositivo Tutor, verás el marcador del hijo moverse en tiempo real.

### Probar Zonas Seguras
1. Como Tutor, ve a "Crear Zona" y dibuja un polígono en el mapa.
2. Mueve al Hijo (físicamente o simulando GPS) dentro del polígono.
3. El Tutor recibirá una notificación push: "El hijo ha entrado a la zona segura".

## 📄 Licencia

Este proyecto es parte de un trabajo universitario de la Universidad Autónoma Gabriel René Moreno.

## 👥 Autores

- Sistema de Información Geográfica
