# Trabajo Domiciliario Obligatorio
## Instituto CTC - Colonia

### Información del Entregable

**Materia:** Diseño y Desarrollo de Aplicaciones  
**Modalidad:** Trabajo Domiciliario Obligatorio  
**Plataforma:** ASP.NET Core .NET 8 MVC  

### Forma de Entrega

**Entregable:** Repositorio de GitHub público  
**Método de envío:** Enviar el link del repositorio al profesor por correo electrónico  

### Documentación Requerida

El repositorio debe incluir la siguiente documentación técnica:

1. **Diagrama de flujo de los diferentes estados del juego**
   - Estados: "jugando" y "presentando resultados"  
   - Transiciones entre estados
   - Condiciones de cambio de estado

2. **Diagrama de clases completo**
   - Todas las clases del modelo
   - Atributos y métodos de cada clase
   - Relaciones entre clases (herencia, asociación, composición, etc)

3. **Wireframes de cada página**
   - Vista principal del juego (estado "jugando")
   - Vista de resultados (estado "presentando resultados")  
   - Modales de minijuegos (V2)
   - Diseño responsive (desktop y móvil)

4. **Diagrama MER (Modelo Entidad-Relación) de la base de datos**
   - Entidades principales
   - Atributos de cada entidad
   - Relaciones con cardinalidades
   - Claves primarias y foráneas

5. **Tests unitarios y documentación de testing**
   - Cobertura mínima del 70% del código de lógica de negocio
   - Tests para controllers principales y servicios
   - Tests para validaciones y cálculo de metas
   - Documentación de casos de prueba y resultados

### Recomendaciones

- Mantener el repositorio organizado con carpetas claras
- Incluir un README.md con instrucciones de instalación y uso
- Documentar el código con comentarios apropiados
- Realizar commits frecuentes con mensajes descriptivos
- **Escribir tests desde el inicio del desarrollo (TDD recomendado)**
- Ejecutar tests antes de cada commit
- Mantener alta cobertura de tests durante todo el desarrollo

---

# Introducción al juego: Coopera

## Descripción del Proyecto

El proyecto consiste en desarrollar una aplicación web multijugador cooperativa en ASP.NET Core .NET 8 MVC.

El flujo básico es el siguiente:

- Los jugadores entran al sitio web.
- Al comenzar una partida, se generan metas de recursos: madera, piedra y comida.
- Cada jugador aporta recursos presionando botones o resolviendo minijuegos (según la versión).
- El juego termina cuando todos los recursos requeridos se alcanzan.
- Se muestran los resultados de la partida (recursos por jugador, totales y tiempo).
- Cualquier jugador puede iniciar una nueva partida.

La aplicación tiene dos estados principales:

- Jugando → los jugadores pueden ingresar su nombre y recolectar recursos.
- Presentando resultados → se muestran los resultados de la última partida y la opción de empezar otra.

El desarrollo se dividirá en etapas incrementales, asegurando siempre un producto funcional que luego se expande.

---

# V1 — Juego básico con botones (sin minijuegos)

### US-0 · Generar metas de recursos al iniciar partida

**Como** sistema
**Quiero** calcular automáticamente las metas de cada recurso al comenzar una nueva partida
**Para** asegurar que cada partida tenga objetivos aleatorios pero balanceados

**Criterios de aceptación (Gherkin)**

```
Escenario: Calcular metas para V1 (botones)
  Dado que se inicia una nueva partida en V1
  Cuando el sistema calcula las metas
  Entonces para cada recurso (madera, piedra, comida) se genera un número aleatorio entre 0 y 1
  Y se multiplica por el factor de dificultad 100
  Y el resultado se redondea al entero más cercano
  Y cada meta debe ser mínimo 10 y máximo 100

Escenario: Calcular metas para V2 (minijuegos)
  Dado que se inicia una nueva partida en V2
  Cuando el sistema calcula las metas
  Entonces para cada recurso se genera un número aleatorio entre 0 y 1
  Y se multiplica por el factor de dificultad 10
  Y el resultado se redondea al entero más cercano
  Y cada meta debe ser mínimo 1 y máximo 10

Escenario: Persistir metas de la partida
  Dado que se han calculado las metas de recursos
  Cuando se almacenan en el sistema
  Entonces las metas permanecen constantes durante toda la partida
  Y se pueden consultar en cualquier momento
```

