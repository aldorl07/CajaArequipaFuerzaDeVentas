# Guía Paso a Paso: Despliegue de las Apps Flutter en la Web a través de Vercel

Dado que tus proyectos son aplicaciones móviles desarrolladas en **Flutter**, puedes compilarlas para la plataforma **Web** (`Flutter Web`) y alojar los archivos estáticos resultantes en **Vercel** de manera gratuita.

Lo mejor es que, gracias a que tu archivo `lib/firebase_options.dart` ya incluye la configuración de Firebase para Web (`kIsWeb`), **no necesitas modificar tu código fuente**. La conexión con la base de datos Firestore en la nube funcionará automáticamente desde el navegador.

A continuación, se presentan los dos métodos para realizar este despliegue.

---

## Método A: Despliegue Directo usando Vercel CLI (Recomendado y más rápido)

Dado que ya tienes instalado Flutter y Node.js en tu computadora, la forma más sencilla es compilar las aplicaciones de forma local y subirlas a Vercel con la línea de comandos (Vercel CLI).

### Paso 1: Instalar Vercel CLI
Abre tu terminal (PowerShell o CMD) e instala Vercel de forma global:
```bash
npm install -g vercel
```
*Una vez instalado, escribe `vercel login` para iniciar sesión con tu cuenta de GitHub/Vercel.*

### Paso 2: Compilar y desplegar la App Fuerza de Ventas
1. Ve al directorio del proyecto:
   ```bash
   cd "D:\Desarrollo de aplicaciones móviles\app movil\App Fuerza de Ventas"
   ```
2. Compila la app para la Web en modo release:
   ```bash
   flutter clean
   flutter build web --release
   ```
   *Esto generará los archivos web en la carpeta: `build/web/`*
3. Navega a la carpeta de compilación web:
   ```bash
   cd build/web
   ```
4. Despliega la carpeta a Vercel:
   ```bash
   vercel --prod
   ```
   *Vercel te hará unas preguntas rápidas en la terminal:*
   * *Set up and deploy?* Escribe `y` y presiona Enter.
   * *Link to existing project?* Escribe `n`.
   * *What's your project's name?* Escribe `caja-arequipa-fuerza-ventas`.
   * *In which directory is your code located?* Presiona Enter (para usar la carpeta actual `.`).
   * *Want to modify these settings?* Escribe `n`.

¡Listo! Al finalizar la subida, la terminal te entregará una URL de producción (ej. `https://caja-arequipa-fuerza-ventas.vercel.app`).

### Paso 3: Compilar y desplegar la App Cliente
Repite exactamente los mismos pasos en el otro proyecto:
1. Ve al directorio de la app cliente:
   ```bash
   cd "D:\Desarrollo de aplicaciones móviles\app movil\App Cliente"
   ```
2. Compila para web:
   ```bash
   flutter clean
   flutter build web --release
   ```
3. Entra a la carpeta de build:
   ```bash
   cd build/web
   ```
4. Despliega a producción:
   ```bash
   vercel --prod
   ```
   *(Nombra este proyecto `caja-arequipa-cliente-app`)*

---

## Método B: Despliegue Automático mediante GitHub Actions (CI/CD)

Si deseas que cada vez que hagas un `git push` a tu repositorio en GitHub la aplicación se compile y actualice en Vercel de manera automática, debes configurar un flujo de trabajo.

Dado que los servidores de Vercel no tienen preinstalado el SDK de Flutter, utilizaremos **GitHub Actions** para realizar la compilación y luego subir los archivos a Vercel.

### Paso 1: Configurar Tokens en GitHub
1. Ve a tu cuenta de Vercel y obtén tu **Token de Acceso**:
   * Entra a `Vercel Dashboard -> Account Settings -> Tokens -> Create`. Llámalo `VERCEL_TOKEN` y guárdalo.
2. Obtén el ID de tu organización y proyecto en Vercel:
   * Abre el archivo `.vercel/project.json` que se generó en tu máquina al usar Vercel CLI en el método A. Ahí verás los valores de `orgId` y `projectId`.
3. Guarda estos secretos en tu repositorio de GitHub:
   * En tu repositorio de GitHub, ve a `Settings -> Secrets and variables -> Actions -> New repository secret` y añade:
     * `VERCEL_TOKEN`: (El token que creaste en Vercel).
     * `VERCEL_ORG_ID`: (El valor de `orgId`).
     * `VERCEL_PROJECT_ID`: (El valor de `projectId`).

### Paso 2: Crear el archivo de flujo de GitHub Actions
En el directorio raíz de tu proyecto, crea el archivo `.github/workflows/deploy.yml` con el siguiente contenido:

```yaml
name: Deploy Flutter Web to Vercel

on:
  push:
    branches:
      - main # O la rama que uses

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # 1. Instalar Flutter SDK
      - name: Install Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      # 2. Obtener dependencias y Compilar para Web
      - name: Build Web Application
        run: |
          flutter pub get
          flutter build web --release

      # 3. Instalar Vercel CLI
      - name: Install Vercel CLI
        run: npm install -g vercel

      # 4. Desplegar a Vercel
      - name: Deploy to Vercel
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
        run: vercel deploy --prebuilt --prod
```

Cada vez que subas cambios a GitHub, la acción de GitHub compilará tu aplicación de Flutter y la publicará en la URL de Vercel de forma transparente.
