<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## 🚀 Cómo ejecutar este backend (SafeSteps)

### 1. Requisitos previos

- Node.js 18+ y npm
- Docker y Docker Compose (recomendado)
- Firebase Project (para notificaciones push)

### 2. Clonar el repositorio

```bash
# Clona el proyecto
$ git clone <url-del-repo>
$ cd safesteps-backend
```

### 3. Instalar dependencias

```bash
$ npm install
```

### 4. Configurar Firebase (IMPORTANTE)

Para que funcionen las notificaciones push automáticas:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto o crea uno nuevo
3. Ve a **Project Settings** ⚙️ → **Service Accounts**
4. Click en **Generate New Private Key**
5. Guarda el archivo JSON descargado como: `src/config/service-account.json`

⚠️ **IMPORTANTE:** Este archivo contiene credenciales privadas. Ya está en `.gitignore` para protegerlo.

### 5. Ejecutar con Docker Compose (recomendado)

Esto levanta la base de datos PostGIS y el backend conectados correctamente.

```bash
$ docker-compose up --build
```

- El backend estará disponible en: http://localhost:3000
- La base de datos en: localhost:5433 (usuario: postgres, password: 123, db: safesteps)
- Verifica el log: `✅ Firebase Admin SDK initialized successfully`

### 6. Ejecutar solo el backend localmente (sin Docker Compose)

Asegúrate de tener una base de datos PostgreSQL/PostGIS corriendo y configura las variables de entorno en un archivo `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=123
DB_NAME=safesteps
PORT=3000
JWT_SECRET=tu-clave-secreta
```

Luego ejecuta:

```bash
# Modo desarrollo (reinicio automático)
$ npm run start:dev

# Modo normal
$ npm run start

# Producción
$ npm run start:prod
```

### 7. Endpoints principales

#### Autenticación

- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar nuevo usuario
- `PATCH /users/fcm-token` - Actualizar token FCM (requiere JWT)

#### Usuarios

- `GET /tutores` - Listar tutores
- `GET /hijos` - Listar hijos
- `PATCH /hijos/:id/location` - **Actualizar ubicación del hijo** (activa detección automática de zonas)

#### Zonas Seguras (con Polígonos GeoJSON)

- `POST /zonas-seguras` - Crear zona segura con polígono
- `GET /zonas-seguras` - Listar zonas seguras del tutor
- `GET /zonas-seguras/:id` - Ver detalle de zona segura
- `PUT /zonas-seguras/:id` - Actualizar zona segura
- `DELETE /zonas-seguras/:id` - Eliminar zona segura

#### Notificaciones

- `GET /notifications` - Listar notificaciones del usuario
- `GET /notifications/unread/count` - Contar notificaciones sin leer
- `POST /notifications/mark-read` - Marcar como leída
- `POST /notifications/mark-all-read` - Marcar todas como leídas
- `DELETE /notifications/:id` - Eliminar notificación

#### Registros

- `POST /hijos/:hijoId/registros` - Crear registro de actividad
- `GET /hijos/:hijoId/registros` - Listar registros del hijo
- `POST /hijos/:hijoId/registros/sync` - Sincronizar registros offline

### 8. 🎯 Sistema de Notificaciones Automáticas con Geofencing

#### ¿Cómo funciona?

Cuando un hijo actualiza su ubicación mediante WebSocket o HTTP, el backend **automáticamente**:

1. **Detecta** si está dentro de alguna zona segura usando PostGIS (ST_Contains)
2. **Crea** una notificación en la base de datos
3. **Envía** una notificación push al tutor vía Firebase Cloud Messaging

#### Flujo completo:

```
Hijo actualiza ubicación (WebSocket/HTTP)
    ↓
Backend: PATCH /hijos/:id/location
    ↓
HijoService.updateLocation()
    ↓
ZonasSegurasService.checkGeofenceStatus() [PostGIS ST_Contains]
    ↓
Si está dentro de zona segura:
    ↓
NotificationsService.create() → Guarda en BD
    ↓
NotificationsService.sendPushNotification() → Firebase FCM
    ↓
Tutor recibe push notification en su dispositivo (incluso si la app está cerrada)
```

#### Ejemplo de notificación enviada:

```json
{
  "title": "Zona Segura - SafeSteps",
  "body": "✅ Juan Pérez está dentro de la zona segura 'Escuela Primaria'",
  "data": {
    "type": "zona_segura",
    "hijoId": "123",
    "hijoNombre": "Juan Pérez",
    "zonaId": "456",
    "zonaNombre": "Escuela Primaria"
  }
}
```

### 9. 📱 Integración con Flutter

#### Requisitos en la app de Flutter:

1. **Configurar Firebase Cloud Messaging:**

```dart
// Inicializar Firebase en main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Solicitar permisos
FirebaseMessaging messaging = FirebaseMessaging.instance;
await messaging.requestPermission();

// Obtener token FCM
String? token = await messaging.getToken();
```

2. **Enviar FCM Token al backend:**

```dart
// Después del login, actualizar el token
await http.patch(
  Uri.parse('http://localhost:3000/users/fcm-token'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'fcmToken': token}),
);
```

3. **Actualizar ubicación del hijo (WebSocket o HTTP):**

```dart
// Opción 1: WebSocket (recomendado para tiempo real)
socket.emit('update-location', {
  'hijoId': hijoId,
  'latitud': position.latitude,
  'longitud': position.longitude,
});

// Opción 2: HTTP PATCH
await http.patch(
  Uri.parse('http://localhost:3000/hijos/$hijoId/location'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'latitud': position.latitude,
    'longitud': position.longitude,
  }),
);
```

