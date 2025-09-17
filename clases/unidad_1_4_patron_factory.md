# Clase 4 – Patrón Factory: Creación de Objetos Flexible y Testeable

**Duración:** 3 horas  
**Objetivo general:** aprender el **patrón Factory** para crear objetos sin acoplar el código a clases concretas, aplicarlo en **validadores dinámicos** y **conectores de base de datos**, y escribir **tests unitarios** que verifiquen la creación correcta de instancias según criterios específicos.

---

## Índice

1. Módulo 1 — ¿Por qué necesitamos Factory? (Problema del acoplamiento)
2. Módulo 2 — Factory Method: Implementación básica
3. Módulo 3 — Abstract Factory: Familias de objetos relacionados
4. Módulo 4 — Ejercicios progresivos: Sistema de validación y persistencia
5. Recursos para patrones de creación
6. Testing de factories con dependencias
7. Glosario de términos de patrones
8. Cierre

---

## Módulo 1 — ¿Por qué necesitamos Factory? (Problema del acoplamiento)

> El patrón Factory **desacopla la creación de objetos** del código que los usa, permitiendo flexibilidad y mejor testabilidad.

### 1.1 Principios fundamentales

* **Separación de responsabilidades**: quien usa el objeto no debe saber cómo crearlo
* **Inversión de dependencias**: depender de abstracciones, no de implementaciones concretas
* **Principio abierto/cerrado**: abierto a extensión (nuevos tipos), cerrado a modificación
* **Single Responsibility**: cada factory tiene una sola razón para cambiar

### 1.2 Ejemplo 1 – Validadores de entrada (problemático vs profesional)

**❌ Problemático (acoplamiento fuerte, difícil de extender):**

```csharp
// Program.cs (MALO - acoplado a implementaciones concretas)
public void ProcesarRegistro(string tipoValidacion, string email, string password)
{
    if (tipoValidacion == "basica")
    {
        var validador = new ValidadorBasico(); // new directo = acoplamiento
        if (!validador.EsValido(email, password))
            throw new ArgumentException("Datos inválidos");
    }
    else if (tipoValidacion == "estricta")  
    {
        var validador = new ValidadorEstricto(); // más acoplamiento
        if (!validador.EsValido(email, password))
            throw new ArgumentException("Datos inválidos");
    }
    // ¿Qué pasa si queremos agregar ValidadorPremium? → modificar este código
    
    GuardarUsuario(email, password);
}
```

**✅ Profesional (Factory desacopla la creación):**

```csharp
// IValidadorUsuario.cs
public interface IValidadorUsuario
{
    bool EsValido(string email, string password);
    string ObtenerMensajeError();
}

// ValidadorFactory.cs  
public class ValidadorFactory
{
    public IValidadorUsuario Crear(TipoValidacion tipo)
    {
        return tipo switch
        {
            TipoValidacion.Basica => new ValidadorBasico(),
            TipoValidacion.Estricta => new ValidadorEstricto(),
            TipoValidacion.Premium => new ValidadorPremium(), // fácil agregar nuevos
            _ => throw new ArgumentException($"Tipo no soportado: {tipo}")
        };
    }
}

// Program.cs (UI desacoplada)
public void ProcesarRegistro(TipoValidacion tipo, string email, string password)
{
    var factory = new ValidadorFactory();
    IValidadorUsuario validador = factory.Crear(tipo); // desacoplado
    
    if (!validador.EsValido(email, password))
    {
        Console.WriteLine($"Error: {validador.ObtenerMensajeError()}");
        return;
    }
    
    GuardarUsuario(email, password);
}
```

**Qué mejora:** extensibilidad sin modificar código existente, testabilidad con mocks, responsabilidades claras.

### 1.3 Ventajas del patrón Factory

* **Flexibilidad**: agregar nuevos tipos sin tocar código existente
* **Testabilidad**: mockear factories para tests unitarios
* **Configurabilidad**: decidir qué crear basado en configuración
* **Mantenibilidad**: lógica de creación centralizada en un lugar

---

## Módulo 2 — Factory Method: Implementación básica

> Objetivo: **definir una interfaz para crear objetos**, pero permitir que las subclases decidan qué clase instanciar.

### 2.1 Estructura del Factory Method

