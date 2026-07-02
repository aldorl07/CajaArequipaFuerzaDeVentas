# Guía de Despliegue del Ecosistema Móvil Caja Arequipa en la Nube

Esta guía adapta los lineamientos de la rúbrica docente del proyecto "Banco Andino" al ecosistema real y actual de tus dos aplicaciones: **App Cliente** y **App Fuerza de Ventas**, las cuales utilizan una arquitectura **Serverless / BaaS (Backend-as-a-Service)** mediante **Firebase Firestore**.

---

## 1. Comparativa de Arquitecturas

A diferencia de la arquitectura tradicional de 3 capas expuesta en la guía de "Banco Andino" (Base de Datos SQL + Backend API + Frontend Web + Apps), tu ecosistema está simplificado y optimizado de la siguiente manera:

| Componente | Banco Andino (Profesor) | Caja Arequipa (Tu Proyecto) | Estado en tu Ecosistema |
|---|---|---|---|
| **Base de Datos** | PostgreSQL en Neon | **Firebase Firestore (NoSQL)** | **En la nube** (Proyecto: `caja-arequipa-cliente-aldor`) |
| **Backend API** | FastAPI en Koyeb | **Serverless (Conexión Directa)** | Integrado en los SDKs de Firebase en cada App |
| **Portal Web** | React + Vite en Vercel | *No requerido / Apps Móviles Directas* | N/A |
| **App Fuerza de Ventas** | Flutter en Google Play | **Flutter en Google Play / APK** | Lista para compilar en producción |
| **App Clientes** | Flutter en Google Play | **Flutter en Google Play / APK** | Lista para compilar en producción |

---

## 2. Flujo de Conectividad Caja Arequipa

Dado que no existe un servidor intermedio (FastAPI), ambas aplicaciones móviles se conectan directamente a la base de datos distribuida en la nube de Google mediante HTTPS:

```
    ┌────────────────────────────────────────────────────────┐
    │              Firebase Firestore Cloud                  │
    │        Proyecto: `caja-arequipa-cliente-aldor`         │
    └───────────────┬────────────────────────┬───────────────┘
                    │                        │
            HTTPS   ▼                        ▼   HTTPS
       ┌────────────────────────┐        ┌────────────────────────┐
       │      App Cliente       │        │ App Fuerza de Ventas   │
       │     (Banca Móvil)      │        │   (Asesor de Campo)    │
       └────────────────────────┘        └────────────────────────┘
```

---

## 3. Guía de Despliegue Paso a Paso

### Paso 1: Asegurar el Entorno de Producción en Firebase
La base de datos (Firestore) ya se encuentra desplegada y accesible en la nube de Google. Para pasar a producción completa:

1. **Configurar Reglas de Seguridad en Firebase Console**:
   Asegúrate de que las reglas de lectura/escritura en Firebase Console para Firestore no estén en "Modo de Prueba" (que expira en 30 días). Configura reglas de acceso adecuadas, por ejemplo:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true; // O restringido por autenticación de usuario
       }
     }
   }
   ```
2. **Poblar datos semilla**:
   El sembrado inicial se ejecuta automáticamente en la App Fuerza de Ventas gracias a la clase `FirebaseSeeder.seedDatabase()` incluida en `lib/main.dart`. Al iniciar la aplicación con conexión, los oficiales y clientes de prueba (incluyendo a *Aldo Alexandre Requena Lavi*) se registrarán en la nube.

---

### Paso 2: Configuración de Conexión en las Aplicaciones
Ambas aplicaciones leen las credenciales del mismo proyecto Firebase de manera nativa sin necesidad de URLs fijas en código. Asegúrate de verificar los siguientes archivos:

*   **Android**: El archivo `google-services.json` debe estar presente en `android/app/` en ambas aplicaciones.
*   **Código de Inicialización**: Ambos proyectos deben inicializar Firebase en el `main.dart`:
    ```dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    ```

---

### Paso 3: Firma de las Aplicaciones (Keystore)
Para poder publicar las aplicaciones en Google Play o distribuirlas de manera segura a los usuarios finales, debes firmar digitalmente cada APK/AAB.

1.  **Generar claves de firma**:
    Ejecuta el siguiente comando en tu terminal para generar un archivo almacén de claves (`.jks`) seguro (repite para cada app usando alias distintos):
    ```bash
    # Para App Fuerza de Ventas
    keytool -genkey -v -keystore C:\Users\aldor\caja-fventas.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fventas

    # Para App Cliente
    keytool -genkey -v -keystore C:\Users\aldor\caja-cliente.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cliente
    ```
2.  **Configurar variables de firma**:
    Crea el archivo `android/key.properties` en cada proyecto (y agrégalo al `.gitignore` para seguridad) con este contenido:
    ```properties
    storePassword=contraseña_del_almacen
    keyPassword=contraseña_de_la_llave
    keyAlias=fventas
    storeFile=C:\\Users\\aldor\\caja-fventas.jks
    ```
3.  **Vincular firma en Gradle**:
    En `android/app/build.gradle` de cada app, lee este archivo y configúralo en la sección de firmas de lanzamiento:
    ```groovy
    def keystorePropertiesFile = rootProject.file("key.properties")
    def keystoreProperties = new Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(new java.io.FileInputStream(keystorePropertiesFile))
    }

    android {
        signingConfigs {
            release {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
        buildTypes {
            release {
                signingConfig signingConfigs.release
            }
        }
    }
    ```

---

### Paso 4: Compilar paquetes de lanzamiento
Limpia temporales y compila la versión optimizada de producción:

*   **Para descarga directa e instalación rápida (APK)**:
    ```bash
    flutter clean
    flutter build apk --release
    ```
    *El instalable se generará en: `build/app/outputs/flutter-apk/app-release.apk`*
*   **Para subir a Google Play Store (App Bundle)**:
    ```bash
    flutter clean
    flutter build appbundle --release
    ```
    *El paquete de tienda se generará en: `build/app/outputs/bundle/release/app-release.aab`*

---

### Paso 5: Distribución / Google Play Console
1.  Inicia sesión en tu cuenta de **Google Play Console**.
2.  Crea una nueva aplicación, completa la ficha técnica y la política de privacidad.
3.  Sube el archivo `.aab` al canal de **Pruebas Internas** para testeo inmediato sin demoras de revisión.
4.  Una vez validado, promuévelo a **Producción**.
