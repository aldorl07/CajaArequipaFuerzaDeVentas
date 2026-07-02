ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

## 30 Casos para practicar — Crédito Empresarial (flujo de originación móvil) 

## Ecosistema y alcance 

Cada caso representa **una operación de crédito empresarial (Microempresa)** que recorre el flujo completo del ecosistema Banco Andino, de extremo a extremo: 

```
App Clientes (Flutter)  ──►  Core / API REST  ──►  App Fuerza de Ventas (Flutter)
──►  Comité  ──►  Desembolso
   (la solicitud)            (FastAPI · 8003)          (visita y evaluación en
campo)
                                   │
                                   ▼
                         Base de datos bd_core_mobile (PostgreSQL)
                                   │  (sync_outbox)
                                   ▼
                         Núcleo bd_core_financiero
```

El estudiante actúa en **dos roles** sobre el mismo expediente: primero como **cliente** que registra la solicitud desde su app, y luego como **asesor de negocios** que la recibe en su cartera, la evalúa en campo y la lleva hasta el desembolso. 

## Tarifario aplicado 

Crédito Empresarial — Microempresa. TEA **40.92 %** (con seguro de desgravamen) o **43.92 %** (sin seguro de desgravamen). Todas las cuotas son iguales (cuota fija, amortización francesa). La cuota se calcula con la tasa efectiva mensual TEM = (1 + TEA)^(1/12) − 1. 

## Flujo que debe seguir el estudiante en cada caso 

1. **App Clientes — registrar la solicitud.** Inicia sesión como cliente (documento + clave) y registra la solicitud de crédito con los datos del caso (monto, plazo, destino, garantía). El canal de la solicitud queda como `cliente` y nace en estado `enviado` . El sistema devuelve un número de expediente. 

2. **Core — recepción.** La solicitud llega al core y se encola para promoverse al núcleo; queda visible para la agencia y se asigna al asesor responsable. 

3. **App Fuerza de Ventas — cartera del día.** Inicia sesión como asesor (código de empleado + clave). La solicitud aparece en la cartera del día con tipo de gestión `NUEVA_SOLICITUD` . Ubica al cliente y abre su ficha. 

4. **Visita en campo.** Registra el resultado de la visita ( `visitado` ), con la observación y las coordenadas del negocio del caso. 

5. **Pre-evaluación y buró.** Ejecuta la pre-evaluación por capacidad de pago y la consulta de buró y listas. Verifica que el resultado coincida con el esperado del caso. 

6. **Documentos y firma.** Adjunta los documentos indicados (documento de identidad por ambos lados, sustento del negocio, foto del negocio y de la visita) y captura la firma del cliente. 

1 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

7. **Envío al core y comité.** Promueve la solicitud al núcleo. El expediente avanza por los estados `recibido_comite` → `en_evaluacion` → decisión. 

8. **Decisión y desembolso.** Según la decisión del comité del caso: si es aprobado (o condicionado), registra el desembolso y genera el **cronograma de pagos** ; si es rechazado, registra el motivo y cierra el expediente. 

Estados del expediente: `borrador` → `enviado` → `recibido_comite` → `en_evaluacion` → `aprobado` / `condicionado` / `rechazado` → `desembolsado` . 

Nota sobre el buró simulado: la calificación depende del último dígito del documento del cliente, por lo que cada caso produce un perfil de buró determinista. Un cliente en lista de inhabilitados **bloquea** la solicitud en el paso 5. 

## Caso 1 

**Solicitante (rol cliente).** Anaximandro Quispe · Documento 40118120 · Teléfono 964110201. Negocio: Bodega «Bodega Don Anaxi», en El Tambo, 48 meses de antigüedad. Ingreso mensual estimado S/ 2,200.00; gasto mensual S/ 900.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 1,000.00; plazo 12 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Capital de trabajo: compra de mercaderia. Cuota de referencia mostrada al cliente: S/ 100.95. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad normal. Visita: resultado `visitado` ; ubicación del negocio lat -12.0581, lng -75.2027. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 4,500.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 1,000.00. 

**Desembolso** el 02/02/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 100.95** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/03/2026|100.95|70.14|30.81|929.86|
|2|03/04/2026|100.95|72.31|28.64|857.55|
|3|03/05/2026|100.95|74.53|26.42|783.02|
|…|…|…|…|…|…|
|12|03/02/2027|100.95|97.87|3.01|0.00|



