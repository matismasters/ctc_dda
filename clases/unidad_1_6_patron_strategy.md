# Clase 6 – Patrón Strategy: Algoritmos Intercambiables y Extensibles

**Duración:** 3 horas  
**Objetivo general:** dominar el **patrón Strategy** para encapsular algoritmos intercambiables, eliminar estructuras **if/else complejas**, implementar **estrategias de descuentos** y **métodos de pago**, y escribir **tests parametrizados** que verifiquen comportamiento de múltiples estrategias sin duplicar código.

---

## Índice

1. Módulo 1 — El problema de los algoritmos hardcodeados
2. Módulo 2 — Strategy básico: Encapsular algoritmos
3. Módulo 3 — Strategy con Factory: Selección dinámica
4. Módulo 4 — Composición de estrategias: Combinando comportamientos
5. Módulo 5 — Ejercicios progresivos: Sistema de pricing y pagos
6. Recursos para algoritmos configurable
7. Testing de strategies con casos parametrizados
8. Glosario de términos de comportamiento
9. Cierre

---

## Módulo 1 — El problema de los algoritmos hardcodeados

> El **hardcodeo de algoritmos** en estructuras **if/else** o **switch** crea código **rígido**, **difícil de extender** y que **viola el principio abierto/cerrado**.

### 1.1 Principios fundamentales

* **Encapsulación de algoritmos**: cada algoritmo vive en su propia clase
* **Intercambiabilidad**: cambiar comportamiento sin modificar código cliente
* **Extensibilidad**: agregar nuevos algoritmos sin tocar los existentes
* **Responsabilidad única**: cada estrategia tiene una sola razón para cambiar

### 1.2 Ejemplo 1 – Cálculo de descuentos (problemático vs profesional)

**❌ Problemático (if/else hardcodeado, difícil de extender):**

```csharp
// ServicioDescuentos.cs (MALO - algoritmos hardcodeados)
public class ServicioDescuentos_Malo
{
    public decimal CalcularDescuento(decimal montoBase, string tipoCliente, int cantidadProductos)
    {
        decimal descuento = 0;
        
        // ¡Estructura if/else rígida!
        if (tipoCliente == "VIP")
        {
            if (cantidadProductos >= 10)
                descuento = montoBase * 0.25m; // 25% para VIP con 10+ productos
            else if (cantidadProductos >= 5)
                descuento = montoBase * 0.20m; // 20% para VIP con 5+ productos  
            else
                descuento = montoBase * 0.15m; // 15% VIP base
        }
        else if (tipoCliente == "Premium")
        {
            if (cantidadProductos >= 10)
                descuento = montoBase * 0.15m; // 15% Premium con 10+ productos
            else if (cantidadProductos >= 5)
                descuento = montoBase * 0.10m; // 10% Premium con 5+ productos
            else
                descuento = montoBase * 0.05m; // 5% Premium base
        }
        else if (tipoCliente == "Regular")
        {
            if (cantidadProductos >= 10)
                descuento = montoBase * 0.05m; // 5% Regular con 10+ productos
            else
                descuento = 0; // Sin descuento para Regular < 10 productos
        }
        else if (tipoCliente == "Estudiante") // ¿Qué pasa si agregamos este tipo nuevo?
        {
            // ¡Tenemos que modificar este método! Viola principio abierto/cerrado
            descuento = montoBase * 0.10m;
        }
        
        return descuento;
    }
    
    // Problemas:
    // 1. ¿Cómo testear cada rama sin código duplicado?
    // 2. ¿Cómo agregar "ClienteEmpresarial" sin tocar este código?
    // 3. Lógica compleja mezclada, difícil de mantener
}
```

**✅ Profesional (Strategy encapsula cada algoritmo):**

```csharp
// IEstrategiaDescuento.cs
public interface IEstrategiaDescuento
{
    decimal CalcularDescuento(decimal montoBase, int cantidadProductos);
    string ObtenerDescripcion();
}

// EstrategiaDescuentoVip.cs
public class EstrategiaDescuentoVip : IEstrategiaDescuento
{
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos)
    {
        return cantidadProductos switch
        {
            >= 10 => montoBase * 0.25m, // 25% para 10+
            >= 5 => montoBase * 0.20m,  // 20% para 5+  
            _ => montoBase * 0.15m       // 15% base
        };
    }
    
    public string ObtenerDescripcion() => "Descuento VIP con escalas por volumen";
}

// EstrategiaDescuentoPremium.cs  
public class EstrategiaDescuentoPremium : IEstrategiaDescuento
{
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos)
    {
        return cantidadProductos switch
        {
            >= 10 => montoBase * 0.15m, // 15% para 10+
            >= 5 => montoBase * 0.10m,  // 10% para 5+
            _ => montoBase * 0.05m       // 5% base
        };
    }
    
    public string ObtenerDescripcion() => "Descuento Premium progresivo";
}

// EstrategiaDescuentoRegular.cs
public class EstrategiaDescuentoRegular : IEstrategiaDescuento  
{
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos)
    {
        return cantidadProductos >= 10 ? montoBase * 0.05m : 0m;
    }
    
    public string ObtenerDescripcion() => "Descuento solo para compras grandes";
}

// ServicioDescuentos.cs - Solo coordina, no calcula
public class ServicioDescuentos
{
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos, IEstrategiaDescuento estrategia)
    {
        if (montoBase <= 0) return 0;
        if (estrategia == null) return 0;
        
        return estrategia.CalcularDescuento(montoBase, cantidadProductos);
    }
}

// Uso del patrón
public void EjemploUso()
{
    var servicio = new ServicioDescuentos();
    
    IEstrategiaDescuento estrategiaVip = new EstrategiaDescuentoVip();
    decimal descuentoVip = servicio.CalcularDescuento(1000m, 8, estrategiaVip);
    // Resultado: 200 (20% porque son 8 productos, rango 5-9)
    
    // Fácil cambiar estrategia
    IEstrategiaDescuento estrategiaPremium = new EstrategiaDescuentoPremium();  
    decimal descuentoPremium = servicio.CalcularDescuento(1000m, 8, estrategiaPremium);
    // Resultado: 100 (10% porque son 8 productos, rango 5-9)
}
```

**Qué mejora:** cada algoritmo encapsulado, fácil testing individual, extensible sin modificar código existente.

### 1.3 Ventajas del patrón Strategy

* **Eliminación de if/else complejos**: código más limpio y legible
* **Extensibilidad**: agregar nuevas estrategias sin tocar código existente
* **Testabilidad**: cada estrategia se prueba independientemente
* **Reutilización**: misma estrategia en múltiples contextos
* **Configurabilidad**: decidir estrategia en runtime desde configuración

---

## Módulo 2 — Strategy básico: Encapsular algoritmos

> Objetivo: **definir una familia de algoritmos**, encapsular cada uno, y **hacerlos intercambiables** en tiempo de ejecución.

### 2.1 Estructura básica del Strategy

