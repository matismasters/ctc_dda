# Clase 7 – Testing en Aplicaciones MVC: Fundamentos y Primeros Pasos

**Duración:** 3 horas  
**Objetivo general:** comprender los **tipos fundamentales de testing** en aplicaciones web MVC, distinguir cuándo y por qué usar **tests unitarios vs tests de integración**, aprender la **arquitectura de testing** en ASP.NET Core con **xUnit**, y aplicar estos conceptos para **testear acciones de controladores y endpoints** siguiendo las mejores prácticas profesionales.

---

## Índice

1. Módulo 1 — ¿Por qué testear aplicaciones web? (Conceptos fundamentales)
2. Módulo 2 — Anatomía del testing en MVC (Capas y responsabilidades)
3. Módulo 3 — Tests unitarios vs Tests de integración (Cuándo usar cada uno)
4. Módulo 4 — Configuración y primeros tests con TestServer
5. Recursos para testing avanzado
6. Comandos y herramientas de testing
7. Glosario de términos de testing
8. Cierre

---

## Módulo 1 — ¿Por qué testear aplicaciones web? (Conceptos fundamentales)

> Las aplicaciones web tienen **múltiples capas interactuando**: controladores, servicios, persistencia, validaciones y UI. Cada capa puede fallar de formas diferentes, y el testing nos permite **detectar problemas antes que los usuarios cada vez que hacemos cambios**.

### 1.1 Los riesgos únicos de las aplicaciones web

**Diferencias con aplicaciones de consola:**

* **Estado compartido**: múltiples usuarios acceden simultáneamente
* **Protocolos HTTP**: status codes, headers, rutas, verbos
* **Integración compleja**: bases de datos, servicios externos, autenticación
* **UI dinámico**: formularios, validaciones, experiencia de usuario

### 1.2 El costo de los errores en producción

**Sin testing automatizado:**

* **Detección tardía**: los errores los encuentran los usuarios finales
* **Cascada de problemas**: un error en un controlador puede afectar múltiples funcionalidades
* **Pérdida de confianza**: cada deploy es una apuesta
* **Tiempo de corrección**: debugging en producción bajo presión

**Con testing automatizado:**

* **Detección temprana**: errores encontrados en segundos, no semanas
* **Refactoring seguro**: cambios con confianza de no romper funcionalidad existente
* **Documentación viva**: los tests muestran cómo se espera que funcione el código
* **Velocidad de desarrollo**: menos tiempo debuggeando, más tiempo construyendo

### 1.3 ¿Qué hace especial al testing en MVC?

```csharp
// En consola testeábamos así (simple):
[Fact]
public void Sumar_DosNumeros_RetornaSuma()
{
    // Arrange - Act - Assert directo
    Assert.Equal(5, Calculadora.Sumar(2, 3));
}

// En MVC necesitamos considerar más elementos:
// - HTTP Request/Response
// - Routing y Model Binding  
// - Dependencias (Services, DbContext)
// - Estado de la aplicación
// - Autenticación/Autorización
```

**La complejidad adicional requiere estrategias diferentes.**

---

## Módulo 2 — Anatomía del testing en MVC (Capas y responsabilidades)

> Objetivo: entender **qué testear en cada capa** y **cómo estructurar** un proyecto de testing profesional.

### 2.1 Las capas de una aplicación MVC y sus responsabilidades

**Capa de Presentación (Views/UI):**
* Renderizado de HTML/CSS/JavaScript
* Formularios y validaciones del lado cliente
* Experiencia de usuario
* Presentación de datos

**Capa de Aplicación/Coordinación (Controllers):**
* Recibir requests HTTP
* Validar entrada del usuario
* Coordinar llamadas a servicios
* Retornar responses apropiados
* Manejo de routing y model binding

**Capa de Negocio (Services):**
* Lógica de dominio pura
* Reglas de negocio
* Validaciones complejas
* Orquestación de operaciones

**Capa de Datos (Repositories/DbContext):**
* Persistencia y recuperación
* Consultas específicas
* Transacciones

### 2.2 Estrategias de testing por capa

**Views (Presentación): Testing de UI/UX:**
* Testing visual y de componentes (fuera del scope de esta clase)
* Validaciones del lado cliente
* Comportamiento de JavaScript