```csharp
// Producto abstracto
public abstract class ConectorBaseDatos
{
    public abstract void Conectar();
    public abstract void EjecutarConsulta(string sql);
    public abstract void Desconectar();
}

// Productos concretos
public class ConectorSqlServer : ConectorBaseDatos
{
    public override void Conectar() => Console.WriteLine("Conectando a SQL Server...");
    public override void EjecutarConsulta(string sql) => Console.WriteLine($"SQL Server: {sql}");
    public override void Desconectar() => Console.WriteLine("Desconectando SQL Server");
}

public class ConectorMySql : ConectorBaseDatos  
{
    public override void Conectar() => Console.WriteLine("Conectando a MySQL...");
    public override void EjecutarConsulta(string sql) => Console.WriteLine($"MySQL: {sql}");
    public override void Desconectar() => Console.WriteLine("Desconectando MySQL");
}
```

### 2.2 Factory Method implementación

```csharp
// Creator abstracto
public abstract class FabricaConector
{
    // Factory Method - implementan las subclases
    public abstract ConectorBaseDatos CrearConector();
    
    // Operación que usa el factory method
    public void ProcesarConsulta(string sql)
    {
        ConectorBaseDatos conector = CrearConector(); // acá está la magia
        conector.Conectar();
        conector.EjecutarConsulta(sql);
        conector.Desconectar();
    }
}

// Creators concretos
public class FabricaSqlServer : FabricaConector
{
    public override ConectorBaseDatos CrearConector() => new ConectorSqlServer();
}

public class FabricaMySql : FabricaConector
{
    public override ConectorBaseDatos CrearConector() => new ConectorMySql();
}
```

### 2.3 Ejercicio guiado (15 min)

> Objetivo: implementar factory method para procesadores de archivos (CSV, JSON, XML).

1. **Crear la abstracción:**

```csharp
public abstract class ProcesadorArchivo
{
    public abstract void ProcesarLinea(string linea);
    public abstract string ObtenerExtension();
}
```

2. **Implementar procesadores concretos:**

```csharp
public class ProcesadorCsv : ProcesadorArchivo
{
    public override void ProcesarLinea(string linea)
    {
        string[] columnas = linea.Split(',');
        Console.WriteLine($"CSV: {columnas.Length} columnas procesadas");
    }
    public override string ObtenerExtension() => ".csv";
}

// TODO: Implementar ProcesadorJson y ProcesadorXml siguiendo el mismo patrón
```

3. **Crear factory method:**

```csharp
public abstract class FabricaProcesador
{
    public abstract ProcesadorArchivo CrearProcesador();
    
    public void ProcesarArchivo(string rutaArchivo)
    {
        ProcesadorArchivo procesador = CrearProcesador();
        // lógica común de procesamiento...
    }
}
```

**Criterio de éxito:** poder agregar nuevos tipos de procesadores sin modificar código existente.

---

## Módulo 3 — Abstract Factory: Familias de objetos relacionados

> Objetivo: crear **familias completas de objetos relacionados** sin especificar sus clases concretas.

### 3.1 Cuándo usar Abstract Factory

**Usar cuando necesites:**
* Crear grupos de objetos que trabajan juntos
* Intercambiar familias completas de productos
* Garantizar que los objetos de una familia son compatibles

### 3.2 Ejemplo: Sistema de UI multiplataforma

```csharp
// Productos abstractos (familia de controles UI)
public abstract class Button
{
    public abstract void Render();
    public abstract void OnClick();
}

public abstract class TextBox
{
    public abstract void Render();
    public abstract void SetText(string text);
}

// Familia Windows
public class WindowsButton : Button
{
    public override void Render() => Console.WriteLine("Renderizando botón Windows");
    public override void OnClick() => Console.WriteLine("Click estilo Windows");
}

public class WindowsTextBox : TextBox
{
    public override void Render() => Console.WriteLine("Renderizando textbox Windows");
    public override void SetText(string text) => Console.WriteLine($"Windows text: {text}");
}

// Familia Mac  
public class MacButton : Button
{
    public override void Render() => Console.WriteLine("Renderizando botón Mac");
    public override void OnClick() => Console.WriteLine("Click estilo Mac");
}

public class MacTextBox : TextBox
{
    public override void Render() => Console.WriteLine("Renderizando textbox Mac");
    public override void SetText(string text) => Console.WriteLine($"Mac text: {text}");
}
```

### 3.3 Abstract Factory implementación