**Requerimientos técnicos:**
- Usar un generador de números pseudoaleatorios con semilla basada en timestamp para reproducibilidad en testing
- Almacenar las metas en sesión o base de datos según la arquitectura elegida
- Validar que las metas generadas estén dentro de los rangos esperados

---

### US-1 · Recolectar recursos mediante botones

**Como** jugador
**Quiero** ingresar mi nombre y presionar un botón por recurso
**Para** contribuir a que el equipo alcance las metas de la partida

**Criterios de aceptación (Gherkin)**

```
Escenario: Ingresar nombre para jugar
  Dado que accedo a la aplicación en estado "jugando"
  Cuando se muestra el popup de ingreso de nombre
  Y ingreso un nombre válido (1-20 caracteres alfanuméricos)
  Entonces puedo comenzar a recolectar recursos asociados a ese nombre
  Y el popup se cierra

Escenario: Validar nombre inválido
  Dado que se muestra el popup de ingreso de nombre
  Cuando ingreso un nombre vacío o con caracteres especiales
  Entonces se muestra un mensaje de error
  Y el popup permanece abierto

Escenario: Recolectar recurso válido
  Dado que ya ingresé mi nombre
  Y la partida está en estado "jugando"
  Cuando presiono el botón de un recurso que no ha alcanzado su meta
  Entonces el contador de ese recurso aumenta en 1
  Y se registra mi nombre, el recurso recolectado y timestamp
  Y veo un feedback visual de éxito

Escenario: Intentar recolectar recurso completo
  Dado que un recurso ya alcanzó su meta
  Cuando intento presionar el botón de ese recurso
  Entonces el botón aparece deshabilitado
  Y no se suma ningún recurso

Escenario: Recolección concurrente
  Dado que múltiples jugadores presionan botones simultáneamente
  Cuando se procesa la recolección
  Entonces cada acción se registra correctamente
  Y el contador se incrementa en el orden correcto

Escenario: Mostrar progreso en números
  Dado que ya se han recolectado algunos recursos
  Cuando visualizo la pantalla de juego
  Entonces veo el progreso de cada recurso expresado como "X/Y" (recolectado/meta)
  Y los botones de recursos completados aparecen deshabilitados
```

**Requerimientos técnicos:**
- Implementar validación de nombres del lado cliente y servidor
- Usar atomic operations para evitar race conditions en recolección concurrente
- Almacenar timestamp con precisión de milisegundos
- Implementar debounce en botones para evitar double-clicks accidentales
- Sanitizar nombres de usuario para prevenir XSS

---

### US-2 · Finalizar la partida al cumplir metas

**Como** sistema
**Quiero** detectar cuando todos los recursos alcanzan la meta
**Para** marcar la partida como finalizada

**Criterios de aceptación (Gherkin)**

```
Escenario: Partida completada
  Dado que todos los recursos alcanzaron sus metas
  Cuando se registra el último recurso
  Entonces la partida pasa al estado "presentando resultados"
  Y no se permite seguir sumando recursos
  Y se calcula el tiempo total de la partida

Escenario: Verificación automática de finalización
  Dado que la partida está en estado "jugando"
  Cuando se registra un nuevo recurso
  Entonces el sistema verifica si todas las metas se cumplieron
  Y si es así, finaliza automáticamente la partida

Escenario: Transición atómica de estado
  Dado que el último recurso necesario está siendo recolectado por múltiples jugadores
  Cuando se procesa la recolección simultánea
  Entonces solo una acción completa la partida
  Y las demás se ignoran correctamente
```

**Requerimientos técnicos:**
- Implementar verificación atómica de finalización para evitar race conditions
- Usar transacciones de base de datos para garantizar consistencia en el cambio de estado
- Calcular tiempo total como diferencia entre primer y último recurso recolectado

---

### US-3 · Mostrar resultados de la última partida

**Como** visitante
**Quiero** ver una tabla con los resultados cuando una partida termina
**Para** conocer cuánto recolectó cada jugador y el tiempo total

