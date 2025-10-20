# Trabajo Domiciliario Obligatorio 2
## Instituto CTC - Colonia

### Información del Entregable

**Materia:** Diseño y Desarrollo de Aplicaciones  
**Modalidad:** Trabajo Domiciliario Obligatorio  
**Plataforma:** ASP.NET Core .NET 8 Web API  

### Forma de Entrega

**Entregable:** Repositorio de GitHub público  
**Método de envío:** Enviar el link del repositorio al profesor por correo electrónico  

### Documentación Requerida

El repositorio debe incluir la siguiente documentación técnica:

1. **Diagrama de clases completo de la API**
   - Todas las clases del modelo (DTOs, servicios, controladores)
   - Atributos y métodos de cada clase
   - Relaciones entre clases (herencia, composición, inyección de dependencias)

2. **Documentación de endpoints con Swagger**
   - Documentación de cada endpoint con ejemplos
   - Definición de modelos de request/response
   - Códigos de estado HTTP documentados

3. **Diagrama MER (Modelo Entidad-Relación) de la base de datos**
   - Entidades principales (preguntas, tipos de juego, etc.)
   - Atributos de cada entidad
   - Relaciones con cardinalidades
   - Claves primarias y foráneas
   - Normalizacion

4. **Tests unitarios y de integración**
   - Cobertura mínima del 80% del código de lógica de negocio
   - Tests para controllers y servicios
   - Tests de integración para endpoints
   - Tests para generación y validación de preguntas
   - Documentación de casos de prueba y resultados

### Recomendaciones

- Mantener el repositorio organizado con carpetas claras
- Incluir un README.md con instrucciones de instalación y uso
- Documentar el código con comentarios apropiados y summaries XML
- Realizar commits frecuentes con mensajes descriptivos
- **Escribir tests desde el inicio del desarrollo (TDD recomendado)**
- Ejecutar tests antes de cada commit
- Mantener alta cobertura de tests durante todo el desarrollo
- **Seguir convenciones REST para el diseño de la API**

---

# Introducción al proyecto: API de Minijuegos

## Descripción del Proyecto

El proyecto consiste en desarrollar una **API RESTful** en ASP.NET Core .NET 8 que proporcione servicios para generar preguntas de minijuegos y validar sus respuestas.

La API debe exponer 2 endpoints principales:

- **GET /api/minijuegos/pregunta?tipo={tipo}** - Generar preguntas para tres tipos de minijuegos: matemáticas, memoria y lógica
- **POST /api/minijuegos/validar** - Validar respuestas enviadas por clientes externos

Esta API está diseñada para ser consumida por aplicaciones cliente (web, móvil, etc.) que implementen la lógica de presentación de los minijuegos.

Los tres tipos de minijuegos son:

1. **Matemáticas (madera)**: Suma de tres números aleatorios
2. **Memoria (piedra)**: Secuencia de números con pregunta de memoria
3. **Lógica (comida)**: Proposiciones lógicas sobre tres números

La API debe ser stateless, bien documentada y seguir principios REST.

---

# Especificación de Endpoints

## Endpoint 1: Generar Pregunta

### US-1 · Generar pregunta de minijuego por tipo

**Como** aplicación cliente  
**Quiero** solicitar una pregunta para un tipo específico de minijuego  
**Para** presentársela al usuario y que pueda resolverla  

**Criterios de aceptación (Gherkin)**

```
Escenario: Generar pregunta de matemáticas
  Dado que hago una petición GET a /api/minijuegos/pregunta?tipo=matematicas
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 200
  Y el response contiene tres números aleatorios entre 1 y 100
  Y tambien incluye un ID único de pregunta
  Y tambien incluye el tipo de minijuego "matematicas"

Escenario: Generar pregunta de memoria
  Dado que hago una petición GET a /api/minijuegos/pregunta?tipo=memoria
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 200
  Y el response contiene una secuencia de 5 números entre 1 y 20
  Y tambien incluye una pregunta aleatoria sobre la secuencia
  Y tambien incluye el codigo de dicha pregunta sobre la secuencia
  Y tambien incluye un ID único de pregunta
  Y tambien incluye el tipo de minijuego "memoria"

Escenario: Generar pregunta de lógica
  Dado que hago una petición GET a /api/minijuegos/pregunta?tipo=logica
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 200
  Y el response contiene tres números aleatorios entre 1 y 100
  Y tambien incluye una proposición lógica sobre los números
  Y tambien incluye el codigo de la proposicion logica
  Y tambien incluye un ID único de pregunta
  Y tambien incluye el tipo de minijuego "logica"

Escenario: Tipo de minijuego inválido
  Dado que hago una petición GET a /api/minijuegos/pregunta?tipo=invalido
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 400
  Y el response contiene un mensaje de error descriptivo

Escenario: Parámetro tipo faltante
  Dado que hago una petición GET a /api/minijuegos/pregunta sin parámetro tipo
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 400
  Y el response contiene mensaje "El parámetro 'tipo' es requerido"
```