```csharp
// Strategy abstracto - define la operación
public interface IEstrategiaEnvio
{
    decimal CalcularCosto(decimal peso, string destino);
    TimeSpan EstimarTiempoEntrega(string destino);
    string ObtenerTransportista();
}

// Estrategias concretas - implementan algoritmos específicos
public class EnvioEstandar : IEstrategiaEnvio
{
    public decimal CalcularCosto(decimal peso, string destino)
    {
        decimal costoBase = 5.0m;
        decimal costoPorKg = 2.0m;
        decimal multiplicadorDestino = destino.ToUpper() switch
        {
            "MONTEVIDEO" => 1.0m,
            "INTERIOR" => 1.5m,
            "INTERNACIONAL" => 3.0m,
            _ => 1.2m
        };
        
        return (costoBase + peso * costoPorKg) * multiplicadorDestino;
    }
    
    public TimeSpan EstimarTiempoEntrega(string destino) => destino.ToUpper() switch
    {
        "MONTEVIDEO" => TimeSpan.FromDays(2),
        "INTERIOR" => TimeSpan.FromDays(3),
        "INTERNACIONAL" => TimeSpan.FromDays(7),
        _ => TimeSpan.FromDays(4)
    };
    
    public string ObtenerTransportista() => "Correo Nacional";
}

public class EnvioExpress : IEstrategiaEnvio
{
    public decimal CalcularCosto(decimal peso, string destino)
    {
        // Express es más caro pero más rápido
        decimal costoBase = 15.0m;
        decimal costoPorKg = 5.0m;
        decimal multiplicadorDestino = destino.ToUpper() switch
        {
            "MONTEVIDEO" => 1.0m,
            "INTERIOR" => 1.8m,
            "INTERNACIONAL" => 4.0m,
            _ => 1.5m
        };
        
        return (costoBase + peso * costoPorKg) * multiplicadorDestino;
    }
    
    public TimeSpan EstimarTiempoEntrega(string destino) => destino.ToUpper() switch
    {
        "MONTEVIDEO" => TimeSpan.FromHours(24),
        "INTERIOR" => TimeSpan.FromDays(1),  
        "INTERNACIONAL" => TimeSpan.FromDays(3),
        _ => TimeSpan.FromDays(2)
    };
    
    public string ObtenerTransportista() => "Express Delivery";
}

public class EnvioGratis : IEstrategiaEnvio
{
    private readonly decimal _montoMinimoParaEnvioGratis;
    
    public EnvioGratis(decimal montoMinimoParaEnvioGratis = 1000m)
    {
        _montoMinimoParaEnvioGratis = montoMinimoParaEnvioGratis;
    }
    
    public decimal CalcularCosto(decimal peso, string destino)
    {
        // Nota: En un caso real, el contexto pasaría el monto de la compra
        // Por simplicidad, asumimos que siempre califica para envío gratis
        return 0m;
    }
    
    public TimeSpan EstimarTiempoEntrega(string destino) => destino.ToUpper() switch
    {
        "MONTEVIDEO" => TimeSpan.FromDays(3),
        "INTERIOR" => TimeSpan.FromDays(5),
        _ => TimeSpan.FromDays(4)
    };
    
    public string ObtenerTransportista() => "Logística Propia";
}
```

### 2.2 Context - Clase que usa las estrategias

```csharp
// CalculadoraEnvio.cs - Context que usa strategies
public class CalculadoraEnvio
{
    private IEstrategiaEnvio _estrategiaActual;
    
    public CalculadoraEnvio(IEstrategiaEnvio estrategia)
    {
        _estrategiaActual = estrategia ?? throw new ArgumentNullException(nameof(estrategia));
    }
    
    // Permite cambiar estrategia en runtime
    public void CambiarEstrategia(IEstrategiaEnvio nuevaEstrategia)
    {
        _estrategiaActual = nuevaEstrategia ?? throw new ArgumentNullException(nameof(nuevaEstrategia));
    }
    
    // Métodos que delegan a la estrategia actual
    public decimal CalcularCostoEnvio(decimal peso, string destino)
    {
        return _estrategiaActual.CalcularCosto(peso, destino);
    }
    
    public TimeSpan EstimarTiempoEntrega(string destino)
    {
        return _estrategiaActual.EstimarTiempoEntrega(destino);
    }
    
    public string ObtenerInformacionEnvio(decimal peso, string destino)
    {
        var costo = _estrategiaActual.CalcularCosto(peso, destino);
        var tiempo = _estrategiaActual.EstimarTiempoEntrega(destino);
        var transportista = _estrategiaActual.ObtenerTransportista();
        
        return $"Transportista: {transportista}\n" +
               $"Costo: ${costo:F2}\n" +
               $"Tiempo estimado: {tiempo.TotalDays} días";
    }
}
```

### 2.3 Ejercicio guiado (20 min)

> Objetivo: implementar estrategias de validación de passwords con diferentes niveles de seguridad.

1. **Definir interfaz de estrategia:**

```csharp
public interface IEstrategiaValidacionPassword
{
    bool EsValido(string password);
    string ObtenerMensajeError();
    int ObtenerNivelSeguridad(); // 1-5, donde 5 es más seguro
}
```

2. **Implementar estrategias concretas:**

```csharp
public class ValidacionBasica : IEstrategiaValidacionPassword
{
    public bool EsValido(string password)
    {
        // Solo verificar longitud mínima
        return !string.IsNullOrEmpty(password) && password.Length >= 6;
    }
    
    public string ObtenerMensajeError() => "Password debe tener al menos 6 caracteres";
    public int ObtenerNivelSeguridad() => 1;
}

public class ValidacionIntermedia : IEstrategiaValidacionPassword
{
    public bool EsValido(string password)
    {
        if (string.IsNullOrEmpty(password) || password.Length < 8)
            return false;
            
        // Debe tener al menos una mayúscula y un número
        bool tieneMayuscula = password.Any(char.IsUpper);
        bool tieneNumero = password.Any(char.IsDigit);
        
        return tieneMayuscula && tieneNumero;
    }
    
    public string ObtenerMensajeError() => "Password debe tener 8+ caracteres, al menos una mayúscula y un número";
    public int ObtenerNivelSeguridad() => 3;
}

public class ValidacionAvanzada : IEstrategiaValidacionPassword
{
    public bool EsValido(string password)
    {
        if (string.IsNullOrEmpty(password) || password.Length < 12)
            return false;
            
        bool tieneMayuscula = password.Any(char.IsUpper);
        bool tieneMinuscula = password.Any(char.IsLower);
        bool tieneNumero = password.Any(char.IsDigit);
        bool tieneEspecial = password.Any(c => "!@#$%^&*()_+-=[]{}|;:,.<>?".Contains(c));
        
        return tieneMayuscula && tieneMinuscula && tieneNumero && tieneEspecial;
    }
    
    public string ObtenerMensajeError() => "Password debe tener 12+ caracteres, mayúsculas, minúsculas, números y símbolos especiales";
    public int ObtenerNivelSeguridad() => 5;
}
```