Caso 2 

2 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitante (rol cliente).** Eulalia Mamani · Documento 41223341 · Teléfono 964110202. Negocio: Restaurante «Picanteria La Eulalia», en Chilca, 36 meses de antigüedad. Ingreso mensual estimado S/ 3,000.00; gasto mensual S/ 1,400.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 3,000.00; plazo 12 meses; TEA 40.92 % (con seguro de desgravamen); garantía: sin garantia; destino: Compra de cocina industrial. Cuota de referencia mostrada al cliente: S/ 299.59. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0921, lng -75.2105. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 3,000.00. 

**Desembolso** el 05/02/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 299.59** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/03/2026|299.59|212.60|86.99|2,787.40|
|2|05/04/2026|299.59|218.76|80.83|2,568.64|
|3|05/05/2026|299.59|225.11|74.48|2,343.53|
|…|…|…|…|…|…|
|12|05/02/2027|299.59|291.10|8.44|0.00|



## Caso 3 

**Solicitante (rol cliente).** Teofilo Huaman · Documento 42330336 · Teléfono 964110203. Negocio: Carpinteria «Maderas Huaman», en Pilcomayo, 60 meses de antigüedad. Ingreso mensual estimado S/ 4,200.00; gasto mensual S/ 1,800.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 5,000.00; plazo 18 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Maquinaria: sierra y cepillo. Cuota de referencia mostrada al cliente: S/ 366.02. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0496, lng -75.2486. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 5,000.00. 

**Desembolso** el 10/02/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

3 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Cuota mensual: S/ 366.02** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/03/2026|366.02|211.99|154.03|4,788.01|
|2|10/04/2026|366.02|218.52|147.50|4,569.49|
|3|10/05/2026|366.02|225.25|140.77|4,344.24|
|…|…|…|…|…|…|
|18|10/08/2027|366.02|355.18|10.94|0.00|



## Caso 4 

**Solicitante (rol cliente).** Casandra Flores · Documento 43440349 · Teléfono 964110204. Negocio: Abarrotes «Distribuidora Casandra», en Huancayo, 84 meses de antigüedad. Ingreso mensual estimado S/ 7,000.00; gasto mensual S/ 2,600.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 8,000.00; plazo 6 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Reposicion de stock por campana. Cuota de referencia mostrada al cliente: S/ 1,480.73. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0651, lng -75.2049. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 14,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 8,000.00. 

**Desembolso** el 15/02/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,480.73** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/03/2026|1,480.73|1,234.29|246.44|6,765.71|
|2|15/04/2026|1,480.73|1,272.31|208.42|5,493.40|
|3|15/05/2026|1,480.73|1,311.50|169.23|4,181.90|
|…|…|…|…|…|…|
|6|15/08/2026|1,480.73|1,436.45|44.25|0.00|



## Caso 5 

**Solicitante (rol cliente).** Demostenes Rojas · Documento 40556071 · Teléfono 964110205. Negocio: Ferreteria «Ferreteria El Constructor», en San Agustin de Cajas, 30 meses de antigüedad. Ingreso mensual estimado S/ 

4 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

5,200.00; gasto mensual S/ 2,100.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 10,000.00; plazo 12 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Ampliacion de local. Cuota de referencia mostrada al cliente: S/ 1,009.46. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0188, lng -75.2271. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 10,000.00. 

**Desembolso** el 01/03/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,009.46** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/04/2026|1,009.46|701.40|308.06|9,298.60|
|2|03/05/2026|1,009.46|723.01|286.45|8,575.59|
|3|03/06/2026|1,009.46|745.28|264.18|7,830.31|
|…|…|…|…|…|…|
|12|03/03/2027|1,009.46|979.29|30.17|0.00|



## Caso 6 

**Solicitante (rol cliente).** Hipatia Condori · Documento 41669066 · Teléfono 964110206. Negocio: Textil «Confecciones Hipatia», en El Tambo, 54 meses de antigüedad. Ingreso mensual estimado S/ 6,800.00; gasto mensual S/ 2,900.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 12,000.00; plazo 24 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Compra de maquinas remalladoras. Cuota de referencia mostrada al cliente: S/ 700.94. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0612, lng -75.2118. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 12,000.00. 

**Desembolso** el 05/03/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 700.94** · Cronograma final (las cuotas son iguales): 

