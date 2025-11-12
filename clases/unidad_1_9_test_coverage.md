# Clase 9 – Test Coverage: Medición y Reportes de Cobertura de Código

**Duración:** 3 horas  
**Objetivo general:** comprender **por qué medir la cobertura de código** es fundamental en desarrollo profesional, aprender a **configurar y ejecutar reportes de test coverage** en proyectos C# ASP.NET Core usando **coverlet** y **ReportGenerator**, interpretar métricas de cobertura y usar esta información para **mejorar la calidad y confiabilidad** del código mediante tests estratégicos.

---

## Índice

1. Módulo 1 — ¿Por qué medir cobertura de código? (El problema de código sin tests)
2. Módulo 2 — Fundamentos de test coverage (Métricas y conceptos clave)
3. Módulo 3 — Configuración de coverlet para ASP.NET Core
4. Módulo 4 — Generación y visualización de reportes
5. Recursos para análisis avanzado de cobertura
6. Comandos esenciales de test coverage
7. Mejores prácticas y límites de la cobertura
8. Glosario de términos de test coverage
9. Cierre

---

## Módulo 1 — ¿Por qué medir cobertura de código? (El problema de código sin tests)

> Escribir tests es importante, pero **¿cómo sabemos si estamos testeando suficiente código?** La cobertura de código nos da una métrica objetiva para identificar áreas críticas sin protección y tomar decisiones informadas sobre dónde invertir esfuerzo en testing.

### 1.1 El problema invisible: código sin protección

**Escenario común en proyectos sin métricas:**

```csharp
// Servicio con múltiples métodos
public class ProductoService
{
    public Producto Crear(ProductoDto dto)
    {
        // Este método tiene tests ✅
        return new Producto { Nombre = dto.Nombre };
    }
    
    public Producto Actualizar(int id, ProductoDto dto)
    {
        // Este método tiene tests ✅
        return new Producto { Id = id, Nombre = dto.Nombre };
    }
    
    public void Eliminar(int id)
    {
        // Este método NO tiene tests ❌
        // ¿Qué pasa si hay un bug aquí?
    }
    
    public decimal CalcularDescuento(int cantidad)
    {
        // Este método NO tiene tests ❌
        // ¿La lógica de descuento funciona correctamente?
        if (cantidad > 100) return 0.15m;
        if (cantidad > 50) return 0.10m;
        return 0m;
    }
}
```

**Sin métricas de cobertura:**
* **Ceguera**: no sabemos qué código está protegido y qué no
* **Falsa seguridad**: creemos que tenemos "buenos tests" pero solo cubrimos el 40% del código
* **Refactoring peligroso**: modificamos código sin tests sin saberlo
* **Bugs en producción**: código crítico sin protección

### 1.2 El costo de código sin cobertura

**Riesgos reales:**

* **Regresiones no detectadas**: cambios que rompen funcionalidad existente
* **Bugs críticos en producción**: errores que los usuarios encuentran primero
* **Tiempo perdido en debugging**: horas buscando problemas que tests habrían detectado
* **Pérdida de confianza**: cada deploy es una apuesta

**Con cobertura medida:**

* **Visibilidad clara**: sabemos exactamente qué está protegido
* **Decisiones informadas**: priorizamos tests donde más importa
* **Refactoring seguro**: identificamos código sin tests antes de modificarlo
* **Mejora continua**: métricas objetivas para mejorar la calidad

### 1.3 ¿Qué hace especial al test coverage en ASP.NET Core?

**Complejidad adicional:**

```csharp
// En consola solo testeábamos lógica pura
public int Sumar(int a, int b) => a + b; // fácil de cubrir al 100%

// En ASP.NET Core tenemos múltiples capas:
public class ProductosController : ControllerBase
{
    // Controladores: ¿cubrimos todos los endpoints?
    [HttpGet("{id}")]
    public IActionResult Obtener(int id) { ... }
    
    [HttpPost]
    public IActionResult Crear(ProductoDto dto) { ... }
    
    [HttpPut("{id}")]
    public IActionResult Actualizar(int id, ProductoDto dto) { ... }
}

public class ProductoService
{
    // Servicios: ¿cubrimos todos los casos edge?
    public Producto Procesar(ProductoDto dto)
    {
        if (dto == null) throw new ArgumentNullException(); // ¿testeado?
        if (string.IsNullOrEmpty(dto.Nombre)) return null; // ¿testeado?
        return new Producto { Nombre = dto.Nombre }; // ¿testeado?
    }
}
```

