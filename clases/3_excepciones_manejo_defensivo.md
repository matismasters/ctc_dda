# Clase 3 – Excepciones y Manejo Defensivo

**Duración:** 3 horas  
**Objetivo:** Entender cuándo usar excepciones apropiadamente y implementar manejo defensivo para validaciones de entrada.

---

## Módulo 1 — Filosofía sobre excepciones

### ¿Cuándo SÍ usar excepciones?

**Solo para situaciones verdaderamente inesperadas:**

```csharp
// ✅ CORRECTO: Problemas técnicos inesperados
public void GuardarPartida(Partida partida)
{
    try 
    {
        File.WriteAllText("partida.json", JsonConvert.SerializeObject(partida));
    }
    catch (IOException ex) // Sin espacio en disco, permisos, etc.
    {
        throw new PartidaNoGuardadaException("No se pudo guardar", ex);
    }
}
```

### ¿Cuándo NO usar excepciones?

**NUNCA para validaciones de entrada de usuario:**

```csharp
// ❌ INCORRECTO: Usuario ingresa datos en formulario - es esperable que sean incorrectos
public void ProcesarNombreJugador(string nombreIngresado)
{
    if (string.IsNullOrEmpty(nombreIngresado))
        throw new ArgumentException("Nombre requerido"); // MAL - es entrada de usuario
        
    if (nombreIngresado.Length > 20)
        throw new ArgumentException("Nombre muy largo"); // MAL - es entrada de usuario
}

// ✅ CORRECTO: Usar manejo defensivo para entrada de usuario
public Result<string> ValidarNombreJugador(string nombreIngresado)
{
    if (string.IsNullOrEmpty(nombreIngresado))
        return Result<string>.Error("El nombre es requerido"); // BIEN
        
    if (nombreIngresado.Length > 20)
        return Result<string>.Error("Máximo 20 caracteres"); // BIEN
        
    return Result<string>.Exito(nombreIngresado);
}
```

### Regla fundamental

> **"Excepciones para lo excepcional, validaciones para lo esperable"**

**Pregunta clave:** *¿Es esto algo que espero durante el uso normal?*
- **SÍ** → usar validaciones con mensajes de error
- **NO** → usar excepciones

---

## Módulo 2 — Conceptos básicos de excepciones

### Sintaxis básica

```csharp
// Lanzar excepción
if (!File.Exists(archivo))
    throw new FileNotFoundException($"No existe: {archivo}");

// Capturar excepción  
try
{
    var contenido = File.ReadAllText(archivo);
    // procesar...
}
catch (FileNotFoundException)
{
    // manejar archivo faltante
}
catch (IOException ex)
{
    // manejar otros problemas de E/S
    Console.WriteLine($"Error: {ex.Message}");
}
finally
{
    // limpiar recursos (siempre se ejecuta)
}
```

### Tipos comunes de excepciones

```csharp
// Para bibliotecas/APIs donde null no es espectable
throw new ArgumentNullException(nameof(parametro));

// Para estados inválidos del sistema
throw new InvalidOperationException("No se puede pagar sin sesión activa");

// Para operaciones no implementadas
throw new NotImplementedException("Funcionalidad en desarrollo");
```

### Mejores prácticas básicas

- **SÍ:** Mensajes informativos y específicos
- **SÍ:** Incluir excepción original como InnerException  
- **SÍ:** Limpiar recursos en finally o using
- **NO:** Usar excepciones para control de flujo normal
- **NO:** Silenciar excepciones con catch vacío

---

## Módulo 3 — Manejo defensivo vs excepciones

### Manejo defensivo con servicios externos

```csharp
public class ServicioBaseDatos
{
    public bool TryConectar(string connectionString, out string mensajeError)
    {
        mensajeError = null;
        
        // Validación de entrada (esperable que falle)
        if (string.IsNullOrEmpty(connectionString))
        {
            mensajeError = "La cadena de conexión es requerida";
            return false;
        }
        
        try
        {
            // Operación técnica que puede fallar inesperadamente
            var conexion = new SqlConnection(connectionString);
            conexion.Open();
            conexion.Close();
            return true;
        }
        catch (SqlException ex)
        {
            // Manejar fallo técnico sin propagar excepción
            mensajeError = "No se pudo conectar a la base de datos";
            return false;
        }
    }
}
```

### Aplicación con archivos