5 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/04/2026|700.94|352.97|347.97|11,647.03|
|2|05/05/2026|700.94|363.20|337.74|11,283.83|
|3|05/06/2026|700.94|373.74|327.20|10,910.09|
|…|…|…|…|…|…|
|24|05/03/2028|700.94|681.16|19.75|0.00|



## Caso 7 

**Solicitante (rol cliente).** Anibal Vargas · Documento 43773379 · Teléfono 964110207. Negocio: Transporte «Transportes Anibal», en Concepcion, 42 meses de antigüedad. Ingreso mensual estimado S/ 9,500.00; gasto mensual S/ 4,200.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 15,000.00; plazo 18 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: vehicular; destino: Cuota inicial de vehiculo de carga. Cuota de referencia mostrada al cliente: S/ 1,098.07. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.9182, lng -75.3142. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 14,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 15,000.00. 

**Desembolso** el 10/03/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,098.07** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/04/2026|1,098.07|635.99|462.08|14,364.01|
|2|10/05/2026|1,098.07|655.58|442.49|13,708.43|
|3|10/06/2026|1,098.07|675.77|422.30|13,032.66|
|…|…|…|…|…|…|
|18|10/09/2027|1,098.07|1,065.30|32.82|0.00|



## Caso 8 

**Solicitante (rol cliente).** Penelope Apaza · Documento 40886086 · Teléfono 964110208. Negocio: Avicola «Granja Penelope», en Sapallanga, 72 meses de antigüedad. Ingreso mensual estimado S/ 8,800.00; gasto mensual S/ 3,600.00. 

6 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 18,000.00; plazo 24 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Ampliacion de galpon. Cuota de referencia mostrada al cliente: S/ 1,072.10. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.1581, lng -75.1762. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 18,000.00. 

**Desembolso** el 15/03/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,072.10** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/04/2026|1,072.10|517.60|554.50|17,482.40|
|2|15/05/2026|1,072.10|533.54|538.56|16,948.86|
|3|15/06/2026|1,072.10|549.98|522.12|16,398.88|
|…|…|…|…|…|…|
|24|15/03/2028|1,072.10|1,039.97|32.04|0.00|



## Caso 9 

**Solicitante (rol cliente).** Heraclito Ccahua · Documento 41990091 · Teléfono 964110209. Negocio: Comercio «Importaciones Heraclito», en Huancayo, 96 meses de antigüedad. Ingreso mensual estimado S/ 12,000.00; gasto mensual S/ 5,000.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 20,000.00; plazo 36 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Capital para nueva sucursal. Cuota de referencia mostrada al cliente: S/ 927.12. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0668, lng -75.2103. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 20,000.00. 

**Desembolso** el 02/04/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 927.12** · Cronograma final (las cuotas son iguales): 

7 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/05/2026|927.12|311.01|616.11|19,688.99|
|2|03/06/2026|927.12|320.59|606.53|19,368.40|
|3|03/07/2026|927.12|330.47|596.65|19,037.93|
|…|…|…|…|…|…|
|36|03/04/2029|927.12|899.39|27.71|0.00|



## Caso 10 

**Solicitante (rol cliente).** Cleopatra Soto · Documento 43003039 · Teléfono 964110210. Negocio: Farmacia «Botica Cleopatra», en Chupaca, 66 meses de antigüedad. Ingreso mensual estimado S/ 11,000.00; gasto mensual S/ 4,400.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 25,000.00; plazo 24 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Equipamiento y stock farmaceutico. Cuota de referencia mostrada al cliente: S/ 1,460.29. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.056, lng -75.287. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 14,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 25,000.00. 

**Desembolso** el 05/04/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,460.29** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/05/2026|1,460.29|735.35|724.94|24,264.65|
|2|05/06/2026|1,460.29|756.67|703.62|23,507.98|
|3|05/07/2026|1,460.29|778.61|681.68|22,729.37|
|…|…|…|…|…|…|
|24|05/04/2028|1,460.29|1,419.24|41.15|0.00|



## Caso 11 

**Solicitante (rol cliente).** Esquilo Ramos · Documento 40110010 · Teléfono 964110211. Negocio: Bodega «Minimarket Esquilo», en Huayucachi, 24 meses de antigüedad. Ingreso mensual estimado S/ 1,900.00; gasto mensual S/ 800.00. 