**La cobertura nos ayuda a identificar:**
* Endpoints sin tests
* Casos edge no cubiertos
* Validaciones sin verificar
* Manejo de errores sin probar

---

## Módulo 2 — Fundamentos de test coverage (Métricas y conceptos clave)

> Objetivo: entender **qué significa realmente** la cobertura de código y **qué métricas** son útiles para evaluar la calidad de nuestros tests.

### 2.1 ¿Qué es la cobertura de código?

**Definición:**
La **cobertura de código** (code coverage) es una métrica que indica **qué porcentaje del código fuente** ha sido ejecutado por los tests. Mide qué líneas, ramas, métodos o clases fueron ejercitados durante la ejecución de los tests.

**No es una medida de calidad:**
* **Cobertura alta ≠ Tests buenos**: puedes tener 100% de cobertura con tests malos
* **Cobertura baja = Riesgo alto**: código sin tests es código frágil
* **Cobertura es una herramienta**: nos ayuda a encontrar código sin protección

### 2.2 Tipos de cobertura

**Cobertura de líneas (Line Coverage):**
Mide qué porcentaje de líneas de código fueron ejecutadas.

```csharp
public decimal CalcularTotal(decimal precio, int cantidad)
{
    decimal total = precio * cantidad;        // Línea 1: ✅ ejecutada
    if (cantidad > 10)                        // Línea 2: ✅ ejecutada
    {
        total *= 0.9m;                        // Línea 3: ❌ NO ejecutada (cantidad <= 10)
    }
    return total;                             // Línea 4: ✅ ejecutada
}

// Cobertura de líneas: 3/4 = 75%
```

**Cobertura de ramas (Branch Coverage):**
Mide qué porcentaje de decisiones condicionales fueron evaluadas en ambos sentidos (true y false).

```csharp
public decimal CalcularTotal(decimal precio, int cantidad)
{
    decimal total = precio * cantidad;
    if (cantidad > 10)                        // Rama 1: ✅ true ejecutado
    {                                         // Rama 2: ❌ false NO ejecutado
        total *= 0.9m;
    }
    return total;
}

// Cobertura de ramas: 1/2 = 50%
```

**Cobertura de métodos (Method Coverage):**
Mide qué porcentaje de métodos fueron llamados al menos una vez.

```csharp
public class ProductoService
{
    public Producto Crear(ProductoDto dto)     // Método 1: ✅ ejecutado
    {
        return new Producto { Nombre = dto.Nombre };
    }
    
    public Producto Actualizar(int id, ProductoDto dto)  // Método 2: ✅ ejecutado
    {
        return new Producto { Id = id };
    }
    
    public void Eliminar(int id)               // Método 3: ❌ NO ejecutado
    {
        // Sin tests
    }
}

// Cobertura de métodos: 2/3 = 66.67%
```

### 2.3 Métricas útiles en ASP.NET Core

**Cobertura por capa:**
* **Controllers**: ¿todos los endpoints tienen tests?
* **Services**: ¿toda la lógica de negocio está cubierta?
* **Repositories**: ¿las operaciones de datos están verificadas?
* **Validators**: ¿las validaciones tienen tests?

**Cobertura por tipo de test:**
* **Unit Tests**: cobertura de lógica pura
* **Integration Tests**: cobertura de flujos completos
* **E2E Tests**: cobertura de casos de uso críticos

### 2.4 ¿Qué porcentaje de cobertura es suficiente?

**No hay una respuesta única, pero guías prácticas:**

* **0-50%**: Riesgo alto, código frágil
* **50-70%**: Aceptable para proyectos en desarrollo
* **70-85%**: Buen nivel, código confiable
* **85-95%**: Excelente, código muy confiable
* **95-100%**: Puede ser excesivo (ley de rendimientos decrecientes)

**Consideraciones importantes:**
* **Código crítico**: debe tener cobertura alta (90%+)
* **Código legacy**: mejorar gradualmente, no todo de una vez
* **Código simple**: no necesita 100% (getters/setters triviales)
* **Código complejo**: necesita alta cobertura (lógica de negocio)

---

## Módulo 3 — Configuración de coverlet para ASP.NET Core