3. **Crear validador que usa estrategias:**

```csharp
public class ValidadorPassword
{
    private IEstrategiaValidacionPassword _estrategia;
    
    public ValidadorPassword(IEstrategiaValidacionPassword estrategia)
    {
        _estrategia = estrategia;
    }
    
    public ResultadoValidacion Validar(string password)
    {
        bool esValido = _estrategia.EsValido(password);
        return new ResultadoValidacion
        {
            EsValido = esValido,
            MensajeError = esValido ? null : _estrategia.ObtenerMensajeError(),
            NivelSeguridad = _estrategia.ObtenerNivelSeguridad()
        };
    }
}

public class ResultadoValidacion
{
    public bool EsValido { get; set; }
    public string MensajeError { get; set; }
    public int NivelSeguridad { get; set; }
}
```

**Criterio de éxito:** poder cambiar nivel de validación sin modificar código del validador.

---

## Módulo 3 — Strategy con Factory: Selección dinámica

> Objetivo: **combinar Strategy con Factory** para seleccionar estrategias dinámicamente basado en **configuración** o **contexto**.

### 3.1 Factory de estrategias

```csharp
// Enum para tipos de estrategia
public enum TipoEstrategiaDescuento
{
    Vip,
    Premium,
    Regular,  
    Estudiante,
    Empleado
}

// Factory que crea estrategias
public class EstrategiaDescuentoFactory
{
    // Registro de estrategias disponibles
    private readonly Dictionary<TipoEstrategiaDescuento, Func<IEstrategiaDescuento>> _estrategias;
    
    public EstrategiaDescuentoFactory()
    {
        _estrategias = new Dictionary<TipoEstrategiaDescuento, Func<IEstrategiaDescuento>>
        {
            { TipoEstrategiaDescuento.Vip, () => new EstrategiaDescuentoVip() },
            { TipoEstrategiaDescuento.Premium, () => new EstrategiaDescuentoPremium() },
            { TipoEstrategiaDescuento.Regular, () => new EstrategiaDescuentoRegular() },
            { TipoEstrategiaDescuento.Estudiante, () => new EstrategiaDescuentoEstudiante() },
            { TipoEstrategiaDescuento.Empleado, () => new EstrategiaDescuentoEmpleado() }
        };
    }
    
    public IEstrategiaDescuento Crear(TipoEstrategiaDescuento tipo)
    {
        if (_estrategias.TryGetValue(tipo, out var factory))
        {
            return factory();
        }
        
        throw new ArgumentException($"No existe estrategia para el tipo: {tipo}");
    }
    
    // Método para registro dinámico de nuevas estrategias
    public void RegistrarEstrategia(TipoEstrategiaDescuento tipo, Func<IEstrategiaDescuento> factory)
    {
        _estrategias[tipo] = factory;
    }
    
    // Obtener todas las estrategias disponibles
    public IEnumerable<TipoEstrategiaDescuento> ObtenerTiposDisponibles()
    {
        return _estrategias.Keys;
    }
}
```

### 3.2 Selección basada en configuración

```csharp
// Configuración desde appsettings.json
public class ConfiguracionDescuentos
{
    public string EstrategiaDefault { get; set; } = "Regular";
    public Dictionary<string, string> EstrategiasPorTipoCliente { get; set; } = new();
    public bool PermitirDescuentosAcumulables { get; set; } = false;
}

// Selector de estrategias inteligente
public class SelectorEstrategiaDescuento
{
    private readonly EstrategiaDescuentoFactory _factory;
    private readonly ConfiguracionDescuentos _configuracion;
    
    public SelectorEstrategiaDescuento(
        EstrategiaDescuentoFactory factory, 
        ConfiguracionDescuentos configuracion)
    {
        _factory = factory;
        _configuracion = configuracion;
    }
    
    public IEstrategiaDescuento SeleccionarEstrategia(Cliente cliente, Pedido pedido)
    {
        // Lógica de negocio para seleccionar estrategia apropiada
        
        // 1. Por tipo de cliente específico
        if (_configuracion.EstrategiasPorTipoCliente.TryGetValue(cliente.TipoCliente, out var tipoEspecifico))
        {
            if (Enum.TryParse<TipoEstrategiaDescuento>(tipoEspecifico, out var tipo))
                return _factory.Crear(tipo);
        }
        
        // 2. Por reglas de negocio (ejemplo: estudiantes con carnet)
        if (cliente.EsEstudiante && cliente.TieneCarnetEstudiantil)
            return _factory.Crear(TipoEstrategiaDescuento.Estudiante);
            
        // 3. Por volumen de compra (upgrade automático)
        if (pedido.MontoTotal >= 5000m)
            return _factory.Crear(TipoEstrategiaDescuento.Vip);
        else if (pedido.MontoTotal >= 2000m)
            return _factory.Crear(TipoEstrategiaDescuento.Premium);
            
        // 4. Default desde configuración
        if (Enum.TryParse<TipoEstrategiaDescuento>(_configuracion.EstrategiaDefault, out var tipoDefault))
            return _factory.Crear(tipoDefault);
            
        // 5. Fallback
        return _factory.Crear(TipoEstrategiaDescuento.Regular);
    }
}
```

### 3.3 Integración con dependency injection

```csharp
// Program.cs - Registro en container de DI
public void ConfigureServices(IServiceCollection services)
{
    // Configuración
    services.Configure<ConfiguracionDescuentos>(Configuration.GetSection("Descuentos"));
    
    // Factory
    services.AddSingleton<EstrategiaDescuentoFactory>();
    
    // Selector
    services.AddScoped<SelectorEstrategiaDescuento>();
    
    // Servicio principal
    services.AddScoped<ServicioPedidos>();
}

// ServicioPedidos.cs - Uso integrado
public class ServicioPedidos
{
    private readonly SelectorEstrategiaDescuento _selectorEstrategia;
    
    public ServicioPedidos(SelectorEstrategiaDescuento selectorEstrategia)
    {
        _selectorEstrategia = selectorEstrategia;
    }
    
    public decimal CalcularTotalConDescuentos(Cliente cliente, Pedido pedido)
    {
        // El selector maneja toda la lógica de selección
        IEstrategiaDescuento estrategia = _selectorEstrategia.SeleccionarEstrategia(cliente, pedido);
        
        decimal montoBase = pedido.MontoTotal;
        decimal descuento = estrategia.CalcularDescuento(montoBase, pedido.CantidadProductos);
        
        return montoBase - descuento;
    }
}
```

---

## Módulo 4 — Composición de estrategias: Combinando comportamientos

> Objetivo: **combinar múltiples estrategias** para crear comportamientos complejos usando **Composite** y **Decorator** patterns.

### 4.1 Estrategia compuesta