**Controllers (Coordinación): Orquestación, no lógica:**
```csharp
// ❌ Mal: Controller con lógica compleja (difícil de testear)
public IActionResult CalcularDescuento(int cantidad, decimal precio)
{
    decimal descuento = 0;
    if (cantidad > 10 && cantidad < 50) descuento = 0.05m;
    else if (cantidad >= 50) descuento = 0.10m;
    
    decimal total = precio * cantidad * (1 - descuento);
    return Ok(new { Total = total });
}

// ✅ Bien: Controller delgado, lógica en servicio (fácil de testear)
public IActionResult CalcularDescuento(int cantidad, decimal precio)
{
    var resultado = _calculadoraService.CalcularTotal(cantidad, precio);
    return Ok(resultado);
}
```

**Services: Lógica pura y testeable:**
```csharp
// ✅ Servicio con lógica aislada
public class CalculadoraService
{
    public decimal CalcularTotal(int cantidad, decimal precio)
    {
        var descuento = ObtenerDescuento(cantidad);
        return precio * cantidad * (1 - descuento);
    }
    
    private decimal ObtenerDescuento(int cantidad) => cantidad switch
    {
        >= 50 => 0.10m,
        >= 10 => 0.05m,
        _ => 0.00m
    };
}
```

### 2.3 Estructura de proyecto para testing

```
Solucion/
├── src/
│   ├── MiApp.Web/          # Proyecto MVC
│   ├── MiApp.Core/         # Servicios y lógica
│   └── MiApp.Data/         # Repositorios y DbContext
└── tests/
    ├── MiApp.UnitTests/    # Tests unitarios (Services, lógica)
    └── MiApp.IntegrationTests/  # Tests de integración (Controllers, endpoints)
```

**¿Por qué separar Unit vs Integration tests?**

* **Velocidad**: unitarios corren en milisegundos, integración en segundos
* **Propósito**: unitarios verifican lógica, integración verifica coordinación
* **Dependencias**: unitarios no necesitan base de datos, integración sí
* **Debugging**: unitarios pinpoint exacto del problema, integración scope amplio

---

## Módulo 3 — Tests unitarios vs Tests de integración (Cuándo usar cada uno)

> Objetivo: **tomar decisiones informadas** sobre qué tipo de test escribir para cada escenario.

### 3.1 Tests Unitarios: "Esta pieza funciona correctamente"

**Características:**
* **Velocidad**: < 10ms por test
* **Aislamiento**: no dependen de DB, HTTP, FileSystem
* **Scope**: un método, una clase
* **Propósito**: verificar lógica algorítmica y reglas de negocio

**Cuándo usar:**
* Cálculos y transformaciones de datos
* Validaciones complejas
* Lógica de negocio pura
* Servicios con dependencias mockeable

```csharp
// Ejemplo conceptual: Test unitario para servicio
[Fact]
public void CalcularDescuento_CantidadMayor50_Aplica10Porciento()
{
    // Arrange
    var calculadora = new CalculadoraService();
    
    // Act
    decimal total = calculadora.CalcularTotal(cantidad: 60, precio: 100m);
    
    // Assert
    Assert.Equal(5400m, total); // 60 * 100 * 0.9
}
```

### 3.2 Tests de Integración: "Las piezas trabajan juntas correctamente"

**Características:**
* **Velocidad**: 100ms - 5s por test
* **Realismo**: usa DB real (o in-memory), HTTP real
* **Scope**: múltiples capas, end-to-end de una funcionalidad
* **Propósito**: verificar que la integración funciona

**Cuándo usar:**
* Endpoints y controladores completos
* Flujos que involucran múltiples servicios
* Validación de routing y model binding
* Comportamiento con base de datos real

```csharp
// Ejemplo conceptual: Test de integración para endpoint
[Fact]
public async Task POST_CalcularDescuento_ReturnsCorrectTotal()
{
    // Arrange: configurar TestServer con app completa
    
    // Act: hacer HTTP request real
    var response = await client.PostAsync("/api/descuentos", content);
    
    // Assert: verificar HTTP response
    response.EnsureSuccessStatusCode();
    var resultado = await response.Content.ReadFromJsonAsync<DescuentoDto>();
    Assert.Equal(5400m, resultado.Total);
}
```

### 3.3 La pirámide de testing aplicada a MVC

**Distribución recomendada:**
```
     /\     <- E2E Tests (pocos, críticos)
    /  \
   /    \   <- Integration Tests (moderados)
  /      \
 /        \
/__________\ <- Unit Tests (muchos, rápidos)
```

**En números prácticos:**
* **70% Unit Tests**: servicios, validaciones, cálculos
* **25% Integration Tests**: controladores, endpoints importantes
* **5% E2E Tests**: flujos de usuario críticos

