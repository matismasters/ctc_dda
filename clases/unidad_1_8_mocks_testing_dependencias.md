# Clase 8 – Mocks: Testing con Dependencias Aisladas

**Duración:** 3 horas  
**Objetivo general:** comprender **por qué y cuándo necesitamos aislar dependencias** en testing, distinguir entre **mocks, stubs, fakes y spies**, aprender a usar **Moq** para crear test doubles profesionales, y aplicar estos conceptos para **testear controladores y servicios** que dependen de bases de datos, servicios externos o recursos costosos.

---

## Índice

1. Módulo 1 — El problema de las dependencias en testing
2. Módulo 2 — Test Doubles: Mocks, Stubs, Fakes y Spies  
3. Módulo 3 — Moq en acción: Primeros mocks profesionales
4. Módulo 4 — Testing de Controllers con dependencias mockeadas
5. Recursos para mocking avanzado
6. Mejores prácticas y anti-patrones
7. Glosario de términos de mocking
8. Cierre

---

## Módulo 1 — El problema de las dependencias en testing

> En el mundo real, nuestras clases **no existen aisladas**. Un controlador depende de servicios, un servicio depende de repositorios, un repositorio depende de base de datos. ¿Cómo testeamos algo que depende de **recursos externos, lentos o impredecibles**?

### 1.1 ¿Qué hace que el testing sea difícil?

**El escenario típico:**

```csharp
// Un controlador con dependencias reales
public class ProductosController : ControllerBase
{
    private readonly IProductoService _productoService;
    private readonly IEmailService _emailService;
    private readonly ILoggingService _logger;
    
    public ProductosController(IProductoService productoService, 
                              IEmailService emailService,
                              ILoggingService logger)
    {
        _productoService = productoService;
        _emailService = emailService;  
        _logger = logger;
    }
    
    [HttpPost]
    public async Task<IActionResult> CrearProducto(ProductoDto dto)
    {
        var producto = await _productoService.CrearAsync(dto);
        await _emailService.EnviarNotificacionAsync(producto);
        _logger.LogInfo($"Producto creado: {producto.Id}");
        return CreatedAtAction(nameof(ObtenerProducto), new { id = producto.Id }, producto);
    }
}
```

**¿Cómo testeo `CrearProducto` sin...?**

* ❌ **Conectar a base de datos real** (lento, estado compartido)
* ❌ **Enviar emails reales** (costoso, efectos secundarios)
* ❌ **Escribir logs reales** (contaminación de archivos)
* ❌ **Depender de servicios externos** (pueden estar offline)

### 1.2 El costo de dependencias reales en tests

**Tests frágiles y lentos:**

* **Velocidad**: tests que tardan segundos en lugar de milisegundos
* **Fiabilidad**: tests que fallan por razones ajenas al código bajo prueba
* **Preparación compleja**: setup de base de datos, servicios, configuración
* **Efectos secundarios**: modificación de estado global o externo
* **Determinismo perdido**: resultados que varían según el entorno

**Tests que no son unitarios:**

```csharp
// ❌ Este NO es un test unitario (depende de recursos externos)
[Fact]
public async Task CrearProducto_ProductoValido_GuardaEnBaseDatos()
{
    var controller = new ProductosController(
        new ProductoService(new DatabaseContext()), // BD real
        new SmtpEmailService(config),               // Email real  
        new FileLogger("/logs/test.log")            // Archivo real
    );
    
    // Este test es lento, frágil y puede fallar por muchas razones
    // que no tienen que ver con la lógica del controlador
}
```

### 1.3 La solución: Aislamiento mediante Test Doubles

**Test Doubles = actores de repuesto:**

Como en el cine, donde un **doble de riesgo** reemplaza al actor principal en escenas peligrosas, los **test doubles** reemplzan dependencias reales en escenarios de testing.

**Beneficios del aislamiento:**

* **Velocidad**: tests en memoria, sin I/O
* **Determinismo**: comportamiento predecible y controlado
* **Foco**: testear únicamente la lógica bajo prueba
* **Independencia**: tests que no dependen de infraestructura externa

---

## Módulo 2 — Test Doubles: Mocks, Stubs, Fakes y Spies

> Objetivo: entender **qué tipo de test double usar** en cada situación y **por qué existe esta taxonomía**.

### 2.1 La familia de Test Doubles

**No todos los "objetos falsos" son iguales:**