**Modelos de Response:**

```json
// Matemáticas
{
  "id": "1234",
  "tipo": "matematicas",
  "numeros": [23, 45, 67],
  "fechaCreacion": "2024-03-15T10:30:00Z"
}

// Memoria
{
  "id": "4567",
  "tipo": "memoria",
  "secuencia": [5, 12, 8, 15, 3],
  "pregunta": "¿Había exactamente 2 números pares?",
  "codigo_pregunta": "2PARES",
  "fechaCreacion": "2024-03-15T10:31:00Z"
}

// Lógica
{
  "id": "891011",
  "tipo": "logica",
  "numeros": [25, 48, 63],
  "proposicion": "A > B > C = true?",
  "codigo_proposicion": "SECUENCIA_MAYOR",
  "fechaCreacion": "2024-03-15T10:32:00Z"
}
```

---

## Endpoint 2: Validar Respuesta

### US-2 · Validar respuesta de minijuego

**Como** aplicación cliente  
**Quiero** enviar la respuesta del usuario junto con el ID de la pregunta  
**Para** obtener confirmación si la respuesta es correcta o incorrecta  

**Criterios de aceptación (Gherkin)**

```
Escenario: Validar respuesta correcta de matemáticas
  Dado que tengo una pregunta con ID "12345"
  Y los números eran [23, 45, 67]
  Cuando hago POST a /api/minijuegos/validar con respuesta 135
  Entonces recibo status code 200
  Y el response indica "esCorrecta": true
  Y tambien incluye un mensaje de éxito
  Y tambien incluye la respuesta correcta

Escenario: Validar respuesta incorrecta de memoria
  Dado que tengo una pregunta de memoria con ID válido
  Y la respuesta correcta era "Sí"
  Cuando hago POST a /api/minijuegos/validar con respuesta "No"
  Entonces recibo status code 200
  Y el response indica "esCorrecta": false
  Y tambien incluye un mensaje explicativo
  Y tambien incluye la respuesta correcta

Escenario: Validar con ID de pregunta inexistente
  Dado que hago POST a /api/minijuegos/validar
  Y el ID de pregunta no existe en el sistema
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 404
  Y el response contiene mensaje "Pregunta no encontrada"

Escenario: Validar con datos inválidos
  Dado que hago POST a /api/minijuegos/validar
  Y no incluyo el ID de pregunta o la respuesta
  Cuando el servidor procesa la solicitud
  Entonces recibo status code 400
  Y el response contiene detalles de los errores de validación
```

**Modelo de Request:**

```json
{
  "preguntaId": "88821",
  "respuesta": "135" // String para manejar diferentes tipos
}
```

**Modelo de Response:**

```json
{
  "esCorrecta": true,
  "mensaje": "¡Respuesta correcta!",
  "respuestaCorrecta": "135",
  "tipoMinijuego": "matematicas",
}
```

---

# Requerimientos Técnicos Generales

## Arquitectura y Patrones

1. **Patrones**: Implementar al menos 2 patrones
2. **Servicios**: Para lógica de negocio de los minijuegos

## Persistencia

1. **Entity Framework Core** con SQL Server
2. **Migraciones** para actualización de esquema

## Documentación

1. **Swagger/OpenAPI** completamente configurado
3. **Ejemplos de uso** en Swagger UI
4. **README** con instrucciones de instalación y uso

---

# Lógica de Minijuegos Detallada

## Matemáticas

**Generación:**
- Tres números aleatorios entre 1 y 100
- Almacenar resultado correcto para validación

**Validación:**
- Comparar respuesta numérica con suma calculada
- Aceptar respuestas en formato string o number

## Memoria

**Generación:**
- Secuencia de 5 números entre 1 y 20
- Seleccionar pregunta aleatoria de estas opciones:
  1. "¿Había exactamente 2 números pares?" | CODIGO: "2PARES"
  2. "¿Había exactamente 2 números impares?" | CODIGO: "2IMPARES"
  3. "¿La suma de todos los números superaba 50?" | CODIGO: "SUMATODOMAYOR50"
  4. "¿Había 2 números iguales?" | CODIGO: "2IGUALES"
  5. "¿Había algún número menor a 10?" | CODIGO: "ALGUNO_MENOR10"

**Validación:**
- Evaluar lógicamente cada tipo de pregunta
- Aceptar respuestas: "Sí"/"No", "Si"/"No", "true"/"false" (case insensitive)