### 3.4 Decisión práctica: "¿Qué tipo de test escribo?"

**Pregúntate:**

1. **¿Puedo testear esto sin HTTP/DB?** → Unit Test
2. **¿Necesito verificar routing/model binding?** → Integration Test  
3. **¿Es lógica de negocio pura?** → Unit Test
4. **¿Es coordinación entre capas?** → Integration Test
5. **¿Necesito verificar la respuesta HTTP completa?** → Integration Test

---

## Módulo 4 — Configuración y primeros tests con TestServer

> Objetivo: **configurar el entorno de testing** para MVC y escribir los primeros tests de integración usando **TestServer**.

### 4.1 ¿Qué es TestServer y por qué usarlo?

**TestServer** es el mecanismo de ASP.NET Core para crear una **instancia completa** de tu aplicación web **en memoria** para testing.

**Beneficios:**
* **Realismo**: usa tu aplicación real, no mocks
* **Velocidad**: no necesita IIS ni sockets de red
* **Control**: puedes configurar base de datos específica para tests
* **Isolación**: cada test tiene su propia instancia

### 4.2 Configuración básica de Integration Tests

```bash
# Crear proyecto de tests de integración
dotnet new xunit -n MiApp.IntegrationTests
cd MiApp.IntegrationTests

# Agregar paquetes necesarios
dotnet add package Microsoft.AspNetCore.Mvc.Testing
dotnet add package Microsoft.EntityFrameworkCore.InMemory

# Referenciar proyecto web
dotnet add reference ../MiApp.Web/MiApp.Web.csproj
```

### 4.3 Anatomia de un Integration Test básico

**Elementos necesarios:**

1. **WebApplicationFactory**: fabrica que crea TestServer
2. **HttpClient**: cliente para hacer requests
3. **Setup de DB**: configurar base de datos para tests
4. **Cleanup**: limpiar estado entre tests

```csharp
// Estructura conceptual (sin implementación completa)
public class CalculadoraControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    
    public CalculadoraControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task GET_Calculadora_ReturnsSuccessStatusCode()
    {
        // Arrange: el setup ya está hecho en constructor
        
        // Act: hacer request real
        var response = await _client.GetAsync("/calculadora");
        
        // Assert: verificar response
        response.EnsureSuccessStatusCode();
    }
}
```

### 4.4 Testing de diferentes tipos de endpoints

**GET Endpoints (lectura):**
* Verificar status code correcto
* Validar estructura de response
* Comprobar headers si aplica

**POST Endpoints (escritura):**
* Verificar que acepta modelo válido
* Validar response de creación exitosa
* Comprobar que rechaza modelo inválido
* Verificar que datos se persisten correctamente

**Error Handling:**
* Verificar status codes de error apropiados
* Validar mensajes de error
* Comprobar comportamiento con datos inválidos

### 4.5 Por qué esta aproximación es profesional

* **Confianza real**: testa tu aplicación como la usa el usuario
* **Detección temprana**: encuentra problemas de integración antes del deploy
* **Refactoring seguro**: cambios en controladores con seguridad
* **Documentación viva**: los tests muestran cómo usar tu API
* **Base para CI/CD**: estos tests corren automáticamente en cada push

---

## Recursos para testing avanzado

### Librerías complementarias

* **FluentAssertions**: assertions más expresivos y legibles
* **Bogus**: generación de datos de prueba realistas
* **Moq/NSubstitute**: mocking para unit tests
* **Testcontainers**: base de datos real en Docker para tests

### Herramientas de análisis

```bash
# Cobertura de código
dotnet add package coverlet.collector
dotnet test --collect:"XPlat Code Coverage"

# Reportes de cobertura
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage
```

---

## Comandos y herramientas de testing

### Comandos esenciales

```bash
# Ejecutar todos los tests
dotnet test

# Ejecutar tests específicos
dotnet test --filter "Category=Integration"
dotnet test --filter "FullyQualifiedName~CalculadoraController"

# Tests con detalles
dotnet test --verbosity normal
dotnet test --logger "console;verbosity=detailed"

# Tests en paralelo/secuencial
dotnet test --parallel    # (default)
dotnet test --no-parallel # para tests con recursos compartidos
```

### Configuración de test categories

```csharp
// Categorizar tests
[Fact, Trait("Category", "Unit")]
public void UnitTest_Example() { }

[Fact, Trait("Category", "Integration")]  
public void IntegrationTest_Example() { }
```