**Criterios de aceptación (Gherkin)**

```
Escenario: Ver tabla de resultados
  Dado que la partida ha terminado
  Cuando accedo a la aplicación
  Entonces veo una tabla con el nombre de cada jugador
  Y la cantidad de recursos recolectados de cada tipo (madera, piedra, comida)
  Y el total de recursos recolectados por jugador
  Y el tiempo total de la partida en formato legible (MM:SS)
  Y las metas finales alcanzadas de cada recurso

Escenario: Ordenar tabla por contribución
  Dado que estoy viendo los resultados de la partida
  Cuando visualizo la tabla
  Entonces los jugadores aparecen ordenados por total de recursos recolectados (mayor a menor)
  Y en caso de empate, se ordena por orden alfabético de nombre

Escenario: Ver partida sin jugadores
  Dado que una partida terminó pero no tuvo participantes
  Cuando accedo a la aplicación
  Entonces veo un mensaje indicando "Partida completada sin participantes"
  Y las metas que fueron establecidas

Escenario: Ver detalles de metas alcanzadas
  Dado que estoy viendo los resultados
  Cuando visualizo la información de la partida
  Entonces veo las metas originales establecidas para cada recurso
  Y el total final alcanzado (que debe coincidir con las metas)
```

**Requerimientos técnicos:**
- Formatear tiempo total en formato MM:SS o HH:MM:SS si supera 1 hora
- Implementar ordenación estable para casos de empate
- Validar que los totales mostrados coincidan con las metas establecidas
- Preservar datos de la partida anterior hasta que se inicie una nueva

---

### US-4 · Iniciar una nueva partida

**Como** visitante
**Quiero** tener un botón “Comenzar nueva partida” en la vista de resultados
**Para** poder volver a jugar desde cero

**Criterios de aceptación (Gherkin)**

```
Escenario: Reiniciar partida
  Dado que estoy en la pantalla de resultados
  Cuando presiono el botón "Comenzar nueva partida"
  Entonces se crean nuevas metas de recursos usando US-0
  Y se limpian todos los datos de la partida anterior
  Y la aplicación pasa al estado "jugando"
  Y al recargar cualquier jugador ve el popup para ingresar su nombre

Escenario: Confirmación de nueva partida
  Dado que estoy en la pantalla de resultados
  Cuando presiono el botón "Comenzar nueva partida"
  Entonces se muestra una confirmación "¿Está seguro de iniciar una nueva partida?"
  Y si confirmo, se procede con el reinicio
  Y si cancelo, permanezco en la pantalla de resultados

Escenario: Múltiples usuarios iniciando partida
  Dado que múltiples usuarios presionan "Comenzar nueva partida" simultáneamente
  Cuando se procesa la acción
  Entonces solo se crea una nueva partida
  Y todos los usuarios ven el mismo estado actualizado

Escenario: Acceso directo en estado jugando
  Dado que la partida ya está en estado "jugando"
  Cuando un usuario accede a la aplicación
  Entonces no ve la pantalla de resultados
  Y ve directamente el popup de ingreso de nombre
```

**Requerimientos técnicos:**
- Implementar soft confirmation antes de iniciar nueva partida
- Limpiar sesiones y datos cached de la partida anterior
- Usar operaciones atómicas para evitar múltiples inicializaciones simultáneas
- Validar que la nueva partida tenga metas válidas antes de cambiar el estado

---

### US-5 · Visualizar progreso en gráfico (Chart.js)

**Como** jugador
**Quiero** ver el progreso representado en un gráfico de barras
**Para** tener una representación visual más clara que los números

**Criterios de aceptación (Gherkin)**

