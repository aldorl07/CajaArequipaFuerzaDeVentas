HU_AppFuerzaVentas_v3.md 

2026-05-26 

## Historias de Usuario y Requerimientos Funcionales 

## App Fuerza de Ventas — Oficiales de Credito en Campo 

Basado en el flujo operativo real de plataformas de movilidad para microfinanzas en Peru Curso: Desarrollo de Aplicaciones Moviles | 2026 

Docente: Mg. Guillermo E. Pena Garcia 

## Contexto del negocio 

El asesor de negocios sale diariamente al campo para visitar microempresas, negocios rurales y clientes individuales. La app reemplaza el expediente fisico: descarga automaticamente la cartera del dia desde el sistema central, permite registrar solicitudes en campo sin internet, captura fotos de documentos, consulta el buro de credito y transmite electronicamnete la solicitud completa al comite de evaluacion. 

El ciclo completo sigue cinco etapas: 

## **Pre-evaluacion → Evaluacion → Aprobacion → Desembolso → Recuperacion** 

Cada estudiante adapta marca, colores y productos a la entidad financiera asignada. El flujo de negocio es identico para todas las instituciones de microfinanzas. 

## Modulos y epicas 

|**Modulo**|**Epica**|**HU**|**RF**|
|---|---|---|---|
|M0|Autenticacion y perfiles|HU-01 a HU-03|RF-01 a RF-08|
|M1|Cartera diaria|HU-04 a HU-07|RF-09 a RF-18|
|M2|Planificacion de ruta|HU-08 a HU-10|RF-19 a RF-26|
|M3|Ficha del cliente|HU-11 a HU-14|RF-27 a RF-36|
|M4|Pre-evaluacion y prospeccion|HU-15 a HU-16|RF-37 a RF-42|
|M5|Captura de solicitud de credito|HU-17 a HU-20|RF-43 a RF-54|
|M6|Captura de documentos|HU-21 a HU-22|RF-55 a RF-60|
|M7|Consulta de buro y listas|HU-23 a HU-24|RF-61 a RF-66|
|M8|Transmision electronica|HU-25 a HU-26|RF-67 a RF-72|
|M9|Estado de solicitudes|HU-27 a HU-29|RF-73 a RF-79|
|M10|Recuperacion de cartera vencida|HU-30 a HU-31|RF-80 a RF-84|
|M11|Reportes y supervision|HU-32 a HU-33|RF-85 a RF-90|



1 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **Total: 33 Historias de Usuario · 90 Requerimientos Funcionales** 

## M0 — Autenticacion y perfiles 

## HU-01 · Login del asesor de negocios 

**Como** asesor de negocios, **quiero** iniciar sesion con mi codigo de empleado y contrasena, **para** acceder unicamente a las funciones que corresponden a mi perfil desde el dispositivo movil. 

## **Criterios de aceptacion:** 

- El formulario solicita codigo de empleado (numerico) y contrasena con opcion de mostrar/ocultar. Al autenticar correctamente, la sesion persiste. El asesor no repite login cada dia. 

- Al superar 5 intentos fallidos, el acceso se bloquea 30 minutos con cuenta regresiva visible. La sesion expira si el dispositivo permanece inactivo mas de 8 horas. 

- No es posible navegar al interior de la app sin haberse autenticado. 

**Story points:** 5 **Perfil:** Operador (asesor de negocios y auxiliar de creditos en campo) 

## **RF-01 — Formulario de login** 

El formulario contiene campo de codigo de empleado con teclado numerico, campo de contrasena con alternancia ver/ocultar, boton "Ingresar" y enlace "Problemas para ingresar". Las cuentas son creadas unicamente por el Administrador; no existe registro propio. 

## **RF-02 — Autenticacion contra Supabase Auth** 

El sistema convierte el codigo de empleado en un identificador de correo interno para autenticar contra Supabase Auth. El token de sesion se almacena de forma segura y encriptada en el dispositivo. 

## **RF-03 — Persistencia y renovacion de sesion** 

Al relanzar la app con sesion vigente, navega directamente al Dashboard sin pasar por login. El token se renueva automaticamente antes de expirar. 

## **RF-04 — Bloqueo por intentos fallidos** 

Un contador local incrementa en cada error de autenticacion. Al llegar a 5, el boton se deshabilita con un temporizador visible de 30 minutos. El bloqueo persiste aunque se cierre y reabra la app. 

## HU-02 · Perfiles de acceso diferenciados 

**Como** administrador de agencia, **quiero** que cada usuario vea solo las funciones correspondientes a su perfil, **para** mantener el control de acceso y evitar operaciones no autorizadas. 

## **Criterios de aceptacion:** 

El sistema maneja cuatro perfiles: Operador, Super Operador, Supervisor y Administrador. 

2 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

- El Operador accede a: Cartera, Ruta, Ficha, Solicitud y Documentos. 

- El Supervisor accede adicionalmente a: Reportes, Reasignacion de tareas y Monitor en mapa. El Administrador accede a todo, incluyendo gestion de usuarios y configuracion. 

- El perfil se obtiene del token de sesion y no puede modificarse desde el dispositivo. 

## **Story points:** 3 

## **RF-05 — Menu lateral adaptativo por perfil** 

El menu lateral muestra unicamente las opciones habilitadas para el perfil autenticado. Las opciones no autorizadas no aparecen; no se muestran deshabilitadas. 

## **RF-06 — Roles y sus capacidades** 

|**Perfil**|**Capacidades principales**|
|---|---|
|Operador|Captura de tareas en campo. Solo movil.|
|Super Operador|Operador + jefe de comite en campo. Acceso a reportes de supervision web.|
|Supervisor|Administrador de agencia. Gestiona tareas, visualiza reportes y reasigna.|
|Administrador|Todo lo anterior mas gestion de usuarios, formularios y configuracion.|



## HU-03 · Cierre de sesion y borrado de datos sensibles 

**Como** asesor de negocios, **quiero** cerrar sesion desde el menu lateral, **para** que mis datos de cartera no sean accesibles si otra persona toma el dispositivo. 

## **Criterios de aceptacion:** 

El menu lateral siempre muestra la opcion "Cerrar sesion". 

   - Al confirmar, se invalida el token en el servidor y se eliminan sesion y cartera en cache local. La app navega a la pantalla de login sin posibilidad de volver atras. 

- Si existen solicitudes pendientes de envio, se muestra aviso: "Tienes X solicitudes sin sincronizar. 

- Cerrar de todas formas?". 

## **Story points:** 3 

## **RF-07 — Flujo de cierre de sesion** 

Secuencia al confirmar logout: invalidar token en Supabase, borrar token local, borrar tablas de cartera y fichas en cache, navegar a login limpiando el historial de navegacion. 

## **RF-08 — Advertencia de documentos pendientes** 

Antes de cerrar sesion, consultar la cola de solicitudes con `pendiente_sync = true` . Si el conteo es mayor a cero, mostrar dialogo de confirmacion con el numero exacto de registros pendientes. 

3 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## M1 — Cartera diaria 

## HU-04 · Ver la lista de cartera asignada del dia 

**Como** asesor de negocios, **quiero** ver al iniciar el dia la lista completa de clientes asignados a mi, **para** planificar visitas sin depender de conexion a internet durante el dia. 

## **Criterios de aceptacion:** 

- La lista muestra por cada cliente: nombre, documento censurado (***456), tipo de gestion con 

- etiqueta de color, monto del credito y nivel de prioridad (ALTA / MEDIA / NORMAL). 

   - Un indicador en el encabezado muestra: "15 clientes · 4 visitados · 11 pendientes". Los clientes visitados se desplazan al fondo con fondo gris y marca de completado. Una barra de progreso muestra el avance del dia (visitados sobre total). Los datos estan disponibles sin conexion desde la ultima sincronizacion. 

## **Story points:** 8 

## **RF-09 — Consulta de cartera desde Supabase** 

Al iniciar sesion o al pulsar "Actualizar", la app consulta la tabla `cartera_diaria` filtrando por `asesor_id` y `fecha_asignacion` igual a la fecha actual, ordenando por `score_prioridad` descendente. El resultado se guarda localmente para uso offline. 

## **RF-10 — Tipos de gestion y colores de etiqueta** 

|**Tipo**|**Color**|**Descripcion**|
|---|---|---|
|RENOVACION|Azul|Credito vigente proximo a vencer|
|AMPLIACION|Verde|Cliente solicita incremento de monto|
|NUEVA SOLICITUD|Naranja|Prospecto o cliente nuevo|
|SEGUIMIENTO|Gris|Visita de control post-desembolso|
|RECUPERACION MORA|Rojo|Cliente con cuotas vencidas|
|DESERTOR|Morado|Cliente que dejo de operar con la institucion|



## **RF-11 — Filtros de cartera** 

Fila de filtros con opciones: Todos / Renovaciones / Nuevas / En mora / Visitados. El filtrado opera sobre los datos locales sin necesidad de nueva consulta a red. El contador del encabezado se actualiza con el subconjunto filtrado. 

## **RF-12 — Busqueda rapida** 

Campo de busqueda con retraso de 300ms. Busca por nombre completo o ultimos cuatro digitos del documento contra los datos en cache local. 

4 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## HU-05 · Descarga automatica nocturna de cartera 

**Como** asesor de negocios, **quiero** que la app descargue mi cartera del dia siguiente cada noche automaticamente, **para** llegar al campo con todos los datos disponibles sin esperar sincronizacion. 

## **Criterios de aceptacion:** 

   - Una tarea programada ejecuta la sincronizacion a las 22:00 horas todos los dias. 

- La sincronizacion descarga: cartera asignada, fichas de clientes, ultimos tres meses de movimientos y 

- preaprobados vigentes. 

   - Al completar, envia notificacion: "Tu cartera de manana esta lista: X clientes." 

   - Si falla, reintenta a las 22:30 y 23:00 con incremento progresivo de espera. 

El encabezado de Cartera muestra "Ultima actualizacion: hoy 22:03". 

## **Story points:** 5 

## **RF-13 — Tarea programada de sincronizacion nocturna (WorkManager en Flutter:** **`workmanager` package)** 

Tarea periodica diaria programada para las 22:00 horas con restriccion de red activa. En caso de fallo, politica de reintento exponencial con maximo tres intentos. 

