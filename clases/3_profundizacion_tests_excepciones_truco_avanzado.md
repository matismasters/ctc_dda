# Clase 3 – Profundización en Tests: Manejo de Excepciones y Truco Avanzado

**Duración:** 3 horas
**Objetivo general:** dominar el **manejo de excepciones en tests unitarios**, revisar las soluciones de los ejercicios del Truco (conteo de envido y comparación de manos), aplicar **validaciones robustas** con tests de excepciones, y consolidar el uso de **assertions avanzadas** para casos edge y situaciones excepcionales.

---

## Índice

1. Módulo 1 — Revisión de soluciones: Truco ejercicios 4.2 y 4.3
2. Módulo 2 — Manejo de excepciones en tests unitarios
3. Módulo 3 — Aplicación práctica: validaciones robustas en Truco
4. Módulo 4 — Tests parametrizados avanzados y casos edge
5. Recursos adicionales para testing robusto
6. Glosario de términos de testing avanzado
7. Cierre

---

## Módulo 1 — Revisión de soluciones: Truco ejercicios 4.2 y 4.3

> **Análisis grupal:** evaluación de las implementaciones del cálculo de envido y comparación de manos, identificando **patrones de diseño**, **casos no contemplados** y **oportunidades de mejora** en el diseño de tests.

### 1.1 Revisión del Ejercicio 4.2 — Cálculo de puntos de Envido

**Criterios de evaluación de las soluciones:**

* **Lógica correcta**: ¿Se implementaron correctamente las reglas del envido?
* **Manejo de casos edge**: ¿Qué pasa con manos sin cartas del mismo palo?
* **Validaciones de entrada**: ¿Se valida que la mano tenga exactamente 3 cartas?
* **Tests comprehensivos**: ¿Los tests cubren todos los escenarios posibles?
* **Separación de responsabilidades**: ¿La lógica está aislada y es testeable?

**Problemas para testear:**

```csharp
// Problemas comunes a discutir:
// 1. ¿Qué pasa si mano es null?
// 2. ¿Qué pasa si mano tiene menos de 3 cartas?
// 3. ¿Qué pasa si mano tiene más de 3 cartas?
// 4. ¿Los valores de las cartas están bien mapeados? (1=1, sota=10, etc.)
// 5. ¿Se contempla el caso de 3 cartas del mismo palo?
```

### 1.2 Revisión del Ejercicio 4.3 — Comparación de manos de Envido

**Análisis de implementaciones del JuezEnvido:**

```csharp
// Implementación típica encontrada
public class JuezEnvido
{
    private readonly CalculadoraEnvido _calculadora;
    
    public JuezEnvido(CalculadoraEnvido calculadora) 
        => _calculadora = calculadora;
    
    public ResultadoEnvido CompararManos(List<Carta> mano1, List<Carta> mano2)
    {
        int puntos1 = _calculadora.CalcularPuntos(mano1);
        int puntos2 = _calculadora.CalcularPuntos(mano2);
        
        // ¿Falta validación aquí también?
        
        return new ResultadoEnvido
        {
            Ganador = puntos1 > puntos2 ? 1 : (puntos2 > puntos1 ? 2 : 0),
            PuntosJugador1 = puntos1,
            PuntosJugador2 = puntos2
        };
    }
}
```

### 1.3 Patrones de tests encontrados

**Tests bien estructurados:**

```csharp
[Theory]
[InlineData(new[] {"7 Espadas", "6 Espadas", "2 Oros"}, 33)] // 7+6+20
[InlineData(new[] {"1 Copas", "2 Copas", "3 Bastos"}, 23)]   // 1+2+20
[InlineData(new[] {"Rey Oros", "Sota Bastos", "4 Copas"}, 12)] // Rey más alta
public void CalcularPuntos_CasosNormales_RetornaCorrectamente(string[] descripcionCartas, int esperado)
{
    // Arrange
    var mano = ConstruirMano(descripcionCartas);
    var calculadora = new CalculadoraEnvido();
    
    // Act
    int resultado = calculadora.CalcularPuntos(mano);
    
    // Assert
    Assert.Equal(esperado, resultado);
}
```

**Tests que faltan (casos edge no contemplados):**

```csharp
// ¿Alguien testó estos casos?
[Fact]
public void CalcularPuntos_ManoNula_DeberiaLanzarExcepcion() { }

[Fact] 
public void CalcularPuntos_ManoVacia_DeberiaLanzarExcepcion() { }

[Fact]
public void CalcularPuntos_ManoConMenosDe3Cartas_DeberiaLanzarExcepcion() { }

[Fact]
public void CompararManos_AmbaManos33Puntos_EsEmpate() { }
```