```csharp
// Factory abstracto
public abstract class UIFactory
{
    public abstract Button CrearButton();
    public abstract TextBox CrearTextBox();
}

// Factories concretos
public class WindowsUIFactory : UIFactory
{
    public override Button CrearButton() => new WindowsButton();
    public override TextBox CrearTextBox() => new WindowsTextBox();
}

public class MacUIFactory : UIFactory
{
    public override Button CrearButton() => new MacButton();
    public override TextBox CrearTextBox() => new MacTextBox();
}

// Cliente que usa la factory
public class FormularioLogin
{
    private readonly UIFactory _uiFactory;
    
    public FormularioLogin(UIFactory uiFactory)
    {
        _uiFactory = uiFactory; // inyección de dependencia
    }
    
    public void CrearFormulario()
    {
        Button btnLogin = _uiFactory.CrearButton();
        TextBox txtUsuario = _uiFactory.CrearTextBox();
        
        // usar los controles - están garantizados de ser de la misma familia
        btnLogin.Render();
        txtUsuario.Render();
    }
}
```

### 3.4 Configuración e inyección

```csharp
// Program.cs - configuración de la factory según ambiente
public static void Main()
{
    UIFactory factory = ObtenerFactoryPorPlataforma();
    var formulario = new FormularioLogin(factory);
    formulario.CrearFormulario();
}

private static UIFactory ObtenerFactoryPorPlataforma()
{
    string plataforma = Environment.OSVersion.Platform.ToString();
    return plataforma.Contains("Win") ? new WindowsUIFactory() : new MacUIFactory();
}
```

---

## Módulo 4 — Ejercicios progresivos: Sistema de validación y persistencia

> **Meta general:** construir un sistema integrado que use **Factory Method** para validadores y **Abstract Factory** para persistencia de datos.

### 4.1 Contexto: Sistema de registro de usuarios

**Elementos fundamentales:**

* **Validadores**: básico, estricto, enterprise (diferentes reglas)
* **Persistencia**: base de datos, archivos, servicios web
* **Configuración**: decidir qué usar según ambiente (dev, staging, production)
* **Testing**: verificar creación correcta y funcionamiento

### 4.2 Ejercicio 1 — Factory de validadores con configuración

**Objetivo:** crear factory que seleccione validador basado en configuración externa.

**Metodología TDD:**

1. **Escribir tests primero** para verificar:
   * Factory crea el validador correcto según configuración
   * Validador creado implementa la interfaz esperada
   * Factory lanza excepción para tipos no soportados
   * Validadores tienen comportamientos diferenciados

```csharp
// ValidadorFactoryTests.cs
[TestClass]
public class ValidadorFactoryTests
{
    [Fact]
    public void Crear_TipoBasico_RetornaValidadorBasico()
    {
        // Arrange
        var factory = new ValidadorFactory();
        
        // Act
        IValidadorUsuario validador = factory.Crear(TipoValidacion.Basica);
        
        // Assert
        Assert.IsType<ValidadorBasico>(validador);
    }
    
    [Fact]
    public void Crear_TipoInvalido_LanzaExcepcion()
    {
        // Arrange & Act & Assert
        var factory = new ValidadorFactory();
        Assert.Throws<ArgumentException>(() => factory.Crear((TipoValidacion)999));
    }
}
```

2. **Implementar** factory y validadores después de tener tests verdes

### 4.3 Ejercicio 2 — Abstract Factory para persistencia

**Objetivo:** implementar familias de objetos para persistir datos en diferentes medios.

**Familias a implementar:**
* **Base de datos**: UserRepository, LogRepository (SQL)
* **Archivos**: UserFileRepository, LogFileRepository (JSON/CSV)
* **Memoria**: UserMemoryRepository, LogMemoryRepository (testing)

```csharp
// Productos abstractos
public abstract class IUserRepository
{
    public abstract void GuardarUsuario(Usuario usuario);
    public abstract Usuario ObtenerUsuario(int id);
}

public abstract class ILogRepository  
{
    public abstract void GuardarLog(string mensaje, DateTime fecha);
    public abstract List<LogEntry> ObtenerLogs(DateTime desde);
}

// Factory abstracto
public abstract class PersistenceFactory
{
    public abstract IUserRepository CrearUserRepository();
    public abstract ILogRepository CrearLogRepository();
}
```

### 4.4 Ejercicio 3 — Integración completa con configuración

**Objetivo:** integrar validación y persistencia usando dependency injection y configuración.