## **RF-14 — Notificacion push local al completar** 

Al terminar la sincronizacion, se emite una notificacion local con el numero de clientes cargados y enlace directo a la pantalla de Cartera. 

## HU-06 · Segmentacion y priorizacion automatica de visitas 

**Como** asesor de negocios, **quiero** que el sistema indique que clientes son mas urgentes cada dia, **para** maximizar el impacto de mis visitas segun los objetivos de la agencia. 

## **Criterios de aceptacion:** 

- La cartera se ordena automaticamente por: mora vencida primero, luego renovaciones de alto 

- monto, ampliaciones, seguimiento y nuevas solicitudes. 

   - Un puntaje de prioridad (0 a 100) determina el orden de cada cliente. 

   - El asesor puede reordenar manualmente su lista arrastrando elementos. 

   - El reordenamiento manual persiste localmente y no afecta la asignacion del sistema central. 

## **Story points:** 5 

## **RF-15 — Logica de puntaje de prioridad** 

El puntaje se calcula localmente con estos pesos: mora activa (40 puntos base mas dias de mora hasta 30 puntos adicionales), renovacion con monto mayor a S/5,000 (35 puntos), ampliacion (25 puntos), seguimiento (10 puntos), nueva solicitud (5 puntos). Maximo 100 puntos. 

5 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **RF-16 — Reordenamiento manual con arrastrar y soltar** 

La pantalla de cartera permite reorganizar la lista arrastrando cada elemento. El nuevo orden se guarda localmente en la tabla `cartera_orden_local` . 

## HU-07 · Marcar visita como completada 

**Como** asesor de negocios, **quiero** registrar el resultado de cada visita al salir de la ficha del cliente, **para** llevar control del avance del dia y que mi supervisor lo vea en tiempo real. 

## **Criterios de aceptacion:** 

- Al salir de la ficha del cliente, un panel inferior ofrece: Visitado / No encontrado / Reagendar / 

- Negocio cerrado. 

   - Cada resultado incluye campo de observacion libre (maximo 200 caracteres). 

- Al confirmar, el elemento cambia visualmente y se actualiza en Supabase con marca de tiempo y 

- coordenadas GPS del momento. 

Sin conexion, el cambio queda en cola local y se sincroniza al reconectar. 

El supervisor ve el cambio en tiempo real en el portal web. 

## **Story points:** 5 

## **RF-17 — Registro de resultado de visita** 

Al confirmar el resultado, el sistema envia a Supabase los campos: `estado_visita` , `resultado_visita` , `observacion_visita` , `timestamp_visita` , `lat_visita` y `lng_visita` . Sin conexion, guarda en tabla local `visitas_pendientes` con `pendiente_sync = true` . 

## **RF-18 — Sincronizacion de visitas pendientes al reconectar** 

El monitor de red detecta la reconexion y dispara la sincronizacion de todas las filas con `pendiente_sync = true` , enviandolas en lote a Supabase y marcando cada una como sincronizada al completar. 

## M2 — Planificacion de ruta 

## HU-08 · Ver mapa de visitas del dia con ruta optimizada 

**Como** asesor de negocios, **quiero** ver un mapa con todos mis clientes del dia y una ruta sugerida, **para** reducir tiempo de desplazamiento y visitar mas clientes. 

## **Criterios de aceptacion:** 

- El mapa muestra un marcador por cliente con color segun prioridad: rojo (ALTA), amarillo (MEDIA), 

- verde (NORMAL). 

- Al tocar un marcador, aparece una ficha rapida con nombre, tipo de gestion y boton "Ver ficha 

- completa". 

El boton "Optimizar ruta" reordena los marcadores por distancia y tiempo desde la posicion actual. La ruta optima se dibuja como linea conectando los puntos en orden. 

6 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

El boton "Navegar" lanza Waze o Google Maps con el primer destino. 

Los clientes ya visitados cambian su marcador a gris con marca de completado. 

## **Story points:** 8 

## **RF-19 — Integracion de Google Maps en Flutter** 

Uso del paquete `google_maps_flutter` . Los marcadores se crean con color diferenciado por prioridad. La polilinia de ruta optima se dibuja sobre el mapa como capa adicional. 

## **RF-20 — Permisos de ubicacion** 

La app solicita permiso de ubicacion precisa al abrir el modulo de ruta. Si el usuario deniega, se muestra explicacion clara de por que es necesario. Sin permiso, el mapa funciona pero sin posicion actual ni optimizacion de ruta. 

## **RF-21 — Algoritmo de optimizacion de ruta** 

Algoritmo del vecino mas cercano: parte desde la posicion actual del asesor, en cada paso elige el cliente no visitado mas proximo por distancia euclidiana, hasta cubrir toda la cartera. El resultado se presenta como lista reordenada y polilinia en el mapa. 

## **RF-22 — Lanzar app de navegacion externa** 

Al pulsar "Navegar", la app intenta abrir Waze con las coordenadas del destino. Si Waze no esta instalado, abre Google Maps. Si ninguna esta disponible, abre el navegador con Google Maps web. 

## HU-09 · Gestionar geocercas por zona de trabajo 

**Como** administrador de agencia, **quiero** definir zonas geograficas para cada asesor, **para** organizar la fuerza comercial por sectores y medir cobertura real. 

## **Criterios de aceptacion:** 

El mapa permite definir poligonos que delimitan zonas de trabajo. 

Cada zona tiene nombre, color distintivo y lista de asesores asignados. 

- El asesor ve el contorno de su zona como capa semitransparente en su mapa. 

- Si el asesor registra una visita fuera de su zona, el sistema muestra un aviso (no bloquea). 

## **Story points:** 5 

## **RF-23 — Capa de geocerca en el mapa** 

El poligono de la zona se renderiza como capa de relleno semitransparente sobre el mapa con borde del color asignado a la zona. 

## **RF-24 — Deteccion de visita fuera de zona** 

7 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Antes de guardar el resultado de una visita, se compara la ubicacion GPS actual con el poligono de zona usando el algoritmo de rayo (Ray Casting). Si esta fuera, aparece un aviso: "Esta visita esta fuera de tu zona asignada. Se registrara igualmente." 

## HU-10 · Registrar coordenadas GPS del negocio del cliente 

**Como** asesor de negocios, **quiero** capturar y actualizar la ubicacion exacta del negocio del cliente durante la visita, **para** que futuras visitas y el mapa del equipo sean mas precisos. 

## **Criterios de aceptacion:** 

- En la ficha del cliente, el boton "Actualizar ubicacion del negocio" captura las coordenadas actuales. Se muestra la direccion aproximada obtenida por geocodificacion inversa. 

- El asesor puede confirmar o descartar la ubicacion capturada. 

- Al confirmar, se actualizan las coordenadas del cliente en Supabase. 

## **Story points:** 3 

## **RF-25 — Captura de coordenadas con GPS de alta precision** 

Uso del paquete `geolocator` con precision alta. La captura se realiza al momento de pulsar el boton, mostrando indicador de carga mientras obtiene la senal. 

## **RF-26 — Geocodificacion inversa** 

Uso del paquete `geocoding` para convertir coordenadas en direccion legible: calle, distrito, ciudad. Se muestra como texto editable para que el asesor pueda corregir si es necesario. 

## M3 — Ficha del cliente 

## HU-11 · Ver ficha completa del cliente antes de la visita 

**Como** asesor de negocios, **quiero** consultar toda la informacion del cliente antes de visitarlo, **para** llegar preparado con datos actualizados sin depender de papeles. 

## **Criterios de aceptacion:** 

- La ficha muestra: foto o iniciales, nombre completo, documento, direccion, telefono, tipo y 

- antiguedad del negocio. 

- Seccion "Posicion del cliente": deuda total en el sistema, cuotas al dia, cuotas en mora, fecha del 

- ultimo pago. 

- Seccion "Historial crediticio": ultimos cinco creditos con monto, plazo, tasa, estado y porcentaje de 

- pagos puntuales. 

   - Seccion "Oferta vigente": monto preaprobado por el sistema de scoring (si existe). 

   - Boton "Llamar" abre el marcador telefonico con el numero del cliente prellenado. Los datos se cargan desde cache si no hay conexion. 

**Story points:** 8 

8 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **RF-27 — Estructura de la pantalla de ficha** 

La pantalla usa desplazamiento vertical con secciones apiladas: encabezado del cliente, datos de contacto y negocio, posicion en el sistema, historial de creditos, oferta preaprobada y botonera de acciones. 

## **RF-28 — Semaforo de riesgo crediticio** 

|**Calificacion SBS**|**Color del semaforo**|**Descripcion**|
|---|---|---|
|Normal|Verde|Sin observaciones|
|CPP (Con Problemas Potenciales)|Amarillo|Requiere atencion|
|Deficiente|Naranja|Requiere comite especial|
|Dudoso|Rojo|Alto riesgo|
|Perdida|Gris oscuro|No procede evaluacion|



## **RF-29 — Llamada directa desde la ficha** 

El boton "Llamar" lanza la app telefonica del dispositivo con el numero del cliente. No realiza la llamada automaticamente; el asesor confirma desde el marcador. 

## **RF-30 — Consulta de posicion del cliente** 

Se invoca una Supabase Edge Function `consulta-posicion` que devuelve: deuda total consolidada, numero de cuentas vigentes, numero de cuentas en mora, dias de mayor mora historica y fecha del ultimo pago registrado. 

## HU-12 · Ver grafico de comportamiento de pagos 

**Como** asesor de negocios, **quiero** ver un grafico mensual del comportamiento de pagos del cliente en los ultimos 12 meses, **para** evaluar visualmente si es candidato a una nueva operacion antes de proponer algo. 

## **Criterios de aceptacion:** 

- Grafico de barras con 12 columnas: verde = pago puntual, rojo = pago con mora, gris = sin cuota 

- ese mes. 

- Indicadores debajo del grafico: porcentaje de pagos puntuales, dias promedio de mora, monto total 

- pagado. 

El grafico funciona offline con datos descargados en la sincronizacion nocturna. 

## **Story points:** 5 

## **RF-31 — Grafico de comportamiento con fl_chart** 