```csharp
public class ManejadorConfiguracion
{
    public bool TryCargarConfiguracion(string rutaArchivo, out Dictionary<string, string> config, out string error)
    {
        config = null;
        error = null;
        
        // Validación de entrada
        if (string.IsNullOrEmpty(rutaArchivo))
        {
            error = "La ruta del archivo es requerida";
            return false;
        }
        
        try
        {
            // Operación de I/O que puede fallar
            var contenido = File.ReadAllText(rutaArchivo);
            config = JsonConvert.DeserializeObject<Dictionary<string, string>>(contenido);
            return true;
        }
        catch (FileNotFoundException)
        {
            error = "Archivo de configuración no encontrado";
            return false;
        }
        catch (IOException ex)
        {
            error = "Error leyendo el archivo de configuración";
            return false;
        }
    }
}
```

### Patrón TryXxx (común en .NET)

```csharp
public bool TryValidarNombre(string nombre, out string mensajeError)
{
    // Inicializar parámetro 'out' (obligatorio en C#)
    mensajeError = null;
    
    if (string.IsNullOrWhiteSpace(nombre))
    {
        mensajeError = "El nombre es requerido";
        return false; // Indicar fallo de validación
    }
    
    if (nombre.Length > 20)
    {
        mensajeError = "Máximo 20 caracteres";
        return false;
    }
    
    return true; // Validación exitosa
}

// Uso del patrón TryXxx
public string ProcesarNombre(string input)
{
    // TryValidarNombre hace dos cosas:
    // 1. Retorna true/false indicando si la validación pasó
    // 2. Si falla, pone el mensaje de error en la variable 'error'
    if (!TryValidarNombre(input, out string error))
    {
        return $"Nombre inválido: {error}";
    }
    
    return "Nombre procesado correctamente";
}
```

### Ejemplo práctico: int.TryParse

```csharp
public void ProcesarEntradaUsuario(string input)
{
    // int.TryParse(string, out int) hace lo siguiente:
    // 1. Intenta convertir el string a entero
    // 2. Retorna 'true' si la conversión es exitosa, 'false' si falla  
    // 3. Si es exitosa, el número convertido se guarda en 'numero'
    // 4. Si falla, 'numero' queda en 0
    if (!int.TryParse(input, out int numero))
    {
        MostrarMensaje("Por favor ingrese un número válido");
        return; // Salir sin procesar
    }
    
    // Solo llegamos aquí si la conversión fue exitosa
    // 'numero' ahora contiene el valor entero válido
    ProcesarNumero(numero);
}
```

### Comparación práctica

```csharp
// ❌ Con excepciones para validaciones (costoso y complejo)
foreach (var archivo in archivos)
{
    try
    {
        var config = CargarConfiguracion(archivo); // Lanza excepción si archivo inválido
        ProcesarConfiguracion(config);
    }
    catch (FileNotFoundException ex)
    {
        MostrarError($"Archivo no encontrado: {archivo}");
    }
    catch (FormatException ex)
    {
        MostrarError($"Formato inválido: {archivo}");
    }
}

// ✅ Con manejo defensivo (simple y claro)
foreach (var archivo in archivos)
{
    if (TryCargarConfiguracion(archivo, out var config, out var error))
    {
        ProcesarConfiguracion(config);
    }
    else
    {
        MostrarError($"Error en {archivo}: {error}");
    }
}
```

---

## Módulo 4 — Testing apropiado

### Testing de manejo defensivo

```csharp
public class ServicioBaseDatosTests
{
    [Fact]
    public void TryConectar_ConnectionStringVacio_RetornaError()
    {
        var servicio = new ServicioBaseDatos();
        
        var exito = servicio.TryConectar("", out string error);
        
        // NO esperamos excepción, sino manejo gracioso
        Assert.False(exito);
        Assert.Contains("cadena de conexión es requerida", error);
    }

    [Fact]
    public void TryConectar_ConnectionStringValido_RetornaExito()
    {
        var servicio = new ServicioBaseDatos();
        var connectionString = "Server=localhost;Database=test;";
        
        var exito = servicio.TryConectar(connectionString, out string error);
        
        Assert.True(exito);
        Assert.Null(error);
    }
}
```

### Testing de captura de excepciones técnicas

```csharp
[Fact]
public void TryGuardarUsuario_ErrorBaseDatos_ManejaExcepcionCorrectamente()
{
    // Arrange: mock que simula fallo técnico
    var mockConexion = new Mock<IConexionBaseDatos>();
    mockConexion.Setup(c => c.Ejecutar(It.IsAny<string>()))
                .Throws(new SqlException("Connection timeout")); // Simular fallo de BD
           
    var servicio = new ServicioBaseDatos(mockConexion.Object);
    var usuario = new Usuario { Nombre = "Test" };

    // Act: el servicio debe CAPTURAR la excepción
    var exito = servicio.TryGuardarUsuario(usuario, out string error);

    // Assert: verificar que se manejó sin propagar
    Assert.False(exito);
    Assert.Contains("No se pudo conectar", error);
    // Verificar que no se filtra información técnica
    Assert.DoesNotContain("Connection timeout", error);
}
```