```
Escenario: Ver gráfico de recursos inicial
  Dado que la partida está en estado jugando y no se ha recolectado ningún recurso
  Cuando ingreso a la aplicación
  Entonces veo un gráfico con tres barras en gris: madera, piedra y comida
  Y cada barra muestra 0 de progreso hasta su meta correspondiente
  Y las etiquetas indican "0/X" donde X es la meta de cada recurso

Escenario: Ver gráfico con progreso parcial
  Dado que algunos recursos han sido recolectados
  Cuando visualizo el gráfico
  Entonces las barras muestran el progreso actual con color distintivo
  Y las barras no completadas permanecen en gris en su parte faltante
  Y las etiquetas muestran "recolectado/meta" actualizados

Escenario: Actualización periódica automática
  Dado que estoy en la pantalla de juego
  Cuando pasan exactamente 5 segundos
  Entonces el gráfico se actualiza automáticamente via JavaScript
  Y se hace una petición AJAX para obtener el progreso más reciente
  Y la animación de barras muestra el cambio de progreso

Escenario: Manejo de errores de actualización
  Dado que estoy viendo el gráfico
  Cuando falla la petición de actualización automática
  Entonces el gráfico mantiene los datos anteriores
  Y se reintenta la actualización en el próximo ciclo de 5 segundos
  Y no se muestra error visible al usuario

Escenario: Finalización del juego
  Dado que todos los recursos alcanzaron sus metas
  Cuando el gráfico se actualiza
  Entonces todas las barras se muestran 100% completas
  Y después de 2 segundos se redirige a la pantalla de resultados
  Y el gráfico desaparece

Escenario: Barras completadas individualmente
  Dado que uno o más recursos alcanzaron su meta
  Cuando visualizo el gráfico
  Entonces las barras completas se muestran en color de éxito
  Y las barras incompletas mantienen el color de progreso normal
```

**Requerimientos técnicos:**
- Usar Chart.js versión 3+ con animaciones suaves
- Implementar peticiones AJAX cada 5 segundos usando setInterval
- Manejar errores de red sin interrumpir la experiencia del usuario
- Usar colores accesibles que distingan progreso, completo y pendiente
- Implementar responsive design para el gráfico en diferentes pantallas
- Limpiar intervalos de JavaScript cuando se cambia de vista para evitar memory leaks

---

# V2 — Expansión con minijuegos

### US-6 · Integración de minijuegos en los botones

**Como** jugador
**Quiero** que al presionar un botón se abra un minijuego asociado
**Para** ganar el recurso únicamente si lo resuelvo correctamente

**Criterios de aceptación (Gherkin)**

```
Escenario: Abrir minijuego por recurso
  Dado que estoy en la pantalla de juego en V2
  Y ya ingresé mi nombre
  Cuando presiono el botón "Madera" 
  Entonces se abre un popup con el minijuego de matemáticas
  Y el juego principal se bloquea hasta completar o cerrar el popup

Escenario: Resolver minijuego correctamente
  Dado que tengo abierto un minijuego
  Cuando resuelvo correctamente el desafío
  Entonces se cierra el popup automáticamente
  Y se suma 1 al recurso correspondiente
  Y se registra mi nombre, recurso y timestamp
  Y se muestra un mensaje de éxito "¡Recurso recolectado!"

Escenario: Fallar minijuego
  Dado que tengo abierto un minijuego
  Cuando envío una respuesta incorrecta
  Entonces se cierra el popup automáticamente
  Y no se suma ningún recurso
  Y se muestra un mensaje de error "Respuesta incorrecta, intenta de nuevo"

Escenario: Cerrar minijuego sin completar
  Dado que tengo abierto un minijuego
  Cuando presiono el botón "X" o "Cancelar"
  Entonces se cierra el popup sin registrar acción
  Y regreso a la pantalla principal de juego
  Y no se suma ningún recurso

Escenario: Asociación correcta minijuego-recurso
  Dado que estoy en la pantalla de juego
  Cuando presiono "Madera" abro matemáticas
  Y cuando presiono "Piedra" abro memoria  
  Y cuando presiono "Comida" abro lógica
  Entonces cada botón abre su minijuego correspondiente
```

**Requerimientos técnicos:**
- Implementar modal/popup que bloquee la interacción con el fondo
- Cada minijuego debe cargar en máximo 2 segundos
- Manejar timeout si el usuario no responde en 60 segundos
- Validar respuestas del lado servidor para prevenir manipulación

---

### US-7 · Minijuego de Matemáticas (para madera)

**Como** jugador
**Quiero** resolver una suma de tres números aleatorios
**Para** recolectar madera cuando la respuesta sea correcta

**Criterios de aceptación (Gherkin)**