Uso del paquete `fl_chart` para el grafico de barras. El color de cada barra se determina segun el estado de pago del periodo: verde para pago puntual, rojo para pago con mora, gris para periodos sin cuota. El eje X 

9 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## muestra los meses abreviados. 

## **RF-32 — Calculo de indicadores de comportamiento** 

Los indicadores se calculan en el ViewModel a partir de los datos locales: 

- Porcentaje puntual: cuotas al dia entre total de cuotas multiplicado por 100. 

- Dias promedio de mora: suma de dias de mora en cuotas morosas entre numero de cuotas morosas. Monto total pagado: suma de todos los montos pagados registrados. 

## HU-13 · Ver oferta preaprobada del scoring 

**Como** asesor de negocios, **quiero** ver el monto maximo preaprobado calculado por el sistema antes de la visita, **para** llegar con una propuesta concreta en lugar de generar expectativas sin respaldo. 

## **Criterios de aceptacion:** 

- La seccion "Oferta vigente" muestra: monto maximo, plazo sugerido, tasa TEA referencial, nivel de 

- confianza del puntaje y fecha de vencimiento de la oferta. 

   - Si no existe preaprobado, muestra: "Sin oferta vigente. Puede iniciar solicitud nueva." 

   - El boton "Usar esta oferta" prellenea el formulario de solicitud con esos datos. 

## **Story points:** 5 

## **RF-33 — Consulta de preaprobados vigentes** 

Se consulta la tabla `creditos_preaprobados` filtrando por `cliente_id` , `vigente = true` y 

`fecha_vencimiento` mayor o igual a la fecha actual. Se toma el registro con mayor `score_confianza` . 

## **RF-34 — Tarjeta visual de oferta preaprobada** 

La tarjeta usa fondo verde claro con borde verde. Muestra monto formateado, plazo en meses, tasa TEA en porcentaje, barra horizontal de confianza del puntaje y fecha de vigencia. El boton de accion lleva al formulario de solicitud con los campos prellenados. 

## HU-14 · Recibir alertas de caida de cartera 

**Como** asesor de negocios, **quiero** recibir alertas cuando un cliente entra en mora o tiene variaciones importantes, **para** actuar de forma preventiva antes de que el credito se deteriore. 

## **Criterios de aceptacion:** 

Las alertas muestran una insignia numerica sobre el icono de cartera en el menu. 

- Tipos de alerta: primer dia de mora, mora mayor a 30 dias, mora mayor a 60 dias, pago parcial, pago 

- total. 

Al tocar una alerta, navega directamente a la ficha del cliente correspondiente. 

- Las alertas leidas se marcan y desaparecen de la insignia al dia siguiente. 

10 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**Story points:** 5 

## **RF-35 — Suscripcion Realtime para alertas** 

La app se suscribe al canal Realtime de Supabase para inserciones en la tabla `alertas_cartera` donde `asesor_id` coincide con el usuario autenticado. Al recibir un evento, actualiza el estado del ViewModel y refresca la insignia. 

## **RF-36 — Insignia numerica en menu** 

El numero de alertas no leidas se muestra como insignia roja sobre el icono de campana en el menu lateral. Se actualiza en tiempo real al recibir nuevas alertas o al marcar las existentes como leidas. 

## M4 — Pre-evaluacion y prospeccion 

## HU-15 · Pre-evaluar a un prospecto en campo 

**Como** asesor de negocios, **quiero** registrar datos basicos de un prospecto y obtener una pre-evaluacion crediticia en campo, **para** saber si el prospecto califica antes de iniciar el proceso formal. 

## **Criterios de aceptacion:** 

- El formulario captura: documento, nombres, tipo de negocio, ingresos estimados, destino del credito 

- y monto solicitado. 

   - Al pulsar "Pre-evaluar", el sistema consulta la posicion del prospecto en el sistema financiero. 

- El resultado indica: APTO (continuar evaluacion), REVISAR (requiere analisis adicional) o NO 

- PROCEDE. 

   - Si esta apto, el boton "Iniciar solicitud formal" abre el formulario completo con datos prellenados. Sin conexion, la pre-evaluacion queda en cola y se procesa al reconectar. 

## **Story points:** 8 

## **RF-37 — Formulario de prospeccion** 

Campos requeridos: numero de documento (8 digitos), nombres, apellidos, fecha de nacimiento, tipo de negocio (lista desplegable), antiguedad del negocio en anos y meses, ingresos estimados mensuales, monto solicitado (control deslizante entre S/500 y S/50,000) y destino del credito. 

## **RF-38 — Consulta en linea al sistema de pre-evaluacion** 

Se invoca la Edge Function `pre-evaluar` con los datos del prospecto. La funcion devuelve: calificacion (APTO / REVISAR / NO PROCEDE), motivo en caso de restriccion y puntaje interno estimado. 

## **RF-39 — Presentacion visual del resultado de pre-evaluacion** 

11 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Resultado**|**Color de fondo**|**Etiqueta visible**|**Accion disponible**|
|---|---|---|---|
|APTO|Verde|Puede continuar la evaluacion|Iniciar solicitud formal|
|REVISAR|Amarillo|Requiere analisis adicional|Registrar observaciones|
|NO PROCEDE|Rojo|No cumple condiciones|Informar al cliente|



## HU-16 · Gestionar campanas de renovaciones y ampliaciones 

**Como** asesor de negocios, **quiero** ver los clientes con oferta de renovacion o ampliacion activa en mi cartera, **para** gestionar campanas comerciales sin perder oportunidades del periodo. 

## **Criterios de aceptacion:** 

Una seccion "Campanas activas" en el dashboard muestra las ofertas vigentes del periodo. 

- Cada oferta indica: tipo (renovacion / ampliacion / producto paralelo), monto ofertado, fecha de 

- vencimiento y cliente al que aplica. 

Al gestionar una oferta en campo, el sistema inicia el proceso de solicitud con datos prellenados. 

- Las ofertas expiradas se marcan automaticamente como vencidas al dia siguiente. 

## **Story points:** 5 

## **RF-40 — Consulta de campanas activas** 

Se consulta la tabla `campanas_activas` filtrando por `asesor_id` , `activa = true` y `fecha_vencimiento` mayor o igual a hoy. Los resultados se ordenan por fecha de vencimiento ascendente para priorizar las mas proximas a expirar. 

## **RF-41 — Tarjeta de campana activa** 

Cada campana muestra: etiqueta del tipo con color diferenciado, nombre del cliente, monto de la oferta formateado, cuenta regresiva de dias restantes y boton "Gestionar ahora". 

## **RF-42 — Registro de cliente desertor** 

Para clientes desertores, el formulario captura: motivo de desercion (lista predefinida), institucion a la que migro (si se conoce), probabilidad de retorno (Alta / Media / Baja) y observaciones libres. 

## M5 — Captura de solicitud de credito en campo 

## HU-17 · Registrar solicitud de credito en cuatro pasos (offline-first) 

**Como** asesor de negocios, **quiero** capturar la solicitud de credito completa del cliente directamente en su negocio, **para** iniciar el proceso de evaluacion sin regresar a la agencia. 

## **Criterios de aceptacion:** 

12 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

- El formulario tiene cuatro pasos secuenciales: Datos del solicitante, Datos del negocio, Condiciones 

- del credito, Confirmacion y firma. 

- Cada paso valida sus campos antes de permitir avanzar. Los campos obligatorios no completados se 

- resaltan en rojo. 

   - El asesor puede guardar borrador en cualquier paso y retomarlo despues. 

- Con conexion, la solicitud se envia al instante. Sin conexion, queda en cola con indicador "Pendiente 

- de envio". 

Al enviar, se genera un numero de expediente local visible al asesor. 

El formulario se adapta segun el tipo de producto: microcredito (comercio, productivo o servicio) o 

- consumo. 

## **Story points:** 13 

## **RF-43 — Indicador de progreso de cuatro pasos** 

El encabezado del formulario muestra los cuatro pasos con estado visual: completado (relleno), activo (borde destacado) o pendiente (vacio). La navegacion entre pasos usa botones "Anterior" y "Siguiente"; el deslizamiento lateral esta deshabilitado para evitar saltar validaciones. 

## **RF-44 — Paso 1: Datos del solicitante** 

|**Campo**|**Tipo**|**Validacion**|
|---|---|---|
|Nombres|Texto|Obligatorio, solo letras|
|Apellidos|Texto|Obligatorio|
|Documento|Numerico|8 digitos exactos|
|Fecha de nacimiento|Selector de fecha|Edad entre 18 y 75 anos|
|Estado civil|Lista|Soltero / Casado / Conviviente / Divorciado / Viudo|
|Grado de instruccion|Lista|Primaria / Secundaria / Tecnico / Universitario|
|Telefono|Numerico|9 digitos|
|Correo electronico|Texto|Formato valido (opcional)|



El formulario activa campos adicionales para conyuge o garante segun el estado civil y las reglas del producto seleccionado. 

## **RF-45 — Paso 2: Datos del negocio y destino del credito** 

|**Campo**|**Tipo**|**Validacion**|
|---|---|---|
|Tipo de negocio|Lista|Comercio / Servicios / Produccion /<br>Agropecuario|
|Nombre del negocio|Texto|Obligatorio|
|Direccion del negocio|Texto|Obligatorio|



13 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Validacion**|
|---|---|---|
|Antiguedad del negocio|Numerico (anos +<br>meses)|Minimo 6 meses|
|Ingresos estimados<br>mensuales|Decimal|Mayor que cero|
|Gastos mensuales|Decimal|Mayor o igual a cero|
|Patrimonio estimado|Decimal|Opcional|
|Destino del credito|Texto libre|Maximo 500 caracteres|
|Actividad economica|Lista|Segun catalogo CIIU|



## **RF-46 — Paso 3: Condiciones del credito** 

Control deslizante para el monto solicitado entre S/500 y S/150,000. Lista desplegable para plazo en meses (3, 6, 12, 18, 24, 36, 48 o 60). Selector de moneda (PEN o USD). Selector de tipo de cuota (mensual, quincenal o semanal). Lista de garantia (sin garantia, aval, hipotecaria o prendaria). 

Una tarjeta de simulacion se actualiza en tiempo real al modificar monto o plazo, mostrando: cuota estimada, total a pagar, costo financiero total y TEA referencial. 

