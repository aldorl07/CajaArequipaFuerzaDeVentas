DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

## Guía didáctica — Despliegue del ecosistema móvil Banco Andino en la nube 

Publicación de un sistema completo de canales móviles desde cero hasta producción, usando servicios gratuitos o de bajo costo. El alumno parte de un proyecto que corre en `localhost` y termina con un sistema accesible desde internet y dos aplicaciones móviles instalables desde la tienda. 

## 1. Panorama del sistema 

El ecosistema tiene cinco repositorios que cumplen roles distintos pero conectados: 

||||**Dónde**|
|---|---|---|---|
|**Repositorio**|**Rol**|**Tecnología**|**se**|
||||**publica**|
|`mobile_bd_core_financiero_andino_postgresql`|Base de datos<br>operacional|PostgreSQL<br>(`bd_core_mobile`)|**Neon**|
||API de|||
|`mobile_backend_core_andino_fastapi`|negocio (auth,<br>cartera,|FastAPI · puerto<br>8003|**Koyeb**|
||solicitudes)|||
||Portal web del|||
|`mobile_front_core_andino_react`|personal /|React + Vite|**Vercel**|
||asesores|||
||App de fuerza|||
|`mobile_app_fventas_andino_flutter`|de ventas<br>(asesor de|Flutter|**Google**<br>**Play**|
||campo)|||
|`mobile_app_clientes_andino_flutter`|App del<br>cliente (banca<br>móvil)|Flutter|**Google**<br>**Play**|



La regla de oro: **cada capa solo conoce a la capa de abajo por una URL** . El front conoce al backend por una URL; las apps conocen al backend por una URL; el backend conoce a la base por una cadena de conexión. Cuando algo deja de funcionar en producción, casi siempre es una de esas URLs apuntando al lugar equivocado. 

## Flujo de dependencias 

```
                 ┌─────────────────────────────┐
                 │   Neon (PostgreSQL)          │
                 │   bd_core_mobile             │
```

1 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

**==> picture [512 x 218] intentionally omitted <==**

**----- Start of picture text -----**<br>
                 └──────────────┬──────────────┘<br>                                │ DATABASE_URL<br>                                ▼<br>                 ┌─────────────────────────────┐<br>                 │   Koyeb (FastAPI)            │<br>                 │   uvicorn main:app           │<br>                 │   https://...koyeb.app       │<br>                 └───┬──────────────────────┬───┘<br>                     │ VITE_BASE_URL         │ baseUrl (api_client.dart)<br>                     ▼                       ▼<br>        ┌────────────────────┐   ┌────────────────────────────┐<br>        │ Vercel (React+Vite)│   │ Flutter (fventas + clientes)│<br>        │ portal del personal│   │ Google Play                 │<br>        └────────────────────┘   └────────────────────────────┘<br>**----- End of picture text -----**<br>


## Orden de despliegue (no se puede alterar) 

1. **Base de datos** (Neon) — sin ella, el backend no arranca. 

2. **Backend** (Koyeb) — necesita la cadena de Neon. 

3. **Frontend web** (Vercel) — necesita la URL del backend. 

4. **Apps móviles** (Play Store) — necesitan la URL del backend y un proceso de firma propio. 

Antes de tocar la nube, el sistema debe funcionar completo en local. La nube no arregla errores; los hace más caros de encontrar. 

## 2. Requisitos previos 

Cuenta de **GitHub** con los cinco repos (ya creados). 

- Cuenta gratuita en **Neon** (neon.tech). 

- Cuenta gratuita en **Koyeb** (koyeb.com). 

- Cuenta gratuita en **Vercel** (vercel.com). 

- Cuenta de **Google Play Console** (pago único de 25 USD, requisito para publicar apps). Herramientas locales: `git` , `psql` (cliente PostgreSQL), Python 3.11+, Node.js 18+, Flutter SDK. 

## 3. Paso 1 — Base de datos en Neon 