4. **Escuchar notificaciones push:**

```dart
// Cuando la app está en primer plano
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Notificación recibida: ${message.notification?.title}');
  // Mostrar dialog o snackbar
});

// Cuando la app está en segundo plano/cerrada
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  print('App abierta desde notificación');
  // Navegar a pantalla de notificaciones
});
```

5. **Crear zonas seguras con polígonos:**

```dart
// Usar google_maps_flutter para dibujar polígonos
List<LatLng> polygonPoints = [
  LatLng(-17.7833, -63.1821),
  LatLng(-17.7835, -63.1819),
  LatLng(-17.7837, -63.1823),
  LatLng(-17.7835, -63.1825),
];

await http.post(
  Uri.parse('http://localhost:3000/zonas-seguras'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'nombre': 'Escuela Primaria',
    'descripcion': 'Zona escolar segura',
    'poligono': {
      'type': 'Polygon',
      'coordinates': [
        polygonPoints.map((p) => [p.longitude, p.latitude]).toList()
      ]
    },
    'hijoIds': [123, 456], // IDs de los hijos asociados
  }),
);
```

### 10. 🔧 Tecnologías utilizadas

- **Framework:** NestJS 11.0.1
- **Base de datos:** PostgreSQL 15 + PostGIS 3.3
- **ORM:** TypeORM 0.3.27
- **Autenticación:** JWT + Passport
- **Notificaciones:** Firebase Admin SDK 13.6.0
- **Geoespacial:** PostGIS (ST_Contains, ST_MakePoint, ST_SetSRID)
- **Containerización:** Docker + Docker Compose

### 11. 📚 Documentación adicional

#### Documentación del Backend:

- **NOTIFICACIONES_EXPLICACION.md** - Arquitectura detallada del sistema de notificaciones
- **CODIGO_IMPLEMENTACION_ZONAS.md** - Código de implementación del geofencing
- **RESUMEN_NOTIFICACIONES.md** - Resumen ejecutivo con diagramas
- **IMPLEMENTACION_COMPLETA.md** - Estado de implementación del sistema
- **CHECKLIST_FINAL.md** - Checklist de verificación
- **src/config/README.md** - Instrucciones para configurar Firebase

#### Guías de Integración Flutter (guides/flutter/):

**🚨 ACTUALIZACIÓN CRÍTICA (6 Dic 2025 - 8:45 AM):**

- ✅ **3 BUGFIXES CRÍTICOS APLICADOS** - Sistema de notificaciones funcionando al 100%
- ✅ BUGFIX #3: tutorId ya NO es null en SQL (user.sub → user.id)
- ✅ GET /notifications ya NO devuelve array vacío
- ✅ POST /mark-all-read ya NO crashea con 500
- ✅ POST /mark-read ahora marca correctamente como leída
- 📖 **LEE PRIMERO:** `guides/flutter/notifications/ACCION_REQUERIDA.txt`

**Guías Principales:**

- **README.txt** - 📘 Guía completa de integración Flutter (EMPIEZA AQUÍ)
- **notifications/ACCION_REQUERIDA.txt** - 🚨 Bugfixes críticos y checklist rápido
- **notifications/CHANGELOG_DICIEMBRE_2025.txt** - 📋 Detalles técnicos de los 3 bugfixes
- **notifications/SISTEMA_AUTOMATICO.txt** - ⭐ Sistema automático de notificaciones
- **notifications/servicio_completo.txt** - ⭐ Código production-ready del servicio
- **notifications/FLUJO_CORRECTO_LECTURA.txt** - 💡 Cómo marcar como leída correctamente
- **hijos/update_location_automatico.txt** - ⭐ Tracking automático de ubicación
- **auth/** - Autenticación y FCM tokens
- **tutores/** - Gestión de tutores
- **zonas-seguras/** - Creación de zonas con polígonos
- **registros/** - Historial de actividades

**🎯 Para desarrolladores Flutter:** Lee primero `guides/flutter/notifications/ACCION_REQUERIDA.txt` si tienes problemas con notificaciones, o `guides/flutter/README.txt` para visión general del sistema.

### 12. Notas importantes

- ✅ El backend detecta automáticamente cuando un hijo entra a una zona segura
- ✅ No necesitas implementar la detección en Flutter, el backend lo hace
- ✅ Las notificaciones llegan incluso si la app del tutor está cerrada
- ✅ Usa polígonos GeoJSON para zonas con formas complejas
- ✅ PostGIS maneja cálculos geoespaciales con alta precisión
- ✅ Guías completas de integración disponibles en `guides/flutter/`

---

## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

### Deployment en Render

Para desplegar este backend en Render.com, debes configurar las siguientes variables de entorno (Environment Variables):

- `DATABASE_URL` = Internal Database URL (provisto por Render PostgreSQL)
- `NODE_ENV` = `production`
- `JWT_SECRET` = tu-clave-secreta
- `JWT_EXPIRES_IN` = 7d (o el tiempo que prefieras)
- `NPM_CONFIG_PRODUCTION` = `false` (para que Render instale devDependencies necesarias para el build)

TypeORM utilizará automáticamente `DATABASE_URL` si está definida, configurando SSL para producción. Si no está definida, seguirá usando las variables locales `DB_*`.

---

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