## **RF-47 — Formula de simulacion de cuota en tiempo real** 

La cuota mensual se calcula con la formula de amortizacion francesa: 

- Tasa mensual equivalente = (1 + TEA)^(1/12) - 1 

- Cuota mensual = Monto x Tasa mensual / (1 - (1 + Tasa mensual)^(-Plazo en meses)) 

El calculo es sincrono en el ViewModel y no requiere conexion a red. 

## **RF-48 — Paso 4: Confirmacion y firma digital** 

Vista de resumen en modo solo lectura con todos los datos ingresados. Lienzo tactil para que el cliente firme con el dedo. La firma se convierte a imagen y se adjunta a la solicitud. Casilla obligatoria: "El cliente declara que los datos son veraces". 

## HU-18 · Guardar y retomar borradores de solicitud 

**Como** asesor de negocios, **quiero** guardar una solicitud incompleta como borrador y retomarla despues, **para** completarla en una segunda visita sin perder los datos ya ingresados. 

## **Criterios de aceptacion:** 

Al intentar salir del formulario, aparece dialogo: "Guardar borrador / Descartar / Cancelar". 

- La pantalla "Borradores" lista las solicitudes incompletas con: nombre del cliente, paso alcanzado, 

- fecha y monto. 

Al seleccionar un borrador, navega al paso donde se quedo con todos los campos prellenados. 

14 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Deslizar un borrador hacia un lado y confirmar lo elimina permanentemente. 

## **Story points:** 3 

## **RF-49 — Persistencia de borradores en SQLite local** 

Los borradores se guardan en la tabla local `solicitudes_borrador` con todos los campos del formulario serializados, el numero de paso alcanzado y la marca de tiempo de la ultima edicion. 

## HU-19 · Simulador de credito rapido independiente 

**Como** asesor de negocios, **quiero** calcular rapidamente la cuota de cualquier monto y plazo sin abrir una solicitud formal, **para** responder al instante las preguntas del cliente durante la visita. 

## **Criterios de aceptacion:** 

Pantalla accesible desde el menu lateral y desde la ficha del cliente. 

- Control deslizante de monto (S/500 a S/150,000) y selector de plazo. 

- Cuota mensual, total a pagar y costo financiero se actualizan en tiempo real. Funciona completamente sin conexion. 

El boton "Crear solicitud con estos datos" navega al formulario con monto y plazo prellenados. 

## **Story points:** 5 

## **RF-50 — Pantalla del simulador** 

Tres tarjetas de indicador con: cuota mensual, total a pagar y costo financiero. El calculo usa la misma formula del formulario de solicitud (RF-47). El boton de accion pasa los parametros como argumentos a la ruta de solicitud. 

## HU-20 · Ver historial de mis solicitudes del mes 

**Como** asesor de negocios, **quiero** ver todas las solicitudes que he registrado en el periodo, **para** hacer seguimiento y reportar mi productividad. 

## **Criterios de aceptacion:** 

Lista agrupada por semana con contador de cada estado. 

- Encabezado con indicadores: total enviadas, aprobadas, desembolsadas y monto total del mes. Al tocar una solicitud, navega al detalle de su estado actual. 

## **Story points:** 3 

## **RF-51 — Consulta de solicitudes del periodo** 

Se consulta la tabla `solicitudes_credito` filtrando por `asesor_id` y `created_at` dentro del mes actual, ordenando por fecha descendente. 

15 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **RF-52 — Indicadores mensuales del asesor** 

Los indicadores se calculan desde el resultado de la consulta: total de filas enviadas, subconjunto con `estado = aprobado` , subconjunto con `estado = desembolsado` , suma de `monto_aprobado` y tasa de aprobacion como porcentaje. 

## M6 — Captura de documentos 

## HU-21 · Fotografiar documentos del cliente con validacion de nitidez 

**Como** asesor de negocios, **quiero** capturar fotos de los documentos del cliente con validacion de calidad automatica, **para** evitar que documentos ilegibles rechacen la solicitud en el comite. 

## **Criterios de aceptacion:** 

- Documentos obligatorios: documento de identidad anverso, documento de identidad reverso, foto 

- del negocio, foto del asesor con el cliente. 

   - Documentos opcionales: RUC, recibo de servicios, contrato de arriendo. 

   - La app valida automaticamente la nitidez de cada foto antes de aceptarla. 

   - Cada foto se comprime automaticamente a un maximo de 800 KB antes de subir. 

   - Un listado visual muestra el estado de cada documento: LISTO / PENDIENTE / OBLIGATORIO. El boton "Enviar solicitud" solo se activa cuando todos los obligatorios estan en estado LISTO. 

## **Story points:** 8 

## **RF-53 — Captura con camera package y marco guia** 

Uso del paquete `camera` de Flutter. La vista previa muestra un marco guia superpuesto indicando el tipo de documento esperado. La captura se realiza al pulsar el boton de la camara en la pantalla de preview. 

## **RF-54 — Compresion y validacion de nitidez** 

Despues de capturar, la imagen pasa por dos procesos: (1) calculo de la varianza del Laplaciano para detectar desenfoque — si el puntaje esta por debajo del umbral configurado, se solicita retomar la foto; (2) compresion iterativa reduciendo la calidad en pasos de 10 puntos hasta que el archivo sea menor a 800 KB. La imagen validada y comprimida se sube a Supabase Storage en la ruta `documentos-` 

`solicitudes/{solicitud_id}/{tipo_documento}.jpg` . 

## HU-22 · Revisar y gestionar fotos adjuntas antes del envio 

**Como** asesor de negocios, **quiero** revisar las fotos adjuntas y reemplazar las que no sean claras, **para** asegurar que el comite pueda leer todos los documentos sin problemas. 

## **Criterios de aceptacion:** 

Galeria horizontal de miniaturas con el nombre del documento debajo de cada una. 

- Al tocar una miniatura, se abre visor a pantalla completa con zoom de pinza. 

- El boton "Retomar" en el visor permite reemplazar esa foto sin afectar las demas. 

16 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

El boton "Eliminar" muestra dialogo de confirmacion antes de borrar. 

## **Story points:** 3 

## **RF-55 — Visor de imagenes con zoom** 

Uso del paquete `photo_view` para el visor a pantalla completa con soporte de zoom mediante gesto de pinza. 

## **RF-56 — Eliminacion de documento con confirmacion** 

Al eliminar: borrar el archivo de Supabase Storage, eliminar el registro de la tabla `solicitudes_documentos` y actualizar la vista del listado. Si alguna operacion falla, mostrar mensaje de error y revertir los cambios aplicados. 

## M7 — Consulta de buro y listas negras 

## HU-23 · Consultar historial en centrales de riesgo en campo 

**Como** asesor de negocios, **quiero** consultar el reporte crediticio del cliente durante la visita, **para** tomar una decision informada sobre la solicitud sin regresar a la oficina. 

## **Criterios de aceptacion:** 

- La consulta requiere firma digital de consentimiento del cliente (Ley de Proteccion de Datos 

- Personales, Ley 29733). 

- El resultado muestra: calificacion SBS, numero de entidades con deuda activa, deuda total en el 

- sistema, mayor deuda individual y dias de mayor mora historica. 

   - El semaforo de resultado sigue la misma codificacion que la ficha del cliente (RF-28). 

   - La consulta queda registrada con marca de tiempo como evidencia de auditoria. 

- Si existe una consulta del mismo cliente realizada en los ultimos 30 dias, el sistema ofrece reutilizar 

- ese resultado para no impactar el historial del cliente. 

## **Story points:** 8 

## **RF-57 — Consentimiento previo a la consulta** 

Antes de ejecutar la consulta, se muestra el texto legal de autorizacion completo. El cliente firma en el lienzo tactil. La firma y la marca de tiempo se guardan como evidencia junto al resultado de la consulta. 

## **RF-58 — Integracion con Edge Function de buro (simulada para el curso)** 

Se invoca la Edge Function `consulta-buro` con el numero de documento. La funcion devuelve en formato JSON: calificacion SBS, numero de entidades con deuda, deuda total, mayor deuda individual y dias de mayor mora. En produccion, esta funcion conectaria con los servicios reales de la SBS, Equifax o Experian. 

## **RF-59 — Interpretacion automatica del resultado** 

17 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

El sistema genera un texto interpretativo en lenguaje natural basado en el resultado. Ejemplo: "El cliente tiene historial en dos entidades con deuda total de S/15,400. Sin mora historica. Recomendacion: proceder con la evaluacion." 

## HU-24 · Consultar listas de restriccion y alerta de fraude 

**Como** asesor de negocios, **quiero** verificar si el cliente aparece en listas de restriccion, **para** no iniciar procesos con personas inhabilitadas. 

## **Criterios de aceptacion:** 

- La consulta verifica la lista interna de la institucion y las listas de inhabilitados del sistema financiero. Si aparece en una lista, se muestra un aviso bloqueante en rojo con el motivo. 

- Si esta limpio, se muestra confirmacion en verde y se permite continuar. 

- El resultado queda registrado en el expediente. 

## **Story points:** 3 

## **RF-60 — Consulta combinada buro mas listas negras** 

Un unico endpoint verifica ambas fuentes y devuelve: si el cliente esta en lista negra ( `en_lista_negra: bool` ), el motivo de bloqueo si aplica y el resultado del buro. Si `en_lista_negra` es verdadero, el formulario de solicitud no puede abrirse para ese cliente mientras persista el bloqueo. 

## **RF-61 — Pantalla de resultado de verificacion** 

Si el cliente esta bloqueado: dialogo modal con fondo rojo, texto del motivo y unico boton "Entendido". El formulario de solicitud permanece inaccesible. Si esta limpio: indicador verde y acceso habilitado al formulario. 

## M8 — Transmision electronica al sistema central 

## HU-25 · Enviar solicitud completa con todos los documentos 

**Como** asesor de negocios, **quiero** transmitir electronicamente la solicitud completa al sistema central en un solo proceso, **para** que el comite la reciba de inmediato y pueda evaluarla el mismo dia. 

## **Criterios de aceptacion:** 

- El boton "Enviar al comite" verifica que esten completos: todos los documentos obligatorios, el 

- formulario completo, el reporte de buro o justificacion de omision, y la firma del cliente. 