8 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 2,000.00; plazo 12 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Compra de congeladora. Cuota de referencia mostrada al cliente: S/ 201.89. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad normal. Visita: resultado `visitado` ; ubicación del negocio lat -12.1339, lng -75.209. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 4,500.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 2,000.00. 

**Desembolso** el 10/04/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 201.89** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/05/2026|201.89|140.28|61.61|1,859.72|
|2|10/06/2026|201.89|144.60|57.29|1,715.12|
|3|10/07/2026|201.89|149.05|52.84|1,566.07|
|…|…|…|…|…|…|
|12|10/04/2027|201.89|195.88|6.03|0.00|



## Caso 12 

**Solicitante (rol cliente).** Ariadna Quispe · Documento 41226021 · Teléfono 964110212. Negocio: Peluqueria «Estilos Ariadna», en El Tambo, 40 meses de antigüedad. Ingreso mensual estimado S/ 3,300.00; gasto mensual S/ 1,300.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 4,000.00; plazo 18 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Mobiliario y equipos de salon. Cuota de referencia mostrada al cliente: S/ 292.82. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0573, lng -75.2161. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 4,000.00. 

**Desembolso** el 15/04/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 292.82** · Cronograma final (las cuotas son iguales): 

9 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/05/2026|292.82|169.60|123.22|3,830.40|
|2|15/06/2026|292.82|174.82|118.00|3,655.58|
|3|15/07/2026|292.82|180.21|112.61|3,475.37|
|…|…|…|…|…|…|
|18|15/10/2027|292.82|284.07|8.75|0.00|



## Caso 13 

**Solicitante (rol cliente).** Sofocles Huanca · Documento 43336033 · Teléfono 964110213. Negocio: Panaderia «Panaderia Sofocles», en Sicaya, 58 meses de antigüedad. Ingreso mensual estimado S/ 5,600.00; gasto mensual S/ 2,300.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 6,000.00; plazo 12 meses; TEA 40.92 % (con seguro de desgravamen); garantía: sin garantia; destino: Horno rotativo. Cuota de referencia mostrada al cliente: S/ 599.17. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0228, lng -75.3134. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 0 entidad(es) con deuda, deuda total S/ 0.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 6,000.00. 

**Desembolso** el 02/05/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 599.17** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/06/2026|599.17|425.18|173.99|5,574.82|
|2|03/07/2026|599.17|437.51|161.66|5,137.31|
|3|03/08/2026|599.17|450.20|148.97|4,687.11|
|…|…|…|…|…|…|
|12|03/05/2027|599.17|582.33|16.89|0.00|



## Caso 14 

**Solicitante (rol cliente).** Casiopea Torres · Documento 40550055 · Teléfono 964110214. Negocio: Mecanica «Taller Casiopea», en Pilcomayo, 50 meses de antigüedad. Ingreso mensual estimado S/ 7,400.00; gasto mensual S/ 3,000.00. 

10 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 7,500.00; plazo 6 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Herramienta neumatica. Cuota de referencia mostrada al cliente: S/ 1,388.18. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0512, lng -75.2451. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** DEFICIENTE, 2 entidad(es) con deuda, deuda total S/ 16,000.00, 45 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 7,500.00. 

**Desembolso** el 05/05/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,388.18** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/06/2026|1,388.18|1,157.14|231.04|6,342.86|
|2|05/07/2026|1,388.18|1,192.78|195.40|5,150.08|
|3|05/08/2026|1,388.18|1,229.53|158.65|3,920.55|
|…|…|…|…|…|…|
|6|05/11/2026|1,388.18|1,346.69|41.49|0.00|



## Caso 15 

**Solicitante (rol cliente).** Aristofanes Cruz · Documento 41669166 · Teléfono 964110215. Negocio: Agropecuario «Insumos Aristofanes», en Orcotuna, 78 meses de antigüedad. Ingreso mensual estimado S/ 8,200.00; gasto mensual S/ 3,300.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 9,000.00; plazo 24 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Capital para campana agricola. Cuota de referencia mostrada al cliente: S/ 536.05. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.976, lng -75.3361. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 9,000.00. 

**Desembolso** el 10/05/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 536.05** · Cronograma final (las cuotas son iguales): 

11 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/06/2026|536.05|258.80|277.25|8,741.20|
|2|10/07/2026|536.05|266.77|269.28|8,474.43|
|3|10/08/2026|536.05|274.99|261.06|8,199.44|
|…|…|…|…|…|…|
|24|10/05/2028|536.05|520.02|16.02|0.00|