```csharp
// Estrategia que combina múltiples estrategias
public class EstrategiaDescuentoCompuesta : IEstrategiaDescuento
{
    private readonly List<IEstrategiaDescuento> _estrategias;
    private readonly TipoComposicion _tipoComposicion;
    
    public EstrategiaDescuentoCompuesta(TipoComposicion tipo, params IEstrategiaDescuento[] estrategias)
    {
        _tipoComposicion = tipo;
        _estrategias = estrategias?.ToList() ?? new List<IEstrategiaDescuento>();
    }
    
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos)
    {
        if (!_estrategias.Any()) return 0;
        
        return _tipoComposicion switch
        {
            TipoComposicion.Maximo => CalcularMaximo(montoBase, cantidadProductos),
            TipoComposicion.Minimo => CalcularMinimo(montoBase, cantidadProductos),
            TipoComposicion.Suma => CalcularSuma(montoBase, cantidadProductos),
            TipoComposicion.Promedio => CalcularPromedio(montoBase, cantidadProductos),
            _ => 0
        };
    }
    
    private decimal CalcularMaximo(decimal montoBase, int cantidad)
    {
        return _estrategias.Max(e => e.CalcularDescuento(montoBase, cantidad));
    }
    
    private decimal CalcularMinimo(decimal montoBase, int cantidad)
    {
        return _estrategias.Min(e => e.CalcularDescuento(montoBase, cantidad));
    }
    
    private decimal CalcularSuma(decimal montoBase, int cantidad)
    {
        // Suma de descuentos, pero con límite para evitar descuento > 100%
        decimal totalDescuento = _estrategias.Sum(e => e.CalcularDescuento(montoBase, cantidad));
        return Math.Min(totalDescuento, montoBase * 0.9m); // Máximo 90% de descuento
    }
    
    private decimal CalcularPromedio(decimal montoBase, int cantidad)
    {
        return _estrategias.Average(e => e.CalcularDescuento(montoBase, cantidad));
    }
    
    public string ObtenerDescripcion()
    {
        var descripciones = _estrategias.Select(e => e.ObtenerDescripcion());
        return $"Combinación ({_tipoComposicion}): {string.Join(" + ", descripciones)}";
    }
}

public enum TipoComposicion
{
    Maximo,    // El mayor descuento de todas las estrategias
    Minimo,    // El menor descuento de todas las estrategias  
    Suma,      // Suma de todos los descuentos (con límite)
    Promedio   // Promedio de todos los descuentos
}
```

### 4.2 Estrategia decoradora (condicional)

```csharp
// Decorador que aplica condiciones a una estrategia
public class EstrategiaDescuentoCondicional : IEstrategiaDescuento
{
    private readonly IEstrategiaDescuento _estrategiaBase;
    private readonly Func<decimal, int, bool> _condicion;
    private readonly string _descripcionCondicion;
    
    public EstrategiaDescuentoCondicional(
        IEstrategiaDescuento estrategiaBase, 
        Func<decimal, int, bool> condicion,
        string descripcionCondicion)
    {
        _estrategiaBase = estrategiaBase;
        _condicion = condicion;
        _descripcionCondicion = descripcionCondicion;
    }
    
    public decimal CalcularDescuento(decimal montoBase, int cantidadProductos)
    {
        // Solo aplicar estrategia si se cumple la condición
        if (_condicion(montoBase, cantidadProductos))
        {
            return _estrategiaBase.CalcularDescuento(montoBase, cantidadProductos);
        }
        
        return 0; // No aplica descuento si no se cumple condición
    }
    
    public string ObtenerDescripcion()
    {
        return $"{_estrategiaBase.ObtenerDescripcion()} (Condición: {_descripcionCondicion})";
    }
    
    // Métodos de factoría para condiciones comunes
    public static EstrategiaDescuentoCondicional PorMontoMinimo(IEstrategiaDescuento estrategia, decimal montoMinimo)
    {
        return new EstrategiaDescuentoCondicional(
            estrategia,
            (monto, cantidad) => monto >= montoMinimo,
            $"Compra mínima ${montoMinimo}"
        );
    }
    
    public static EstrategiaDescuentoCondicional PorCantidadMinima(IEstrategiaDescuento estrategia, int cantidadMinima)
    {
        return new EstrategiaDescuentoCondicional(
            estrategia,
            (monto, cantidad) => cantidad >= cantidadMinima,
            $"Cantidad mínima {cantidadMinima} productos"
        );
    }
    
    public static EstrategiaDescuentoCondicional PorDiasSemana(IEstrategiaDescuento estrategia, params DayOfWeek[] diasValidos)
    {
        return new EstrategiaDescuentoCondicional(
            estrategia,
            (monto, cantidad) => diasValidos.Contains(DateTime.Today.DayOfWeek),
            $"Solo {string.Join(", ", diasValidos)}"
        );
    }
}
```

### 4.3 Builder para estrategias complejas

```csharp
// Builder para crear estrategias complejas de forma fluida
public class EstrategiaDescuentoBuilder
{
    private readonly List<IEstrategiaDescuento> _estrategias = new();
    private TipoComposicion _tipoComposicion = TipoComposicion.Maximo;
    
    public EstrategiaDescuentoBuilder ConEstrategia(IEstrategiaDescuento estrategia)
    {
        _estrategias.Add(estrategia);
        return this;
    }
    
    public EstrategiaDescuentoBuilder ConDescuentoVip()
    {
        return ConEstrategia(new EstrategiaDescuentoVip());
    }
    
    public EstrategiaDescuentoBuilder ConDescuentoPorVolumen(int cantidadMinima, decimal porcentaje)
    {
        var estrategia = new EstrategiaDescuentoPorcentaje(porcentaje);
        var condicional = EstrategiaDescuentoCondicional.PorCantidadMinima(estrategia, cantidadMinima);
        return ConEstrategia(condicional);
    }
    
    public EstrategiaDescuentoBuilder ConDescuentoFindeSemana(IEstrategiaDescuento estrategia)
    {
        var condicional = EstrategiaDescuentoCondicional.PorDiasSemana(
            estrategia, 
            DayOfWeek.Saturday, 
            DayOfWeek.Sunday
        );
        return ConEstrategia(condicional);
    }
    
    public EstrategiaDescuentoBuilder UsandoComposicion(TipoComposicion tipo)
    {
        _tipoComposicion = tipo;
        return this;
    }
    
    public IEstrategiaDescuento Construir()
    {
        if (!_estrategias.Any())
            return new EstrategiaDescuentoRegular();
            
        if (_estrategias.Count == 1)
            return _estrategias.First();
            
        return new EstrategiaDescuentoCompuesta(_tipoComposicion, _estrategias.ToArray());
    }
}

// Ejemplo de uso del builder
public void EjemploBuilder()
{
    var estrategiaCompleja = new EstrategiaDescuentoBuilder()
        .ConDescuentoVip()
        .ConDescuentoPorVolumen(cantidadMinima: 10, porcentaje: 0.05m)
        .ConDescuentoFindeSemana(new EstrategiaDescuentoPorcentaje(0.10m))
        .UsandoComposicion(TipoComposicion.Suma)
        .Construir();
    
    // Esta estrategia combina:
    // - Descuento VIP base
    // - 5% adicional si compra 10+ productos  
    // - 10% adicional si es fin de semana
    // - Los suma todos (con límite del 90%)
}
```