- Una pantalla de progreso muestra los pasos: Validando datos, Subiendo documentos (N de M), 

- Registrando en sistema central, Asignando expediente, Solicitud enviada. 

   - Si el proceso falla a mitad, puede reanudarse desde el ultimo paso completado. 

   - Al finalizar, se muestra el numero de expediente oficial y el tiempo estimado de respuesta. El asesor recibe notificacion de confirmacion. 

**Story points:** 8 

18 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **RF-62 — Validacion previa al envio** 

Antes de iniciar la transmision, el sistema verifica la presencia de cada documento obligatorio, la completitud de todos los campos del formulario, la existencia de firma del cliente y el resultado del buro adjunto. Si hay errores, se muestra la lista completa de elementos faltantes antes de permitir el envio. 

## **RF-63 — Pantalla de progreso del envio** 

Un indicador vertical de pasos muestra el estado de cada etapa: pendiente, en proceso y completado. El paso activo muestra un indicador de carga circular. Los pasos completados muestran una marca de verificacion. 

## **RF-64 — Transmision atomica con soporte de reanudacion** 

El estado del proceso se guarda localmente despues de cada paso exitoso. Si la transmision se interrumpe (cierre de app, perdida de conexion), al reintentar el sistema lee el estado guardado y salta directamente al primer paso no completado. 

## **RF-65 — Subida paralela de documentos** 

Los documentos se suben en paralelo usando operaciones asincronas concurrentes para minimizar el tiempo total de transmision. 

## HU-26 · Recibir confirmacion del comite en tiempo real 

**Como** asesor de negocios, **quiero** recibir notificacion cuando el comite confirme la recepcion y cuando tome una decision, **para** comunicarme con el cliente sin necesidad de consultar manualmente el sistema. 

## **Criterios de aceptacion:** 

- Notificacion al recibir la solicitud en el comite (menos de 5 minutos tras el envio). 

- Notificacion al aprobar: incluye monto aprobado y fecha estimada de desembolso. Notificacion al rechazar: incluye motivo del rechazo. 

- Notificacion al desembolsar: el cliente puede retirar en agencia. 

- Al tocar cualquier notificacion, abre directamente el detalle de esa solicitud. 

## **Story points:** 3 

## **RF-66 — Suscripcion Realtime para cambios de estado** 

La app se suscribe al canal Realtime de Supabase para actualizaciones en la tabla `solicitudes_credito` donde `asesor_id` coincide con el usuario. Al recibir un cambio de estado, actualiza el estado del ViewModel y emite la notificacion correspondiente. 

## **RF-67 — Contenido de notificaciones push por estado** 

19 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Estado**|**Titulo**|**Cuerpo**|
|---|---|---|
|recibido_comite|Solicitud recibida|{Cliente} — Expediente {num} en evaluacion|
|aprobado|Credito aprobado|{Cliente} — S/{monto} aprobado. Desembolso: {fecha}|
|condicionado|Solicitud condicionada|{Cliente} — {condicion_adicional}|
|rechazado|Solicitud rechazada|{Cliente} — {motivo_rechazo}|
|desembolsado|Credito desembolsado|{Cliente} puede retirar en agencia|



## M9 — Estado de solicitudes 

## HU-27 · Ver tablero de estado de todas mis solicitudes activas 

**Como** asesor de negocios, **quiero** ver el estado actualizado de todas mis solicitudes en un tablero visual, **para** saber en que etapa esta cada expediente y si necesito actuar. 

## **Criterios de aceptacion:** 

- Pestanas por estado: Enviadas / En comite / Aprobadas / Desembolsadas / Rechazadas. Cada pestana muestra el conteo de solicitudes en ese estado. 

- Las tarjetas se mueven automaticamente a la pestana correcta cuando cambia el estado. Filtro por rango de fechas y monto disponible. 

**Story points:** 8 

## **RF-68 — Pestanas con contadores actualizados en tiempo real** 

La suscripcion Realtime actualiza los contadores de cada pestana y reubicat las tarjetas al pestana correspondiente cuando llega un cambio de estado, con una animacion de transicion. 

## **RF-69 — Tarjeta de solicitud en el tablero** 

Cada tarjeta muestra: nombre del cliente, monto solicitado, dias desde el envio, nombre del analista asignado (si aplica) y etiqueta de estado con color correspondiente. 

## HU-28 · Ver detalle completo de una solicitud enviada 

**Como** asesor de negocios, **quiero** ver todos los detalles de una solicitud enviada incluyendo el historial de cambios, **para** responder preguntas del cliente sobre el estado de su expediente. 

## **Criterios de aceptacion:** 

- Muestra: datos del solicitante, condiciones del credito, miniaturas de documentos, linea de tiempo 

- del proceso con marcas de tiempo. 

La linea de tiempo muestra etapas futuras en gris con linea punteada. 

- El boton "Compartir estado" genera un PDF de una pagina enviable por WhatsApp. El asesor puede agregar notas internas (privadas, no visibles al cliente). 

20 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**Story points:** 5 

## **RF-70 — Linea de tiempo del proceso** 

Un componente vertical muestra cada evento con: icono de estado, descripcion de la accion, responsable (sistema o nombre del analista) y marca de tiempo. Las etapas futuras se dibujan con linea punteada y color gris. 

## **RF-71 — Generacion de PDF de estado para compartir** 

Se genera un documento PDF de una pagina usando el paquete `pdf` de Flutter con: logo de la institucion, datos del cliente, condiciones del credito solicitado, estado actual con fecha y codigo QR de seguimiento. 

## **RF-72 — Notas internas del asesor** 

Campo de texto con maximo 500 caracteres. Las notas se guardan en la tabla `solicitudes_notas_internas` con identificador del asesor, identificador de la solicitud, contenido y marca de tiempo. Solo el asesor autor y el supervisor de la agencia pueden verlas. 

## HU-29 · Recibir notificacion de aprobacion o rechazo 

**Como** asesor de negocios, **quiero** recibir un mensaje inmediato cuando el comite decide sobre una solicitud, **para** comunicarme con el cliente lo antes posible. 

## **Criterios de aceptacion:** 

Las notificaciones se agrupan por asesor en el panel de notificaciones del dispositivo. 

- Al deslizar una notificacion, se marca como leida en el sistema. 

Ver RF-66 y RF-67 para el contenido y comportamiento de las notificaciones. 

## **Story points:** 3 

## **RF-73 — Firebase Cloud Messaging para notificaciones remotas** 

Integracion con Firebase Cloud Messaging usando el paquete `firebase_messaging` . El token FCM del dispositivo se guarda en el campo `token_fcm` de la tabla `asesores_negocio` al iniciar sesion. El servidor dispara el mensaje cuando cambia el estado de la solicitud. 

## **RF-74 — Agrupacion de notificaciones en el dispositivo** 

Las notificaciones del mismo asesor se agrupan bajo un mismo grupo en el panel de notificaciones de Android, con un resumen expandible que muestra todas las solicitudes con cambio de estado reciente. 

## M10 — Recuperacion de cartera vencida 

HU-30 · Ver listado de mora diaria 

21 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**Como** asesor de negocios, **quiero** ver la lista de mis clientes con cuotas vencidas ordenada por urgencia, **para** priorizar las gestiones de cobranza del dia. 

## **Criterios de aceptacion:** 

La lista muestra: cliente, dias de mora, monto vencido y fecha del ultimo contacto. 

- Ordenada por dias de mora descendente (mayor urgencia primero). 

- Semaforo de dias de mora: 1 a 30 dias = amarillo, 31 a 60 = naranja, mas de 60 = rojo. 

- Un indicador en el encabezado muestra el monto total vencido de la cartera del asesor. 

## **Story points:** 5 

## **RF-75 — Consulta de mora diaria** 

Se consulta la tabla `cartera_vencida` filtrando por `asesor_id` y `dias_mora` mayor a cero, ordenando por `dias_mora` descendente. 

## **RF-76 — Codificacion de color por dias de mora** 

|**Rango de dias**|**Color de etiqueta**|**Urgencia**|
|---|---|---|
|1 a 30 dias|Amarillo|Seguimiento preventivo|
|31 a 60 dias|Naranja|Gestion prioritaria|
|Mas de 60 dias|Rojo|Recuperacion urgente|



## HU-31 · Registrar accion de cobranza en campo 

**Como** asesor de negocios, **quiero** registrar el resultado de una gestion de cobranza con todos los detalles, **para** que el sistema actualice el estado del credito y el supervisor vea mi gestion. 

## **Criterios de aceptacion:** 

Formulario de accion: tipo de gestion (Visita / Llamada / Mensaje), resultado (Compromiso de pago 

- / Pago parcial / Sin contacto / Se niega a pagar), fecha y monto del compromiso si aplica. 

   - Un compromiso de pago genera una alerta automatica al asesor en la fecha acordada. La gestion queda registrada con coordenadas GPS y marca de tiempo. Si es pago parcial, el saldo vencido se actualiza en tiempo real. 

## **Story points:** 5 

## **RF-77 — Formulario de accion de cobranza** 

Los campos capturados son: tipo de gestion, resultado de la visita, monto pagado (si aplica), fecha del compromiso de pago (selector de fecha), monto comprometido, observaciones libres, coordenadas GPS del momento y marca de tiempo automatica. 

## **RF-78 — Alerta de seguimiento de compromiso** 

22 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Al registrar un compromiso de pago con fecha futura, se programa una tarea de notificacion local para ese dia usando el paquete `flutter_local_notifications` . La notificacion indica el nombre del cliente y el monto comprometido. 

## M11 — Reportes y supervision 

## HU-32 · Ver reporte de cobertura de visitas del dia 

**Como** supervisor de agencia, **quiero** ver en tiempo real el avance de todos mis asesores en el mapa, **para** saber quienes estan trabajando, donde se encuentran y cuantas gestiones han completado. 

## **Criterios de aceptacion:** 

- Mapa con marcadores de distintos colores por asesor mostrando su ultima ubicacion. 

- Panel lateral con tabla: asesor, visitados sobre total asignado, ultima sincronizacion. Filtro por agencia y por fecha. 

Solo visible para perfiles Supervisor y Administrador. 

## **Story points:** 5 

## **RF-79 — Monitor de supervision en tiempo real** 

