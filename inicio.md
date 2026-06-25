[1:12 p. m., 25/6/2026] Aldo Requena: ## App para Fuerza de Ventas (Oficiales de Credito)

Lista de cartera diaria — clientes con renovaciones, carga automatica

- Planificacion de ruta — mapa de visitas del dia
- Ficha del cliente — historial crediticio y productos activos
- Nueva solicitud de credito — captura en campo, formulario offline-first
- Captura de documentos — foto de DNI y documentos legales Consulta de buro de credito — verificacion en campo
- Transmision electronica — envio al sistema central
- Estado de solicitudes — enviado > en evaluacion > aprobado > desembolsado
[1:56 p. m., 25/6/2026] Aldo Requena: ## HU-C01 — Login

*Como* cliente registrado *Quiero* ingresar con mi usuario y contrasena *Para* acceder a mis cuentas de forma segura

## *Criterios de aceptacion:*

- Campos: usuario/DNI y contrasena
- Logo y nombre de la entidad financiera asignada visible
- Colores y branding de la entidad (color primario, secundario)
- Boton "Ingresar" navega al Dashboard (sin validacion real en S9)
- Credenciales correctas hardcodeadas en el ViewModel

*Pantalla:* LoginScreen *ViewModel:* AuthViewModel con estado loading , success , error

## HU-C02 — Dashboard principal

*Como* cliente autenticado *Quiero* ver un resumen de mis productos financieros *Para* tener una vision rapida de mi situacion financiera

## *Criterios de aceptacion:*

- Saludo con nombre del cliente (dato hardcodeado en ViewModel)
- Tarjeta de saldo de cuenta de ahorros
- Tarjeta de credito activo con monto pendiente
- Barra de navegacion inferior con tabs visibles: Inicio, Cuentas, Creditos, Perfil (los tabs solo Inicio funciona en S9)
- Boton o icono de cerrar sesion que regresa al Login

*Pantalla:* DashboardScreen *ViewModel:* HomeViewModel con datos ficticios de cuenta y credito
[2:06 p. m., 25/6/2026] Aldo Requena: *Prompt para el inicio del desarrollo de la app móvil de fuerza de ventas – Caja Arequipa*  

Actúa como líder técnico y genera la documentación inicial del proyecto. El siguiente prompt define el alcance base, la arquitectura tecnológica y los lineamientos de diseño para construir un MVP funcional. Conforme avance el proyecto, se irán agregando nuevos requerimientos.  

---

### 1. Información general del proyecto  
*Nombre tentativo:* App Oficial de Crédito – Caja Arequipa  
*Objetivo:* Dotar a los oficiales de crédito de una herramienta móvil que les permita gestionar su cartera diaria, capturar nuevas solicitudes en campo (modo offline-first), consultar información de clientes y transmitir las operaciones al sistema central del banco.  
*Usuarios:* Fuerza de ventas externa (oficiales de crédito) con dispositivos Android/iOS.  

---

### 2. Funcionalidades iniciales (MVP)  

| Módulo | Descripción |  
|--------|-------------|  
| *Lista de cartera diaria* | Visualización de clientes con créditos por renovar. Carga automática desde el sistema central al iniciar sesión o sincronizar. |  
| *Planificación de ruta* | Mapa con las visitas del día, geolocalización de clientes y optimización simple de recorrido. |  
| *Ficha del cliente* | Datos básicos, historial crediticio resumido (últimos créditos, comportamiento de pago) y productos activos con el banco. |  
| *Nueva solicitud de crédito* | Formulario de captura en campo (datos personales, monto, plazo, destino). Debe funcionar sin conexión y sincronizar al recuperar internet. |  
| *Captura de documentos* | Toma de fotos (cámara) de DNI y otros documentos legales, con almacenamiento local y posterior carga a la nube. |  
| *Consulta de buró de crédito* | Botón de verificación en campo que muestre el resultado de la consulta (integración simulada inicialmente, endpoint real a futuro). |  
| *Transmisión electrónica* | Envío de la solicitud completa (formulario + documentos) al sistema central del banco. |  
| *Estado de solicitudes* | Panel con el ciclo de vida de cada solicitud: Enviado → En Evaluación → Aprobado → Desembolsado. Actualización mediante notificaciones push o sincronización manual. |  

---