* **Dummy**: objeto que se pasa pero nunca se usa
* **Stub**: devuelve respuestas predefinidas
* **Fake**: implementación simplificada que funciona  
* **Mock**: verifica interacciones y comportamiento
* **Spy**: registra información sobre cómo fue usado

### 2.2 Dummy Objects - "Solo necesito algo que compile"

```csharp
// Cuando necesitas pasar un parámetro pero no lo usas
public class CalculadoraService
{
    public CalculadoraService(ILogger logger) { /* logger se guarda pero no se usa en este test */ }
    
    public decimal Sumar(decimal a, decimal b) => a + b; // método que no usa logger
}

[Fact]
public void Sumar_DosNumeros_RetornaSuma()
{
    // Dummy: solo para que compile, nunca se usa
    var dummyLogger = new Mock<ILogger>().Object;
    var calculadora = new CalculadoraService(dummyLogger);
    
    var resultado = calculadora.Sumar(2m, 3m);
    
    Assert.Equal(5m, resultado);
}
```

### 2.3 Stubs - "Devuelve lo que necesito"

```csharp
// Stub: configura respuestas predefinidas
[Fact]
public void CrearProducto_PrecioValido_CalculaDescuentoCorrectamente()
{
    // Arrange: configurar stub para devolver descuento específico
    var stubDescuentoService = new Mock<IDescuentoService>();
    stubDescuentoService.Setup(x => x.ObtenerDescuento(It.IsAny<decimal>()))
                       .Returns(0.1m); // siempre retorna 10%
    
    var service = new ProductoService(stubDescuentoService.Object);
    
    // Act
    var precio = service.CalcularPrecioFinal(100m);
    
    // Assert: verificar que usó correctamente el descuento
    Assert.Equal(90m, precio);
}
```

### 2.4 Fakes - "Una implementación real pero simple"

```csharp
// Fake: implementación en memoria que realmente funciona
public class FakeProductoRepository : IProductoRepository
{
    private readonly List<Producto> _productos = new();
    
    public async Task<Producto> ObtenerAsync(int id)
        => _productos.FirstOrDefault(p => p.Id == id);
    
    public async Task GuardarAsync(Producto producto)
    {
        producto.Id = _productos.Count + 1;
        _productos.Add(producto);
    }
}

[Fact]
public async Task CrearProducto_ProductoValido_LoGuardaCorrectamente()
{
    // Fake repository que funciona en memoria
    var fakeRepository = new FakeProductoRepository();
    var service = new ProductoService(fakeRepository);
    
    var producto = await service.CrearAsync(new ProductoDto { Nombre = "Test" });
    
    var guardado = await fakeRepository.ObtenerAsync(producto.Id);
    Assert.Equal("Test", guardado.Nombre);
}
```

### 2.5 Mocks - "Verificar que se llamó correctamente"

```csharp
// Mock: verifica comportamiento e interacciones
[Fact]
public async Task CrearProducto_ProductoValido_EnviaNotificacion()
{
    // Arrange: mock que verifica interacciones
    var mockEmailService = new Mock<IEmailService>();
    var service = new ProductoService(mockEmailService.Object);
    
    // Act
    await service.CrearAsync(new ProductoDto { Nombre = "Test" });
    
    // Assert: verificar que se llamó el método correcto
    mockEmailService.Verify(x => x.EnviarNotificacionAsync(It.IsAny<Producto>()), 
                           Times.Once);
}
```

### 2.6 Spies - "¿Qué pasó exactamente?"

```csharp
// Spy: registra información sobre las llamadas
[Fact]
public async Task ProcesarPedido_PedidoComplejo_LogeaPassosCorrectamente()
{
    var spyLogger = new Mock<ILogger>();
    var service = new PedidoService(spyLogger.Object);
    
    await service.ProcesarAsync(pedidoComplejo);
    
    // Verificar secuencia específica de logs
    spyLogger.Verify(x => x.LogInfo("Iniciando procesamiento"), Times.Once);
    spyLogger.Verify(x => x.LogInfo("Validando datos"), Times.Once);
    spyLogger.Verify(x => x.LogInfo("Guardando en base de datos"), Times.Once);
}
```

### 2.7 ¿Cuándo usar cada tipo?

**Decisión práctica:**

* **Dummy**: cuando necesitas pasar una dependencia pero no la usas
* **Stub**: cuando necesitas datos específicos de dependencias  
* **Fake**: cuando necesitas funcionalidad real pero simple (ej: repositorio en memoria)
* **Mock**: cuando lo importante es **verificar que se llamó** a la dependencia
* **Spy**: cuando necesitas inspeccionar **cómo se usó** la dependencia

