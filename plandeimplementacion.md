Plan de Implementación: App Fuerza de Ventas – Caja Arequipa
Este plan detalla la arquitectura, el diseño y la implementación de la aplicación para Oficiales de Crédito (Fuerza de Ventas) de Caja Arequipa. La aplicación será construida en Flutter con una arquitectura modular orientada a características (feature-first), implementando una experiencia offline-first con mocks integrados para emular Firebase y el core bancario.

Arquitectura y Estructura Modular
El proyecto se estructurará siguiendo los lineamientos de diseño modular, separando las características para facilitar el mantenimiento y escalabilidad futura.


lib/
├── core/
│   ├── theme/           # Paleta de colores Caja Arequipa, tipografía Roboto/SF Pro
│   ├── navigation/      # Rutas y flujo de navegación general
│   ├── widgets/         # Componentes comunes de diseño premium (botones, inputs, loaders)
│   └── database/        # Servicio local de almacenamiento (offline-first & sync simulation)
├── features/
│   ├── auth/            # LoginScreen, AuthViewModel
│   ├── dashboard/       # DashboardScreen, HomeViewModel
│   ├── cartera/         # Lista de cartera de clientes a renovar
│   ├── ruta/            # Planificación de ruta, optimización simple y mapa interactivo mock
│   ├── cliente/         # Ficha del cliente, historial de créditos
│   ├── solicitud/       # Formulario de nueva solicitud (offline-first)
│   ├── documentos/      # Captura de DNI y documentos (soporte cámara/archivo local)
│   ├── buro/            # Consulta simulada de buró de crédito
│   └── estados/         # Panel de ciclo de vida de solicitudes (Enviado -> En Evaluación -> Aprobado -> Desembolsado)
└── main.dart
Lineamientos de Diseño e Identidad Visual (Caja Arequipa)
Aplicaremos rigurosamente la paleta de colores de Caja Arequipa:

Azul Marino Corporativo (#002454): Color principal de fondos, cabeceras e identidad.
Turquesa Brillante (#00C4D3): Acentos digitales, botones principales y llamadas a la acción.
Amarillo Mostaza (#FF9E1B): Pestañas activas y resaltados críticos.
Isotipo y Estados:
Verde Césped (#1FA02F): Estado "Aprobado" o "Sincronizado".
Turquesa Oscuro (#008EA7): Estado "En Evaluación".
Naranja/Ocre (#C67A43): Alertas o estado "Enviado".
Rojo Coral (#D93D41): Errores, rechazos o estado "Error de sincronización".
Fondo de Interfaz (#F0F4F8): Gris claro premium para mejorar el contraste.
Fondos de Tarjetas (#FFFFFF): Blanco puro con sombras sutiles (glassmorphism y elevación Material 3).
Estrategia Offline-First y Mocks
Base de Datos Local:
Crearemos un DatabaseService genérico basado en almacenamiento de archivos JSON utilizando path_provider y shared_preferences. Esto garantiza compatibilidad 100% en Web, Android, iOS y Windows sin requerir configuraciones de motores pesados.
Guardará la cartera diaria de clientes, el itinerario de visitas y las solicitudes capturadas fuera de línea.
Control de Sincronización (Sync Status):
Cada solicitud local tendrá un estado de sincronización: pending, synced, failed.
Se proveerá un indicador global de conectividad interactivo en el dashboard para simular la pérdida y recuperación de señal.
Simulaciones:
Buró de Crédito: Retorna perfil crediticio detallado (semáforo de riesgo verde/amarillo/rojo).
Transmisión Electrónica: Simula envío de JSON y subida de archivos de documentos con progreso visual de carga.
Proposed Changes
Componente Core: Base de datos y Navegación
[NEW] 
database_service.dart
Clase encargada de guardar información de forma local (clientes, solicitudes, estado de sincronización y fotos).

[NEW] 
app_theme.dart
Definición de estilos de Material 3 con la paleta de Caja Arequipa.

[NEW] 
viewmodel_provider.dart
Proveedor genérico de ViewModel adaptado del proyecto App Cliente para consistencia.

Componente Features: Módulos del Negocio
[NEW] 
auth
Pantalla de Login con diseño corporativo elegante y credenciales de prueba.

[NEW] 
dashboard
Pantalla principal con resumen de cartera diaria, estado de la red (online/offline), estadísticas rápidas y accesos directos.

[NEW] 
cartera
Lista de clientes por renovar con filtros y carga automática simulada.

[NEW] 
ruta
Mapa simulado premium interactivo que dibuja la ruta sugerida de visitas, permite marcar clientes visitados y calcular la optimización de ruta.

[NEW] 
cliente
Pantalla de ficha de cliente que muestra su historial, nivel de riesgo (buró) e información de contacto.

[NEW] 
solicitud
Formulario offline-first y sección para adjuntar fotografías del DNI del cliente, gestionando la sincronización en segundo plano.

[NEW] 
estados
Panel que lista las solicitudes enviadas y su estado actual: Enviado, En Evaluación, Aprobado, Desembolsado con notificaciones push simuladas.

Plan de Verificación
Pruebas Automatizadas
Ejecutar flutter analyze para verificar la validez del código Dart y ausencia de errores de sintaxis o lints.
Compilar y ejecutar pruebas básicas sobre los viewmodels si se requiere.
Verificación Manual
Compilar la aplicación para plataforma Windows y Web para realizar pruebas de funcionalidad del MVP:
Iniciar sesión con credenciales de prueba.
Visualizar la cartera diaria.
Alternar el interruptor de red (Online / Offline) en la UI y validar que las solicitudes creadas en Offline se guarden localmente y se marquen como "Pendiente de Sincronización".
Recuperar el estado "Online" y ejecutar la sincronización de las solicitudes pendientes, validando que se actualicen en Firestore Mock.
Interactuar con el planificador de rutas para comprobar la simulación gráfica y optimización.
Comprobar la captura simulada de documentos y la consulta del buró de crédito.