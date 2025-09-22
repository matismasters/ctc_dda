# Patrón Factory

---

## ¿Qué es el Patrón Factory?

El **patrón Factory** es un mecanismo para crear objetos sin especificar exactamente qué clase concreta instanciar. En lugar de usar `new` directamente, delegamos la creación de objetos a una "fábrica" que decide cuál crear.

**En términos simples:** Es como ir a una fábrica de automóviles y pedir "un auto económico" en lugar de tener que saber exactamente cómo construir un Fiat Uno paso a paso.

---

## ¿Cuándo usar Factory?

✅ **Úsalo cuando:**
- Tienes diferentes tipos de objetos similares que crear (notificaciones, validadores, reportes)
- No sabes de antemano qué tipo específico necesitas crear
- Quieres cambiar qué tipo de objeto crear sin modificar tu código
- Necesitas testear tu código sin depender de clases concretas

❌ **No lo uses cuando:**
- Solo tienes un tipo de objeto para crear
- La creación del objeto es muy simple
- El costo de la abstracción es mayor que sus beneficios

---

## ¿Por qué usar Factory?

### Problema: Código acoplado a clases concretas

```csharp
public class ServicioNotificaciones
{
    public void EnviarNotificacion(string tipo, string mensaje, string destinatario)
    {
        // Acoplado a clases específicas
        if (tipo == "email")
        {
            var notificador = new NotificadorEmail(); // ¡Acoplamiento!
            notificador.Enviar(mensaje, destinatario);
        }
        else if (tipo == "sms")
        {
            var notificador = new NotificadorSMS(); // ¡Más acoplamiento!
            notificador.Enviar(mensaje, destinatario);
        }
        
        // ¿Cómo agregar WhatsApp sin modificar este código?
    }
}
```

### Problemas de este enfoque:
- **Difícil de extender**: agregar nuevos tipos requiere modificar el código
- **Difícil de testear**: necesitas instancias reales de cada clase
- **Violación del principio abierto/cerrado**: cerrado para extensión

---

## Solución: Patrón Factory

### 1. Interfaz común

```csharp
public interface INotificador
{
    void Enviar(string mensaje, string destinatario);
}
```

### 2. Implementaciones concretas

```csharp
public class NotificadorEmail : INotificador
{
    public void Enviar(string mensaje, string destinatario)
    {
        Console.WriteLine($"Enviando email a {destinatario}: {mensaje}");
    }
}

public class NotificadorSMS : INotificador
{
    public void Enviar(string mensaje, string destinatario)
    {
        Console.WriteLine($"Enviando SMS a {destinatario}: {mensaje}");
    }
}
```

### 3. Factory que crea los objetos

```csharp
public class NotificadorFactory
{
    public INotificador Crear(string tipo)
    {
        return tipo.ToLower() switch
        {
            "email" => new NotificadorEmail(),
            "sms" => new NotificadorSMS(),
            _ => throw new ArgumentException($"Tipo de notificador no soportado: {tipo}")
        };
    }
}
```

### 4. Servicio usando el Factory

```csharp
public class ServicioNotificaciones
{
    private readonly NotificadorFactory _factory;

    public ServicioNotificaciones(NotificadorFactory factory)
    {
        _factory = factory;
    }

    public void EnviarNotificacion(string tipo, string mensaje, string destinatario)
    {
        // Solo lógica de negocio, sin acoplamiento
        if (string.IsNullOrEmpty(mensaje) || string.IsNullOrEmpty(destinatario))
            throw new ArgumentException("Mensaje y destinatario son requeridos");

        INotificador notificador = _factory.Crear(tipo);
        notificador.Enviar(mensaje, destinatario);
    }
}
```

---

## Ejemplo de uso

```csharp
// En tu aplicación
var factory = new NotificadorFactory();
var servicio = new ServicioNotificaciones(factory);

// Enviar diferentes tipos de notificaciones
servicio.EnviarNotificacion("email", "Hola mundo", "juan@email.com");
servicio.EnviarNotificacion("sms", "Código: 1234", "099123456");

// Agregar nuevos tipos es fácil - solo se modifica el factory
```

---

## Beneficios de esta solución

### ✅ **Extensible**
Agregar WhatsApp es fácil:
```csharp
public class NotificadorWhatsApp : INotificador
{
    public void Enviar(string mensaje, string destinatario)
    {
        Console.WriteLine($"Enviando WhatsApp a {destinatario}: {mensaje}");
    }
}

// Solo modificas el factory, no el servicio
public INotificador Crear(string tipo)
{
    return tipo.ToLower() switch
    {
        "email" => new NotificadorEmail(),
        "sms" => new NotificadorSMS(),
        "whatsapp" => new NotificadorWhatsApp(), // ¡Nuevo!
        _ => throw new ArgumentException($"Tipo de notificador no soportado: {tipo}")
    };
}
```

### ✅ **Testeable**
```csharp
[Test]
public void EnviarNotificacion_TipoValido_CreaNotificadorCorrecto()
{
    // Arrange
    var factory = new NotificadorFactory(); // Sin dependencias!
    var servicio = new ServicioNotificaciones(factory);
    
    // Act & Assert - no necesita base de datos ni servicios externos
    servicio.EnviarNotificacion("email", "test", "test@test.com");
    // El test es rápido y confiable
}
```

### ✅ **Separación de responsabilidades**
- **Factory**: solo sabe cómo crear objetos
- **Servicio**: solo sabe la lógica de negocio
- **Notificadores**: solo saben cómo enviar su tipo específico

---

## Resumen

El patrón Factory te permite:
1. **Desacoplar** la creación de objetos del código que los usa
2. **Extender** fácilmente agregando nuevos tipos sin modificar código existente
3. **Testear** más fácilmente con objetos controlados
4. **Centralizar** la lógica de creación en un solo lugar

**Recuerda:** Factory es como tener una "fábrica" que sabe cómo crear diferentes productos, permitiéndote pedir lo que necesitas sin tener que saber cómo construirlo.