## Caso 16 

**Solicitante (rol cliente).** Calipso Mendoza · Documento 43880088 · Teléfono 964110216. Negocio: Calzado «Calzados Calipso», en Huancayo, 62 meses de antigüedad. Ingreso mensual estimado S/ 7,900.00; gasto mensual S/ 3,100.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 11,000.00; plazo 18 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Compra de cuero y maquinaria. Cuota de referencia mostrada al cliente: S/ 793.03. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0689, lng -75.2055. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** CPP, 1 entidad(es) con deuda, deuda total S/ 9,000.00, 20 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 11,000.00. 

**Desembolso** el 15/05/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 793.03** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/06/2026|793.03|474.06|318.97|10,525.94|
|2|15/07/2026|793.03|487.80|305.23|10,038.14|
|3|15/08/2026|793.03|501.95|291.08|9,536.19|
|…|…|…|…|…|…|
|18|15/11/2027|793.03|770.76|22.35|0.00|



## Caso 17 

**Solicitante (rol cliente).** Demetrio Quispe · Documento 40119019 · Teléfono 964110217. Negocio: Comercio «Mayorista Demetrio», en Jauja, 90 meses de antigüedad. Ingreso mensual estimado S/ 11,500.00; gasto mensual S/ 4,700.00. 

12 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 13,500.00; plazo 12 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Reposicion de inventario mayorista. Cuota de referencia mostrada al cliente: S/ 1,362.77. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.7752, lng -75.4995. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 14,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 13,500.00. 

**Desembolso** el 02/06/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,362.77** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/07/2026|1,362.77|946.89|415.88|12,553.11|
|2|03/08/2026|1,362.77|976.06|386.71|11,577.05|
|3|03/09/2026|1,362.77|1,006.13|356.64|10,570.92|
|…|…|…|…|…|…|
|12|03/06/2027|1,362.77|1,322.02|40.73|0.00|



## Caso 18 

**Solicitante (rol cliente).** Antigona Flores · Documento 41226126 · Teléfono 964110218. Negocio: Restaurante «Recreo Antigona», en Concepcion, 70 meses de antigüedad. Ingreso mensual estimado S/ 9,200.00; gasto mensual S/ 3,900.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto 

solicitado S/ 16,000.00; plazo 36 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Ampliacion y remodelacion. Cuota de referencia mostrada al cliente: S/ 741.70. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.9201, lng -75.311. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 16,000.00. 

**Desembolso** el 05/06/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 741.70** · Cronograma final (las cuotas son iguales): 

13 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/07/2026|741.70|248.81|492.89|15,751.19|
|2|05/08/2026|741.70|256.48|485.22|15,494.71|
|3|05/09/2026|741.70|264.38|477.32|15,230.33|
|…|…|…|…|…|…|
|36|05/06/2029|741.70|719.29|22.16|0.00|



## Caso 19 

**Solicitante (rol cliente).** Pitagoras Rojas · Documento 43339033 · Teléfono 964110219. Negocio: Ferreteria «Ferreteria Pitagoras», en El Tambo, 100 meses de antigüedad. Ingreso mensual estimado S/ 13,000.00; gasto mensual S/ 5,200.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 17,000.00; plazo 24 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Compra de stock estructural. Cuota de referencia mostrada al cliente: S/ 993.00. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0599, lng -75.2143. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 0 entidad(es) con deuda, deuda total S/ 0.00, 0 día(s) de mayor mora. 

**Decisión del comité: APROBADO.** Monto aprobado S/ 17,000.00. 

**Desembolso** el 10/06/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 993.00** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/07/2026|993.00|500.04|492.96|16,499.96|
|2|10/08/2026|993.00|514.54|478.46|15,985.42|
|3|10/09/2026|993.00|529.46|463.54|15,455.96|
|…|…|…|…|…|…|
|24|10/06/2028|993.00|964.96|27.98|0.00|



## Caso 20 

**Solicitante (rol cliente).** Berenice Apaza · Documento 40556056 · Teléfono 964110220. Negocio: Textil «Tejidos Berenice», en San Jeronimo de Tunan, 46 meses de antigüedad. Ingreso mensual estimado S/ 8,600.00; gasto mensual S/ 3,500.00. 

14 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto 