Neon es PostgreSQL administrado, con un plan gratuito que incluye una rama principal y conexión por _pooler_ . Reemplaza al PostgreSQL local. 

## 3.1 Crear el proyecto 

1. Ingresar a neon.tech y crear un proyecto nuevo. 

2. Región: elegir la más cercana (us-east). 

3. Nombre de la base: `bd_core_mobile` (puede crearse la base con ese nombre o usar la `neondb` por defecto y crear la nuestra después). 

4. Copiar la **cadena de conexión** (Connection string). Tiene esta forma: 

2 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

```
postgresql://usuario:password@ep-xxxx.us-east-2.aws.neon.tech/bd_core_mobile?
sslmode=require
```

Guardar dos variantes si Neon las ofrece: la **pooled** (con `-pooler` en el host) para la aplicación, y la **directa** 

para correr migraciones. 

## 3.2 Cargar el esquema 

El esquema está en el repo del backend: `sql/01_schema_bd_core_mobile.sql` . 

Opción A — desde la terminal con `psql` : 

```
psql "postgresql://usuario:password@ep-xxxx.../bd_core_mobile?sslmode=require" \
  -f sql/01_schema_bd_core_mobile.sql
```

Opción B — desde el **SQL Editor** de Neon: pegar el contenido del archivo y ejecutar. 

## 3.3 Cargar los datos demo (seed) 

El seed es un script de Python ( `scripts/seed_bd_core_mobile.py` ) que crea el asesor de prueba `0001 /` 

`1234` . Se corre desde la máquina local apuntando a Neon: 

```
# Linux/Mac
```

```
export DATABASE_URL="postgresql://usuario:password@ep-xxxx.../bd_core_mobile?
sslmode=require"
python -m scripts.seed_bd_core_mobile
```

```
# Windows (PowerShell)
$env:DATABASE_URL="postgresql://usuario:password@ep-xxxx.../bd_core_mobile?
sslmode=require"
python -m scripts.seed_bd_core_mobile
```

## 3.4 Verificación 

```
SELECT codigo_empleado FROM asesores LIMIT 1;   -- debe devolver 0001
```

Si responde, la base está lista. **No avanzar al backend hasta confirmar esto.** 

## 4. Paso 2 — Backend FastAPI en Koyeb 

Koyeb despliega directo desde GitHub: detecta que es Python, instala `requirements.txt` y levanta el proceso. Reemplaza al `uvicorn` local. 

3 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

## 4.1 Preparar el repositorio 

El backend ya lee la configuración por variables de entorno. Confirmar que `app/core/cfg_config.py` toma `DATABASE_URL` y el secreto JWT del entorno (revisar `.env.example` para ver los nombres exactos). Si alguna variable está escrita "a mano" en el código, moverla a entorno antes de subir. 

Importante: en local el puerto es `8003` , pero en la nube el puerto lo asigna la plataforma mediante la variable `PORT` . El comando de arranque debe usar `$PORT` , no `8003` fijo. 

## 4.2 Crear el servicio en Koyeb 

1. En Koyeb: **Create Service → GitHub** y autorizar la cuenta. 

2. Elegir el repo `mobile_backend_core_andino_fastapi` , rama `main` . 

3. Builder: **Buildpack** (Koyeb detecta Python por `requirements.txt` ). 

4. **Run command** (sobrescribir): 

```
uvicorn main:app --host 0.0.0.0 --port $PORT
```

5. **Exposed port / health check** : usar `8000` (o el valor de `$PORT` que Koyeb expone, normalmente 8000). El path de health puede ser `/docs` . 

6. Instancia: la más pequeña del plan gratuito (Free / Nano). 

## 4.3 Variables de entorno en Koyeb 

En la sección **Environment variables** del servicio, agregar (los nombres exactos salen de `.env.example` ): 