---

## Módulo 5 — Ejercicios progresivos: Sistema de pricing y pagos

> **Meta general:** construir sistema completo de **pricing dinámico** y **procesamiento de pagos** usando múltiples estrategias que se pueden combinar y configurar.

### 5.1 Contexto: Sistema de e-commerce avanzado

**Elementos fundamentales:**

* **Estrategias de pricing**: por volumen, por temporada, por cliente, por producto
* **Estrategias de pago**: tarjeta crédito, débito, transferencia, efectivo, criptomonedas
* **Composición**: combinar múltiples descuentos con reglas de negocio
* **Configuración**: selección dinámica basada en contexto
* **Testing**: verificar comportamiento de todas las combinaciones

### 5.2 Ejercicio 1 — Sistema de pricing con múltiples estrategias

**Objetivo:** implementar sistema de pricing que combine descuentos, impuestos y promociones.

**Metodología TDD:**

1. **Escribir tests primero** para verificar:
   * Cada estrategia de pricing calcula correctamente
   * Composición de estrategias funciona según reglas de negocio
   * Selección dinámica elige estrategia apropiada
   * Casos edge (descuentos mayores al 100%, precios negativos) se manejan

```csharp
// Tests para estrategias de pricing
[TestClass]
public class EstrategiasPricingTests
{
    [Theory]
    [InlineData(1000, 5, 50)]   // 5% para cantidades bajas
    [InlineData(1000, 15, 150)] // 15% para cantidades medias  
    [InlineData(1000, 25, 250)] // 25% para cantidades altas
    public void EstrategiaDescuentoPorVolumen_CantidadEspecifica_CalculaCorrectamente(
        decimal monto, int cantidad, decimal esperado)
    {
        // Arrange
        var estrategia = new EstrategiaDescuentoPorVolumen();
        
        // Act
        decimal descuento = estrategia.CalcularDescuento(monto, cantidad);
        
        // Assert
        Assert.Equal(esperado, descuento);
    }
    
    [Fact]
    public void EstrategiaCompuesta_SumaConLimite_NoExcede90Porciento()
    {
        // Arrange - estrategias que individualmente darían > 90% descuento
        var estrategia1 = new EstrategiaDescuentoPorcentaje(0.50m); // 50%
        var estrategia2 = new EstrategiaDescuentoPorcentaje(0.40m); // 40%
        var estrategia3 = new EstrategiaDescuentoPorcentaje(0.30m); // 30%
        
        var compuesta = new EstrategiaDescuentoCompuesta(
            TipoComposicion.Suma, 
            estrategia1, estrategia2, estrategia3
        ); // Total sería 120%, pero debe limitarse a 90%
        
        // Act
        decimal descuento = compuesta.CalcularDescuento(1000m, 10);
        
        // Assert
        Assert.Equal(900m, descuento); // 90% de 1000
    }
    
    [Fact]
    public void SelectorEstrategia_ClienteVipCompraGrande_SeleccionaEstrategiaOptima()
    {
        // Arrange
        var cliente = new Cliente { TipoCliente = "VIP", EsEstudiante = false };
        var pedido = new Pedido { MontoTotal = 5500m, CantidadProductos = 12 };
        
        var selector = new SelectorEstrategiaDescuento(factory, configuracion);
        
        // Act
        var estrategia = selector.SeleccionarEstrategia(cliente, pedido);
        
        // Assert
        Assert.IsType<EstrategiaDescuentoVip>(estrategia);
    }
}
```

2. **Implementar** sistema de pricing después de tener tests verdes

### 5.3 Ejercicio 2 — Estrategias de procesamiento de pagos

**Objetivo:** implementar diferentes métodos de pago como estrategias intercambiables.

```csharp
// IEstrategiaPago.cs
public interface IEstrategiaPago
{
    Task<ResultadoPago> ProcesarPagoAsync(decimal monto, DatosPago datosPago);
    decimal CalcularComision(decimal monto);
    TimeSpan ObtenerTiempoConfirmacion();
    bool SoportaReembolsos { get; }
}

// Estrategias concretas de pago
public class PagoTarjetaCredito : IEstrategiaPago
{
    private readonly IProveedorPagos _proveedorPagos;
    
    public PagoTarjetaCredito(IProveedorPagos proveedorPagos)
    {
        _proveedorPagos = proveedorPagos;
    }
    
    public async Task<ResultadoPago> ProcesarPagoAsync(decimal monto, DatosPago datosPago)
    {
        // Validaciones específicas de tarjeta de crédito
        if (!ValidarNumeroTarjeta(datosPago.NumeroTarjeta))
            return ResultadoPago.Error("Número de tarjeta inválido");
            
        if (DateTime.Parse(datosPago.FechaVencimiento) <= DateTime.Now)
            return ResultadoPago.Error("Tarjeta vencida");
        
        // Procesar con proveedor externo
        try
        {
            var respuesta = await _proveedorPagos.ProcesarTarjetaCreditoAsync(
                datosPago.NumeroTarjeta, 
                datosPago.CodigoSeguridad, 
                monto
            );
            
            return respuesta.Exitoso 
                ? ResultadoPago.Exito(respuesta.TransaccionId, CalcularComision(monto))
                : ResultadoPago.Error(respuesta.MensajeError);
        }
        catch (Exception ex)
        {
            return ResultadoPago.Error($"Error procesando pago: {ex.Message}");
        }
    }
    
    public decimal CalcularComision(decimal monto) => monto * 0.029m; // 2.9%
    public TimeSpan ObtenerTiempoConfirmacion() => TimeSpan.FromMinutes(2);
    public bool SoportaReembolsos => true;
    
    private bool ValidarNumeroTarjeta(string numero)
    {
        // Algoritmo de Luhn para validar tarjetas
        // Implementación simplificada
        return !string.IsNullOrEmpty(numero) && numero.Length >= 13 && numero.Length <= 19;
    }
}

public class PagoTransferenciaBancaria : IEstrategiaPago
{
    public async Task<ResultadoPago> ProcesarPagoAsync(decimal monto, DatosPago datosPago)
    {
        // Transferencia bancaria requiere validación manual
        // En un caso real, esto sería asíncrono
        
        if (string.IsNullOrEmpty(datosPago.CuentaBancaria))
            return ResultadoPago.Error("Cuenta bancaria requerida");
            
        // Simular proceso de transferencia
        await Task.Delay(1000); // Simular llamada a API bancaria
        
        // En realidad, esto estaría pendiente de confirmación
        return ResultadoPago.Pendiente("Transferencia iniciada, aguardando confirmación bancaria");
    }
    
    public decimal CalcularComision(decimal monto) => 5.0m; // Comisión fija
    public TimeSpan ObtenerTiempoConfirmacion() => TimeSpan.FromHours(24);
    public bool SoportaReembolsos => false; // Las transferencias no se pueden reembolsar automáticamente
}

public class PagoCriptomoneda : IEstrategiaPago
{
    private readonly IBlockchainService _blockchainService;
    
    public PagoCriptomoneda(IBlockchainService blockchainService)
    {
        _blockchainService = blockchainService;
    }
    
    public async Task<ResultadoPago> ProcesarPagoAsync(decimal monto, DatosPago datosPago)
    {
        if (string.IsNullOrEmpty(datosPago.WalletAddress))
            return ResultadoPago.Error("Dirección de wallet requerida");
            
        try
        {
            // Convertir monto a criptomoneda
            decimal montoCrypto = await ConvertirACriptomoneda(monto, datosPago.TipoCriptomoneda);
            
            // Procesar transacción en blockchain
            var transaccionId = await _blockchainService.EnviarTransaccionAsync(
                datosPago.WalletAddress, 
                montoCrypto, 
                datosPago.TipoCriptomoneda
            );
            
            return ResultadoPago.Exito(transaccionId, CalcularComision(monto));
        }
        catch (Exception ex)
        {
            return ResultadoPago.Error($"Error en transacción blockchain: {ex.Message}");
        }
    }
    
    public decimal CalcularComision(decimal monto) => 0.01m; // Comisión muy baja
    public TimeSpan ObtenerTiempoConfirmacion() => TimeSpan.FromMinutes(10);
    public bool SoportaReembolsos => false; // Las transacciones blockchain son irreversibles
    
    private async Task<decimal> ConvertirACriptomoneda(decimal montoUSD, string tipoCripto)
    {
        // Obtener tasa de cambio actual
        // En un caso real, esto vendría de una API de exchange
        var tasaCambio = tipoCripto.ToUpper() switch
        {
            "BTC" => 45000m,
            "ETH" => 3000m,
            "USDT" => 1m,
            _ => throw new ArgumentException($"Criptomoneda no soportada: {tipoCripto}")
        };
        
        return montoUSD / tasaCambio;
    }
}

// DTOs de soporte
public class DatosPago
{
    public string NumeroTarjeta { get; set; }
    public string CodigoSeguridad { get; set; }
    public string FechaVencimiento { get; set; }
    public string CuentaBancaria { get; set; }
    public string WalletAddress { get; set; }
    public string TipoCriptomoneda { get; set; }
}

public class ResultadoPago
{
    public bool EsExitoso { get; set; }
    public bool EstaPendiente { get; set; }
    public string TransaccionId { get; set; }
    public string MensajeError { get; set; }
    public decimal ComisionAplicada { get; set; }
    
    public static ResultadoPago Exito(string transaccionId, decimal comision)
        => new() { EsExitoso = true, TransaccionId = transaccionId, ComisionAplicada = comision };
        
    public static ResultadoPago Error(string mensaje)
        => new() { EsExitoso = false, MensajeError = mensaje };
        
    public static ResultadoPago Pendiente(string mensaje)
        => new() { EstaPendiente = true, MensajeError = mensaje };
}
```