solicitado S/ 19,000.00; plazo 18 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Maquinaria de tejido plano. Cuota de referencia mostrada al cliente: S/ 1,390.89. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.9871, lng -75.2899. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 19,000.00. 

**Desembolso** el 15/06/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,390.89** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/07/2026|1,390.89|805.58|585.31|18,194.42|
|2|15/08/2026|1,390.89|830.40|560.49|17,364.02|
|3|15/09/2026|1,390.89|855.98|534.91|16,508.04|
|…|…|…|…|…|…|
|18|15/12/2027|1,390.89|1,349.36|41.57|0.00|



## Caso 21 

**Solicitante (rol cliente).** Anaxagoras Huaman · Documento 43889089 · Teléfono 964110221. Negocio: Transporte «Carga Anaxagoras», en Huancayo, 84 meses de antigüedad. Ingreso mensual estimado S/ 14,000.00; gasto mensual S/ 5,800.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto 

solicitado S/ 22,000.00; plazo 36 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: vehicular; destino: Cuota inicial de camion. Cuota de referencia mostrada al cliente: S/ 1,019.83. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0644, lng -75.2088. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 14,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 22,000.00. 

**Desembolso** el 02/07/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,019.83** · Cronograma final (las cuotas son iguales): 

15 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/08/2026|1,019.83|342.11|677.72|21,657.89|
|2|03/09/2026|1,019.83|352.65|667.18|21,305.24|
|3|03/10/2026|1,019.83|363.51|656.32|20,941.73|
|…|…|…|…|…|…|
|36|03/07/2029|1,019.83|989.49|30.48|0.00|



## Caso 22 

**Solicitante (rol cliente).** Climene Vargas · Documento 41003001 · Teléfono 964110222. Negocio: Avicola «Avicola Climene», en Sapallanga, 76 meses de antigüedad. Ingreso mensual estimado S/ 13,500.00; gasto mensual S/ 5,500.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 24,000.00; plazo 24 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Equipamiento de planta. Cuota de referencia mostrada al cliente: S/ 1,401.88. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.156, lng -75.179. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 24,000.00. 

**Desembolso** el 05/07/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 1,401.88** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/08/2026|1,401.88|705.94|695.94|23,294.06|
|2|05/09/2026|1,401.88|726.41|675.47|22,567.65|
|3|05/10/2026|1,401.88|747.47|654.41|21,820.18|
|…|…|…|…|…|…|
|24|05/07/2028|1,401.88|1,362.36|39.51|0.00|



## Caso 23 

**Solicitante (rol cliente).** Epaminondas Soto · Documento 40115011 · Teléfono 964110223. Negocio: Bodega «Bodega Epaminondas», en Pucara, 28 meses de antigüedad. Ingreso mensual estimado S/ 2,600.00; gasto mensual S/ 1,000.00. 

16 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 1,500.00; plazo 6 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Compra de vitrinas. Cuota de referencia mostrada al cliente: S/ 277.64. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad normal. Visita: resultado `visitado` ; ubicación del negocio lat -12.1701, lng -75.1611. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 2 entidad(es) con deuda, deuda total S/ 12,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 1,500.00. 

**Desembolso** el 10/07/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 277.64** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/08/2026|277.64|231.43|46.21|1,268.57|
|2|10/09/2026|277.64|238.56|39.08|1,030.01|
|3|10/10/2026|277.64|245.91|31.73|784.10|
|…|…|…|…|…|…|
|6|10/01/2027|277.64|269.32|8.30|0.00|



## Caso 24 

**Solicitante (rol cliente).** Lisistrata Ramos · Documento 41336036 · Teléfono 964110224. Negocio: Comercio «Variedades Lisistrata», en Huancayo, 52 meses de antigüedad. Ingreso mensual estimado S/ 4,100.00; gasto mensual S/ 1,700.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 3,500.00; plazo 12 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Capital de trabajo. Cuota de referencia mostrada al cliente: S/ 353.31. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0633, lng -75.2071. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** NORMAL, 1 entidad(es) con deuda, deuda total S/ 6,000.00, 0 día(s) de mayor mora. 

## **Decisión del comité: APROBADO.** Monto aprobado S/ 3,500.00. 

**Desembolso** el 15/07/2026; cuotas a pagar el día 15 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 353.31** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|15/08/2026|353.31|245.49|107.82|3,254.51|