|**Variable**|**Valor**|
|---|---|
|`DATABASE_URL`|cadena**pooled**de Neon|
|`JWT_SECRET`(o el nombre real)|una clave larga y aleatoria|
|`JWT_ALGORITHM`|`HS256`|
|`ACCESS_TOKEN_EXPIRE_MINUTES`|`60`(o el valor del proyecto)|



Marcar como **Secret** las que sean sensibles (cadena de base y secreto JWT). 

## 4.4 CORS (paso que casi siempre se olvida) 

El backend debe permitir explícitamente el dominio del front (Vercel) y las apps. En el `CORSMiddleware` de FastAPI: 

```
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
"https://tu-portal.vercel.app",   # front en Vercel
"http://localhost:5173",          # desarrollo local
    ],
    allow_credentials=True,
```

4 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

```
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Las apps Flutter no necesitan CORS (no son navegadores), pero sí necesitan que la URL sea **HTTPS** , que Koyeb provee por defecto. 

## 4.5 Verificación 

Koyeb da una URL pública del tipo `https://mobile-core-andino-xxxx.koyeb.app` . Abrir: 

```
https://mobile-core-andino-xxxx.koyeb.app/docs
```

Debe cargar la documentación interactiva de FastAPI. Probar el login desde ahí con `0001 / 1234` . Si devuelve un token, el backend está en producción. 

## 5. Paso 3 — Front React en Vercel 

Vercel publica el portal del personal (React + Vite) como sitio estático global. Reemplaza al `npm run dev` local. 

## 5.1 Punto crítico de Vite 

Las variables `VITE_*` se **incrustan en el momento de compilar** , no en tiempo de ejecución. Si se cambia la URL del backend, hay que **recompilar** (redeploy). Esto confunde a todos la primera vez. 

## 5.2 Importar el proyecto 

1. En Vercel: **Add New → Project** e importar `mobile_front_core_andino_react` . 

2. Framework Preset: **Vite** (lo detecta solo). 

3. Build Command: `npm run build` . 

4. Output Directory: `dist` . 

## 5.3 Variable de entorno 

## En **Settings → Environment Variables** : 

## **Variable Valor** 

```
VITE_BASE_URLhttps://mobile-core-andino-xxxx.koyeb.app
```

(Sin barra final.) Aplicar a _Production_ . Luego **Deploy** . 

## 5.4 Verificación 

Vercel entrega una URL del tipo `https://tu-portal.vercel.app` . Abrirla, iniciar sesión con `0001 / 1234` y confirmar que carga la cartera. Si el login falla con error de red o CORS, revisar: 

5 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

- que `VITE_BASE_URL` apunte a la URL real de Koyeb; 

- que ese dominio de Vercel esté en `allow_origins` del backend; 

- que se haya hecho **redeploy** después de cambiar la variable. 

## 6. Paso 4 — Apps Flutter en Google Play 

Las dos apps ( `fventas` y `clientes` ) se publican como paquetes Android ( `.aab` ) en Google Play Console. Es el paso más largo porque incluye firma, fichas de tienda y revisión de Google. 

## 6.1 Apuntar la app a la nube 

Hoy la app apunta a una IP de la red local ( `http://192.168.1.35:8003` ) definida en 

`lib/core/network/api_client.dart` . En producción debe apuntar a la URL HTTPS de Koyeb: 

```
// lib/core/network/api_client.dart
constString baseUrl = "https://mobile-core-andino-xxxx.koyeb.app";
```

Pendiente del ecosistema: la capa de datos de las apps todavía usa Supabase en algunos módulos. Para producción real contra este backend, esos servicios deben migrarse a llamadas REST contra el API de Koyeb (es el "pendiente" declarado en el README del backend). Para una primera publicación de prueba puede convivir, pero conviene cerrarlo antes de pasar a producción abierta. 

## 6.2 Generar la clave de firma (keystore) 

Una sola vez por app. **Guardar el keystore y sus contraseñas con extremo cuidado: si se pierde, no se puede volver a actualizar la app en Play.** 