> Objetivo: **configurar coverlet** para generar métricas de cobertura en proyectos ASP.NET Core y entender cómo funciona el proceso de recolección de datos.

### 3.1 ¿Qué es coverlet?

**Coverlet** es una herramienta de código abierto para .NET que recolecta métricas de cobertura de código durante la ejecución de tests. Es la herramienta estándar recomendada por Microsoft para proyectos .NET Core y .NET 5+.

**Características principales:**
* **Multi-plataforma**: funciona en Windows, Linux y macOS
* **Integración nativa**: se integra con `dotnet test`
* **Múltiples formatos**: genera reportes en diferentes formatos (cobertura, json, etc.)
* **Ligero**: no requiere configuración compleja

### 3.2 Instalación de coverlet

**Opción 1: Como paquete NuGet en el proyecto de tests (recomendado)**

```bash
# Navegar al proyecto de tests
cd MiApp.Tests

# Agregar el paquete coverlet.collector
dotnet add package coverlet.collector

# Verificar que se agregó correctamente
dotnet list package
```

**Opción 2: Como herramienta global (alternativa)**

```bash
# Instalar como herramienta global
dotnet tool install -g coverlet.console

# Verificar instalación
coverlet --version
```

### 3.3 Configuración en el archivo .csproj

**Configuración básica en el proyecto de tests:**

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="coverlet.collector" Version="6.0.0">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
    <PackageReference Include="xunit" Version="2.6.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\MiApp.Web\MiApp.Web.csproj" />
  </ItemGroup>

</Project>
```

**Configuración avanzada (opcional):**

```xml
<PropertyGroup>
  <!-- Incluir solo ciertos assemblies -->
  <CoverletOutputFormat>cobertura</CoverletOutputFormat>
  <CoverletOutput>./coverage/</CoverletOutput>
  
  <!-- Excluir archivos generados automáticamente -->
  <Exclude>[*.Tests]*,[*.Test]*</Exclude>
</PropertyGroup>
```

### 3.4 ¿Cómo funciona el coverage con proyectos separados?

> **Pregunta común:** "Tengo dos proyectos separados (uno de tests y uno principal), ¿esto es un problema? ¿El coverage mide el proyecto principal o el de tests?"

**Respuesta corta:** No es un problema, es la práctica estándar. El coverage mide el **proyecto principal** (el que se referencia), no el proyecto de tests.

**Cómo funciona:**

**Estructura típica:**
```
Solucion/
├── MiApp.Web/              # Proyecto principal (código de producción)
│   ├── Services/
│   ├── Controllers/
│   └── Models/
└── MiApp.Tests/            # Proyecto de tests
    ├── Services/
    └── Controllers/
```

**Cuando ejecutas `dotnet test` desde el proyecto de tests:**

1. **Coverlet detecta automáticamente** qué proyectos son de tests (por la propiedad `<IsTestProject>true</IsTestProject>`)
2. **Excluye automáticamente** el código del proyecto de tests del reporte de cobertura
3. **Mide solo el código** de los proyectos referenciados (en este caso, `MiApp.Web`)

**Ejemplo práctico:**

```csharp
// MiApp.Web/Services/ProductoService.cs (PROYECTO PRINCIPAL)
namespace MiApp.Web.Services;

public class ProductoService
{
    public Producto Crear(ProductoDto dto)  // ✅ Este código SÍ se mide
    {
        return new Producto { Nombre = dto.Nombre };
    }
}
```

```csharp
// MiApp.Tests/Services/ProductoServiceTests.cs (PROYECTO DE TESTS)
namespace MiApp.Tests.Services;

public class ProductoServiceTests
{
    [Fact]
    public void Crear_ProductoValido_RetornaProducto()  // ❌ Este código NO se mide
    {
        ProductoService service = new ProductoService();
        ProductoDto dto = new ProductoDto { Nombre = "Test" };
        Producto resultado = service.Crear(dto);
        Assert.NotNull(resultado);
    }
}
```

**Resultado del reporte de cobertura:**

```
MiApp.Web/                          # ✅ Solo el proyecto principal aparece
├── Services/
│   └── ProductoService.cs: 100%    # ✅ Cobertura medida aquí
└── Controllers/
    └── ProductosController.cs: 75%

MiApp.Tests/                        # ❌ NO aparece en el reporte
└── (excluido automáticamente)
```

**Verificación práctica:**

Si quieres confirmar qué proyectos se están midiendo, puedes revisar el archivo XML generado:

```bash
# Ejecutar tests con cobertura
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/