```
Escenario: Presentar desafío matemático
  Dado que se abre el minijuego de matemáticas
  Cuando se carga el popup
  Entonces veo tres números aleatorios entre 1 y 100
  Y veo la expresión "A + B + C = ?"
  Y veo un campo de texto para ingresar la respuesta
  Y veo botones "Enviar" y "Cancelar"

Escenario: Responder suma correctamente
  Dado que veo tres números aleatorios (ej: 23, 45, 67)
  Y calculo mentalmente la suma correcta (135)
  Cuando ingreso "135" en el campo de texto
  Y presiono "Enviar"
  Entonces veo mensaje "¡Correcto! Has recolectado madera"
  Y se cierra el popup
  Y se suma 1 al recurso madera

Escenario: Responder suma incorrecta
  Dado que veo tres números aleatorios (ej: 23, 45, 67)
  Cuando ingreso un número incorrecto (ej: "130")
  Y presiono "Enviar"
  Entonces veo mensaje "Respuesta incorrecta. La suma correcta era 135"
  Y se cierra el popup después de 2 segundos
  Y no se suma ningún recurso

Escenario: Validar entrada no numérica
  Dado que tengo el campo de respuesta disponible
  Cuando ingreso texto no numérico (ej: "abc")
  Y presiono "Enviar"
  Entonces veo mensaje "Por favor ingresa un número válido"
  Y el popup permanece abierto
  Y puedo corregir mi respuesta

Escenario: Manejar números grandes
  Dado que se generan tres números que suman más de 200
  Cuando ingreso la respuesta correcta
  Entonces el sistema acepta números de hasta 4 dígitos
  Y funciona correctamente

Escenario: Timeout del minijuego
  Dado que tengo abierto el minijuego de matemáticas
  Cuando pasan 60 segundos sin enviar respuesta
  Entonces se cierra automáticamente el popup
  Y veo mensaje "Tiempo agotado"
  Y no se suma ningún recurso
```

**Requerimientos técnicos:**
- Generar números aleatorios usando Math.random() del lado cliente y validar del lado servidor
- Implementar timeout de 60 segundos con countdown visual
- Validar que la entrada sea numérica y esté en rango razonable (0-999)
- Mostrar la respuesta correcta cuando se falla para propósito educativo

---

### US-8 · Minijuego de Memoria (para piedra)

**Como** jugador
**Quiero** memorizar una secuencia de 5 números y responder una pregunta sobre ellos
**Para** recolectar piedra cuando mi respuesta sea correcta

**Criterios de aceptación (Gherkin)**

```
Escenario: Presentar secuencia de números
  Dado que se abre el minijuego de memoria
  Cuando se carga el popup
  Entonces veo el texto "Memoriza la siguiente secuencia:"
  Y se muestran 5 números aleatorios entre 1 y 20
  Y cada número aparece por 1 segundo
  Y hay 0.5 segundos de pausa entre números
  Y después del último número veo "Preparándose pregunta..."

Escenario: Responder pregunta de paridad correctamente
  Dado que vi la secuencia [5, 12, 8, 15, 3]
  Y aparece la pregunta "¿Había exactamente 2 números pares?"
  Cuando analizo que hay 2 pares (12, 8) y respondo "Sí"
  Y presiono "Enviar"
  Entonces veo mensaje "¡Correcto! Has recolectado piedra"
  Y se cierra el popup
  Y se suma 1 al recurso piedra

Escenario: Responder pregunta de suma correctamente
  Dado que vi la secuencia [10, 15, 8, 12, 5]
  Y aparece la pregunta "¿La suma de todos los números superaba 50?"
  Cuando calculo que 10+15+8+12+5=50 y respondo "No"
  Y presiono "Enviar"
  Entonces veo mensaje "¡Correcto! Has recolectado piedra"
  Y se suma 1 al recurso piedra

Escenario: Responder pregunta de duplicados correctamente
  Dado que vi la secuencia [7, 12, 7, 18, 3]
  Y aparece la pregunta "¿Había 2 números iguales?"
  Cuando identifico que hay dos 7s y respondo "Sí"
  Entonces veo mensaje "¡Correcto! Has recolectado piedra"

Escenario: Responder pregunta de rango correctamente
  Dado que vi la secuencia [15, 18, 12, 20, 14]
  Y aparece la pregunta "¿Había algún número menor a 10?"
  Cuando analizo que todos son ≥10 y respondo "No"
  Entonces veo mensaje "¡Correcto! Has recolectado piedra"

Escenario: Responder incorrectamente cualquier pregunta
  Dado que vi una secuencia de números
  Y aparece cualquier pregunta válida
  Cuando mi respuesta es incorrecta
  Y presiono "Enviar"
  Entonces veo mensaje "Respuesta incorrecta. La respuesta correcta era: [Sí/No]"
  Y se cierra el popup después de 2 segundos
  Y no se suma ningún recurso

Escenario: Generación de preguntas aleatorias
  Dado que completo la visualización de la secuencia
  Cuando se muestra la pregunta
  Entonces puede ser cualquiera de estas 5 opciones:
  Y "¿Había exactamente 2 números pares?"
  Y "¿Había exactamente 2 números impares?"
  Y "¿La suma de todos los números superaba 50?"
  Y "¿Había 2 números iguales?"
  Y "¿Había algún número menor a 10?"

Escenario: Timeout durante secuencia o pregunta
  Dado que estoy en cualquier fase del minijuego
  Cuando pasan 60 segundos desde que se abrió
  Entonces se cierra automáticamente el popup
  Y veo mensaje "Tiempo agotado"
  Y no se suma ningún recurso
```