### 5.4 Ejercicio 3 — Integración completa con selección dinámica

**Objetivo:** integrar pricing y pagos en un sistema completo que seleccione estrategias basado en contexto.

```csharp
// ServicioProcesadorPedidos.cs - Orquesta todo el proceso
public class ServicioProcesadorPedidos
{
    private readonly SelectorEstrategiaDescuento _selectorDescuento;
    private readonly SelectorEstrategiaPago _selectorPago;
    
    public ServicioProcesadorPedidos(
        SelectorEstrategiaDescuento selectorDescuento,
        SelectorEstrategiaPago selectorPago)
    {
        _selectorDescuento = selectorDescuento;
        _selectorPago = selectorPago;
    }
    
    public async Task<ResultadoProcesamiento> ProcesarPedidoCompletoAsync(
        Cliente cliente, 
        Pedido pedido, 
        PreferenciaPago preferenciaPago)
    {
        try
        {
            // 1. Calcular pricing con descuentos
            var estrategiaDescuento = _selectorDescuento.SeleccionarEstrategia(cliente, pedido);
            decimal descuento = estrategiaDescuento.CalcularDescuento(pedido.MontoTotal, pedido.CantidadProductos);
            decimal montoConDescuento = pedido.MontoTotal - descuento;
            
            // 2. Seleccionar método de pago
            var estrategiaPago = _selectorPago.SeleccionarEstrategia(preferenciaPago, montoConDescuento);
            decimal comision = estrategiaPago.CalcularComision(montoConDescuento);
            decimal montoFinal = montoConDescuento + comision;
            
            // 3. Procesar pago
            var resultadoPago = await estrategiaPago.ProcesarPagoAsync(montoConDescuento, preferenciaPago.DatosPago);
            
            if (!resultadoPago.EsExitoso && !resultadoPago.EstaPendiente)
            {
                return ResultadoProcesamiento.Error($"Pago falló: {resultadoPago.MensajeError}");
            }
            
            // 4. Crear resumen de procesamiento
            var resumen = new ResumenProcesamiento
            {
                MontoOriginal = pedido.MontoTotal,
                DescuentoAplicado = descuento,
                EstrategiaDescuento = estrategiaDescuento.ObtenerDescripcion(),
                MontoConDescuento = montoConDescuento,
                ComisionPago = comision,
                EstrategiaPago = estrategiaPago.GetType().Name,
                MontoFinal = montoFinal,
                TransaccionId = resultadoPago.TransaccionId,
                EstaPendienteConfirmacion = resultadoPago.EstaPendiente,
                TiempoConfirmacionEstimado = estrategiaPago.ObtenerTiempoConfirmacion()
            };
            
            return ResultadoProcesamiento.Exito(resumen);
        }
        catch (Exception ex)
        {
            return ResultadoProcesamiento.Error($"Error procesando pedido: {ex.Message}");
        }
    }
}

// DTOs para el resultado
public class PreferenciaPago
{
    public TipoMetodoPago Metodo { get; set; }
    public DatosPago DatosPago { get; set; }
    public bool PermiteComisiones { get; set; } = true;
    public decimal ComisionMaximaAceptable { get; set; } = decimal.MaxValue;
}

public class ResumenProcesamiento
{
    public decimal MontoOriginal { get; set; }
    public decimal DescuentoAplicado { get; set; }
    public string EstrategiaDescuento { get; set; }
    public decimal MontoConDescuento { get; set; }
    public decimal ComisionPago { get; set; }
    public string EstrategiaPago { get; set; }
    public decimal MontoFinal { get; set; }
    public string TransaccionId { get; set; }
    public bool EstaPendienteConfirmacion { get; set; }
    public TimeSpan TiempoConfirmacionEstimado { get; set; }
}

public class ResultadoProcesamiento
{
    public bool EsExitoso { get; set; }
    public string MensajeError { get; set; }
    public ResumenProcesamiento Resumen { get; set; }
    
    public static ResultadoProcesamiento Exito(ResumenProcesamiento resumen)
        => new() { EsExitoso = true, Resumen = resumen };
        
    public static ResultadoProcesamiento Error(string mensaje)
        => new() { EsExitoso = false, MensajeError = mensaje };
}
```