# Ver el contenido del XML (Linux/Mac)
cat ./coverage-results/*/coverage.cobertura.xml | grep -i "package name"

# Verás algo como:
# <package name="MiApp.Web" ...>  ✅ Proyecto principal
# NO verás: <package name="MiApp.Tests" ...>  ❌ Proyecto de tests excluido
```

**¿Por qué es así?**

* **Los tests no son código de producción**: no tiene sentido medir su cobertura
* **El objetivo es proteger el código de producción**: queremos saber qué porcentaje de nuestro código real está protegido
* **Separación clara**: proyectos separados permiten excluir automáticamente los tests

**Conclusión:**

✅ **Tener proyectos separados NO es un problema**, es la práctica recomendada  
✅ **El coverage mide el proyecto principal** (MiApp.Web), no el de tests  
✅ **Coverlet excluye automáticamente** proyectos marcados como `<IsTestProject>true</IsTestProject>`  
✅ **Solo necesitas referenciar** el proyecto principal desde el proyecto de tests (como ya lo haces con `<ProjectReference>`)

### 3.5 Ejecución básica de tests con cobertura

**Comando básico:**

```bash
# Ejecutar tests y recolectar cobertura
dotnet test --collect:"XPlat Code Coverage"

# El reporte se genera en formato cobertura XML
# Ubicación típica: TestResults/[guid]/coverage.cobertura.xml
```

**Comando con opciones adicionales:**

```bash
# Especificar formato y directorio de salida
dotnet test --collect:"XPlat Code Coverage" \
            --results-directory:./coverage-results/ \
            -- DataCollectionRunSettings.DataCollectors.DataCollector.Configuration.Format=cobertura
```

### 3.6 Verificación de la configuración

**Test rápido para verificar que coverlet funciona:**

```csharp
// MiApp.Tests/CalculadoraTests.cs
using Xunit;

namespace MiApp.Tests;

public class CalculadoraTests
{
    [Fact]
    public void Sumar_DosNumeros_RetornaSuma()
    {
        // Arrange
        int a = 2;
        int b = 3;
        
        // Act
        int resultado = Calculadora.Sumar(a, b);
        
        // Assert
        Assert.Equal(5, resultado);
    }
}
```

```csharp
// MiApp.Web/Calculadora.cs
namespace MiApp.Web;

public static class Calculadora
{
    public static int Sumar(int a, int b)
    {
        return a + b;
    }
    
    // Método sin tests para demostrar cobertura parcial
    public static int Restar(int a, int b)
    {
        return a - b;
    }
}
```

**Ejecutar y verificar:**

```bash
dotnet test --collect:"XPlat Code Coverage"
```

**Resultado esperado:**
* Tests ejecutados exitosamente
* Archivo XML de cobertura generado
* Cobertura de `Sumar`: 100%
* Cobertura de `Restar`: 0%

---

## Módulo 4 — Generación y visualización de reportes

> Objetivo: **generar reportes visuales** de cobertura usando **ReportGenerator** y aprender a **interpretar los resultados** para tomar decisiones sobre dónde escribir más tests.

### 4.1 ¿Por qué necesitamos reportes visuales?

**El problema con archivos XML:**

```xml
<!-- coverage.cobertura.xml es difícil de leer -->
<coverage line-rate="0.75" branch-rate="0.60">
  <packages>
    <package name="MiApp.Web" line-rate="0.75">
      <!-- Miles de líneas de XML... -->
    </package>
  </packages>
</coverage>
```

**Los reportes HTML nos permiten:**
* **Visualización clara**: ver qué archivos/clases/métodos están cubiertos
* **Navegación fácil**: hacer clic para ver detalles
* **Colores intuitivos**: verde (cubierto), rojo (no cubierto)
* **Métricas resumidas**: porcentajes por proyecto/clase/método

### 4.2 Instalación de ReportGenerator

**Instalar como herramienta global:**

```bash
# Instalar ReportGenerator globalmente
dotnet tool install -g dotnet-reportgenerator-globaltool

# Verificar instalación
reportgenerator --version
```

**Actualizar herramienta (si ya está instalada):**

```bash
dotnet tool update -g dotnet-reportgenerator-globaltool
```

### 4.3 Generación de reporte HTML

**Proceso completo en dos pasos:**

**Paso 1: Ejecutar tests con cobertura**

```bash
# Ejecutar tests y generar archivo XML de cobertura
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/
```

**Paso 2: Generar reporte HTML**

```bash
# Generar reporte HTML desde el XML
reportgenerator \
  -reports:"./coverage-results/**/coverage.cobertura.xml" \
  -targetdir:"./coverage-report" \
  -reporttypes:Html