### Principios para testing

**SÍ hacer:**
- Testear que errores se manejan gracefully
- Verificar mensajes de error apropiados
- Simular fallos técnicos con mocks

**NO hacer:**
- `Assert.Throws` para validaciones de entrada de usuario
- Permitir que detalles técnicos lleguen al usuario

---

## Módulo 5 — Ejercicio práctico

### Implementar sistema de validación robusto

**Objetivo:** Crear servicios que manejen fallos técnicos y validaciones de entrada usando patrones defensivos.

### Paso 1: Implementar validaciones con manejo defensivo

```csharp
// TODO: Implementar servicio que maneja fallos de base de datos
public class ServicioBaseDatos
{
    public bool TryGuardarUsuario(Usuario usuario, out string mensajeError)
    {
        // TODO: Validar entrada de usuario sin excepciones
        // TODO: Manejar SqlException si ocurre al conectar
        // TODO: Retornar true/false con mensaje apropiado
    }
}
```

### Paso 2: Manejo de archivos con recuperación de errores

```csharp
public class ManejadorArchivos
{
    public bool TryCargarConfiguracion(string rutaArchivo, out Configuracion config, out string error)
    {
        // TODO: Validar que la ruta no esté vacía
        // TODO: Manejar FileNotFoundException, IOException
        // TODO: Retornar configuración válida o mensaje de error
    }
}
```

### Paso 3: Tests del manejo defensivo

```csharp
[TestClass]
public class ServicioBaseDatosTests
{
    [Fact]
    public void TryGuardarUsuario_DatosValidos_RetornaExito()
    {
        // TODO: Probar con datos válidos
        // TODO: Assert.True(exito)
        // TODO: Verificar que no hay mensaje de error
    }
    
    [Fact] 
    public void TryGuardarUsuario_BaseDatosNoDisponible_ManejaGraciosamente()
    {
        // TODO: Simular SqlException con Mock
        // TODO: Assert.False(exito)  
        // TODO: Verificar mensaje amigable al usuario
        // IMPORTANTE: NO usar Assert.Throws
    }
}
```

### Paso 4: Demostración grupal y discusión

- **Mostrar soluciones** de diferentes grupos
- **Comparar enfoques** TryXxx vs excepciones
- **Discutir** cuándo usar cada patrón
- **Identificar** errores comunes y mejores prácticas

---

## Criterios de evaluación

### ✅ Correcto
- Usa patrones TryXxx para validaciones de entrada
- NO lanza excepciones para datos inválidos de usuario
- SÍ maneja excepciones técnicas (BD, red, I/O) apropiadamente
- Tests verifican `bool` de retorno y parámetros `out`, NO usan `Assert.Throws` para validaciones
- Mensajes amigables al usuario, detalles técnicos solo en logs

### ❌ Incorrecto
- Usar excepciones para validar entrada de usuario
- Tests con `Assert.Throws` para validaciones esperables
- Exponer detalles técnicos al usuario final
- Silenciar excepciones con catch vacío

---

## Recursos adicionales

**Librerías útiles:**
- **FluentValidation**: Validaciones complejas declarativas sin excepciones
- **Polly**: Resilencia y reintentos para fallos técnicos
- **Microsoft.Extensions.Logging**: Para logging apropiado de errores técnicos

**Patrones recomendados:**
- **TryXxx Pattern**: Estilo .NET estándar para operaciones que pueden fallar
- **Chain of Responsibility**: Para validaciones complejas en secuencia
- **Circuit Breaker**: Para manejar fallos repetidos de servicios externos

---

## Resumen

### Transformación lograda

**❌ Enfoque anterior (problemático):**
```csharp
// Lanzar excepciones para validaciones esperables
if (entrada == null) throw new ArgumentNullException();
// Tests que esperan excepciones para datos inválidos
Assert.Throws<ArgumentException>(() => Validar(""));
```

**✅ Enfoque moderno (robusto):**
```csharp
// Manejo defensivo con TryXxx patterns
if (entrada == null) { error = "Entrada requerida"; return false; }
// Tests que verifican manejo gracioso
Assert.False(TryValidar("", out string error));
```

### Beneficios del cambio

- **Performance**: Eliminamos overhead costoso de excepciones
- **Claridad**: Flujos de éxito/error son explícitos y predecibles
- **UX**: Usuarios reciben mensajes amigables, no crashes
- **Mantenibilidad**: Código más fácil de testear y debuggear
- **Profesional**: Refleja mejores prácticas de la industria

### Para recordar

> **"Las excepciones son para situaciones excepcionales, no para el flujo normal de validación"**

Este cambio de mentalidad es fundamental para escribir aplicaciones robustas y profesionales.