---

## Módulo 2 — Manejo de excepciones en tests unitarios

> **Concepto clave:** los tests no solo validan el comportamiento correcto, sino también que el código **falle elegantemente** ante entradas inválidas o situaciones excepcionales.

### 2.1 ¿Por qué testear excepciones?

**Razones fundamentales:**

* **Contratos claros**: definir qué entradas son válidas y cuáles no
* **Debugging más fácil**: fallos predecibles en lugar de comportamiento indefinido
* **Robustez**: el sistema se comporta bien ante errores
* **Documentación**: los tests muestran qué excepciones esperar

### 2.2 `Assert.Throws<T>` — Sintaxis básica

**Forma básica:**

```csharp
[Fact]
public void Dividir_PorCero_LanzaDivideByZeroException()
{
    // Arrange
    var calculadora = new Calculadora();
    
    // Act & Assert
    Assert.Throws<DivideByZeroException>(() => calculadora.Dividir(10, 0));
}
```

**Forma con validación del mensaje:**

```csharp
[Fact]
public void CrearCarta_NumeroInvalido_LanzaArgumentException()
{
    // Act & Assert
    var excepcion = Assert.Throws<ArgumentException>(() => new Carta(15, Palo.Espadas));
    
    Assert.Contains("debe estar entre 1 y 12", excepcion.Message);
}
```

### 2.3 `Assert.ThrowsAny<T>` — Para jerarquías de excepciones

```csharp
[Fact]
public void ProcesarArchivo_ArchivoNoExiste_LanzaExcepcionDeIO()
{
    var procesador = new ProcesadorArchivos();
    
    // Acepta IOException o cualquier subclase
    Assert.ThrowsAny<IOException>(() => procesador.Procesar("archivo_inexistente.txt"));
}
```

### 2.4 Patrón Record-Exception para validación compleja

```csharp
[Fact]
public void ValidarMano_ManoInvalida_ExcepcionConDetalles()
{
    // Arrange
    var manoInvalida = new List<Carta> { /* solo 2 cartas */ };
    var validador = new ValidadorMano();
    
    // Act
    var excepcion = Record.Exception(() => validador.Validar(manoInvalida));
    
    // Assert
    Assert.NotNull(excepcion);
    Assert.IsType<ArgumentException>(excepcion);
    Assert.Contains("exactamente 3 cartas", excepcion.Message);
}
```

### 2.5 Validación de parámetros comunes

**ArgumentNullException:**

```csharp
public void CalcularPuntos(List<Carta> mano)
{
    if (mano == null)
        throw new ArgumentNullException(nameof(mano));
    
    if (mano.Count != 3)
        throw new ArgumentException("La mano debe tener exactamente 3 cartas", nameof(mano));
    
    // lógica...
}

// Test correspondiente:
[Fact]
public void CalcularPuntos_ManoNula_LanzaArgumentNullException()
{
    var calculadora = new CalculadoraEnvido();
    
    Assert.Throws<ArgumentNullException>(() => calculadora.CalcularPuntos(null));
}
```

**ArgumentOutOfRangeException:**

```csharp
public Carta(int numero, Palo palo)
{
    if (numero < 1 || numero > 12 || numero == 8 || numero == 9 || numero == 10)
        throw new ArgumentOutOfRangeException(nameof(numero), 
            "Número de carta inválido para mazo español");
    
    Numero = numero;
    Palo = palo;
}

[Theory]
[InlineData(0)]
[InlineData(8)]
[InlineData(9)]  
[InlineData(10)]
[InlineData(13)]
public void CrearCarta_NumeroInvalido_LanzaArgumentOutOfRangeException(int numeroInvalido)
{
    Assert.Throws<ArgumentOutOfRangeException>(() => new Carta(numeroInvalido, Palo.Espadas));
}
```

### 2.6 Custom Exceptions para dominio específico

```csharp
// Excepción específica del dominio
public class ManoInvalidaException : Exception
{
    public ManoInvalidaException(string mensaje) : base(mensaje) { }
    public ManoInvalidaException(string mensaje, Exception innerException) 
        : base(mensaje, innerException) { }
}

// Uso en el código
public int CalcularPuntos(List<Carta> mano)
{
    if (mano == null)
        throw new ManoInvalidaException("La mano no puede ser nula");
    
    if (mano.Count != 3)
        throw new ManoInvalidaException($"Se esperaban 3 cartas, se recibieron {mano.Count}");
    
    if (mano.Any(c => c == null))
        throw new ManoInvalidaException("La mano contiene cartas nulas");
    
    // lógica del envido...
}

// Tests correspondientes
[Fact]
public void CalcularPuntos_ManoNula_LanzaManoInvalidaException()
{
    var calculadora = new CalculadoraEnvido();
    
    var excepcion = Assert.Throws<ManoInvalidaException>(() => calculadora.CalcularPuntos(null));
    Assert.Equal("La mano no puede ser nula", excepcion.Message);
}
```