**Requerimientos técnicos:**
- Usar setTimeout() para mostrar números con intervalos precisos
- Generar secuencias aleatorias evitando patrones obvios
- Implementar lógica para evaluar cada tipo de pregunta automáticamente
- Mostrar countdown visual durante la presentación de la secuencia
- Validar respuestas solo como "Sí"/"No" o botones de opción

---

### US-9 · Minijuego de Lógica (para comida)

**Como** jugador
**Quiero** evaluar una proposición lógica sobre tres números aleatorios
**Para** recolectar comida cuando mi evaluación sea correcta

**Criterios de aceptación (Gherkin)**

```
Escenario: Presentar desafío lógico
  Dado que se abre el minijuego de lógica
  Cuando se carga el popup
  Entonces veo tres números aleatorios entre 1 y 100 (ej: 25, 48, 63)
  Y veo una proposición lógica aleatoria sobre estos números
  Y veo botones "Verdadero" y "Falso"
  Y veo un botón "Cancelar"

Escenario: Evaluar proposición de paridad correctamente
  Dado que veo los números [24, 47, 68]
  Y veo la proposición "Exactamente 2 números son pares"
  Cuando analizo que 24 y 68 son pares (2 números) y respondo "Verdadero"
  Y presiono el botón correspondiente
  Entonces veo mensaje "¡Correcto! Has recolectado comida"
  Y se cierra el popup
  Y se suma 1 al recurso comida

Escenario: Evaluar proposición de suma correctamente
  Dado que veo los números [30, 25, 45]
  Y veo la proposición "La suma de los 3 números es par"
  Cuando calculo 30+25+45=100 (par) y respondo "Verdadero"
  Entonces veo mensaje "¡Correcto! Has recolectado comida"

Escenario: Evaluar proposición de comparación correctamente
  Dado que veo los números [15, 25, 8]
  Y veo la proposición "El número mayor es mayor que la suma de los otros dos"
  Cuando analizo que 25 < (15+8)=23 y respondo "Falso"
  Entonces veo mensaje "¡Correcto! Has recolectado comida"

Escenario: Evaluar proposición de rango correctamente
  Dado que veo los números [75, 82, 66]
  Y veo la proposición "Hay al menos un número mayor que 50"
  Cuando verifico que todos son >50 y respondo "Verdadero"
  Entonces veo mensaje "¡Correcto! Has recolectado comida"

Escenario: Evaluar proposición de unicidad correctamente
  Dado que veo los números [33, 45, 33]
  Y veo la proposición "Todos los números son diferentes"
  Cuando observo que hay dos 33s y respondo "Falso"
  Entonces veo mensaje "¡Correcto! Has recolectado comida"

Escenario: Responder incorrectamente cualquier proposición
  Dado que veo cualquier combinación de números y proposición
  Cuando mi evaluación es incorrecta
  Y presiono el botón correspondiente
  Entonces veo mensaje "Respuesta incorrecta. La respuesta correcta era: [Verdadero/Falso]"
  Y se cierra el popup después de 2 segundos
  Y no se suma ningún recurso

Escenario: Generación de proposiciones aleatorias
  Dado que se muestran los tres números
  Cuando se selecciona la proposición
  Entonces puede ser cualquiera de estas 5 opciones:
  Y "Exactamente 2 números son pares"
  Y "La suma de los 3 números es par"
  Y "El número mayor es mayor que la suma de los otros dos"
  Y "Hay al menos un número mayor que 50"
  Y "Todos los números son diferentes"

Escenario: Timeout del minijuego
  Dado que tengo abierto el minijuego de lógica
  Cuando pasan 60 segundos sin enviar respuesta
  Entonces se cierra automáticamente el popup
  Y veo mensaje "Tiempo agotado"
  Y no se suma ningún recurso
```