```

**Comando combinado (script útil):**

```bash
# Limpiar resultados anteriores
rm -rf coverage-results coverage-report

# Ejecutar tests con cobertura
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/

# Generar reporte HTML
reportgenerator \
  -reports:"./coverage-results/**/coverage.cobertura.xml" \
  -targetdir:"./coverage-report" \
  -reporttypes:Html

# Abrir reporte en navegador (Linux/Mac)
xdg-open coverage-report/index.html

# Abrir reporte en navegador (Windows)
start coverage-report/index.html
```

### 4.4 Interpretación del reporte HTML

**Estructura del reporte:**

```
coverage-report/
├── index.html              # Página principal con resumen
├── MiApp.Web/              # Carpeta por proyecto
│   ├── index.html          # Resumen del proyecto
│   ├── Calculadora.html    # Detalle de cada clase
│   └── ProductoService.html
└── [archivos CSS/JS]       # Recursos para visualización
```

**Información clave en el reporte:**

* **Cobertura total**: porcentaje general del proyecto
* **Cobertura por clase**: qué clases tienen más/menos cobertura
* **Líneas cubiertas/no cubiertas**: detalle línea por línea
* **Ramas cubiertas/no cubiertas**: decisiones condicionales testeadas

**Ejemplo de interpretación:**

```
MiApp.Web
├── Calculadora.cs: 50% cobertura
│   ├── Sumar(): 100% ✅
│   └── Restar(): 0% ❌ (necesita tests)
│
└── ProductoService.cs: 75% cobertura
    ├── Crear(): 100% ✅
    ├── Actualizar(): 100% ✅
    └── Eliminar(): 0% ❌ (necesita tests)
```

### 4.5 Ejemplo práctico: Identificar código sin cobertura

**Escenario: Servicio con cobertura parcial**

```csharp
// MiApp.Web/Services/ProductoService.cs
namespace MiApp.Web.Services;

public class ProductoService
{
    public Producto Crear(ProductoDto dto)
    {
        if (dto == null)
        {
            throw new ArgumentNullException(nameof(dto));
        }
        
        if (string.IsNullOrWhiteSpace(dto.Nombre))
        {
            throw new ArgumentException("El nombre es requerido", nameof(dto));
        }
        
        return new Producto
        {
            Id = GenerarId(),
            Nombre = dto.Nombre,
            Precio = dto.Precio
        };
    }
    
    private int GenerarId()
    {
        return new Random().Next(1, 10000);
    }
}
```

**Tests existentes (cobertura parcial):**

```csharp
// MiApp.Tests/Services/ProductoServiceTests.cs
using Xunit;
using MiApp.Web.Services;

namespace MiApp.Tests.Services;

public class ProductoServiceTests
{
    [Fact]
    public void Crear_ProductoValido_RetornaProducto()
    {
        // Arrange
        ProductoService service = new ProductoService();
        ProductoDto dto = new ProductoDto 
        { 
            Nombre = "Test", 
            Precio = 100m 
        };
        
        // Act
        Producto resultado = service.Crear(dto);
        
        // Assert
        Assert.NotNull(resultado);
        Assert.Equal("Test", resultado.Nombre);
    }
}
```

**Análisis del reporte de cobertura:**

```
ProductoService.cs: 40% cobertura

✅ Cubierto:
- Línea: return new Producto { ... }
- Línea: Nombre = dto.Nombre

❌ NO cubierto:
- Línea: if (dto == null) → necesita test con null
- Línea: throw new ArgumentNullException → necesita test
- Línea: if (string.IsNullOrWhiteSpace(...)) → necesita test con string vacío
- Línea: throw new ArgumentException → necesita test
- Método: GenerarId() → nunca se ejecuta directamente
```

**Mejora: Agregar tests faltantes**

```csharp
// Agregar estos tests para mejorar cobertura
[Fact]
public void Crear_DtoNull_LanzaArgumentNullException()
{
    // Arrange
    ProductoService service = new ProductoService();
    
    // Act & Assert
    Assert.Throws<ArgumentNullException>(() => service.Crear(null));
}