---

## Glosario de términos de testing

* **TestServer**: servidor web en memoria para testing de integración en ASP.NET Core
* **WebApplicationFactory**: factoría que configura y crea instancias de TestServer
* **Integration Test**: test que verifica interacción entre múltiples componentes reales
* **Unit Test**: test que verifica comportamiento de una unidad aislada de código
* **Test Double**: objeto falso usado en tests (mock, stub, fake, spy)
* **Arrange-Act-Assert (AAA)**: patrón para estructurar tests claramente
* **Test Fixture**: configuración compartida entre múltiples tests
* **HttpClient**: cliente HTTP usado para hacer requests en integration tests
* **In-Memory Database**: base de datos temporal en memoria para tests
* **Mocking**: técnica de reemplazar dependencias reales con objetos simulados
* **Code Coverage**: métrica que indica qué porcentaje del código está cubierto por tests
* **Test Category/Trait**: etiqueta para agrupar y filtrar tests por tipo o características

---

## Anexo 1 — Ejercicio: Primeros Integration Tests

**Instrucciones:**

1. **Configurar proyecto de integration tests:**
   * Crear proyecto `MiApp.IntegrationTests` con xUnit
   * Agregar referencia a `Microsoft.AspNetCore.Mvc.Testing`
   * Referenciar el proyecto web principal

2. **Implementar test básico de endpoint existente:**
   * Crear clase `HomeControllerTests`
   * Testear que `GET /` retorna status 200
   * Verificar que el response contiene contenido HTML válido

3. **Agregar test para endpoint con parámetros:**
   * Si tienes controlador con acciones que reciben parámetros
   * Testear con parámetros válidos e inválidos
   * Verificar responses y status codes apropiados

4. **Documentar y reflexionar:**
   * ¿Qué diferencias notas vs tests unitarios de consola?
   * ¿Qué problemas potenciales podrían detectar estos tests?
   * ¿Cómo se siente la velocidad de ejecución comparada?

**Criterio de éxito:** tests que corren exitosamente y verifican comportamiento real de endpoints.

---

## Anexo 2 — Ejercicio Completo: Testing de CRUD Controller

**Instrucciones:**

1. **Preparación del escenario:**
   * Usar un controller existente con operaciones CRUD
   * O crear un `ProductosController` simple con Get/Post/Put/Delete
   * Configurar Entity Framework In-Memory para tests

2. **Implementar tests de integración:**
   * `GET /productos` - retorna lista de productos
   * `POST /productos` - crea producto nuevo
   * `GET /productos/{id}` - retorna producto específico
   * `PUT /productos/{id}` - actualiza producto
   * `DELETE /productos/{id}` - elimina producto

3. **Tests de casos edge:**
   * GET con ID inexistente retorna 404
   * POST con modelo inválido retorna 400
   * PUT con ID mismatch retorna error apropiado
   * DELETE de elemento inexistente maneja correctamente

4. **Organización y limpieza:**
   * Usar `IClassFixture` para setup compartido
   * Implementar limpieza de base de datos entre tests
   * Categorizar tests apropiadamente

5. **Reflexión y documentación:**
   * Comparar velocidad vs tests unitarios
   * Identificar qué errores pueden detectar estos tests
   * Evaluar confianza ganada vs esfuerzo invertido

**Entregables:**
* Proyecto de integration tests funcionando
* Mínimo 8 tests cubriendo escenarios principales
* README explicando cómo ejecutar tests
* Análisis personal del valor agregado

---

## Cierre

### Transformación lograda

**❌ Enfoque anterior (sin tests de MVC):**
```csharp
// Desarrollar → Deployar → Esperar que funcione → Usuario encuentra bug
public IActionResult Crear(ProductoDto dto)
{
    // Código sin tests que puede fallar en producción
    return Ok();
}
```

**✅ Enfoque profesional (con testing strategy):**
```csharp
// Unit test para lógica + Integration test para endpoint
[Fact] public void ValidarProducto_ModeloValido_ReturnsTrue() { ... }
[Fact] public async Task POST_Productos_CreatesAndReturns201() { ... }
```

### Para recordar

> **"En MVC testing is not optional, it's professional responsibility"**

El testing en aplicaciones web no es un lujo: es la diferencia entre código que funciona por casualidad y código que funciona por diseño. La inversión inicial en tests se recupera multiplicada en confianza, velocidad y calidad.