---

## Módulo 3 — Aplicación práctica: validaciones robustas en Truco

### 3.1 Estrategias para validaciones robustas

**Principios de diseño para validaciones:**

**1. Separación de responsabilidades:**
* El método principal (`CalcularPuntos`) delega la validación a métodos específicos
* Cada validación tiene su propia responsabilidad y mensaje de error claro
* La lógica de negocio se ejecuta solo después de validar

**2. Estrategia de validación en capas:**
* **Capa 1**: Validaciones de nulidad (null checks)
* **Capa 2**: Validaciones estructurales (cantidad, tipos)  
* **Capa 3**: Validaciones de contenido (valores válidos)
* **Capa 4**: Validaciones de reglas de negocio (duplicados, coherencia)

**3. Mensajes de error informativos:**
```csharp
// Malo: mensaje genérico
throw new ArgumentException("Mano inválida");

// Bueno: mensaje específico y útil
throw new ArgumentException($"La mano debe tener exactamente 3 cartas. Se recibieron: {mano.Count}");
```

**4. Fail-fast pattern:**
Validar **lo antes posible** en el flujo de ejecución para detectar problemas rápidamente y evitar efectos secundarios.

**5. Uso apropiado de tipos de excepción:**
* `ArgumentNullException` para parámetros nulos
* `ArgumentException` para parámetros con formato/estructura incorrecta  
* `ArgumentOutOfRangeException` para valores fuera de rango
* Excepciones custom para reglas específicas del dominio

### 3.2 Estrategia de testing para validaciones

**Categorías de tests necesarios:**

* **Tests de casos normales**: verificar la lógica correcta del envido
* **Tests de excepciones**: validar que el código falle elegantemente ante entrada inválida
* **Tests de casos edge**: situaciones límite o poco comunes
* **Tests de integración**: verificar que los componentes funcionen juntos

**Principios para tests de excepciones:**

* **Un test por escenario de fallo**: cada tipo de validación debe tener su propio test
* **Verificar tipo y mensaje**: no solo que lance excepción, sino que sea la correcta
* **Nombres descriptivos**: `CalcularPuntos_ManoNula_LanzaArgumentNullException`
* **Usar Theory para múltiples casos similares**: diferentes cantidades inválidas de cartas

**Patrón recomendado para tests de validación:**

```csharp
[Fact]
public void MetodoATester_CondicionQueProvocaError_TipoDeExcepcionEsperada()
{
    // Arrange: preparar datos inválidos
    // Act & Assert: verificar excepción específica
    var excepcion = Assert.Throws<TipoEsperado>(() => objetoATester.Metodo(datosInvalidos));
    Assert.Contains("parte del mensaje esperado", excepcion.Message);
}
```

---

## Módulo 4 — Tests parametrizados avanzados y casos edge

### 4.1 `[MemberData]` — Cuándo y por qué usarlo

**`[MemberData]` vs `[InlineData]` — diferencias conceptuales:**

`[InlineData]` es ideal para **datos simples** (números, strings, booleanos), pero tiene limitaciones:
* Solo tipos básicos como parámetros
* Los datos deben ser constantes de compilación
* No permite objetos complejos como `List<Carta>`

`[MemberData]` es la solución para **casos complejos**:
* Permite objetos complejos como parámetros
* Los datos se generan en tiempo de ejecución
* Facilita la reutilización de conjuntos de datos entre tests
* Permite lógica de generación de datos más sofisticada

**Estructura de MemberData:**

```csharp
public static IEnumerable<object[]> CasosComplejos =>
    new List<object[]>
    {
        new object[] { "descripción", objetoComplejo, valorEsperado },
        new object[] { "descripción", objetoComplejo2, valorEsperado2 }
    };
```

**Cuándo usar cada uno:**

* **`[InlineData]`**: tests con 1-3 parámetros simples, casos típicos
* **`[MemberData]`**: tests con objetos complejos, muchos casos, lógica de generación de datos
* **`[ClassData]`**: cuando la generación de datos requiere lógica compleja o configuración externa

**Ventajas del `[MemberData]`:**