Suscripcion Realtime a la tabla `cartera_diaria` filtrando por `agencia_id` y `fecha_asignacion` igual a hoy. Al recibir actualizaciones, el mapa y la tabla de avance se refrescan sin recargar la pantalla. 

## HU-33 · Ver reporte de productividad mensual 

**Como** jefe regional, **quiero** ver un reporte de solicitudes gestionadas, aprobadas y desembolsadas por asesor en el mes, **para** tomar decisiones sobre metas y resultados del equipo. 

## **Criterios de aceptacion:** 

- Tabla con: asesor, solicitudes enviadas, aprobadas, desembolsadas, monto total y tasa de 

- aprobacion. 

   - Grafico de barras comparativo entre asesores del periodo. 

   - Exportable como PDF. 

Solo accesible para Supervisor y Administrador. 

## **Story points:** 5 

## **RF-80 — Consulta de productividad agregada** 

Se consulta la tabla `solicitudes_credito` agrupada por `asesor_id` y `estado` , filtrando por `agencia_id` y el rango del mes actual. El resultado calcula conteos por estado y suma de montos aprobados. 

## **RF-81 — Grafico comparativo de productividad** 

23 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Grafico de barras agrupadas por asesor usando `fl_chart` , con una barra por estado (enviadas, aprobadas, desembolsadas) y el nombre del asesor en el eje horizontal. 

## Flujo 1 — Ciclo completo del credito en campo 

**==> picture [512 x 101] intentionally omitted <==**

**----- Start of picture text -----**<br>
Inicio del dia Descarga nocturnade cartera Planificacionde ruta Visita al cliente Pre-evaluacionpasa? No Informar alcliente Rechazado Notificarrechazo<br>Si Captura solicitudy documentos y listas negrasConsulta buro Clienteapto? NoSi Firma digitaldel cliente Transmisionelectronica Decisioncomite Condicionado Gestionarcondicion Si puntual?Pago No<br>Aprobado Desembolsoen agencia Seguimientode credito Gestion decobranza<br>**----- End of picture text -----**<br>


## Flujo 2 — Captura de solicitud en campo (4 pasos) 

24 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [511 x 773] intentionally omitted <==**

25 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Abrir nueva solicitud 

Paso 1: Datos del solicitante 

No 

Campos validos? 

Si 

Paso 2: Datos del negocio y destino 

No 

Campos validos? 

Si 

Paso 3: Condiciones del credito 

Simulador en No tiempo real 

26 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

Condiciones acordadas? 

Si 

Paso 4: Confirmacion y firma digital 

Cliente firma en pantalla 

Hay conexion? 

No Si Guardar en Transmision cola offline electronica Indicador Documentos Pendiente de envio obligatorios OK? 

27 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [512 x 359] intentionally omitted <==**

**----- Start of picture text -----**<br>
No<br>Si<br>Completar Subida paralela<br>documentos faltantes de documentos<br>Registro en<br>sistema central<br>Numero de expediente<br>asignado<br>**----- End of picture text -----**<br>


Flujo 3 — Modo offline y sincronizacion 

28 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [511 x 773] intentionally omitted <==**

29 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [512 x 773] intentionally omitted <==**

**----- Start of picture text -----**<br>
Accion del asesor<br>Red<br>disponible?<br>Si No<br>Operacion directa Guardar en<br>en Supabase tabla local<br>Actualizar cache Marcar pendiente<br>SQLite local sync = true<br>Mostrar banner<br>Vista actualizada<br>Modo offline<br>Red<br>recuperada?<br>Si<br>Leer cola<br>de pendientes<br>**----- End of picture text -----**<br>


30 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [512 x 450] intentionally omitted <==**

**----- Start of picture text -----**<br>
No<br>Enviar a<br>Supabase en lote<br>Envio<br>exitoso?<br>No<br>Si<br>Reintentar<br>Marcar sync = false<br>en siguiente ciclo<br>Vista sincronizada<br>**----- End of picture text -----**<br>


## Estructura de base de datos 

Diagrama de relaciones 

## Flujo 5 — Relaciones de base de datos 

**==> picture [512 x 207] intentionally omitted <==**

**----- Start of picture text -----**<br>
agencias<br>tiene<br>gestiona registra asesores_negocio clientes<br>atiende captura aparece_en solicita<br>recibe tiene<br>cartera_diaria solicitudes_credito realiza creditos_preaprobados es_consultado registra gestionado_por creditos recibe<br>vincula genera<br>adjunta tiene genera<br>solicitudes_documentos solicitudes_notas_internas consultas_buro acciones_cobranza alertas_cartera<br>**----- End of picture text -----**<br>


31 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## Descripcion de tablas 

Las tablas se organizan en tres grupos funcionales: 

**Grupo identidad:** `agencias` , `asesores_negocio` **Grupo clientes y creditos:** `clientes` , `creditos` , `creditos_preaprobados` , `campanas_activas` **Grupo operacion en campo:** `cartera_diaria` , `solicitudes_credito` , `solicitudes_documentos` , `consultas_buro` , `acciones_cobranza` , `alertas_cartera` , `solicitudes_notas_internas` 

## Tabla: agencias 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|nombre|VARCHAR(100)|Nombre de la agencia|
|region|VARCHAR(50)|Region geografica|
|lat|DECIMAL(10,7)|Latitud de la agencia|
|lng|DECIMAL(10,7)|Longitud de la agencia|
|activa|BOOLEAN|Si la agencia esta operativa|
|created_at|TIMESTAMPTZ|Fecha de creacion|



## Tabla: asesores_negocio 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|user_id|UUID (FK -> auth.users)|Vinculo con la autenticacion de Supabase|
|codigo_empleado|VARCHAR(10) UNIQUE|Codigo de empleado de la institucion|
|nombres|VARCHAR(100)|Nombres del asesor|
|apellidos|VARCHAR(100)|Apellidos del asesor|
|agencia_id|UUID (FK -> agencias)|Agencia a la que pertenece|
|perfil|VARCHAR(20)|operador / super_operador / supervisor / administrador|
|token_fcm|TEXT|Token de dispositivo para notificaciones push|
|activo|BOOLEAN|Si el asesor esta habilitado|
|created_at|TIMESTAMPTZ|Fecha de creacion|



**Restriccion:** `user_id` es UNIQUE — un usuario de Supabase Auth corresponde a un solo asesor. 

Tabla: clientes 

32 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|numero_documento|VARCHAR(15) UNIQUE|DNI o RUC|
|tipo_documento|VARCHAR(5)|DNI / RUC / CE|
|nombres|VARCHAR(100)|Nombres del cliente|
|apellidos|VARCHAR(100)|Apellidos del cliente|
|fecha_nacimiento|DATE|Fecha de nacimiento|
|estado_civil|VARCHAR(15)|Estado civil|
|telefono|VARCHAR(15)|Telefono principal|
|email|VARCHAR(100)|Correo electronico (opcional)|
|direccion|TEXT|Direccion del domicilio|
|tipo_negocio|VARCHAR(30)|Tipo de actividad economica|
|nombre_negocio|VARCHAR(100)|Nombre del negocio|
|antiguedad_negocio_meses|INTEGER|Meses de operacion del negocio|
|ingresos_estimados|DECIMAL(12,2)|Ingresos mensuales estimados|
|lat|DECIMAL(10,7)|Latitud del negocio|
|lng|DECIMAL(10,7)|Longitud del negocio|
|calificacion_sbs|VARCHAR(15)|Calificacion en el sistema financiero|
|created_at|TIMESTAMPTZ|Fecha de creacion|
|updated_at|TIMESTAMPTZ|Ultima actualizacion|



## Tabla: creditos 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|cliente_id|UUID (FK -> clientes)|Cliente titular del credito|
|asesor_id|UUID (FK -> asesores_negocio)|Asesor que gestiono el credito|
|agencia_id|UUID (FK -> agencias)|Agencia que otorgo el credito|
|producto|VARCHAR(30)|Tipo de producto crediticio|
|monto_desembolsado|DECIMAL(12,2)|Monto desembolsado|
|plazo_meses|INTEGER|Plazo pactado en meses|
|tea|DECIMAL(5,2)|Tasa efectiva anual|



33 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|estado|VARCHAR(20)|vigente / pagado / vencido / castigado|
|fecha_desembolso|DATE|Fecha del desembolso|
|fecha_vencimiento|DATE|Fecha de ultimo pago|
|saldo_actual|DECIMAL(12,2)|Saldo pendiente actual|
|cuotas_total|INTEGER|Numero total de cuotas|
|cuotas_pagadas|INTEGER|Cuotas pagadas a la fecha|
|dias_mora|INTEGER|Dias de mora actuales|
|created_at|TIMESTAMPTZ|Fecha de creacion|



## Tabla: creditos_preaprobados 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|cliente_id|UUID (FK -> clientes)|Cliente al que aplica la oferta|
|asesor_id|UUID (FK -> asesores_negocio)|Asesor asignado para gestionarla|
|monto_maximo|DECIMAL(12,2)|Monto maximo preaprobado|
|plazo_sugerido_meses|INTEGER|Plazo recomendado|
|tea_referencial|DECIMAL(5,2)|Tasa efectiva referencial|
|score_confianza|INTEGER|Puntaje de confianza del scoring (0-100)|
|vigente|BOOLEAN|Si la oferta esta activa|
|fecha_calculo|DATE|Fecha en que se calculo el preaprobado|
|fecha_vencimiento|DATE|Fecha hasta la que es valida la oferta|
|created_at|TIMESTAMPTZ|Fecha de creacion|



## Tabla: cartera_diaria 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|asesor_id|UUID (FK -><br>asesores_negocio)|Asesor asignado|
|cliente_id|UUID (FK -> clientes)|Cliente en la cartera|
|agencia_id|UUID (FK -> agencias)|Agencia de la asignacion|