```csharp
// Servicio que integra todo
public class ServicioRegistro
{
    private readonly ValidadorFactory _validadorFactory;
    private readonly PersistenceFactory _persistenceFactory;
    
    public ServicioRegistro(ValidadorFactory validadorFactory, PersistenceFactory persistenceFactory)
    {
        _validadorFactory = validadorFactory;
        _persistenceFactory = persistenceFactory;
    }
    
    public bool RegistrarUsuario(RegistroRequest request)
    {
        // Factory para validación
        IValidadorUsuario validador = _validadorFactory.Crear(request.TipoValidacion);
        if (!validador.EsValido(request.Email, request.Password))
            return false;
            
        // Abstract factory para persistencia
        IUserRepository userRepo = _persistenceFactory.CrearUserRepository();
        ILogRepository logRepo = _persistenceFactory.CrearLogRepository();
        
        var usuario = new Usuario { Email = request.Email };
        userRepo.GuardarUsuario(usuario);
        logRepo.GuardarLog($"Usuario {request.Email} registrado", DateTime.Now);
        
        return true;
    }
}
```

---

## Recursos para patrones de creación

### Frameworks y librerías relacionadas

* **Microsoft.Extensions.DependencyInjection**: Container IoC integrado con factories
* **Autofac**: Container avanzado con factories y decorators  
* **Castle.Core**: Interceptores y factories dinámicos
* **AutoMapper**: Factory pattern para mapeo de objetos

### Testing de factories

```bash
# Paquetes útiles para testing
dotnet add package Moq                    # Mocking de dependencies
dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions
dotnet add package FluentAssertions      # Assertions más expresivos
```

### Configuración con appsettings.json

```json
{
  "Validacion": {
    "TipoDefault": "Basica",
    "RequiereEmail": true
  },
  "Persistencia": {
    "Tipo": "BaseDatos",
    "ConnectionString": "Server=localhost;Database=test;"
  }
}
```

---

## Testing de factories con dependencias

### Estrategias de testing

```csharp
[TestClass] 
public class ServicioRegistroTests
{
    [Fact]
    public void RegistrarUsuario_ValidacionFalla_RetornaFalse()
    {
        // Arrange - mock factories
        var mockValidadorFactory = new Mock<ValidadorFactory>();
        var mockValidador = new Mock<IValidadorUsuario>();
        mockValidador.Setup(v => v.EsValido(It.IsAny<string>(), It.IsAny<string>()))
                    .Returns(false);
        mockValidadorFactory.Setup(f => f.Crear(It.IsAny<TipoValidacion>()))
                          .Returns(mockValidador.Object);
                          
        var mockPersistenceFactory = new Mock<PersistenceFactory>();
        var servicio = new ServicioRegistro(mockValidadorFactory.Object, mockPersistenceFactory.Object);
        
        // Act
        bool resultado = servicio.RegistrarUsuario(new RegistroRequest 
        { 
            Email = "test@test.com", 
            Password = "123" 
        });
        
        // Assert
        Assert.False(resultado);
        // Verificar que NO se llamó a persistencia
        mockPersistenceFactory.Verify(f => f.CrearUserRepository(), Times.Never);
    }
    
    [Fact]
    public void RegistrarUsuario_ValidacionExitosa_GuardaUsuario()
    {
        // Arrange
        var mockValidador = new Mock<IValidadorUsuario>();
        mockValidador.Setup(v => v.EsValido(It.IsAny<string>(), It.IsAny<string>()))
                    .Returns(true);
                    
        var mockUserRepo = new Mock<IUserRepository>();
        var mockLogRepo = new Mock<ILogRepository>();
        
        var mockValidadorFactory = new Mock<ValidadorFactory>();
        mockValidadorFactory.Setup(f => f.Crear(It.IsAny<TipoValidacion>()))
                          .Returns(mockValidador.Object);
                          
        var mockPersistenceFactory = new Mock<PersistenceFactory>();
        mockPersistenceFactory.Setup(f => f.CrearUserRepository()).Returns(mockUserRepo.Object);
        mockPersistenceFactory.Setup(f => f.CrearLogRepository()).Returns(mockLogRepo.Object);
        
        var servicio = new ServicioRegistro(mockValidadorFactory.Object, mockPersistenceFactory.Object);
        
        // Act
        bool resultado = servicio.RegistrarUsuario(new RegistroRequest 
        { 
            Email = "test@test.com", 
            Password = "ValidPassword123!" 
        });
        
        // Assert
        Assert.True(resultado);
        mockUserRepo.Verify(r => r.GuardarUsuario(It.IsAny<Usuario>()), Times.Once);
        mockLogRepo.Verify(r => r.GuardarLog(It.IsAny<string>(), It.IsAny<DateTime>()), Times.Once);
    }
}
```

---

## Glosario de términos de patrones

