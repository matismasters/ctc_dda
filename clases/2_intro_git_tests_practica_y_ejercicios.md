# Clase 2 – Profundización en Tests Unitarios y Práctica con Ejercicios (Jeringozo y Truco)

**Duración:** 3 horas
**Objetivo general:** profundizar en la **escritura y diseño de tests unitarios**, revisar las soluciones del ejercicio Jeringozo, aplicar **Test-Driven Development (TDD)** básico, y desarrollar una serie de ejercicios progresivos que culminen en la **lógica básica del juego de Truco uruguayo** (reparto de cartas y conteo de envido).

---

## Índice

1. Módulo 1 — Revisión de ejercicios domiciliarios (Jeringozo)
2. Módulo 2 — TDD en vivo: especificaciones para desencriptar Jeringozo
3. Módulo 3 — Comandos adicionales de Git y buenas prácticas
4. Módulo 4 — Ejercicios progresivos: Fundamentos del Truco
5. Recursos adicionales para testing
6. Glosario de términos avanzados
7. Cierre

---

## Módulo 1 — Revisión de ejercicios domiciliarios (Jeringozo)

> **Revisión grupal de soluciones:** análisis de diferentes implementaciones presentadas por los estudiantes, identificación de **patrones comunes**, **casos edge** no contemplados, y **mejores prácticas** en el diseño de tests.

### 1.1 Criterios de evaluación de las soluciones

**Aspectos técnicos a revisar:**

* **Separación de responsabilidades**: ¿La lógica está separada de la UI?
* **Nombrado claro**: ¿Los métodos y variables son autodescriptivos?
* **Casos edge**: ¿Se contemplaron cadenas vacías, solo consonantes, acentos?
* **Tests comprehensivos**: ¿Los tests cubren casos normales y excepcionales?
* **Patrón AAA**: ¿Los tests siguen la estructura Arrange-Act-Assert?

### 1.2 Problemas comunes identificados

**En la implementación:**

```csharp
// Problema común: lógica mezclada con I/O
public static void Main()
{
    Console.WriteLine("Ingrese texto:");
    string texto = Console.ReadLine();
    // lógica de encriptación aquí directamente...
}

// Mejor: separación clara
public static void Main()
{
    Console.WriteLine("Ingrese texto:");
    string texto = Console.ReadLine();
    var jeringozo = new Jeringozo();
    string resultado = jeringozo.Encriptar(texto);
    Console.WriteLine($"Resultado: {resultado}");
}
```

**En los tests:**

```csharp
// Problema: test que no sigue AAA claramente
[Fact]
public void Test1()
{
    Assert.Equal("gapatopo", new Jeringozo().Encriptar("gato"));
}

// Mejor: estructura clara y nombre descriptivo
[Fact]
public void Encriptar_PalabraCon2Vocales_InsertaPEnCadaVocal()
{
    // Arrange
    var jeringozo = new Jeringozo();
    string entrada = "gato";
    
    // Act
    string resultado = jeringozo.Encriptar(entrada);
    
    // Assert
    Assert.Equal("gapatopo", resultado);
}
```

### 1.3 Discusión de casos edge no contemplados

* ¿Qué pasa con las tildes (á, é, í, ó, ú)?
* ¿Cómo manejar caracteres especiales o números?
* ¿La implementación preserva mayúsculas y minúsculas?
* ¿Qué sucede con cadenas muy largas o vacías?

---

## Módulo 2 — TDD en vivo: especificaciones para desencriptar Jeringozo

> **Objetivo:** escribir **primero los tests** para el método `Desencriptar`, siguiendo la metodología **Red-Green-Refactor**, antes de implementar la funcionalidad.

### 2.1 Metodología TDD básica

1. **Red**: escribir un test que falle (porque la funcionalidad no existe).
2. **Green**: escribir el mínimo código necesario para que el test pase.
3. **Refactor**: mejorar el código manteniendo los tests verdes.

### 2.2 Especificaciones a implementar en vivo

**Comportamiento esperado del método `Desencriptar`:**

* Convertir texto encriptado de vuelta al español original
* `"gapatopo"` → `"gato"`
* `"Hopolapa"` → `"Hola"`
* Preservar mayúsculas/minúsculas en su posición original
* Manejar casos donde no hay secuencias de jeringozo