---

## Módulo 3 — Moq en acción: Primeros mocks profesionales

> Objetivo: aprender la **sintaxis y capacidades de Moq** para crear test doubles efectivos en C#.

### 3.1 ¿Por qué Moq?

**Moq** es la librería de mocking más popular en .NET porque:

* **Sintaxis fluida**: fácil de leer y escribir
* **Verificaciones expresivas**: múltiples formas de verificar interacciones
* **Configuración flexible**: desde comportamientos simples hasta complejos
* **Integración perfecta**: funciona nativamente con xUnit, NUnit, MSTest

### 3.2 Instalación y configuración básica

```bash
# Agregar Moq al proyecto de tests
dotnet add package Moq
```

### 3.3 Sintaxis fundamental de Moq

**Crear un mock:**

```csharp
// Crear mock de una interfaz
var mock = new Mock<IEmailService>();

// Obtener el objeto mockeado
IEmailService emailService = mock.Object;
```

**Setup básico - configurar comportamiento:**

```csharp
// Setup: configurar qué debe retornar un método
mock.Setup(x => x.ValidarEmail("test@email.com"))
    .Returns(true);

// Setup con cualquier parámetro
mock.Setup(x => x.ValidarEmail(It.IsAny<string>()))
    .Returns(false);

// Setup para métodos async
mock.Setup(x => x.EnviarAsync(It.IsAny<string>()))
    .ReturnsAsync(true);
```

**Verify - verificar interacciones:**

```csharp
// Verificar que se llamó exactamente una vez
mock.Verify(x => x.EnviarAsync("mensaje"), Times.Once);

// Verificar que nunca se llamó
mock.Verify(x => x.EliminarTodo(), Times.Never);

// Verificar cantidad específica de llamadas
mock.Verify(x => x.LogInfo(It.IsAny<string>()), Times.Exactly(3));
```

### 3.4 Ejemplo completo: Mock de Repository

```csharp
[Fact]
public async Task ActualizarProducto_ProductoExistente_ActualizaCorrectamente()
{
    // Arrange
    var mockRepository = new Mock<IProductoRepository>();
    var productoExistente = new Producto { Id = 1, Nombre = "Original" };
    
    // Setup: configurar comportamiento del mock
    mockRepository.Setup(r => r.ObtenerPorIdAsync(1))
                  .ReturnsAsync(productoExistente);
    
    mockRepository.Setup(r => r.ActualizarAsync(It.IsAny<Producto>()))
                  .Returns(Task.CompletedTask);
    
    var service = new ProductoService(mockRepository.Object);
    var dto = new ProductoDto { Id = 1, Nombre = "Actualizado" };
    
    // Act
    await service.ActualizarAsync(dto);
    
    // Assert: verificar que se llamaron los métodos correctos
    mockRepository.Verify(r => r.ObtenerPorIdAsync(1), Times.Once);
    mockRepository.Verify(r => r.ActualizarAsync(It.Is<Producto>(p => p.Nombre == "Actualizado")), 
                         Times.Once);
}
```

### 3.5 Matchers avanzados con It.Is()

```csharp
// Verificar propiedades específicas del parámetro
mock.Verify(x => x.GuardarProducto(
    It.Is<Producto>(p => p.Precio > 0 && p.Nombre.Length > 3)
), Times.Once);

// Verificar múltiples condiciones
mock.Verify(x => x.EnviarEmail(
    It.Is<Email>(e => e.Destinatario.Contains("@") && 
                      e.Asunto.StartsWith("Notificación"))
), Times.Once);
```

### 3.6 Por qué Moq es una herramienta profesional

* **Tests rápidos**: sin I/O ni dependencias externas
* **Tests deterministas**: comportamiento predecible en cada ejecución  
* **Tests focalizados**: testear solo la lógica bajo prueba
* **Documentación**: los mocks muestran qué dependencias necesita tu código
* **Refactoring seguro**: cambios en implementación detectados inmediatamente

---

## Módulo 4 — Testing de Controllers con dependencias mockeadas

> **Meta general:** aplicar mocking para testear **controllers de MVC** que dependen de servicios, repositorios y recursos externos.

### 4.1 El desafío: Controllers con múltiples dependencias

**Escenario típico:**