## Lógica

**Generación:**
- Tres números aleatorios entre 1 y 100
- Seleccionar proposición aleatoria:
  1. "Exactamente 2 números son pares" | CODIGO: "2PARES"
  2. "La suma de los 3 números es par" | CODIGO: "SUMA_PAR"
  3. "El número mayor es mayor que la suma de los otros dos" | CODIGO: "MAYOR_SUMA_OTROS"
  4. "Hay al menos un número mayor que 50" | CODIGO: "ALGUNO_MAYOR50"
  5. "Todos los números son diferentes" | CODIGO: "TODOS_DIFERENTES"

**Validación:**
- Evaluar proposición lógicamente
- Aceptar respuestas: "Verdadero"/"Falso", "True"/"False" (case insensitive)

---

# Estructura Sugerida del Repositorio

```
MinijuegosAPI/
├── README.md                           # Instrucciones de instalación y uso
├── .gitignore                          # Archivos a ignorar por Git
├── MinijuegosAPI.sln                   # Solución de Visual Studio
├── 
├── MinijuegosAPI/                      # Proyecto principal
│   ├── Controllers/
│   │   └── MinijuegosController.cs     # Controller principal
│   ├── Models/
│   │   ├── PreguntaResponse.cs         # DTOs de response
│   │   ├── ValidarRequest.cs           # DTOs de request
│   │   └── Pregunta.cs                 # Entidad para BD
│   ├── Services/
│   │   ├── IMinijuegoService.cs        # Interface del servicio
│   │   └── MinijuegoService.cs         # Lógica de los 3 minijuegos
│   ├── Data/
│   │   └── ApplicationDbContext.cs     # Contexto de EF
│   ├── Program.cs                      # Configuración de la app
│   └── appsettings.json                # Configuración
├── 
├── docs/
│   ├── diagrama-clases.png             # Diagrama de clases
│   └── diagrama-mer.png                # Diagrama MER
│
└── MinijuegosAPI.Tests/                # Tests
    ├── Controllers/
    │   └── MinijuegosControllerTests.cs
    └── Services/
        └── MinijuegoServiceTests.cs
```

---

# Criterios de Evaluación

## **Funcionalidad de API (40%)**
- Endpoints funcionando correctamente según especificación
- Lógica de generación de preguntas implementada
- Validación de respuestas funcionando para los 3 tipos
- Manejo apropiado de errores y códigos de estado HTTP
- Persistencia de preguntas con TTL

## **Arquitectura y Código (25%)**
- Implementación de patrones (Repository, DI, DTOs)
- Separación apropiada de responsabilidades
- Código limpio y bien estructurado
- Configuración correcta de Entity Framework
- Middleware personalizado implementado

## **Documentación de API (15%)**
- Swagger/OpenAPI completamente configurado
- Documentación XML en controllers
- Colección de Postman funcional
- README con instrucciones claras de instalación
- Diagramas técnicos apropiados

## **Testing y Calidad (15%)**
- **Cobertura de tests mínima del 80%**
- Tests unitarios para servicios y controllers
- Tests de integración para endpoints
- Tests de validación y casos edge
- Tests automatizados ejecutándose correctamente

## **Principios REST y Buenas Prácticas (5%)**
- Uso correcto de verbos HTTP
- Estructura apropiada de URLs
- Headers y content-types correctos
- Versionado de API (opcional para nota extra)
- Rate limiting implementado (opcional para nota extra)

---

# Tecnologías Requeridas

## **Backend**
- **ASP.NET Core .NET 8** - Framework principal para Web API
- **Entity Framework Core** - ORM para base de datos
- **SQL Server / SQLite** - Base de datos
- **Swagger/Swashbuckle** - Documentación automática de API
- **xUnit** - Framework de testing unitario
- **Moq** - Framework para mocking en tests

## **Herramientas**
- **Visual Studio / VS Code** - IDE
- **Git** - Control de versiones
- **GitHub** - Repositorio remoto
- **Draw.io / Lucidchart** - Para diagramas

---

# Fechas Importantes

**Fecha de entrega:**  Viernes 21 de Noviembre. 21/11/2025
**Modalidad de entrega:** Defensa oral con demo de API funcionando  
**Requisitos de entrega:**
- Repositorio GitHub público con código completo
- API desplegada localmente y funcionando durante la defensa
- Swagger UI accesible y documentado
- Tests pasando con cobertura >80%

---

# Contacto

Para dudas técnicas o consultas sobre el proyecto, contactar al profesor por correo Whatsapp incluyendo:
- Descripción específica de la duda
- Código relevante (si aplica)
- Screenshots del problema (si aplica)
- Requests/responses de Postman (si aplica)