### 3. Stack tecnológico  
- *Framework:* Flutter (última versión estable) con soporte para plataformas Android e iOS.  
- *Backend y servicios cloud:* Firebase (integrado mediante CLI).  
  - *Firestore:* Base de datos principal para datos offline y sincronización.  
  - *Firebase Storage:* Almacenamiento de imágenes y documentos.  
  - *Firebase Authentication:* Inicio de sesión seguro para oficiales.  
  - *Cloud Functions (opcional):* Para lógica de negocio sensible o integración futura con el core bancario.  
- *Comunicación con sistema central:* Endpoint REST o SOAP (a definir) consumido desde Cloud Functions o directamente desde la app (con capa de seguridad). En esta etapa se mockeará la respuesta.  
- *Herramientas:* Firebase CLI para despliegue de funciones y configuración de proyecto.  

---

### 4. Lineamientos de diseño y experiencia de usuario  

*Paleta de colores corporativa* – Uso obligatorio en toda la interfaz:  

| Elemento | Color | Código Hex |  
|----------|-------|------------|  
| Color principal (textos, fondos web) | Azul Marino Corporativo | #002454 |  
| Acentos digitales y botones principales | Turquesa Brillante | #00C4D3 |  
| Pestañas activas y resaltados | Amarillo/Mostaza | #FF9E1B |  
| Isotipo (Verde Césped) | Verde Césped | #1FA02F |  
| Isotipo (Turquesa Oscuro) | Turquesa Oscuro | #008EA7 |  
| Isotipo (Naranja/Ocre) | Naranja/Ocre | #C67A43 |  
| Isotipo (Verde Oliva) | Verde Oliva | #7B8C47 |  
| Isotipo (Rojo Coral) | Rojo Coral | #D93D41 |  
| Fondos de interfaz | Gris Claro | #F0F4F8 |  
| Fondos de tarjetas y textos claros | Blanco Puro | #FFFFFF |  

- *Tipografía:* Roboto (Android) / SF Pro (iOS) según plataforma, con buen contraste sobre los fondos.  
- *Componentes:* Material Design 3 adaptado con la paleta corporativa.  
- *Logo/Isotipo:* Incluir los elementos visuales de Caja Arequipa en splash screen y barra superior.  

---

### 5. Requisitos no funcionales clave  
- *Offline-first:* El formulario de solicitud y la captura de documentos deben funcionar sin conexión a internet. Los datos se almacenan localmente y se sincronizan automáticamente al detectar conectividad.  
- *Seguridad:* Cifrado en tránsito (HTTPS) y en reposo para datos sensibles. Autenticación robusta.  
- *Rendimiento:* La sincronización de cartera y solicitudes debe ser rápida y consumir pocos datos móviles.  
- *Escalabilidad:* La arquitectura debe permitir la adición de nuevos módulos (ej. cobranza, metas comerciales, simuladores de crédito).  

---

### 6. Entregables esperados para esta fase  
1. Repositorio Flutter inicializado con estructura modular (features como módulos independientes).  
2. Integración con Firebase (Autenticación, Firestore, Storage) usando la CLI.  
3. Pantallas funcionales con UI fiel a la paleta de colores para los módulos de cartera, ficha de cliente, captura de solicitud y estado de solicitudes.  
4. Lógica offline-first implementada para la nueva solicitud y captura de documentos.  
5. Mock de la consulta de buró y transmisión electrónica (simulación de respuesta exitosa).  
6. Documentación breve sobre cómo añadir nuevos requerimientos en siguientes iteraciones.  

---

### 7. Próximos pasos (a agregar progresivamente)  
- Integración real con el API del core bancario.  
- Módulo de cobranza y gestión de pagos.  
- Simulador de crédito con tasas vigentes.  
- Firma digital de contratos desde el dispositivo.  
- Panel de metas y comisiones para el oficial.  
- Reportes de productividad.  

---

*Instrucción final:* Inicia el desarrollo del MVP siguiendo este prompt. Cualquier duda sobre los requerimientos actuales debe resolverse proponiendo soluciones estándar alineadas a la banca minorista peruana. Mantén la arquitectura lo suficientemente flexible para incorporar los módulos futuros sin reescribir el núcleo. Además, la app al final de desarrollar parte del proyecto, estará conectada a la app de Clientes que se está creando también en este dispositivo.