```
keytool -genkey -v -keystore ~/andino-fventas.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias fventas
```

Crear `android/key.properties` (y agregarlo a `.gitignore` ): 

```
storePassword=...
keyPassword=...
keyAlias=fventas
storeFile=/ruta/andino-fventas.jks
```

Configurar `android/app/build.gradle` para usar ese `signingConfig` en `release` . 

## 6.3 Compilar el paquete de release 

6 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

```
flutter clean
flutter build appbundle --release
```

El archivo queda en `build/app/outputs/bundle/release/app-release.aab` . 

## 6.4 Publicar en Play Console 

1. Crear la aplicación en Play Console (nombre, idioma, categoría: Finanzas). 

2. Completar **Contenido de la app** : política de privacidad (obligatoria para apps financieras), clasificación de contenido, público objetivo, seguridad de datos. 

3. Subir el `.aab` a un canal de **Prueba interna** primero (despliegue en minutos, sin revisión completa). 

4. Probar con cuentas de testers reales. 

5. Promover a **Producción** . La primera revisión de Google puede tardar de días a un par de semanas para apps financieras. 

Repetir todo el proceso (keystore propio, ficha propia, `.aab` propio) para la app de **clientes** . 

## 7. Variables de entorno por componente (resumen) 

|**Componente**|**Variable**|**Origen del valor**|
|---|---|---|
|Koyeb (backend)|`DATABASE_URL`|Neon (pooled)|
|Koyeb (backend)|`JWT_SECRET`|generada por el equipo|
|Vercel (front)|`VITE_BASE_URL`|URL pública de Koyeb|
|Flutter (apps)|`baseUrl`en`api_client.dart`|URL pública de Koyeb|
|FastAPI (CORS)|`allow_origins`|dominio de Vercel|



## 8. Checklist de salida a producción 

- Neon: esquema cargado y seed verificado ( `0001` existe). Koyeb: `/docs` abre y el login devuelve token. 

- Koyeb: variables sensibles marcadas como _secret_ . Backend: CORS incluye el dominio de Vercel. 

- Vercel: `VITE_BASE_URL` correcta y **redeploy** hecho. Vercel: login funciona desde la URL pública. Flutter: `baseUrl` apunta a HTTPS de Koyeb (no IP local). Flutter: keystore generado y respaldado fuera del repo. 

- Play: `.aab` en prueba interna antes de producción. 

- Play: política de privacidad y seguridad de datos completas. 

## 9. Problemas frecuentes 

7 / 8 

DevAppMob_Guia_Despliegue_Banco_Andino.md 

2026-06-23 

|**Síntoma**|**Causa probable**|**Solución**|
|---|---|---|
|Backend no arranca en Koyeb|comando con puerto`8003`fijo|usar`--port $PORT`|
|`connection refused`a la|cadena directa en vez de pooled, o sin|usar la cadena_pooled_de|
|base|`sslmode=require`|Neon|
|Front carga pero login da error|dominio de Vercel no está en|agregarlo y redeploy del|
|CORS|`allow_origins`|backend|
|Cambié`VITE_BASE_URL`y no<br>surte efecto|Vite incrusta en build|hacer**redeploy**en Vercel|
|||usar la URL HTTPS de|
|App móvil no conecta|`baseUrl`apunta a IP local o`http://`|Koyeb|
|Play rechaza la actualización|keystore distinto al original|siempre firmar con el<br>mismo keystore|



## 10. Cierre conceptual 

Desplegar no es "subir archivos": es **separar configuración de código** y **conectar capas por contrato** . Cuando el alumno entiende que la base, el backend, el front y las apps son piezas independientes que solo se hablan por URLs y variables de entorno, puede mover cualquiera de ellas a otro proveedor (cambiar Koyeb por otro, Neon por otro) sin reescribir el sistema. Esa es la competencia real: pensar el software como un conjunto de servicios desacoplados, no como un programa que "corre en mi máquina". 

8 / 8 