* **Claridad**: cada caso puede tener una descripción explicativa
* **Reutilización**: el mismo conjunto de datos puede usarse en múltiples tests
* **Flexibilidad**: permite generar datos dinámicamente
* **Mantenibilidad**: cambios en los datos de prueba se centralizan en un solo lugar

### 4.2 Custom Attributes — Documentación semántica de tests

**¿Para qué sirven los Custom Attributes?**

Los custom attributes permiten **etiquetar** tests con información del dominio, facilitando:
* **Agrupación lógica**: organizar tests por funcionalidad del negocio
* **Documentación**: explicar el contexto específico que se está probando
* **Filtering**: ejecutar solo tests de ciertas categorías
* **Reporting**: generar reportes organizados por aspectos del dominio

**Casos de uso típicos:**
* `[CasoTruco]` para reglas específicas del juego
* `[CasoEdge]` para situaciones límite
* `[Performance]` para tests de rendimiento
* `[Integration]` para tests de integración

### 4.3 Invariantes del dominio — Tests que validan reglas de negocio

**¿Qué son los invariantes?**

Los **invariantes** son reglas que **siempre** deben cumplirse en el dominio, sin importar cómo se llegue al estado. En el contexto del Truco:

* Si el Jugador 1 gana, sus puntos deben ser mayores a los del Jugador 2
* El resultado de envido debe estar entre 0 y 33 puntos
* No puede haber cartas duplicadas en una mano válida
* Una mano siempre debe tener exactamente 3 cartas

**Estrategia para tests de invariantes:**

1. **Identificar las reglas fundamentales** del dominio
2. **Crear tests que validen esas reglas** después de operaciones
3. **Probar con diferentes datos** para asegurar que se mantienen
4. **Fallar rápido** si una invariante se rompe

**Importancia:**
Los tests de invariantes actúan como una **red de seguridad** que detecta inconsistencias lógicas que podrían pasar desapercibidas en tests más específicos.

---

## Recursos adicionales para testing robusto

### Generación automática de datos de prueba

**AutoFixture y `[AutoData]`:**

`[AutoData]` es una herramienta que **genera automáticamente** valores para los parámetros de los tests, útil para:
* **Property-based testing**: verificar propiedades que deben cumplirse con cualquier entrada válida
* **Tests de robustez**: asegurar que el código no falla con datos aleatorios
* **Reducir código repetitivo**: evitar crear manualmente objetos complejos

**Cuándo usar AutoData:**
* Tests que verifican que una operación **no lanza excepciones** con entrada válida
* Validación de **propiedades matemáticas** (A + B = B + A)
* Tests de **performance** con volúmenes variables de datos
* Verificación de **invariantes** con datos diversos

**Limitaciones a considerar:**
* Los datos generados son aleatorios, pueden no reflejar casos reales
* Requiere **filtrado** para asegurar que los datos sean válidos para el dominio
* Los fallos pueden ser **difíciles de reproducir** por la aleatoriedad

### Extensión methods para tests más expresivos

**Builder pattern para tests:**

Los extension methods permiten crear **DSLs (Domain Specific Languages)** que hacen los tests más legibles:

**Beneficios:**
* **Legibilidad**: `7.DeEspadas()` es más claro que `new Carta(7, Palo.Espadas)`  
* **Consistencia**: mismo patrón para crear objetos similares
* **Mantenibilidad**: cambios en constructores se centralizan en las extensions
* **Expresividad**: el código de test cuenta una historia más clara

**Patrón recomendado:**
```csharp
// En lugar de repetir construcción de objetos:
new List<Carta> { new Carta(7, Palo.Espadas), new Carta(6, Palo.Espadas) }

// DSL más expresivo:
new[] { 7.DeEspadas(), 6.DeEspadas() }.ComoMano()
```

**Cuándo aplicar:**
* Cuando se repite la **misma construcción** de objetos en múltiples tests
* Para **dominios complejos** donde la construcción tiene muchos pasos
* Cuando se quiere que los tests sean **auto-documentados**

---

## Glosario de términos de testing avanzado

* **Assert.Throws<T>**: método para verificar que se lanza una excepción específica durante la ejecución.
* **ArgumentNullException**: excepción lanzada cuando se pasa un argumento nulo a un método que no lo permite.
* **ArgumentException**: excepción lanzada cuando uno de los argumentos proporcionados no es válido.
* **ArgumentOutOfRangeException**: excepción lanzada cuando el valor de un argumento está fuera del rango permitido.
* **Record.Exception**: método que captura cualquier excepción lanzada durante la ejecución sin fallar el test.
* **Custom Exception**: excepción personalizada específica del dominio de la aplicación.
* **MemberData**: atributo para proporcionar datos de test desde una propiedad o método estático.
* **AutoData**: atributo de AutoFixture que genera automáticamente datos de prueba aleatorios.
* **Test Extension Methods**: métodos de extensión que hacen más legible y expresivo el código de tests.
* **Invariante de dominio**: regla de negocio que siempre debe cumplirse en el dominio de la aplicación.
* **Caso edge**: situación límite o excepcional que el código debe manejar correctamente.