34 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|fecha_asignacion|DATE|Fecha para la que fue asignada|
|tipo_gestion|VARCHAR(30)|RENOVACION / AMPLIACION / NUEVA_SOLICITUD /<br>SEGUIMIENTO / RECUPERACION_MORA / DESERTOR|
|prioridad|VARCHAR(10)|alta / media / normal|
|score_prioridad|INTEGER|Puntaje calculado (0-100)|
|estado_visita|VARCHAR(20)|pendiente / visitado / no_encontrado / reagendado /<br>negocio_cerrado|
|resultado_visita|VARCHAR(30)|Resultado registrado por el asesor|
|observacion_visita|TEXT|Observaciones libres del asesor|
|timestamp_visita|TIMESTAMPTZ|Fecha y hora del registro|
|lat_visita|DECIMAL(10,7)|Latitud donde se registro la visita|
|lng_visita|DECIMAL(10,7)|Longitud donde se registro la visita|
|orden_manual|INTEGER|Orden de visita definido por el asesor|



**Restriccion:** UNIQUE(asesor_id, cliente_id, fecha_asignacion) — un cliente no puede aparecer dos veces en la cartera del mismo asesor el mismo dia. 

## Tabla: solicitudes_credito 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|numero_expediente|VARCHAR(20) UNIQUE|Numero de expediente oficial asignado|
|asesor_id|UUID (FK -><br>asesores_negocio)|Asesor que capturo la solicitud|
|cliente_id|UUID (FK -> clientes)|Cliente solicitante|
|agencia_id|UUID (FK -> agencias)|Agencia que gestiona|
|tipo_negocio|VARCHAR(30)|Tipo de negocio del solicitante|
|nombre_negocio|VARCHAR(100)|Nombre del negocio|
|actividad_economica|VARCHAR(10)|Codigo CIIU|
|antiguedad_negocio_meses|INTEGER|Meses de operacion del negocio|
|ingresos_estimados|DECIMAL(12,2)|Ingresos mensuales estimados|
|gastos_mensuales|DECIMAL(12,2)|Gastos mensuales|
|patrimonio_estimado|DECIMAL(12,2)|Patrimonio estimado (opcional)|



35 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|tiene_conyuge|BOOLEAN|Si el solicitante declara conyuge|
|conyuge_json|JSONB|Datos del conyuge serializados|
|tiene_garante|BOOLEAN|Si se incluye garante|
|garante_json|JSONB|Datos del garante serializados|
|monto_solicitado|DECIMAL(12,2)|Monto solicitado por el cliente|
|plazo_meses|INTEGER|Plazo solicitado en meses|
|moneda|VARCHAR(3)|PEN o USD|
|tipo_cuota|VARCHAR(10)|mensual / quincenal / semanal|
|garantia|VARCHAR(20)|sin_garantia / aval / hipotecaria / prendaria|
|destino_credito|TEXT|Descripcion del destino del credito|
|cuota_estimada|DECIMAL(10,2)|Cuota mensual simulada|
|tea_referencial|DECIMAL(5,2)|TEA referencial al momento de la solicitud|
|||borrador / enviado / recibido_comite /|
|estado|VARCHAR(30)|en_evaluacion / aprobado / condicionado /|
|||rechazado / desembolsado|
|monto_aprobado|DECIMAL(12,2)|Monto aprobado por el comite|
|motivo_rechazo|TEXT|Motivo del rechazo si aplica|
|condicion_adicional|TEXT|Condicion adicional si aplica|
|analista_asignado|VARCHAR(100)|Analista del comite asignado|
|firma_cliente_base64|TEXT|Firma digital del cliente en base64|
|lat_captura|DECIMAL(10,7)|Latitud donde se capturo la solicitud|
|lng_captura|DECIMAL(10,7)|Longitud donde se capturo la solicitud|
|pendiente_sync|BOOLEAN|Si esta pendiente de sincronizacion offline|
|created_at|TIMESTAMPTZ|Fecha de creacion|
|updated_at|TIMESTAMPTZ|Ultima actualizacion|



## Tabla: solicitudes_documentos 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|solicitud_id|UUID (FK -><br>solicitudes_credito)|Solicitud a la que pertenece|



36 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|tipo_documento|VARCHAR(40)|dni_anverso / dni_reverso / ruc / recibo_servicios /<br>foto_negocio / foto_visita / contrato_arrendamiento|
|storage_url|TEXT|URL del archivo en Supabase Storage|
|tamanio_kb|INTEGER|Tamano del archivo comprimido|
|nitidez_score|DECIMAL(5,2)|Puntaje de nitidez calculado (varianza de Laplaciano)|
|created_at|TIMESTAMPTZ|Fecha de subida|



## Tabla: consultas_buro 

|**Campo**||**Tipo**||**Descripcion**|
|---|---|---|---|---|
|id||UUID (PK)||Identificador unico|
|asesor_id||UUID (FK -> asesores_negocio)||Asesor que realizo la consulta|
|cliente_id||UUID (FK -> clientes)||Cliente consultado|
|dni_consultado||VARCHAR(15)||Documento consultado|
|calificacion_sbs||VARCHAR(20)||Calificacion obtenida|
|||||Numero de entidades con deuda|
|entidades_con_deuda||INTEGER||activa|
|deuda_total_pen||DECIMAL(12,2)||Deuda total en el sistema en soles|
|mayor_deuda||DECIMAL(12,2)||Mayor deuda individual registrada|
|dias_mayor_mora||INTEGER||Dias de mayor mora historica|
|resultado_json||JSONB||Respuesta completa de la fuente|
|firma_consentimiento_base64||TEXT||Firma de consentimiento del cliente|
|solicitud_id||UUID (FK -><br>solicitudes_credito)||Solicitud vinculada (opcional)|
|created_at||TIMESTAMPTZ||Fecha y hora de la consulta|
|Tabla: acciones_cobranza|||||
|**Campo**|**Tipo**||**Descripcion**||
|id|UUID (PK)||Identificador unico||
|asesor_id|UUID (FK -><br>asesores_negocio)||Asesor que realizo la gestion||
|cliente_id|UUID (FK|-> clientes)|Cliente gestionado||



37 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|credito_id|UUID (FK -> creditos)|Credito en mora|
|tipo_gestion|VARCHAR(20)|visita / llamada / mensaje|
|resultado|VARCHAR(30)|compromiso_pago / pago_parcial / sin_contacto /<br>se_niega|
|monto_pagado|DECIMAL(12,2)|Monto pagado si aplica|
|fecha_compromiso|DATE|Fecha acordada para el pago|
|monto_compromiso|DECIMAL(12,2)|Monto comprometido para el pago|
|observaciones|TEXT|Notas adicionales del asesor|
|lat|DECIMAL(10,7)|Latitud de la gestion|
|lng|DECIMAL(10,7)|Longitud de la gestion|
|timestamp_gestion|TIMESTAMPTZ|Fecha y hora de la gestion|



## Tabla: alertas_cartera 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|asesor_id|UUID (FK -><br>asesores_negocio)|Asesor destinatario|
|cliente_id|UUID (FK -> clientes)|Cliente que genero la alerta|
|tipo_alerta|VARCHAR(30)|primer_dia_mora / mora_30d / mora_60d / pago_parcial /<br>pago_total|
|mensaje|TEXT|Texto descriptivo de la alerta|
|leida|BOOLEAN|Si el asesor ya la leyo|
|created_at|TIMESTAMPTZ|Fecha de generacion|



## Tabla: solicitudes_notas_internas 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|UUID (PK)|Identificador unico|
|solicitud_id|UUID (FK -> solicitudes_credito)|Solicitud asociada|
|asesor_id|UUID (FK -> asesores_negocio)|Asesor que escribio la nota|
|contenido|TEXT|Texto de la nota (maximo 500 caracteres)|
|created_at|TIMESTAMPTZ|Fecha de creacion|



38 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## Tabla local SQLite: solicitudes_borrador (solo en dispositivo) 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|TEXT (PK)|UUID generado localmente|
|cliente_id|TEXT|ID del cliente (si fue seleccionado)|
|cliente_nombre|TEXT|Nombre del cliente para mostrar en la lista|
|paso_actual|INTEGER|Numero del ultimo paso completado (1-4)|
|datos_json|TEXT|Todos los campos del formulario serializados en JSON|
|monto_solicitado|REAL|Monto para mostrar en la lista de borradores|
|asesor_id|TEXT|ID del asesor propietario del borrador|
|updated_at|INTEGER|Marca de tiempo de la ultima edicion|



## Tabla local SQLite: visitas_pendientes (cola offline) 

|**Campo**|**Tipo**|**Descripcion**|
|---|---|---|
|id|TEXT (PK)|UUID generado localmente|
|cartero_id|TEXT|ID del registro en cartera_diaria|
|resultado|TEXT|Resultado de la visita|
|observacion|TEXT|Observacion del asesor|
|timestamp_visita|TEXT|Marca de tiempo ISO 8601|
|lat|REAL|Latitud de la visita|
|lng|REAL|Longitud de la visita|
|pendiente_sync|INTEGER|1 = pendiente, 0 = sincronizado|



## Arquitectura MVVM en Flutter 

Flujo 4 — Arquitectura MVVM en Flutter 

39 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

**==> picture [512 x 193] intentionally omitted <==**

**----- Start of picture text -----**<br>
Repository<br>si hay red SupabaseRemoto resultado<br>Red<br>disponible?<br>sin red SQLite<br>guarda cache Local<br>ViewModel — StateNotifier resultado<br>Metodospublicos solicita datos inmutableEstado<br>Vista — Widgets<br>Screen evento usuario nuevo estado ref.watch<br>ConsumerWidget re-renderiza provider<br>**----- End of picture text -----**<br>


## Principio fundamental 

El patron MVVM (Modelo - Vista - ViewModel) separa tres responsabilidades: 

- **Modelo (Model):** los datos y la logica de negocio. Incluye las entidades del dominio, los repositorios y las fuentes de datos (Supabase y SQLite local). 

- **Vista (View):** los Widgets de Flutter que el usuario ve e interactua. No contienen logica de negocio; solo renderizan el estado que reciben y emiten eventos al ViewModel. 

- **ViewModel:** el intermediario. Recibe eventos de la Vista, ejecuta la logica de negocio a traves del Repositorio, y expone el estado resultante para que la Vista lo renderice. 

## Estructura de capas 

```
Vista (Widgets)
     |  observa estado
     v
ViewModel (StateNotifier con Riverpod)
     |  solicita datos
     v
Repositorio
     |             |
     v             v
Supabase     SQLite local
(Remoto)     (Offline)
```