```csharp
public class ProductosController : ControllerBase
{
    private readonly IProductoService _productoService;
    private readonly ICacheService _cacheService;
    private readonly IAuthorizationService _authService;
    
    [HttpGet("{id}")]
    public async Task<IActionResult> ObtenerProducto(int id)
    {
        if (!await _authService.TienePermisoAsync(User, "producto:read"))
            return Forbid();
            
        var cacheKey = $"producto_{id}";
        var producto = await _cacheService.ObtenerAsync<Producto>(cacheKey);
        
        if (producto == null)
        {
            producto = await _productoService.ObtenerPorIdAsync(id);
            if (producto == null)
                return NotFound();
                
            await _cacheService.GuardarAsync(cacheKey, producto, TimeSpan.FromMinutes(5));
        }
        
        return Ok(producto);
    }
}
```

**¿Cómo testear este controller sin?**
* Sistema de autenticación real
* Cache Redis real  
* Base de datos real

### 4.2 Estrategia: Mock de todas las dependencias

```csharp
public class ProductosControllerTests
{
    private readonly Mock<IProductoService> _mockProductoService;
    private readonly Mock<ICacheService> _mockCacheService;
    private readonly Mock<IAuthorizationService> _mockAuthService;
    private readonly ProductosController _controller;
    
    public ProductosControllerTests()
    {
        _mockProductoService = new Mock<IProductoService>();
        _mockCacheService = new Mock<ICacheService>();
        _mockAuthService = new Mock<IAuthorizationService>();
        
        _controller = new ProductosController(
            _mockProductoService.Object,
            _mockCacheService.Object,
            _mockAuthService.Object
        );
    }
}
```

### 4.3 Test de caso exitoso (happy path)

```csharp
[Fact]
public async Task ObtenerProducto_UsuarioAutorizado_ProductoEnCache_ReturnaProducto()
{
    // Arrange
    var productoId = 1;
    var productoCacheado = new Producto { Id = productoId, Nombre = "Producto Test" };
    
    // Setup: usuario autorizado
    _mockAuthService.Setup(x => x.TienePermisoAsync(It.IsAny<ClaimsPrincipal>(), "producto:read"))
                   .ReturnsAsync(true);
    
    // Setup: producto en cache
    _mockCacheService.Setup(x => x.ObtenerAsync<Producto>($"producto_{productoId}"))
                    .ReturnsAsync(productoCacheado);
    
    // Act
    var result = await _controller.ObtenerProducto(productoId);
    
    // Assert
    var okResult = Assert.IsType<OkObjectResult>(result);
    var producto = Assert.IsType<Producto>(okResult.Value);
    Assert.Equal(productoId, producto.Id);
    
    // Verify: no debió llamar al servicio (estaba en cache)
    _mockProductoService.Verify(x => x.ObtenerPorIdAsync(It.IsAny<int>()), Times.Never);
}
```

### 4.4 Test de caso de error (unauthorized)

```csharp
[Fact]
public async Task ObtenerProducto_UsuarioNoAutorizado_ReturnaForbid()
{
    // Arrange
    _mockAuthService.Setup(x => x.TienePermisoAsync(It.IsAny<ClaimsPrincipal>(), "producto:read"))
                   .ReturnsAsync(false);
    
    // Act
    var result = await _controller.ObtenerProducto(1);
    
    // Assert
    Assert.IsType<ForbidResult>(result);
    
    // Verify: no debió llamar a cache ni servicio
    _mockCacheService.Verify(x => x.ObtenerAsync<Producto>(It.IsAny<string>()), Times.Never);
    _mockProductoService.Verify(x => x.ObtenerPorIdAsync(It.IsAny<int>()), Times.Never);
}
```

### 4.5 Test de flujo completo (cache miss)

```csharp
[Fact]
public async Task ObtenerProducto_CacheMiss_ProductoExiste_GuardaEnCacheYRetorna()
{
    // Arrange
    var productoId = 1;
    var producto = new Producto { Id = productoId, Nombre = "Producto Test" };
    
    _mockAuthService.Setup(x => x.TienePermisoAsync(It.IsAny<ClaimsPrincipal>(), "producto:read"))
                   .ReturnsAsync(true);
    
    // Cache miss
    _mockCacheService.Setup(x => x.ObtenerAsync<Producto>($"producto_{productoId}"))
                    .ReturnsAsync((Producto)null);
    
    // Producto existe en servicio
    _mockProductoService.Setup(x => x.ObtenerPorIdAsync(productoId))
                       .ReturnsAsync(producto);
    
    // Act
    var result = await _controller.ObtenerProducto(productoId);
    
    // Assert
    var okResult = Assert.IsType<OkObjectResult>(result);
    var returnedProducto = Assert.IsType<Producto>(okResult.Value);
    Assert.Equal(productoId, returnedProducto.Id);
    
    // Verify: flujo completo
    _mockCacheService.Verify(x => x.ObtenerAsync<Producto>($"producto_{productoId}"), Times.Once);
    _mockProductoService.Verify(x => x.ObtenerPorIdAsync(productoId), Times.Once);
    _mockCacheService.Verify(x => x.GuardarAsync($"producto_{productoId}", producto, TimeSpan.FromMinutes(5)), Times.Once);
}
```