---

## Recursos para algoritmos configurables

### Frameworks y librerías relacionadas

* **Microsoft.Extensions.Configuration**: Configuración dinámica de estrategias
* **Microsoft.Extensions.DependencyInjection**: Registro de estrategias en IoC
* **AutoMapper**: Mapping entre DTOs y entidades en estrategias complejas
* **FluentValidation**: Validaciones declarativas dentro de estrategias

### Configuración dinámica

```json
// appsettings.json - Configuración de estrategias
{
  "Estrategias": {
    "Descuentos": {
      "Default": "Regular",
      "PorTipoCliente": {
        "VIP": "Vip",
        "Premium": "Premium",
        "Estudiante": "Estudiante"
      },
      "UpgradeAutomatico": {
        "MontoParaVip": 5000,
        "MontoParaPremium": 2000
      }
    },
    "Pagos": {
      "ComisionesPorMetodo": {
        "TarjetaCredito": 0.029,
        "TarjetaDebito": 0.015,
        "Transferencia": 5.0,
        "Criptomoneda": 0.001
      },
      "MetodosHabilitados": ["TarjetaCredito", "TarjetaDebito", "Transferencia"]
    }
  }
}
```

### Testing avanzado con parámetros

```bash
# Paquetes para testing avanzado de strategies
dotnet add package xunit                          # Framework de testing
dotnet add package Moq                           # Mocking para dependencies
dotnet add package Microsoft.Extensions.Configuration # Configuración en tests
dotnet add package FluentAssertions              # Assertions expresivos
```

---

## Testing de strategies con casos parametrizados

### Testing parametrizado con Theory

```csharp
[TestClass]
public class EstrategiasIntegracionTests
{
    // Test data para múltiples estrategias y escenarios
    public static IEnumerable<object[]> DatosEstrategiasDescuento =>
        new List<object[]>
        {
            new object[] { new EstrategiaDescuentoVip(), 1000m, 5, 200m },      // VIP: 20% para 5 productos
            new object[] { new EstrategiaDescuentoVip(), 1000m, 12, 250m },     // VIP: 25% para 12 productos
            new object[] { new EstrategiaDescuentoPremium(), 1000m, 5, 100m },  // Premium: 10% para 5 productos
            new object[] { new EstrategiaDescuentoRegular(), 1000m, 5, 0m },    // Regular: 0% para 5 productos
            new object[] { new EstrategiaDescuentoRegular(), 1000m, 12, 50m }   // Regular: 5% para 12 productos
        };
    
    [Theory]
    [MemberData(nameof(DatosEstrategiasDescuento))]
    public void EstrategiasDescuento_CasosVariados_CalculanCorrectamente(
        IEstrategiaDescuento estrategia, 
        decimal monto, 
        int cantidad, 
        decimal esperado)
    {
        // Act
        decimal resultado = estrategia.CalcularDescuento(monto, cantidad);
        
        // Assert
        Assert.Equal(esperado, resultado);
    }
    
    // Test data para combinaciones complejas
    public static IEnumerable<object[]> DatosCombinacionesEstrategias =>
        new List<object[]>
        {
            // [Estrategias, TipoComposicion, Monto, Cantidad, DescuentoEsperado]
            new object[] 
            { 
                new IEstrategiaDescuento[] { new EstrategiaDescuentoVip(), new EstrategiaDescuentoPorcentaje(0.10m) },
                TipoComposicion.Maximo,
                1000m, 
                10,
                250m // Max entre VIP (25%) y 10% fijo = 250
            },
            new object[] 
            { 
                new IEstrategiaDescuento[] { new EstrategiaDescuentoPorcentaje(0.05m), new EstrategiaDescuentoPorcentaje(0.03m) },
                TipoComposicion.Suma,
                1000m, 
                5,
                80m // 5% + 3% = 8% = 80
            }
        };
    
    [Theory]
    [MemberData(nameof(DatosCombinacionesEstrategias))]
    public void EstrategiaCompuesta_CombinacionesVarias_CombinaCorrectamente(
        IEstrategiaDescuento[] estrategias,
        TipoComposicion tipo,
        decimal monto,
        int cantidad,
        decimal esperado)
    {
        // Arrange
        var compuesta = new EstrategiaDescuentoCompuesta(tipo, estrategias);
        
        // Act
        decimal resultado = compuesta.CalcularDescuento(monto, cantidad);
        
        // Assert
        Assert.Equal(esperado, resultado);
    }
}
```

### Testing de selección dinámica

```csharp
[TestClass]
public class SelectorEstrategiaTests
{
    private EstrategiaDescuentoFactory _factory;
    private SelectorEstrategiaDescuento _selector;
    
    [TestInitialize]
    public void Setup()
    {
        _factory = new EstrategiaDescuentoFactory();
        
        var configuracion = new ConfiguracionDescuentos
        {
            EstrategiaDefault = "Regular",
            EstrategiasPorTipoCliente = new Dictionary<string, string>
            {
                { "VIP", "Vip" },
                { "Premium", "Premium" }
            }
        };
        
        _selector = new SelectorEstrategiaDescuento(_factory, configuracion);
    }
    
    [Theory]
    [InlineData("VIP", 1000, false, typeof(EstrategiaDescuentoVip))]
    [InlineData("Premium", 1000, false, typeof(EstrategiaDescuentoPremium))]
    [InlineData("Regular", 1000, true, typeof(EstrategiaDescuentoEstudiante))]   // Estudiante override
    [InlineData("Regular", 6000, false, typeof(EstrategiaDescuentoVip))]         // Upgrade por monto
    [InlineData("Regular", 800, false, typeof(EstrategiaDescuentoRegular))]      // Default
    public void SeleccionarEstrategia_ContextoVariado_SeleccionaCorrectamente(
        string tipoCliente, 
        decimal montoCompra, 
        bool esEstudiante, 
        Type tipoEstrategiaEsperada)
    {
        // Arrange
        var cliente = new Cliente 
        { 
            TipoCliente = tipoCliente, 
            EsEstudiante = esEstudiante,
            TieneCarnetEstudiantil = esEstudiante
        };
        var pedido = new Pedido { MontoTotal = montoCompra };
        
        // Act
        var estrategia = _selector.SeleccionarEstrategia(cliente, pedido);
        
        // Assert
        Assert.IsType(tipoEstrategiaEsperada, estrategia);
    }
}
```

### Performance testing de estrategias