17 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|2|15/09/2026|353.31|253.05|100.26|3,001.46|
|3|15/10/2026|353.31|260.85|92.46|2,740.61|
|…|…|…|…|…|…|
|12|15/07/2027|353.31|342.75|10.56|0.00|



## Caso 25 

**Solicitante (rol cliente).** Filoctetes Cruz · Documento 41552052 · Teléfono 964110225. Negocio: Restaurante «Cevicheria Filoctetes», en Chilca, 18 meses de antigüedad. Ingreso mensual estimado S/ 3,800.00; gasto mensual S/ 2,200.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 11,000.00; plazo 18 meses; TEA 40.92 % (con seguro de desgravamen); garantía: sin garantia; destino: Ampliacion de local nuevo. Cuota de referencia mostrada al cliente: S/ 793.03. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.093, lng -75.209. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** CPP, 2 entidad(es) con deuda, deuda total S/ 18,000.00, 15 día(s) de mayor mora. 

**Decisión del comité: CONDICIONADO.** Antiguedad del negocio menor a 24 meses y carga de gastos alta: el comite aprueba un monto menor. Monto aprobado: **S/ 7,000.00** (sobre el plazo y la TEA solicitados). 

**Desembolso** el 02/08/2026; cuotas a pagar el día 03 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 504.66** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|03/09/2026|504.66|301.68|202.98|6,698.32|
|2|03/10/2026|504.66|310.42|194.24|6,387.90|
|3|03/11/2026|504.66|319.43|185.23|6,068.47|
|…|…|…|…|…|…|
|18|03/02/2028|504.66|490.37|14.22|0.00|



## Caso 26 

**Solicitante (rol cliente).** Calirroe Mendoza · Documento 41888088 · Teléfono 964110226. Negocio: Calzado «Calzados Calirroe», en El Tambo, 34 meses de antigüedad. Ingreso mensual estimado S/ 5,000.00; gasto mensual S/ 2,600.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 16,000.00; plazo 24 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; 

18 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

destino: Maquinaria de mayor capacidad. Cuota de referencia mostrada al cliente: S/ 952.98. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0588, lng -75.2129. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** CPP, 1 entidad(es) con deuda, deuda total S/ 9,000.00, 20 día(s) de mayor mora. 

**Decisión del comité: CONDICIONADO.** Calificacion CPP con 20 dias de mora reciente: se aprueba monto reducido con seguimiento. Monto aprobado: **S/ 10,000.00** (sobre el plazo y la TEA solicitados). 

**Desembolso** el 05/08/2026; cuotas a pagar el día 05 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 595.61** · Cronograma final (las cuotas son iguales): 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|05/09/2026|595.61|287.55|308.06|9,712.45|
|2|05/10/2026|595.61|296.41|299.20|9,416.04|
|3|05/11/2026|595.61|305.54|290.07|9,110.50|
|…|…|…|…|…|…|
|24|05/08/2028|595.61|577.82|17.80|0.00|



## Caso 27 

**Solicitante (rol cliente).** Tucidides Quispe · Documento 42220022 · Teléfono 964110227. Negocio: Ferreteria «Ferreteria Tucidides», en Concepcion, 40 meses de antigüedad. Ingreso mensual estimado S/ 6,200.00; gasto mensual S/ 2,900.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 20,000.00; plazo 24 meses; TEA 40.92 % (con seguro de desgravamen); garantía: hipotecaria; destino: Compra de stock y montacarga. Cuota de referencia mostrada al cliente: S/ 1,168.23. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.9176, lng -75.3155. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** CPP, 2 entidad(es) con deuda, deuda total S/ 18,000.00, 15 día(s) de mayor mora. 

**Decisión del comité: CONDICIONADO.** Endeudamiento externo en 2 entidades y relacion monto/ingreso ajustada: el comite condiciona el monto. Monto aprobado: **S/ 14,000.00** (sobre el plazo y la TEA solicitados). 

**Desembolso** el 10/08/2026; cuotas a pagar el día 10 de cada mes, empezando el mes siguiente. 

**Cuota mensual: S/ 817.76** · Cronograma final (las cuotas son iguales): 

19 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

