# Tipos de Test Doubles - Resumen

> **Test Doubles** son objetos que reemplazan dependencias reales en los tests para hacerlos más controlados, rápidos y confiables.

## 1. Dummy Objects - "Solo necesito algo que compile"

**Propósito:** Objeto que se pasa como parámetro pero nunca se usa en el test.

**Cuándo usar:** Cuando necesitas satisfacer la firma de un constructor o método pero esa dependencia no se utiliza en el escenario que estás testeando.

**Ejemplo:**
```csharp
// El logger se pasa pero nunca se usa en el método Sumar
var dummyLogger = new Mock<ILogger>().Object;
var calculadora = new CalculadoraService(dummyLogger);
```

---

## 2. Stubs - "Devuelve lo que necesito"

**Propósito:** Devuelve respuestas predefinidas sin verificar interacciones.

**Cuándo usar:** Cuando necesitas que una dependencia retorne datos específicos para tu test.

**Ejemplo:**
```csharp
// Configurar stub para devolver descuento específico
stubDescuentoService.Setup(x => x.ObtenerDescuento(It.IsAny<decimal>()))
                   .Returns(0.1m); // siempre retorna 10%
```

---

## 3. Fakes - "Una implementación real pero simple"

**Propósito:** Implementación simplificada que funciona realmente pero de manera más simple (ej: en memoria).

**Cuándo usar:** Cuando necesitas funcionalidad real pero sin la complejidad de la implementación de producción.

**Ejemplo:**
```csharp
// Fake repository que funciona en memoria
public class FakeProductoRepository : IProductoRepository
{
    private readonly List<Producto> _productos = new();
    
    public async Task GuardarAsync(Producto producto)
    {
        producto.Id = _productos.Count + 1;
        _productos.Add(producto);
    }
}
```

---

## 4. Mocks - "Verificar que se llamó correctamente"

**Propósito:** Verifica interacciones y comportamiento esperado. No solo retorna datos, sino que verifica que se hayan hecho las llamadas correctas.

**Cuándo usar:** Cuando lo importante es **verificar que se llamó** a la dependencia con los parámetros correctos.

**Ejemplo:**
```csharp
// Verificar que se llamó el método correcto
mockEmailService.Verify(x => x.EnviarNotificacionAsync(It.IsAny<Producto>()), 
                       Times.Once);
```

---

## 5. Spies - "¿Qué pasó exactamente?"

**Propósito:** Registra información sobre cómo fue utilizado (llamadas realizadas, parámetros, secuencias).

**Cuándo usar:** Cuando necesitas inspeccionar **cómo se usó** la dependencia, especialmente para verificar secuencias o múltiples interacciones.

**Ejemplo:**
```csharp
// Verificar secuencia específica de logs
spyLogger.Verify(x => x.LogInfo("Iniciando procesamiento"), Times.Once);
spyLogger.Verify(x => x.LogInfo("Validando datos"), Times.Once);
spyLogger.Verify(x => x.LogInfo("Guardando en base de datos"), Times.Once);
```

---

## Guía de Decisión Rápida

| Tipo | Uso Principal | Pregunta Clave |
|------|---------------|----------------|
| **Dummy** | Satisfacer firma | "¿Necesito pasar algo pero no lo uso?" |
| **Stub** | Retornar datos | "¿Necesito datos específicos de una dependencia?" |
| **Fake** | Funcionalidad simple | "¿Necesito que funcione realmente pero simple?" |
| **Mock** | Verificar llamadas | "¿Es importante verificar QUE se llamó?" |
| **Spy** | Inspeccionar uso | "¿Necesito ver CÓMO se usó la dependencia?" |

---

## Beneficios Generales de los Test Doubles

✅ **Velocidad**: Tests en memoria, sin I/O  
✅ **Determinismo**: Comportamiento predecible y controlado  
✅ **Foco**: Testear únicamente la lógica bajo prueba  
✅ **Independencia**: Tests que no dependen de infraestructura externa  

---

> **Regla de oro**: "Mock dependencies, not your system under test"

Los test doubles permiten aislar el código bajo prueba para crear tests rápidos, confiables y focalizados en la lógica de negocio.