[Fact]
public void Crear_NombreVacio_LanzaArgumentException()
{
    // Arrange
    ProductoService service = new ProductoService();
    ProductoDto dto = new ProductoDto { Nombre = "", Precio = 100m };
    
    // Act & Assert
    ArgumentException exception = Assert.Throws<ArgumentException>(
        () => service.Crear(dto)
    );
    Assert.Contains("nombre es requerido", exception.Message);
}

[Fact]
public void Crear_NombreSoloEspacios_LanzaArgumentException()
{
    // Arrange
    ProductoService service = new ProductoService();
    ProductoDto dto = new ProductoDto { Nombre = "   ", Precio = 100m };
    
    // Act & Assert
    Assert.Throws<ArgumentException>(() => service.Crear(dto));
}
```

**Resultado después de agregar tests:**

```
ProductoService.cs: 95% cobertura ✅

✅ Cubierto:
- Todos los casos de validación
- Caso exitoso
- Manejo de errores

❌ NO cubierto:
- GenerarId() (método privado, se ejecuta indirectamente)
```

### 4.6 Integración con scripts de automatización

**Script para Windows (coverage.bat):**

```batch
@echo off
echo Limpiando resultados anteriores...
if exist coverage-results rmdir /s /q coverage-results
if exist coverage-report rmdir /s /q coverage-report

echo Ejecutando tests con cobertura...
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/

echo Generando reporte HTML...
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html

echo Reporte generado en: coverage-report\index.html
start coverage-report\index.html
```

**Script para Linux/Mac (coverage.sh):**

```bash
#!/bin/bash

echo "Limpiando resultados anteriores..."
rm -rf coverage-results coverage-report

echo "Ejecutando tests con cobertura..."
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/

echo "Generando reporte HTML..."
reportgenerator \
  -reports:"./coverage-results/**/coverage.cobertura.xml" \
  -targetdir:"./coverage-report" \
  -reporttypes:Html

echo "Reporte generado en: coverage-report/index.html"
xdg-open coverage-report/index.html 2>/dev/null || open coverage-report/index.html 2>/dev/null
```

**Hacer ejecutable (Linux/Mac):**

```bash
chmod +x coverage.sh
./coverage.sh
```

---

## Recursos para análisis avanzado de cobertura

### Herramientas complementarias

* **Coverlet**: recolector de cobertura estándar para .NET
* **ReportGenerator**: generador de reportes HTML/XML/JSON
* **SonarQube**: análisis de calidad de código con cobertura integrada
* **Codecov**: servicio online para tracking de cobertura en CI/CD
* **Azure DevOps**: integración nativa con reportes de cobertura

### Formatos de salida adicionales

```bash
# Generar múltiples formatos
reportgenerator \
  -reports:"./coverage-results/**/coverage.cobertura.xml" \
  -targetdir:"./coverage-report" \
  -reporttypes:"Html;JsonSummary;Badges"
```

### Integración con CI/CD

```yaml
# Ejemplo para GitHub Actions
- name: Run tests with coverage
  run: |
    dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/
    
- name: Generate coverage report
  run: |
    reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html
    
- name: Upload coverage report
  uses: actions/upload-artifact@v3
  with:
    name: coverage-report
    path: coverage-report/
```

---

## Comandos esenciales de test coverage

### Comandos básicos

```bash
# Ejecutar tests con cobertura (formato básico)
dotnet test --collect:"XPlat Code Coverage"

# Especificar directorio de resultados
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/

# Ejecutar tests específicos con cobertura
dotnet test --filter "FullyQualifiedName~ProductoService" --collect:"XPlat Code Coverage"

# Tests con cobertura y salida detallada
dotnet test --collect:"XPlat Code Coverage" --verbosity normal
```

### Comandos de ReportGenerator

```bash
# Generar reporte HTML básico
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html

# Generar múltiples formatos
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:"Html;JsonSummary"

# Excluir archivos específicos del reporte
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html -classfilters:"-*Tests*"