|**N° Cuota**|**Fecha de pago**|**Cuota**|**Capital**|**Interés**|**Saldo**|
|---|---|---|---|---|---|
|1|10/09/2026|817.76|411.79|405.97|13,588.21|
|2|10/10/2026|817.76|423.73|394.03|13,164.48|
|3|10/11/2026|817.76|436.02|381.74|12,728.46|
|…|…|…|…|…|…|
|24|10/08/2028|817.76|794.86|23.05|0.00|



## Caso 28 

**Solicitante (rol cliente).** Aquiles Mamani · Documento 43337037 · Teléfono 964110228. Negocio: Comercio «Comercial Aquiles», en Huancayo, 60 meses de antigüedad. Ingreso mensual estimado S/ 9,000.00; gasto mensual S/ 3,600.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 15,000.00; plazo 24 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: hipotecaria; destino: Capital de trabajo. Cuota de referencia mostrada al cliente: S/ 893.42. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -12.0657, lng -75.2099. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** PERDIDA, 4 entidad(es) con deuda, deuda total S/ 40,000.00, 210 día(s) de mayor mora, en lista de inhabilitados. 

**Decisión del comité: RECHAZADO.** Registrado en lista de inhabilitados del sistema financiero; la solicitud se bloquea en la consulta de buro. No se genera cronograma. Registrar el motivo de rechazo y cerrar el expediente en estado `rechazado` . 

## Caso 29 

**Solicitante (rol cliente).** Medea Apaza · Documento 41884084 · Teléfono 964110229. Negocio: Bodega «Bodega Medea», en Pilcomayo, 22 meses de antigüedad. Ingreso mensual estimado S/ 1,800.00; gasto mensual S/ 1,100.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 14,000.00; plazo 18 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: sin garantia; destino: Compra de camioneta para reparto. Cuota de referencia mostrada al cliente: S/ 1,024.87. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad media. Visita: resultado `visitado` ; ubicación del negocio lat -12.0489, lng -75.247. 

**Pre-evaluación esperada:** REVISAR (puntaje 60). **Buró esperado:** DUDOSO, 3 entidad(es) con deuda, deuda total S/ 25,000.00, 95 día(s) de mayor mora. 

**Decisión del comité: RECHAZADO.** El monto solicitado supera ampliamente la capacidad de pago estimada 

(pre-evaluacion NO_PROCEDE). No se genera cronograma. Registrar el motivo de rechazo y cerrar el 

20 / 21 

ENUNCIADOS_30_CASOS_CREDITO_FLUJO_MOVIL.md 

2026-06-16 

expediente en estado `rechazado` . 

## Caso 30 

**Solicitante (rol cliente).** Esquines Rojas · Documento 43334034 · Teléfono 964110230. Negocio: Transporte «Fletes Esquines», en Jauja, 30 meses de antigüedad. Ingreso mensual estimado S/ 7,000.00; gasto mensual S/ 3,200.00. 

**Solicitud registrada desde la App Clientes.** Producto Crédito Empresarial — Microempresa. Monto solicitado S/ 30,000.00; plazo 24 meses; TEA 43.92 % (sin seguro de desgravamen); garantía: vehicular; destino: Compra de unidad de transporte. Cuota de referencia mostrada al cliente: S/ 1,786.83. Estado inicial: `enviado` . 

**Asignación al asesor.** Tipo de gestión `NUEVA_SOLICITUD` , prioridad alta. Visita: resultado `visitado` ; ubicación del negocio lat -11.774, lng -75.501. 

**Pre-evaluación esperada:** APTO (puntaje 85). **Buró esperado:** DUDOSO, 3 entidad(es) con deuda, deuda total S/ 25,000.00, 95 día(s) de mayor mora. 

**Decisión del comité: RECHAZADO.** Calificacion SBS DUDOSO con 95 dias de mora vigente en 3 entidades: no procede el otorgamiento. No se genera cronograma. Registrar el motivo de rechazo y cerrar el expediente en estado `rechazado` . 

## Resumen de decisiones (clave para el docente) 

Desembolsados: 24 · Condicionados (monto reducido): 3 · Rechazados: 3. 

Casos pensados para practicar las ramas alternas del flujo: el caso de **lista de inhabilitados** debe bloquearse en la consulta de buró; el caso de **capacidad de pago insuficiente** debe quedar en pre-evaluación `NO_PROCEDE` ; el caso de **calificación DUDOSO con mora vigente** debe rechazarse en comité; y los **condicionados** exigen recalcular la cuota sobre el monto aprobado, no sobre el solicitado. 

21 / 21 