**Requerimientos técnicos:**
- Generar números aleatorios que permitan proposiciones interesantes (evitar casos triviales)
- Implementar lógica automática para evaluar cada tipo de proposición
- Validar que al menos 30% de las proposiciones generadas sean verdaderas y 70% falsas para balance
- Mostrar explicación de la respuesta correcta cuando se falla
- Usar botones grandes y claros para "Verdadero"/"Falso"

---

# Estructura Sugerida del Repositorio

```
CooperaGame/
├── README.md                          # Instrucciones de instalación y uso
├── .gitignore                         # Archivos a ignorar por Git
├── CooperaGame.sln                    # Solución de Visual Studio
├── 
├── src/                               # Código fuente
│   ├── CooperaGame/                   # Proyecto principal
│   │   ├── Controllers/               # Controladores MVC
│   │   ├── Models/                    # Modelos de datos
│   │   ├── Views/                     # Vistas Razor
│   │   ├── wwwroot/                   # Archivos estáticos (CSS, JS, imágenes)
│   │   ├── Data/                      # Contexto de base de datos
│   │   └── Services/                  # Lógica de negocio
│   │
├── docs/                              # Documentación técnica
│   ├── diagramas/
│   │   ├── flujo-estados.png          # Diagrama de flujo de estados
│   │   ├── diagrama-clases.png        # Diagrama de clases UML
│   │   └── mer-database.png           # Diagrama MER
│   │
│   ├── wireframes/
│   │   ├── vista-juego-desktop.png    # Wireframe vista principal
│   │   ├── vista-juego-mobile.png     # Versión móvil
│   │   ├── vista-resultados.png       # Vista de resultados
│   │   └── minijuegos-modals.png      # Wireframes de minijuegos
│   │
│   └── documentacion-tecnica.md       # Decisiones técnicas y arquitectura
│
├── tests/                             # Tests unitarios (OBLIGATORIO - cobertura >70%)
└── database/                          # Scripts de base de datos
    ├── schema.sql                     # Script de creación de tablas
    └── seed-data.sql                  # Datos de prueba
```

## Importancia de los Tests Unitarios

### **¿Por qué son fundamentales?**

Los **tests unitarios** son una parte crítica del desarrollo profesional por las siguientes razones:

1. **Calidad del código**: Garantizan que el código funciona como se espera
2. **Refactoring seguro**: Permiten modificar código con confianza
3. **Documentación viva**: Los tests documentan el comportamiento esperado
4. **Detección temprana de errores**: Identifican problemas antes del deployment
5. **Facilitación del trabajo en equipo**: Otros desarrolladores pueden entender y modificar el código

### **Requerimientos de Testing**

#### **Cobertura Mínima Obligatoria: 70%**

**Estructura sugerida con ejemplos tests:**

Atención, las siguientes clases son ejemplos. No es necesario ni requerido tenerlas o implementarlas.

**IMPORTANTE:** Para validaciones de entrada de usuario, usar **manejo defensivo** (Result patterns, validaciones que retornan errores) en lugar de excepciones. Las excepciones deben reservarse únicamente para situaciones verdaderamente inesperadas como fallos de base de datos, problemas de red, etc.