# Generar reporte con umbral mínimo
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html -reporttypes:HtmlSummary
```

### Comandos combinados útiles

```bash
# Pipeline completo: limpiar, testear, reportar
rm -rf coverage-results coverage-report && \
dotnet test --collect:"XPlat Code Coverage" --results-directory:./coverage-results/ && \
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html
```

---

## Mejores prácticas y límites de la cobertura

### ✅ Buenas prácticas

**Usar cobertura como guía, no como meta:**
* **Cobertura alta no garantiza calidad**: puedes tener 100% con tests malos
* **Enfocarse en código crítico**: lógica de negocio necesita alta cobertura
* **Mejorar gradualmente**: no intentar llegar a 100% de una vez
* **Revisar reportes regularmente**: identificar tendencias y áreas problemáticas

**Estrategias efectivas:**
* **Cobertura incremental**: mejorar 5-10% por iteración
* **Priorizar código crítico**: funciones de negocio primero
* **Excluir código generado**: no testear código auto-generado
* **Mantener umbral mínimo**: establecer meta realista (ej: 70%)

### ❌ Anti-patrones comunes

**Cobertura como único objetivo:**
```csharp
// ❌ Malo: test inútil solo para aumentar cobertura
[Fact]
public void Getter_RetornaValor()
{
    Producto producto = new Producto { Nombre = "Test" };
    Assert.Equal("Test", producto.Nombre); // Getter trivial, no necesita test
}

// ✅ Mejor: test que verifica comportamiento importante
[Fact]
public void CalcularDescuento_CantidadMayor100_Aplica15Porciento()
{
    ProductoService service = new ProductoService();
    decimal resultado = service.CalcularDescuento(150);
    Assert.Equal(0.15m, resultado); // Lógica de negocio importante
}
```

**Ignorar código sin cobertura:**
```csharp
// ❌ Malo: código crítico sin tests
public decimal CalcularPrecioFinal(decimal precio, int cantidad)
{
    // Lógica compleja sin tests
    if (cantidad > 100) return precio * 0.85m;
    if (cantidad > 50) return precio * 0.90m;
    return precio;
}