* **Factory Method**: patrón que define interfaz para crear objetos, delegando a subclases decidir qué crear.
* **Abstract Factory**: patrón que proporciona interfaz para crear familias de objetos relacionados.  
* **Creator**: clase abstracta que declara el factory method en Factory Method pattern.
* **Product**: interfaz/clase abstracta que define objetos que crea el factory.
* **Concrete Creator**: subclase que implementa el factory method para crear productos específicos.
* **Concrete Product**: implementación específica de la interfaz Product.
* **Client**: código que usa el factory para obtener objetos sin conocer clases concretas.
* **Dependency Injection**: técnica de proveer dependencias desde el exterior del objeto.
* **Inversion of Control (IoC)**: principio donde el control de dependencias se invierte del cliente al framework.

---

## Anexo 1 — Ejercicio Completo: Sistema de notificaciones

**Instrucciones:**

1. Implementar Factory Method para diferentes tipos de notificaciones (Email, SMS, Push).
2. Crear Abstract Factory para diferentes proveedores (AWS, Azure, Local).
3. Desarrollar tests que verifiquen:
   * Factory crea el tipo correcto de notificación
   * Proveedores diferentes usan APIs diferentes pero interfaz común
   * Integración funciona correctamente con mocks

4. Estructura requerida:

```csharp
// Factory Method - tipos de notificación
public abstract class NotificationSender
{
    public abstract void Send(string mensaje, string destinatario);
}

// Abstract Factory - proveedores
public abstract class NotificationProviderFactory  
{
    public abstract NotificationSender CreateEmailSender();
    public abstract NotificationSender CreateSmsSender();
}

// Implementaciones: AWSFactory, AzureFactory, LocalFactory
```

> Al finalizar, demostrar funcionamiento cambiando proveedores por configuración sin cambiar código cliente.

---

## Anexo 2 — Ejercicio Completo: Sistema de reportes

**Instrucciones:**

1. **Implementar Factory Method para generadores de reportes:**
   * ReporteVentas, ReporteInventario, ReporteUsuarios
   * Cada reporte tiene lógica específica pero interfaz común
   * Factory decide qué reporte crear basado en enum TipoReporte

2. **Desarrollar Abstract Factory para formatos de salida:**
   * Familia PDF: GeneradorVentasPdf, GeneradorInventarioPdf
   * Familia Excel: GeneradorVentasExcel, GeneradorInventarioExcel  
   * Familia HTML: GeneradorVentasHtml, GeneradorInventarioHtml

3. **Integrar con servicio de reportes:**
   * ServicioReportes usa ambos patterns
   * Recibe configuración para decidir tipo y formato
   * Genera reporte usando factories apropiados

4. **Estructura de proyecto:**
   * Proyecto principal: `SistemaReportes.Core`
   * Proyecto de tests: `SistemaReportes.Core.Tests`
   * Cobertura de tests: 95%+ en factories y servicios

5. **Requisitos técnicos:**
   * Factories registradas en DI container
   * Configuración desde appsettings.json
   * Tests unitarios con mocks para todas las combinaciones
   * Logging de qué factory/producto se usa en cada operación

**Entregables:**
* Repositorio GitHub con implementación completa
* Tests funcionando con diferentes combinaciones
* Demostración en vivo cambiando configuración
* README explicando patrones implementados

---

## Cierre

* **Desacoplamiento**: Factory patterns eliminan dependencias directas entre cliente y clases concretas
* **Extensibilidad**: agregar nuevos productos solo requiere implementar interfaz y registrar en factory
* **Testabilidad**: factories se pueden mockear fácilmente para aislar lógica de negocio
* **Próximo paso**: combinar con patrón Repository para crear arquitecturas robustas y mantenibles

### Transformación lograda

**❌ Enfoque anterior (problemático):**
```csharp
// Cliente acoplado a implementaciones concretas
if (tipo == "basica") 
    var validador = new ValidadorBasico(); // acoplamiento fuerte
```

**✅ Enfoque profesional (desacoplado):**
```csharp
// Cliente usa factory, no conoce implementaciones
IValidadorUsuario validador = factory.Crear(tipo); // flexible y testeable
```

### Beneficios del cambio

- **Flexibilidad**: agregar nuevos tipos sin modificar código cliente
- **Testabilidad**: mockear factories para tests aislados
- **Mantenibilidad**: lógica de creación centralizada y bien organizada
- **Escalabilidad**: soportar múltiples familias de objetos relacionados

### Para recordar

> **"No crees objetos directamente; usa factories para mantener tu código flexible y testeable"**

Los patrones Factory son fundamentales para escribir código profesional que pueda evolucionar sin romperse, especialmente cuando se combina con inyección de dependencias y testing apropiado.