### 4.6 Lo que logran estos tests

**Verificación de lógica de coordinación:**
* ¿El controller maneja la autorización correctamente?
* ¿Usa el cache apropiadamente?
* ¿Maneja correctamente los casos de error?
* ¿Retorna los status codes apropiados?

**Sin infraestructura real:**
* Tests que corren en milisegundos
* Sin setup complejo de base de datos o cache
* Comportamiento determinista en cada ejecución
* Aislamiento total de dependencias externas

---

## Recursos para mocking avanzado

### Librerías complementarias

* **Moq**: framework de mocking principal
* **AutoFixture**: generación automática de objetos para tests
* **Bogus**: datos de prueba realistas
* **FluentAssertions**: assertions más expresivos

### Configuraciones avanzadas de Moq

```csharp
// Callbacks: ejecutar lógica cuando se llama un método
mock.Setup(x => x.Procesar(It.IsAny<string>()))
    .Callback<string>(parametro => {
        // lógica adicional cuando se llama al método
    });

// Exceptions: simular errores
mock.Setup(x => x.OperacionPeligrosa())
    .Throws<InvalidOperationException>();

// Secuencias: diferentes comportamientos en llamadas consecutivas  
mock.SetupSequence(x => x.ObtenerSiguiente())
    .Returns("primero")
    .Returns("segundo")  
    .Throws<EndOfStreamException>();
```

---

## Mejores prácticas y anti-patrones

### ✅ Buenas prácticas

* **Mock interfaces, no clases**: más fácil y rápido
* **Verificar comportamiento, no implementación**: qué se llama, no cómo
* **Un mock por dependencia**: clarity y mantenibilidad
* **Setup mínimo necesario**: solo configurar lo que usa el test
* **Nombres descriptivos**: qué escenario testea cada método

### ❌ Anti-patrones comunes

**Over-mocking:**
```csharp
// ❌ Malo: mockear todo, incluso objetos simples
var mockString = new Mock<IStringWrapper>();
mockString.Setup(x => x.Length).Returns(5);

// ✅ Mejor: usar objetos reales cuando sea simple
var texto = "prueba";
Assert.Equal(6, texto.Length);
```

**Testing implementation details:**
```csharp
// ❌ Malo: testear orden exacto de operaciones internas
mock.Verify(x => x.Paso1(), Times.Once);
mock.Verify(x => x.Paso2(), Times.Once);
mock.Verify(x => x.Paso3(), Times.Once);

// ✅ Mejor: testear resultado y efectos secundarios importantes
Assert.Equal(resultadoEsperado, resultado);
mock.Verify(x => x.OperacionCritica(), Times.Once);
```

**Mocks que saben demasiado:**
```csharp
// ❌ Malo: mock configurado con lógica compleja
mock.Setup(x => x.Calcular(It.IsAny<int>()))
    .Returns<int>(x => x * 2 + 5); // lógica de negocio en el mock

// ✅ Mejor: mock simple, lógica en el código real
mock.Setup(x => x.ObtenerMultiplicador()).Returns(2);
```

---

## Glosario de términos de mocking

* **Mock**: test double que verifica interacciones y comportamiento esperado
* **Stub**: test double que devuelve valores predefinidos sin verificaciones
* **Fake**: implementación simplificada pero funcional de una dependencia
* **Dummy**: objeto pasado como parámetro pero nunca usado en el test
* **Spy**: test double que registra información sobre cómo fue utilizado
* **Test Double**: término genérico para cualquier objeto falso usado en testing
* **Setup**: configuración del comportamiento de un mock (qué debe retornar)
* **Verify**: verificación de que un mock fue llamado de la manera esperada
* **It.IsAny<T>()**: matcher que acepta cualquier valor del tipo especificado
* **It.Is<T>()**: matcher con condiciones específicas para el parámetro
* **Times.Once/Never/Exactly(n)**: especificadores de cuántas veces debe llamarse un método
* **Callback**: lógica adicional que se ejecuta cuando se llama un método mockeado
* **ReturnsAsync**: configuración de retorno para métodos asincrónicos
* **Throws**: configuración para que un mock lance una excepción específica