```csharp
[TestClass]
public class EstrategiasPerformanceTests
{
    [Fact]
    public void EstrategiasSimples_1000Iteraciones_CompletanEnTiempoRazonable()
    {
        // Arrange
        var estrategias = new IEstrategiaDescuento[]
        {
            new EstrategiaDescuentoVip(),
            new EstrategiaDescuentoPremium(),
            new EstrategiaDescuentoRegular()
        };
        
        var stopwatch = Stopwatch.StartNew();
        
        // Act
        for (int i = 0; i < 1000; i++)
        {
            foreach (var estrategia in estrategias)
            {
                estrategia.CalcularDescuento(1000m, 10);
            }
        }
        
        stopwatch.Stop();
        
        // Assert - Debe completar en menos de 100ms
        Assert.True(stopwatch.ElapsedMilliseconds < 100, 
            $"Tiempo excedido: {stopwatch.ElapsedMilliseconds}ms");
    }
    
    [Fact]
    public void EstrategiaCompuesta_ConMuchasEstrategias_NoDegrade()
    {
        // Arrange - muchas estrategias
        var estrategias = Enumerable.Range(1, 100)
            .Select(i => new EstrategiaDescuentoPorcentaje(0.01m))
            .Cast<IEstrategiaDescuento>()
            .ToArray();
            
        var compuesta = new EstrategiaDescuentoCompuesta(TipoComposicion.Suma, estrategias);
        
        var stopwatch = Stopwatch.StartNew();
        
        // Act
        for (int i = 0; i < 100; i++)
        {
            compuesta.CalcularDescuento(1000m, 10);
        }
        
        stopwatch.Stop();
        
        // Assert - Incluso con 100 estrategias, debe ser rápido
        Assert.True(stopwatch.ElapsedMilliseconds < 50,
            $"Performance degradada con muchas estrategias: {stopwatch.ElapsedMilliseconds}ms");
    }
}
```

---

## Glosario de términos de comportamiento

* **Strategy Pattern**: patrón que define familia de algoritmos, encapsula cada uno y los hace intercambiables.
* **Context**: clase cliente que usa strategies y permite cambiarlas dinámicamente.
* **Concrete Strategy**: implementación específica de un algoritmo del Strategy pattern.
* **Strategy Factory**: factory que crea strategies basado en criterios dinámicos.
* **Strategy Composition**: combinación de múltiples strategies para crear comportamientos complejos.
* **Algorithm Encapsulation**: técnica de encapsular cada algoritmo en su propia clase.
* **Runtime Strategy Selection**: capacidad de elegir strategy durante ejecución del programa.
* **Strategy Decorator**: patrón que agrega funcionalidad condicional a una strategy existente.
* **Fluent Builder**: patrón para construir strategies complejas usando sintaxis fluida.
* **Parametrized Testing**: técnica de testing que ejecuta mismo test con múltiples sets de datos.

---

## Anexo 1 — Ejercicio Completo: Sistema de recomendaciones

**Instrucciones:**

1. Implementar strategies para diferentes algoritmos de recomendación:
   * Por popularidad, por similitud de usuario, por contenido, por historial de compras
   * Cada strategy tiene parámetros configurables (peso, filtros, límites)

2. Crear sistema de composición de recomendaciones:
   * Combinar múltiples algorithms con pesos diferentes
   * Aplicar filtros post-procesamiento (stock disponible, región, precio)
   * Diversificar resultados para evitar echo chambers

3. Implementar selección dinámica basada en contexto:
   * Usuario nuevo vs recurrente
   * Hora del día, día de semana
   * Comportamiento reciente del usuario
   * A/B testing de algorithms

4. Testing comprehensivo:
   * Performance tests con grandes datasets
   * Tests de calidad de recomendaciones  
   * Tests de diversidad y cobertura
   * Tests de comportamiento con usuarios edge case

> Criterio de éxito: sistema que genere recomendaciones relevantes, diversas y performantes para diferentes tipos de usuarios.

---

## Anexo 2 — Ejercicio Completo: Sistema de pricing dinámico

**Instrucciones:**

1. **Implementar strategies de pricing complejas:**
   * Pricing por demanda (surge pricing como Uber)
   * Pricing competitivo (basado en precios de competencia)
   * Pricing por segmento de cliente (B2B vs B2C)
   * Pricing temporal (happy hours, black friday)
   * Pricing geográfico (por región/ciudad)

2. **Desarrollar sistema de optimización automática:**
   * Strategies que se auto-ajustan basado en métricas
   * A/B testing automático de strategies de pricing
   * Machine learning integration para optimización continua
   * Alertas cuando pricing se desvía de targets

3. **Implementar constraints y validaciones:**
   * Límites mínimo/máximo de precios
   * Margins mínimos requeridos
   * Compliance con regulaciones de pricing
   * Aprobaciones requeridas para cambios grandes

4. **Crear dashboard y reporting:**
   * Visualización en tiempo real del impacto de strategies
   * Comparación de performance entre diferentes approaches
   * Predicción de impacto antes de aplicar cambios
   * Rollback automático si métricas se degradan

5. **Testing avanzado:**
   * Simulaciones Monte Carlo de diferentes scenarios
   * Load testing con múltiples strategies concurrentes
   * Tests de regresión cuando se agregan nuevas strategies
   * Verificación de compliance y auditoría

**Entregables:**
* Sistema completo con múltiples strategies implementadas
* Suite de tests que cubra todos los escenarios de pricing
* Dashboard funcional mostrando métricas en tiempo real
* Documentación de arquitectura y decisiones de diseño
* Demo mostrando optimización automática funcionando

---

## Cierre

* **Flexibilidad**: Strategy pattern elimina if/else complejos y permite algoritmos intercambiables
* **Extensibilidad**: agregar nuevos comportamientos sin modificar código existente
* **Testabilidad**: cada strategy se puede testear independientemente con casos parametrizados
* **Próximo paso**: integrar todos los patrones aprendidos (Factory + Repository + Strategy) en arquitecturas completas

### Transformación lograda

**❌ Enfoque anterior (problemático):**
```csharp
// Lógica hardcodeada con if/else rígidos
if (tipoCliente == "VIP") {
    descuento = montoBase * 0.25m;
} else if (tipoCliente == "Premium") {
    descuento = montoBase * 0.15m;
} // ¿Cómo agregar nuevo tipo sin modificar?
```

**✅ Enfoque profesional (flexible):**
```csharp
// Algoritmos encapsulados, intercambiables y extensibles
IEstrategiaDescuento estrategia = factory.Crear(tipoCliente);
decimal descuento = estrategia.CalcularDescuento(montoBase, cantidad);
// Agregar nuevos tipos solo requiere nueva estrategia
```

### Beneficios del cambio

- **Mantenibilidad**: cada algoritmo en su propia clase, fácil de entender y modificar
- **Extensibilidad**: nuevos comportamientos sin tocar código existente
- **Testabilidad**: testing individual y parametrizado de cada strategy
- **Configurabilidad**: selección dinámica basada en contexto de negocio

### Para recordar

> **"Encapsula algoritmos en strategies para eliminar if/else complejos y hacer tu código extensible"**

El patrón Strategy es fundamental para sistemas que requieren diferentes comportamientos dinámicos, especialmente cuando se combina con Factory para selección automática y Composite para comportamientos complejos.
