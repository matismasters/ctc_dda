# Patrón Factory - Conceptos y Ejercicios

## Explicación Conceptual

El **patrón Factory** es un patrón de diseño creacional que resuelve el problema de **crear objetos sin especificar la clase exacta** que se va a crear. En lugar de usar el operador `new` directamente en el código cliente, se delega la responsabilidad de creación a una clase especializada llamada "factory" (fábrica).

El patrón encapsula la lógica de creación y permite que el código cliente trabaje con **abstracciones** (interfaces o clases abstractas) sin conocer las implementaciones concretas. Esto significa que el código que usa los objetos no necesita saber qué clase específica está siendo instanciada.

La esencia del patrón es **separar el código que usa los objetos del código que los crea**. Esto permite que el sistema sea más flexible, ya que se pueden agregar nuevos tipos de objetos sin modificar el código existente que los utiliza.

## Para Qué Sirve

El patrón Factory sirve para:

- **Desacoplar la creación de objetos**: El código cliente no depende de clases concretas, solo de abstracciones
- **Centralizar la lógica de creación**: Toda la lógica para decidir qué tipo de objeto crear está en un lugar
- **Facilitar el mantenimiento**: Agregar nuevos tipos no requiere modificar código existente
- **Mejorar la testabilidad**: Se pueden crear objetos mock o stub fácilmente para testing
- **Permitir configuración dinámica**: La decisión de qué crear puede basarse en parámetros, configuración o contexto

## Cuándo Se Usa

El patrón Factory se usa cuando:

- **No sabes de antemano qué tipos exactos** necesitarás crear
- **Quieres que el sistema sea extensible** sin modificar código existente
- **La lógica de creación es compleja** y no pertenece al código cliente
- **Necesitas crear familias de objetos relacionados** que deben trabajar juntos
- **Quieres desacoplar** el código de alta nivel de los detalles de implementación
- **El tipo de objeto a crear depende de condiciones** que se evalúan en tiempo de ejecución

Ejemplos comunes incluyen: crear diferentes tipos de conexiones a base de datos, validadores con diferentes reglas, procesadores de archivos según extensión, o estrategias de algoritmos según contexto.

## Historia del Patrón

El patrón Factory fue **formalizado en 1995** por el "Gang of Four" (GoF) en su libro "Design Patterns: Elements of Reusable Object-Oriented Software". Sin embargo, el concepto existía desde **los años 1980** en la programación orientada a objetos.

La idea central proviene de la **manufactura industrial**, donde una "fábrica" produce diferentes productos usando la misma interfaz de producción. En software, esto se tradujo en crear objetos de diferentes tipos usando la misma interfaz de creación.

El patrón se popularizó especialmente con el auge de **Java y C#** en los años 1990-2000, donde frameworks como **Spring** y **.NET** lo adoptaron extensivamente. Hoy en día es uno de los patrones más utilizados en desarrollo profesional.

---

## Sintaxis Básica en C#

### Esqueleto Mínimo

```csharp
// 1. Interfaz o clase abstracta para el producto
public interface IProducto
{
    void Operacion();
}

// 2. Implementaciones concretas del producto
public class ProductoA : IProducto
{
    public void Operacion() => Console.WriteLine("Operación de ProductoA");
}

public class ProductoB : IProducto
{
    public void Operacion() => Console.WriteLine("Operación de ProductoB");
}

// 3. Factory que crea los productos
public class ProductoFactory
{
    public IProducto CrearProducto(string tipo)
    {
        return tipo switch
        {
            "A" => new ProductoA(),
            "B" => new ProductoB(),
            _ => throw new ArgumentException($"Tipo desconocido: {tipo}")
        };
    }
}

// 4. Código cliente que usa la factory
public class Cliente
{
    private readonly ProductoFactory _factory;
    
    public Cliente()
    {
        _factory = new ProductoFactory();
    }
    
    public void EjecutarOperacion(string tipo)
    {
        IProducto producto = _factory.CrearProducto(tipo); // No conoce la clase concreta
        producto.Operacion(); // Solo usa la interfaz
    }
}
```

### Elementos Clave

1. **Producto abstracto** (`IProducto`): Define la interfaz común
2. **Productos concretos** (`ProductoA`, `ProductoB`): Implementaciones específicas
3. **Factory** (`ProductoFactory`): Encapsula la lógica de creación
4. **Cliente** (`Cliente`): Usa la factory, no crea objetos directamente

---

## Ejercicios

### Ejercicio 1: Sistema de Notificaciones

Crear un sistema que pueda enviar notificaciones por diferentes medios (Email, SMS, Push). El sistema debe poder determinar qué tipo de notificación crear según un parámetro string.

**Implementar:**
- Interfaz `INotificacion` con método `Enviar(string mensaje)`
- Clases concretas: `EmailNotificacion`, `SmsNotificacion`, `PushNotificacion`
- Factory `NotificacionFactory` que cree el tipo correcto según parámetro
- Clase cliente que use la factory para enviar notificaciones

### Ejercicio 2: Procesadores de Archivos

Desarrollar un sistema que procese archivos de diferentes formatos (CSV, JSON, XML) según la extensión del archivo.

**Implementar:**
- Interfaz `IProcesadorArchivo` con método `Procesar(string rutaArchivo)`
- Clases concretas para cada formato: `ProcesadorCsv`, `ProcesadorJson`, `ProcesadorXml`
- Factory `ProcesadorFactory` que determine el procesador por extensión de archivo
- Servicio que use la factory para procesar archivos automáticamente

### Ejercicio 3: Calculadoras Especializadas

Construir un sistema de calculadoras especializadas (Básica, Científica, Financiera) que se seleccionen según el nivel del usuario.

**Implementar:**
- Interfaz `ICalculadora` con métodos básicos como `Sumar`, `Restar`, etc.
- Clases concretas con diferentes capacidades: `CalculadoraBasica`, `CalculadoraCientifica`, `CalculadoraFinanciera`
- Factory `CalculadoraFactory` que seleccione según enum `NivelUsuario`
- Aplicación que use la factory para proporcionar la calculadora apropiada al usuario