---

## Anexo 1 — Ejercicio: Primeros mocks con Moq

**Instrucciones:**

1. **Crear proyecto con dependencias:**
   * Proyecto de consola `NotificacionApp`
   * Interfaces: `IEmailService`, `ISmsService`, `ILoggerService`
   * Clase: `NotificacionManager` que use las tres interfaces

2. **Implementar lógica básica:**
   * `NotificacionManager.EnviarNotificacion(Usuario usuario, string mensaje)`
   * Debe enviar email Y SMS al usuario
   * Debe logear cada operación
   * Debe retornar `true` si ambos envíos fueron exitosos

3. **Crear proyecto de tests:**
   * Instalar xUnit y Moq
   * Crear `NotificacionManagerTests`
   * Testear caso exitoso con mocks

4. **Escribir tests específicos:**
   * Caso exitoso: ambos servicios funcionan
   * Caso de error: email falla, SMS funciona
   * Verificar que se loguea correctamente cada operación

**Criterio de éxito:** tests que usan mocks para aislar dependencias y verifican comportamiento sin I/O real.

---

## Anexo 2 — Ejercicio Completo: Testing de ProductoController

**Instrucciones:**

1. **Preparar escenario:**
   * Controller: `ProductosController` con operaciones CRUD
   * Dependencias: `IProductoService`, `IValidacionService`, `ILogger<ProductosController>`
   * Acciones: Get, Post, Put, Delete

2. **Implementar tests unitarios del controller:**
   * **GET /productos/{id}**: caso exitoso, producto no encontrado
   * **POST /productos**: modelo válido, modelo inválido
   * **PUT /productos/{id}**: actualización exitosa, producto no existe
   * **DELETE /productos/{id}**: eliminación exitosa, producto no encontrado

3. **Usar mocks apropiadamente:**
   * Mock del service para controlar datos devueltos
   * Mock del validator para controlar validaciones
   * Mock del logger para verificar logging correcto
   * Verificar que se llaman métodos apropiados en cada caso

4. **Casos de error y edge cases:**
   * Excepciones en el service
   * Diferentes tipos de errores de validación
   * Comportamiento con parámetros inválidos

5. **Organización profesional:**
   * Usar constructor común para setup de mocks
   * Tests con nombres descriptivos
   * AAA pattern claro en cada test
   * Verificaciones apropiadas sin over-testing

**Entregables:**
* Proyecto con controller y tests funcionando
* Mínimo 12 tests cubriendo casos principales
* README explicando qué problema resuelve cada mock
* Análisis: ¿qué diferencia hace usar mocks vs dependencies reales?

---

## Cierre

### Transformación lograda

**❌ Enfoque anterior (tests acoplados):**
```csharp
// Test lento, frágil, con dependencias reales
[Fact]
public async Task CrearProducto_ConBaseDatosReal_Funciona()
{
    var controller = new ProductosController(
        new ProductoService(new RealDbContext()),    // BD real
        new SmtpEmailService(),                      // Email real
        new FileLogger()                             // Archivo real
    );
    // Test que puede fallar por 100 razones diferentes...
}
```

**✅ Enfoque profesional (con mocks):**
```csharp
// Test rápido, determinista, aislado
[Fact]
public async Task CrearProducto_ProductoValido_LlamaServiciosCorrectamente()
{
    // Arrange: mocks configurados para scenario específico
    _mockService.Setup(x => x.CrearAsync(It.IsAny<ProductoDto>()))
               .ReturnsAsync(new Producto { Id = 1 });
    
    // Act & Assert: foco en lógica del controller
    var result = await _controller.CrearProducto(dto);
    
    _mockService.Verify(x => x.CrearAsync(dto), Times.Once);
}
```

### Beneficios del cambio

- **Velocidad**: tests en milisegundos, no segundos
- **Fiabilidad**: tests que fallan solo cuando hay bugs reales  
- **Foco**: testear lógica de coordinación, no infraestructura
- **Documentación**: mocks muestran qué dependencias necesita tu código

### Para recordar

> **"Mock dependencies, not your system under test"**

Los mocks no son para hacer tests complicados. Son para hacer tests **simples, rápidos y focalizados**. Cuando usas mocks correctamente, tus tests se vuelven más claros, no más complejos. Te permiten probar que tu código **coordina bien** con sus dependencias, sin necesidad de que esas dependencias existan realmente durante el test.