### 2.3 Ejercicio en vivo: escribir tests antes que código

**Estructura del ejercicio:**

1. **Paso 1**: Crear tests para casos básicos (palabras simples)
2. **Paso 2**: Agregar tests para casos con mayúsculas
3. **Paso 3**: Tests para casos edge (sin vocales, texto ya desencriptado)
4. **Paso 4**: Ejecutar tests y ver que fallan (Red)

```csharp
// Ejemplo de estructura que se desarrollará en vivo
public class JeringozoTests
{
    [Fact]
    public void Desencriptar_TextoBasico_RegresaTextoOriginal()
    {
        // Se desarrollará en clase...
    }
    
    [Theory]
    [InlineData("gapatopo", "gato")]
    [InlineData("capalapasapa", "casa")]
    public void Desencriptar_CasosVarios_Funciona(string encriptado, string esperado)
    {
        // Se desarrollará en clase...
    }
}
```

### 2.4 Implementación posterior

**Instrucciones post-TDD:**

Una vez completados los tests en clase, implementar el método `Desencriptar` que haga pasar todos los tests escritos. La implementación debe:

* Identificar patrones `p + vocal` en el texto
* Reemplazarlos por la vocal correspondiente
* Mantener intactos otros caracteres
* Preservar el formato original

---

## Módulo 3 — Comandos adicionales de Git y buenas prácticas

### 3.1 Comandos útiles para el trabajo diario

```bash
# Inspección avanzada
git log --oneline --graph --all          # historial visual completo
git show <commit-hash>                    # detalles de un commit específico
git diff HEAD~1                          # cambios del último commit

# Trabajo con archivos
git add -A                               # staged de todos los cambios
git reset HEAD <archivo>                 # unstage de archivo específico
git checkout -- <archivo>               # descartar cambios locales

# Ramas y merging
git branch -a                           # ver todas las ramas (locales y remotas)
git branch -d feature/nombre            # eliminar rama local
git push origin --delete feature/nombre # eliminar rama remota

# Útiles para colaboración
git fetch                               # traer cambios sin hacer merge
git pull --rebase                       # rebase en lugar de merge
```

### 3.2 Buenas prácticas para commits

* **Commits atómicos**: cada commit debe representar un cambio lógico completo
* **Mensajes consistentes**: usar un formato estándar en el equipo
* **Frecuencia adecuada**: ni muy granular ni muy agrupado

```bash
# Buenos ejemplos de mensajes
git commit -m "agrega método Desencriptar con tests básicos"
git commit -m "refactoriza Jeringozo para manejar tildes correctamente"
git commit -m "corrige bug en conteo de puntos con cartas repetidas"
```

---

## Módulo 4 — Ejercicios progresivos: Fundamentos del Truco

> **Meta general:** construir progresivamente las bases para un juego de **Truco uruguayo**, enfocándose en **reparto de cartas** y **cálculo de envido**.

### 4.1 Contexto: ¿Qué necesitamos para jugar al Truco?

**Elementos fundamentales:**

* **Mazo español**: 40 cartas (sin 8, 9 de cada palo)
* **Cartas**: valor del 1 al 7, 10, 11, 12 (sota, caballo, rey)
* **Palos**: espadas, bastos, oros, copas
* **Reparto**: 3 cartas por jugador, 1 carta "muestra"
* **Envido**: suma de puntos basada en reglas de truco

### 4.2 Ejercicio 1 — Representación y reparto de cartas

**Objetivo:** crear clases para representar cartas y un repartidor que distribuya cartas a dos jugadores.

**Metodología TDD:**

1. **Escribir tests primero** para verificar:
   * El mazo contiene exactamente 40 cartas
   * No hay cartas 8, 9
   * Cada jugador recibe exactamente 3 cartas
   * Se asigna 1 carta como muestra
   * No hay cartas repetidas entre jugadores y muestra

2. **Implementar** las clases después de tener tests verdes

### 4.3 Ejercicio 2 — Cálculo de puntos de Envido

**Objetivo:** implementar la lógica para calcular puntos de envido de una mano de 3 cartas.

**Reglas del Envido:**
* Definir entre todos en clase


### 4.4 Ejercicio 3 — Comparación de manos de Envido

**Objetivo:** determinar qué jugador gana el envido comparando sus respectivas manos.