---

## Anexo 1 — Ejercicio Completo: CalculadoraEnvido Robusta

**Instrucciones:**

1. **Implementar CalculadoraEnvido con validaciones completas:**
   * Validar que la mano no sea nula
   * Validar que la mano tenga exactamente 3 cartas
   * Validar que no haya cartas nulas
   * Validar que no haya cartas duplicadas
   * Implementar excepciones específicas con mensajes claros

2. **Crear suite completa de tests:**
   * Tests para casos normales (todas las combinaciones de envido)
   * Tests para todas las validaciones de excepción
   * Tests para casos edge (3 cartas del mismo palo, etc.)
   * Tests parametrizados usando `[Theory]` e `[InlineData]`

3. **Casos de prueba mínimos requeridos:**

```csharp
// Casos normales
[Theory]
[InlineData("7 Espadas, 6 Espadas, 2 Oros", 33)]    // Envido con espadas
[InlineData("1 Copas, 2 Copas, 3 Bastos", 23)]      // Envido con copas  
[InlineData("Rey Oros, Sota Bastos, 4 Copas", 12)]  // Sin envido, Rey más alto
[InlineData("7 Espadas, 7 Bastos, 7 Copas", 7)]     // Sin envido, 7 más alto

// Casos de excepción
- Mano nula
- Mano vacía  
- Mano con 1 carta
- Mano con 2 cartas
- Mano con 4+ cartas
- Mano con carta nula
- Mano con cartas duplicadas

// Casos edge
- 3 cartas del mismo palo (solo usar las 2 más altas)
- Figuras (sota=10, caballo=11, rey=12)
- Ases (1=1 para envido)
```

4. **Estructura del proyecto:**
   * `Truco.Dominio` (clases principales)
   * `Truco.Dominio.Tests` (todos los tests)
   * Cobertura mínima del 95%

---

## Anexo 2 — Ejercicio Completo: Sistema de Comparación Robusto

**Instrucciones:**

1. **Implementar JuezEnvido con validaciones:**
   * Usar inyección de dependencias para CalculadoraEnvido
   * Validar que ambas manos sean válidas
   * Manejar empates correctamente
   * Proporcionar información detallada del resultado

2. **Implementar ResultadoEnvido expandido:**

   La clase `ResultadoEnvido` debe contener:
   * Información del ganador (1, 2, o 0 para empate)
   * Puntos de cada jugador
   * Propiedades calculadas útiles (¿es empate?, diferencia de puntos)
   * Descripción textual del resultado para mostrar al usuario

   **Propiedades mínimas requeridas:**
   * `Ganador`: int (1, 2, o 0)
   * `PuntosJugador1`: int  
   * `PuntosJugador2`: int
   * `EsEmpate`: bool (calculada)
   * `DiferenciaPuntos`: int (calculada)
   * `DescripcionResultado`: string (calculada)

3. **Tests de comparación completos:**
   * Jugador 1 gana
   * Jugador 2 gana  
   * Empates
   * Diferencias mínimas (1 punto)
   * Diferencias máximas (envido vs sin envido)
   * Validaciones de entrada (manos inválidas)

4. **Test de integración completo:**

   Crear un test que integre todo el sistema:
   * **Componentes**: `RepartidorTruco`, `CalculadoraEnvido`, `JuezEnvido`
   * **Flujo**: repartir cartas → calcular envido → comparar resultados
   * **Validaciones del test**:
     - El ganador debe ser válido (0, 1, o 2)
     - Los puntos de cada jugador deben estar en rango válido (0-33)
     - La descripción del resultado no debe ser nula/vacía
     - Si hay ganador, sus puntos deben ser mayores al otro jugador
     - El sistema completo no debe lanzar excepciones con datos válidos

---

## Cierre

* **Robustez**: los tests de excepciones aseguran que el código falle elegantemente ante entradas inválidas.
* **Contratos claros**: las validaciones documentan qué se espera como entrada válida.
* **Confianza**: con validaciones completas, podemos usar el código en cualquier contexto sin temor.
* **Próximo paso**: integrar estas validaciones con capas superiores (controladores, UI) y mantener la robustez en toda la aplicación.