La Vista nunca accede directamente a Supabase ni a SQLite. El Repositorio decide si usar la fuente remota o el cache local segun la disponibilidad de red. 

## Estructura de carpetas del proyecto Flutter 

```
lib/
├── main.dart
├── app/
│   ├── app.dart                      # MaterialApp y configuracion global
```

40 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

```
│   └── router.dart                   # GoRouter con rutas nombradas
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Paleta de colores de la entidad
│   │   └── app_strings.dart          # Textos y etiquetas
│   ├── network/
│   │   └── network_monitor.dart      # Stream de conectividad
│   ├── storage/
│   │   └── local_db.dart             # Inicializacion y migraciones de SQLite
│   └── supabase/
│       └── supabase_client.dart      # Instancia unica de SupabaseClient
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_remote_datasource.dart
│   │   ├── domain/
│   │   │   └── asesor_model.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── login_viewmodel.dart
│   │
│   ├── cartera/
│   │   ├── data/
│   │   │   ├── cartera_repository.dart
│   │   │   ├── cartera_remote_datasource.dart
│   │   │   └── cartera_local_datasource.dart    # SQLite
│   │   ├── domain/
│   │   │   └── cartera_model.dart
│   │   └── presentation/
│   │       ├── cartera_screen.dart
│   │       └── cartera_viewmodel.dart
│   │
│   ├── ruta/
│   │   ├── data/
│   │   │   └── ruta_repository.dart
│   │   └── presentation/
│   │       ├── ruta_screen.dart
│   │       └── ruta_viewmodel.dart
│   │
│   ├── ficha_cliente/
│   │   ├── data/
│   │   │   └── ficha_repository.dart
│   │   └── presentation/
│   │       ├── ficha_screen.dart
│   │       └── ficha_viewmodel.dart
│   │
│   ├── solicitud/
│   │   ├── data/
│   │   │   ├── solicitud_repository.dart
│   │   │   └── solicitud_local_datasource.dart  # Borradores offline
│   │   ├── domain/
```

41 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

```
│   │   │   └── solicitud_model.dart
│   │   └── presentation/
│   │       ├── solicitud_screen.dart             # Stepper de 4 pasos
│   │       └── solicitud_viewmodel.dart
│   │
│   ├── documentos/
│   │   └── presentation/
│   │       ├── documentos_screen.dart
│   │       └── documentos_viewmodel.dart
│   │
│   ├── buro/
│   │   └── presentation/
│   │       ├── buro_screen.dart
│   │       └── buro_viewmodel.dart
│   │
│   ├── estado_solicitudes/
│   │   └── presentation/
│   │       ├── estado_screen.dart
│   │       └── estado_viewmodel.dart
│   │
│   ├── cobranza/
│   │   └── presentation/
│   │       ├── cobranza_screen.dart
│   │       └── cobranza_viewmodel.dart
│   │
│   └── reportes/
│       └── presentation/
│           ├── reportes_screen.dart
│           └── reportes_viewmodel.dart
│
└── shared/
    ├── widgets/
    │   ├── cliente_card.dart
    │   ├── badge_tipo_gestion.dart
    │   ├── semaforo_riesgo.dart
    │   ├── signature_pad.dart
    │   ├── stepper_solicitud.dart
    │   └── documento_checklist.dart
    └── utils/
        ├── formatters.dart           # Formato de moneda, fechas, DNI censurado
        └── validators.dart           # Validaciones de formularios
```

## Responsabilidades de cada capa 

## **Capa de datos (data/)** 

El `DataSource` remoto interactua con Supabase: consultas, inserciones y suscripciones Realtime. El `DataSource` local interactua con SQLite: lectura de cache, escritura de cola offline y consultas de borradores. El `Repository` decide cual fuente usar segun el estado de red, expone una interfaz unica al ViewModel y maneja los errores de red de forma transparente. 

42 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

## **Capa de dominio (domain/)** 

Contiene los modelos de datos puros (clases Dart simples, sin dependencias de frameworks). Son las entidades que viajan entre capas: `CarteraItem` , `SolicitudModel` , `ClienteModel` , etc. Cada modelo incluye un constructor `fromJson` para deserializar desde Supabase y un metodo `toMap` para guardar en SQLite. 

## **Capa de presentacion (presentation/)** 

Cada modulo tiene exactamente un ViewModel y una o mas Screens. El ViewModel extiende `StateNotifier<Estado>` de Riverpod. El Estado es una clase inmutable con todos los valores que la pantalla necesita para renderizarse. La Screen usa `ConsumerWidget` o `ConsumerStatefulWidget` y llama a `ref.watch(viewModelProvider)` para observar el estado. 

## Dependencias principales (pubspec.yaml) 

|**Paquete**|**Version**|**Proposito**|
|---|---|---|
|flutter_riverpod|^2.5.1|Gestion de estado (ViewModel como StateNotifier)|
|riverpod_annotation|^2.3.5|Generacion de providers|
|supabase_flutter|^2.5.0|Auth, base de datos, Storage y Realtime|
|sqflite|^2.3.3|Base de datos local SQLite para modo offline|
|path|^1.9.0|Manejo de rutas de archivos|
|go_router|^14.0.0|Navegacion declarativa con rutas nombradas|
|google_maps_flutter|^2.9.0|Mapa interactivo con marcadores y polilineas|
|geolocator|^12.0.0|Ubicacion GPS del dispositivo|
|geocoding|^3.0.0|Geocodificacion inversa de coordenadas|
|camera|^0.11.0|Captura de fotos para documentos|
|image_picker|^1.1.2|Seleccion de imagenes desde la galeria|
|image|^4.2.0|Compresion y analisis de nitidez de imagenes|
|fl_chart|^0.68.0|Graficos de barras para comportamiento de pagos|
|flutter_local_notifications|^17.2.2|Notificaciones locales del dispositivo|
|firebase_messaging|^15.1.3|Notificaciones push remotas via FCM|
|signature|^5.4.1|Lienzo tactil para firma digital del cliente|
|pdf|^3.11.1|Generacion de documentos PDF|
|printing|^5.13.2|Compartir y exportar documentos PDF|
|intl|^0.19.0|Formato de fechas y numeros|
|connectivity_plus|^6.0.5|Deteccion del estado de la red|



43 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**Paquete**|**Version**|**Proposito**|
|---|---|---|
|workmanager|^0.5.2|Tareas programadas en background|
|flutter_secure_storage|^9.2.2|Almacenamiento seguro del token JWT|



## Flujo de datos offline-first 

El patron de cada operacion de lectura sigue este orden: 

1. El ViewModel solicita datos al Repositorio. 

2. El Repositorio verifica si hay conexion de red activa. 

3. Si hay red: consulta Supabase, guarda el resultado en SQLite como cache y devuelve los datos. 

4. Si no hay red: lee directamente del cache SQLite y devuelve los datos disponibles con una nota de que son datos offline. 

5. El ViewModel actualiza el estado con los datos recibidos. 

6. La Vista se re-renderiza automaticamente al cambiar el estado. 

Para operaciones de escritura sin conexion: 

1. El ViewModel envia la operacion al Repositorio. 

2. El Repositorio detecta ausencia de red. 

3. Guarda la operacion en la tabla de cola offline con `pendiente_sync = true` . 

4. El ViewModel actualiza el estado de la UI con el nuevo dato local. 

5. El monitor de red detecta la reconexion. 

6. El Repositorio lee todas las filas con `pendiente_sync = true` y las envia a Supabase. 

7. Marca cada fila como sincronizada al completar exitosamente. 

## Politicas de seguridad de filas (RLS) en Supabase 

Cada tabla en Supabase tiene habilitadas las politicas de seguridad de filas. Los asesores solo pueden leer y escribir filas donde `asesor_id` coincide con su propio identificador. Los supervisores pueden leer todas las filas de su agencia. Los administradores tienen acceso completo a su institucion. Ninguna operacion desde la app movil puede acceder a datos de otra agencia o institucion. 

## Rubrica de evaluacion — App Fuerza de Ventas 

|**N**|**Criterio**|**Descripcion**|**Puntos**|
|---|---|---|---|
|1|Autenticacion y|Login con Supabase Auth. Perfiles diferenciados. Sesion persistente.||
||perfiles|Logout con borrado de cache.||
|2|Cartera diaria|Lista con tipos de gestion y prioridad. Filtros funcionales. Contador||
|||de avance. Datos offline disponibles.||
|3|Planificacion de|Mapa con marcadores de prioridad. Optimizacion de ruta. Apertura||
||ruta|de app de navegacion externa.||



44 / 45 

HU_AppFuerzaVentas_v3.md 

2026-05-26 

|**N**|**Criterio**|**Descripcion**|**Puntos**|
|---|---|---|---|
|4|Ficha del cliente|Datos completos. Historial crediticio. Grafico de comportamiento.||
|||Oferta preaprobada. Semaforo SBS.||
|5|Formulario de|Cuatro pasos con validacion por campo. Simulador en tiempo real||
||solicitud|con formula correcta. Firma digital. Borradores offline.||
|6|Captura de|Camara con marco guia. Validacion de nitidez. Compresion||
||documentos|automatica. Subida a Storage. Checklist de documentos.||
|7|Consulta de buro|Consentimiento firmado previo. Edge Function mock. Resultado con||
|||semaforo SBS. Historial de consultas.||
|8|Transmision|Validacion previa completa. Pantalla de progreso por pasos.||
||electronica|Reanudacion si falla. Numero de expediente.||
|9|Estado de|Pestanas por estado. Actualizacion Realtime. Linea de tiempo del||
||solicitudes|proceso. Generacion de PDF.||
|10|Recuperacion de|Lista de mora con semaforo. Formulario de accion de cobranza con||
||mora|GPS. Alerta de compromiso programada.||
|11|Modo offline|App funciona sin red. Cola de pendientes visible. Sincronizacion||
|||automatica al reconectar. Banner de estado offline.||
|12|Arquitectura|ViewModel con StateNotifier. Repository separado de la Vista. Sin||
||MVVM|logica de negocio en los Widgets. Providers de Riverpod correctos.||
|13|Branding de la|Logo, colores y nombre de la institucion asignada aplicados||
||entidad|consistentemente en toda la app.||



_Documento generado por Mg. Guillermo E. Pena Garcia — 2026_ 

45 / 45 