**Tests a considerar:**
* Ganador por mayor puntaje
* Empates (mismo puntaje)
* Casos edge con cartas especiales

---

## Recursos adicionales para testing

### Testing frameworks y librerías

* **xUnit.net**: Framework principal recomendadod
* **Bogus**: Generación de datos de prueba realistas
* **AutoFixture**: Creación automática de objetos para tests
d
### Cobertura de código

```bash
# Instalar herramientas
dotnet add package coverlet.collector
dotnet add package ReportGenerator --version 4.8.12

# Ejecutar tests con cobertura
dotnet test --collect:"XPlat Code Coverage"

# Generar reporte HTML
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coveragereport"
```

---

## Glosario de términos avanzados

* **TDD (Test-Driven Development)**: metodología donde se escriben primero los tests, luego la implementación.
* **Red-Green-Refactor**: ciclo de TDD (test falla, test pasa, mejora código).
* **Arrange-Act-Assert (AAA)**: patrón para estructurar tests unitarios.
* **Test Double**: objeto falso usado en tests (mock, stub, fake).
* **Cobertura de código**: métrica que indica qué porcentaje del código está cubierto por tests.
* **Case Edge (Caso borde)**: situaciones límite o excepcionales que el código debe manejar.
* **Assertion**: verificación dentro de un test que determina si pasa o falla.
* **Setup/Teardown**: código que se ejecuta antes/después de cada test.
* **Test Fixture**: conjunto de datos y objetos preparados para ejecutar tests.

---

## Anexo 1 — Ejercicio Completo: Jeringozo Desencriptar

**Instrucciones:**

1. Completar la implementación del método `Desencriptar` basándose en los tests escritos en clase.
2. Agregar tests adicionales para casos no contemplados durante la sesión en vivo.
3. Refactorizar el código si es necesario para mejorar legibilidad.
4. Asegurar que tanto `Encriptar` como `Desencriptar` sean operaciones inversas:

```csharp
[Theory]
[InlineData("gato")]
[InlineData("Hola mundo")]
[InlineData("programación")]
public void EncriptarDesencriptar_OperacionesInversas_TextoOriginal(string textoOriginal)
{
    // Arrange
    var jeringozo = new Jeringozo();
    
    // Act
    string encriptado = jeringozo.Encriptar(textoOriginal);
    string desencriptado = jeringozo.Desencriptar(encriptado);
    
    // Assert
    Assert.Equal(textoOriginal, desencriptado);
}
```

---

## Anexo 2 — Ejercicio Completo: Fundamentos de Truco

**Instrucciones:**

1. **Implementar el sistema base:**
   * Clase `Carta` con sus propiedades
   * Enum `Palo` con los cuatro palos
   * Clase `RepartidorTruco` que genere mazos y reparta cartas
   * Validar que el mazo español tenga exactamente 40 cartas correctas

2. **Desarrollar el cálculo de Envido:**
   * Clase `CalculadoraEnvido` con método para calcular puntos
   * Tests exhaustivos cubriendo todos los casos posibles
   * Manejar correctamente la lógica de "dos cartas del mismo palo"

3. **Crear el sistema de comparación:**
   * Clase `JuezEnvido` para determinar ganadores
   * Manejar empates adecuadamente
   * Tests que verifiquen todos los escenarios posibles

4. **Estructura de proyecto:**
   * Proyecto principal: `Truco.Dominio`
   * Proyecto de tests: `Truco.Dominio.Tests`
   * Seguir convenciones de nombrado consistentes
   * Documentar clases y métodos públicos

5. **Requisitos técnicos:**
   * Cobertura de tests del 90% o superior
   * Todos los tests deben pasar
   * Código limpio siguiendo principios SOLID básicos
   * Commits atómicos con mensajes descriptivos

**Entregables:**
* Repositorio en GitHub con código completo
* Tests unitarios funcionando
* README explicando cómo ejecutar el proyecto
* Demostración en vivo del funcionamiento

---

## Cierre

* **Consolidación**: TDD ayuda a diseñar mejor software y da confianza en los cambios.
* **Progresión**: de ejercicios simples (Jeringozo) a dominios más complejos (Truco).
* **Práctica continua**: escribir tests se vuelve natural con la repetición.
* **Próximo paso**: integrar estas bases con aplicaciones web MVC y APIs, manteniendo la misma disciplina de testing.