1. **Servicios de lógica de negocio**
   - `GameService`: Generación de metas, validación de finalización
   - `ResourceService`: Cálculos de recursos, validaciones
   - `PlayerService`: Validación de nombres, gestión de jugadores

2. **Controllers principales**
   - `HomeController`: Navegación básica
   - `GameController`: Lógica del juego, minijuegos
   - `ResultsController`: Cálculo y presentación de resultados

3. **Modelos con validaciones**
   - Validación de rangos de metas
   - Validación de nombres de jugadores
   - Cálculo de tiempo de partida

4. **Casos edge específicos**
   - Concurrencia en recolección de recursos
   - Finalización simultánea de partida
   - Validación de respuestas de minijuegos

#### **Herramientas Requeridas**

- **xUnit o NUnit**: Framework principal de testing
- **Moq**: Para crear mocks de dependencias
- **Microsoft.AspNetCore.Mvc.Testing**: Para integration tests
- **EntityFramework.InMemory**: Para testing de base de datos

#### **Estructura de Tests**

```
tests/
├── UnitTests/
│   ├── Services/
│   │   ├── GameServiceTests.cs
│   │   ├── ResourceServiceTests.cs
│   │   └── PlayerServiceTests.cs
│   ├── Controllers/
│   │   ├── GameControllerTests.cs
│   │   └── ResultsControllerTests.cs
│   └── Models/
│       └── ValidationTests.cs
└── IntegrationTests/
    ├── GameFlowTests.cs
    └── MinigameTests.cs
```

#### **Criterios de Calidad de Tests**

- **Tests independientes**: Cada test debe poder ejecutarse por separado
- **Nombres descriptivos**: `CalculateTargets_WithValidInput_ReturnsExpectedValues()`
- **Arrange-Act-Assert**: Estructura clara de preparación, acción y verificación
- **Mocking apropiado**: Aislar unidades bajo prueba de dependencias externas
- **Casos positivos y negativos**: Probar tanto éxitos como fallos esperados

## Criterios de Evaluación

### **Funcionalidad (35%)**
- V1 funcional completa (botones + gráfico)
- V2 funcional completa (minijuegos)
- Estados del juego correctamente implementados
- Base de datos funcionando correctamente

### **Código y Arquitectura (25%)**
- Código limpio y bien estructurado
- Uso correcto del patrón MVC
- Manejo adecuado de errores
- Validaciones del lado cliente y servidor

### **Documentación (15%)**
- Diagramas técnicos completos y claros
- Wireframes detallados
- README con instrucciones claras
- Comentarios apropiados en el código

### **Testing y Calidad (20%)**
- **Cobertura de tests unitarios mínima del 70%**
- Tests para lógica de negocio (cálculo de metas, validaciones)
- Tests para controllers principales (Home, Game, Results)
- Tests para servicios y repositorios
- Documentación de estrategia de testing
- Casos de prueba para minijuegos y estados del juego

### **User Stories y Experiencia de Usuario (5%)**
- Implementación fiel a las user stories
- Criterios de aceptación cumplidos
- Experiencia de usuario coherente
- Funcionalidades críticas probadas

## Tecnologías Requeridas

### **Backend**
- **ASP.NET Core .NET 8** - Framework principal
- **Entity Framework Core** - ORM para base de datos
- **SQL Server / SQLite** - Base de datos
- **xUnit / NUnit** - Framework de testing unitario
- **Moq** - Framework para mocking en tests

### **Frontend**
- **Razor Pages / MVC Views** - Vistas del servidor
- **Bootstrap 5** - Framework CSS
- **Chart.js** - Gráficos de progreso
- **JavaScript vanilla** - Interactividad del cliente

### **Herramientas**
- **Visual Studio / VS Code** - IDE
- **Git** - Control de versiones
- **GitHub** - Repositorio remoto
- **Draw.io / Lucidchart** - Para diagramas

## Contacto

Para dudas técnicas o consultas sobre el proyecto, contactar al profesor por correo electrónico incluyendo:
- Nombre completo del estudiante
- Descripción específica de la duda
- Código relevante (si aplica)
- Screenshots del problema (si aplica)