// ✅ Mejor: identificar y testear código crítico
[Theory]
[InlineData(150, 100m, 85m)] // cantidad > 100
[InlineData(75, 100m, 90m)]  // cantidad > 50
[InlineData(10, 100m, 100m)] // cantidad normal
public void CalcularPrecioFinal_CasosVarios_RetornaCorrecto(int cantidad, decimal precio, decimal esperado)
{
    ProductoService service = new ProductoService();
    decimal resultado = service.CalcularPrecioFinal(precio, cantidad);
    Assert.Equal(esperado, resultado);
}
```

### Límites de la cobertura

**Lo que la cobertura NO mide:**
* **Calidad de los tests**: tests malos pueden tener alta cobertura
* **Complejidad del código**: código complejo necesita más tests
* **Casos edge**: puedes tener cobertura sin cubrir casos límite
* **Comportamiento correcto**: cobertura no verifica que el código funciona bien

**Lo que la cobertura SÍ mide:**
* **Porcentaje de código ejecutado**: métrica objetiva
* **Áreas sin protección**: identifica código sin tests
* **Tendencias**: muestra si la cobertura mejora o empeora
* **Comparación**: permite comparar entre proyectos o módulos

---

## Glosario de términos de test coverage

* **Code Coverage (Cobertura de código)**: métrica que indica qué porcentaje del código fuente fue ejecutado por los tests
* **Line Coverage (Cobertura de líneas)**: porcentaje de líneas de código ejecutadas durante los tests
* **Branch Coverage (Cobertura de ramas)**: porcentaje de decisiones condicionales evaluadas en ambos sentidos (true y false)
* **Method Coverage (Cobertura de métodos)**: porcentaje de métodos que fueron llamados al menos una vez
* **Coverlet**: herramienta de código abierto para recolectar métricas de cobertura en .NET
* **ReportGenerator**: herramienta para generar reportes visuales (HTML) desde archivos XML de cobertura
* **Cobertura incremental**: estrategia de mejorar la cobertura gradualmente en lugar de buscar 100% inmediatamente
* **Umbral de cobertura**: porcentaje mínimo de cobertura establecido como meta para un proyecto
* **Código crítico**: código que contiene lógica de negocio importante y debe tener alta cobertura
* **Código generado**: código auto-generado por herramientas que generalmente se excluye de métricas de cobertura
* **Regresión**: bug introducido por cambios recientes que rompe funcionalidad existente
* **Test Double**: objeto falso usado en tests para aislar dependencias (mock, stub, fake)

---

## Anexo 1 — Ejercicio: Primera configuración de test coverage

**Instrucciones:**

1. **Configurar coverlet en proyecto existente:**
   * Tomar un proyecto con tests existentes (o crear uno nuevo)
   * Agregar el paquete `coverlet.collector` al proyecto de tests
   * Verificar la instalación con `dotnet list package`

2. **Ejecutar tests con cobertura:**
   * Ejecutar `dotnet test --collect:"XPlat Code Coverage"`
   * Localizar el archivo XML generado en `TestResults/`
   * Verificar que se generó correctamente

3. **Instalar y configurar ReportGenerator:**
   * Instalar ReportGenerator como herramienta global
   * Generar reporte HTML desde el XML de cobertura
   * Abrir el reporte en el navegador

4. **Analizar el reporte:**
   * Identificar clases/métodos con baja cobertura
   * Listar al menos 3 áreas que necesitan más tests
   * Documentar qué tests faltan para mejorar la cobertura

**Criterio de éxito:** reporte HTML generado exitosamente con identificación clara de áreas sin cobertura.

---

## Anexo 2 — Ejercicio Completo: Mejorar cobertura de un servicio

**Instrucciones:**

1. **Preparar escenario:**
   * Usar un servicio existente con lógica de negocio (ej: `ProductoService`, `CalculadoraService`)
   * El servicio debe tener al menos 3 métodos públicos
   * Debe incluir validaciones y casos edge

2. **Medir cobertura inicial:**
   * Ejecutar tests existentes con cobertura
   * Generar reporte HTML
   * Documentar porcentaje de cobertura inicial
   * Identificar métodos/clases con baja cobertura

3. **Escribir tests faltantes:**
   * Agregar tests para métodos sin cobertura
   * Cubrir casos edge y validaciones
   * Incluir tests para manejo de errores
   * Asegurar que todos los tests pasan

4. **Medir cobertura mejorada:**
   * Ejecutar tests nuevamente con cobertura
   * Generar nuevo reporte HTML
   * Comparar cobertura antes/después
   * Documentar mejoras logradas

5. **Análisis y reflexión:**
   * ¿Qué porcentaje de mejora lograste?
   * ¿Qué áreas aún necesitan más tests?
   * ¿Qué aprendiste sobre la importancia de la cobertura?
   * ¿Cómo usarás esta información en proyectos futuros?

**Entregables:**
* Proyecto con tests mejorados funcionando
* Reportes HTML de cobertura (antes y después)
* Documentación de mejoras realizadas
* Análisis personal del valor de medir cobertura

---

## Cierre

### Transformación lograda

**❌ Enfoque anterior (sin métricas de cobertura):**
```csharp
// Desarrollar tests → Esperar que sean suficientes → Descubrir bugs en producción
public class ProductoService
{
    public Producto Crear(ProductoDto dto)
    {
        // ¿Tiene tests? ¿Cuántos? ¿Cubre todos los casos?
        // Sin métricas, no lo sabemos
        return new Producto { Nombre = dto.Nombre };
    }
}
```

**✅ Enfoque profesional (con cobertura medida):**
```bash
# Desarrollo con visibilidad clara
dotnet test --collect:"XPlat Code Coverage"
reportgenerator -reports:"./coverage-results/**/coverage.cobertura.xml" -targetdir:"./coverage-report" -reporttypes:Html

# Reporte muestra:
# ProductoService.cs: 85% cobertura ✅
# - Crear(): 100% cubierto
# - Validaciones: todas testeadas
# - Casos edge: cubiertos
```

### Beneficios del cambio

- **Visibilidad**: sabemos exactamente qué código está protegido
- **Decisiones informadas**: priorizamos tests donde más importa
- **Mejora continua**: métricas objetivas para evaluar progreso
- **Confianza**: refactoring seguro con conocimiento de cobertura

### Para recordar

> **"Code coverage doesn't guarantee quality, but lack of coverage guarantees risk"**

La cobertura de código no es el objetivo final, pero es una herramienta poderosa para identificar áreas de riesgo. Un proyecto con 70% de cobertura bien distribuida es mucho más confiable que uno con 90% de cobertura concentrada en código trivial. Usa las métricas de cobertura como guía para tomar decisiones informadas sobre dónde invertir esfuerzo en testing, siempre recordando que la calidad de los tests es tan importante como la cantidad de código cubierto.

