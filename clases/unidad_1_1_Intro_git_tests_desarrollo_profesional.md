# Clase 1 – Programación Profesional, Git básico y Anatomía de un Test (C# consola)

**Duración:** 3 horas
**Objetivo general:** comprender qué es **programar profesionalmente**, practicar **buenas vs malas prácticas** con ejemplos en consola, repasar **versionado con Git** (por qué importa y comandos esenciales) con un **ejercicio**, y aprender la **anatomía de un test unitario** en C# (xUnit) enfocándonos en **cómo escribirlos y por qué son relevantes**.

---

## Índice

1. Módulo 1 — Programación profesional (buenas vs malas prácticas)
2. Módulo 2 — Versionado con Git (por qué importa + comandos + ejercicio)
3. Módulo 3 — Anatomía de un test unitario (xUnit)
4. Recursos rápidos
5. Cómo escribir buenos mensajes de commit
6. Glosario de términos
7. Cierre

---

## Módulo 1 — Programación profesional (buenas vs malas prácticas)

> La idea es que el código sea **legible, mantenible, testeable** y **predecible**. No alcanza con “que funcione”; debe poder **evolucionar** sin romperse.

### 1.1 Principios prácticos (mínimos para hoy)

* **Separación de responsabilidades**: la lógica no se mezcla con I/O (consola, archivos).
* **Funciones puras** cuando sea posible: mismas entradas → mismo resultado.
* **Evitar valores mágicos**: usar constantes o parámetros.
* **Nombrado claro**: métodos y variables cuentan una historia.
* **Inyección de dependencias simple**: pasar lo necesario por constructor/parámetros.

### 1.2 Ejemplo 1 – Cálculo de precio final (malo vs profesional)

**Malo (mezcla I/O y lógica, valores mágicos, difícil de testear):**

```csharp
// Program.cs (MALO)
Console.WriteLine("Ingrese precio base:");
string entrada = Console.ReadLine();
decimal precio = decimal.Parse(entrada); // sin validación
decimal total = precio + precio * 0.21m; // 21% hardcodeado
Console.WriteLine($"Total: {total}");
```

**Profesional (UI delgada + lógica aislada y testeable):**

```csharp
// CalculadoraPrecios.cs
public class CalculadoraPrecios
{
    private readonly decimal _tasaImpuesto;
    public CalculadoraPrecios(decimal tasaImpuesto) => _tasaImpuesto = tasaImpuesto;

    public decimal CalcularTotal(decimal precioBase)
    {
        decimal total = precioBase + precioBase * _tasaImpuesto;
        return decimal.Round(total, 2, MidpointRounding.AwayFromZero);
    }
}

// Program.cs (UI)
Console.Write("Ingrese precio base: ");
if (!decimal.TryParse(Console.ReadLine(), out decimal precioBase))
{
    Console.WriteLine("Precio inválido");
    return;
}
CalculadoraPrecios calculadora = new CalculadoraPrecios(0.21m); // dependencia explícita
Console.WriteLine($"Total: {calculadora.CalcularTotal(precioBase)}");
```

**Qué mejora:** responsabilidad única, testabilidad, parámetros explícitos.

### 1.3 Ejemplo 2 – Descuentos por volumen (claridad de reglas)

```csharp
// Malo: reglas opacas, números repartidos por el código
public decimal CalcularDescuento_Malo(int cantidad)
{
    if (cantidad > 9 && cantidad < 50) return 0.05m;
    if (cantidad >= 50 && cantidad < 100) return 0.10m;
    if (cantidad >= 100) return 0.15m;
    return 0m;
}

// Mejor: reglas explícitas y ordenadas
public class PoliticaDescuentos
{
    public decimal ObtenerTasa(int cantidad)
    {
        if (cantidad >= 100) return 0.15m;
        if (cantidad >= 50)  return 0.10m;
        if (cantidad >= 10)  return 0.05m;
        return 0.00m;
    }
}
```

**Tips de lectura:** evitar “ifs sorpresas”, ordenar casos de mayor a menor, cubrir límites en tests.

---

## Módulo 2 — Versionado con Git (por qué importa + comandos + ejercicio)

### 2.1 Por qué importa

* **Historia y trazabilidad**: cada cambio queda registrado (quién, cuándo, por qué).
* **Trabajo en equipo**: ramas, revisiones, merges.
* **Confianza**: si algo sale mal, podemos **volver atrás**.
* **Automatización**: CI/CD corre tests y valida cambios en cada push.

### 2.2 Comandos esenciales (cheatsheet mínimo)

```bash
# Configuración inicial (una sola vez por equipo/PC)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo"

# Crear o inicializar repositorio
git init                # inicia repo en carpeta actual
git clone <url>         # clona repo remoto

# Flujo diario
git status              # ver estado
git add .               # staged files
git commit -m "agrega calculadora de precios"
git log --oneline --graph --decorate

git branch              # lista ramas
git switch -c feature/calculadora   # crea y cambia a rama
# (o) git checkout -b feature/calculadora

git merge feature/calculadora       # fusionar a la rama actual

git remote add origin <url>
git push -u origin main             # primer push
# luego: git push / git pull

# Diferencias y recuperación
git diff                # cambios sin stage
git diff --staged       # cambios staged
git restore <archivo>   # descarta cambios en archivo
```

### 2.3 Ejercicio guiado (10–15 min)

> Objetivo: practicar un **flujo simple** con ramas y commits sobre la app de consola.

1. Crear carpeta y solución:

```bash
mkdir Clase1Git && cd Clase1Git
dotnet new console -n Aplicacion
cd Aplicacion
git init
```

2. Primer commit:

* Crear o editar el archivo **Program.cs** con este contenido:

```csharp
Console.WriteLine("Hola Clase 1");
```

* Luego ejecutar:

```bash
git add .
git commit -m "proyecto consola base"
```

3. Nueva rama de funcionalidad y cambio mínimo:

```bash
git switch -c feature/sumar
```

* Crear el archivo **Calculadora.cs** con este contenido:

```csharp
public static class Calculadora
{
    public static int Sumar(int a, int b) => a + b;
}
```

* Luego ejecutar:

```bash
git add .
git commit -m "agrega Calculadora.Sumar"
```

4. Volver a `main` y fusionar:

```bash
git switch main
git merge feature/sumar
```

5. (Opcional) Publicar en remoto:

```bash
git remote add origin <url-de-tu-repo>
git push -u origin main
```

**Criterio de éxito:** ver commits claros, rama de feature fusionada y el código de `Calculadora.Sumar` disponible en `main`.

---

## Módulo 3 — Anatomía de un test unitario (xUnit)

> Objetivo: aprender a **escribir** tests y a **leer** sus resultados. Más adelante veremos TDD completo; hoy nos enfocamos en la **sintaxis** y en casos **muy sencillos**.

### 3.1 Estructura y patrón AAA

* **Arrange (Preparar)**: preparar datos/objetos.
* **Act (Actuar)**: ejecutar la acción a probar.
* **Assert (Afirmar)**: verificar el resultado.

### 3.2 `[Fact]` vs `[Theory]`

* **`[Fact]`**: caso único, sin parámetros.
* **`[Theory]`**: caso parametrizado para múltiples entradas/salidas.

### 3.3 Proyecto de tests (mínimo)

```bash
# dentro de la solución
cd .. # si estás en Aplicacion
dotnet new xunit -n Aplicacion.Tests
cd Aplicacion.Tests
dotnet add reference ../Aplicacion/Aplicacion.csproj
cd ..
dotnet test
```

### 3.4 Ejemplo 1 — `[Fact]` con algo **extremadamente sencillo**

```csharp
// Aplicacion/Calculadora.cs
public static class Calculadora
{
    public static int Sumar(int a, int b) => a + b;
}

// Aplicacion.Tests/CalculadoraPruebas.cs
using Xunit;

public class CalculadoraPruebas
{
    [Fact]
    public void Sumar_DosNumeros_RetornaSuma()
    {
        // Arrange
        int a = 2; int b = 3;
        // Act
        int resultado = Calculadora.Sumar(a, b);
        // Assert
        Assert.Equal(5, resultado);
    }
}
```

### 3.5 Ejemplo 2 — `[Theory]` parametrizado

```csharp
// Aplicacion.Tests/CalculadoraTeorias.cs
using Xunit;

public class CalculadoraTeorias
{
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(-1, 1, 0)]
    [InlineData(10, 5, 15)]
    public void Sumar_CasosVarios_Ok(int a, int b, int esperado)
    {
        Assert.Equal(esperado, Calculadora.Sumar(a, b));
    }
}
```

### 3.6 Asserts básicos y excepciones

```csharp
// Aplicacion/Matematicas.cs
public static class Matematicas
{
    public static bool EsPar(int n) => n % 2 == 0;
    public static int Dividir(int a, int b)
        => b == 0 ? throw new DivideByZeroException() : a / b;
}

// Aplicacion.Tests/MatematicasPruebas.cs
using Xunit;

public class MatematicasPruebas
{
    [Theory]
    [InlineData(2, true)]
    [InlineData(3, false)]
    public void EsPar_Funciona(int n, bool esperado)
        => Assert.Equal(esperado, Matematicas.EsPar(n));

    [Fact]
    public void Dividir_ConCero_Lanza()
        => Assert.Throws<DivideByZeroException>(() => Matematicas.Dividir(10, 0));
}
```

### 3.7 Por qué es relevante e importante

* **Confianza**: si algo cambia, los tests avisan inmediatamente (regresión).
* **Documentación viva**: muestran **cómo se espera** que funcione el código.
* **Diseño mejor**: escribir tests te obliga a **separar responsabilidades**.
* **Velocidad**: feedback rápido, incluso antes de integrar con UI/Infra.
* **Base para lo que viene**: luego añadiremos cobertura, mocks, integración y TDD completo.

---

## Recursos rápidos

* Frameworks de tests: **xUnit** (recomendado), NUnit, MSTest.
* Asserts expresivos: **FluentAssertions**.
* Dobles de prueba: **Moq**, NSubstitute.
* Cobertura: **coverlet.collector** + ReportGenerator.
* CI/CD: GitHub Actions / Azure Pipelines / GitLab CI.

---

## Cómo escribir buenos mensajes de commit

* **Claridad**: explicar qué se cambió, no sólo “arreglos” o “cosas varias”.
* **Concisión**: una línea corta y descriptiva (50–70 caracteres aprox.).
* **Tiempo presente**: “agrega Calculadora.Sumar” en lugar de “agregué”.
* **Contexto**: si es necesario, se puede agregar un cuerpo debajo con más detalles.
* **Ejemplos correctos:**

  * `agrega validación de entrada en Program.cs`
  * `corrige cálculo de descuento para cantidades de 100+`
  * `refactoriza CalculadoraPrecios para usar constantes claras`

---

## Glosario de términos

* **Commit**: registro de un conjunto de cambios en el repositorio con un mensaje que los describe.
* **Branch (rama)**: línea paralela de trabajo donde se desarrollan cambios sin afectar la rama principal.
* **Merge (fusión)**: proceso de integrar los cambios de una rama en otra.
* **Repositorio**: carpeta controlada por Git que guarda el historial de cambios.
* **Push**: enviar commits locales a un repositorio remoto.
* **Pull**: traer commits del repositorio remoto al local.
* **Test unitario**: prueba automatizada que verifica el comportamiento de una pieza pequeña de código (función o método).
* **Assert**: instrucción dentro del test que verifica un resultado esperado.
* **\[Fact]**: atributo de xUnit que marca un test único, sin parámetros.
* **\[Theory]**: atributo de xUnit que marca un test con datos de entrada parametrizados.

---

## Anexo 1 — Ejercicio de Git (README en GitHub público)

**Instrucciones:**

1. Crear un repositorio **público** en GitHub con el nombre que quieras.
2. Clonar el repositorio en tu máquina local.
3. Crear un archivo **README.md** y escribir un texto de varios párrafos sobre un tema libre (podés usar IA para generarlo).
4. Realizar los siguientes commits (cada paso es un commit separado):

   * Cambiar el **título principal** del documento.
   * Agregar una **introducción** explicando que el texto es sólo para un ejercicio de uso de Git.
   * Agregar al final una **firma** con tu nombre.
5. Crear una **nueva rama**.

   * En esa rama, cambiar los **dos primeros** y los **dos últimos** párrafos. Commit.
   * Luego, reemplazar el texto completo por uno nuevo. Commit.
6. Volver a la rama **main** y fusionar los cambios de la rama creada.
7. Mientras realizás estos pasos, **dibujar en una hoja de papel** una línea representando el avance de los commits y el flujo de Git (commits, ramas, merges).

---

## Anexo 2 — Ejercicio de Tests Unitarios (Jeringozo)

**Instrucciones:**

1. Crear una aplicación de consola en C#.
2. Dentro del proyecto, crear una clase llamada `Jeringozo`.
3. Implementar dos métodos: `Encriptar(string texto)` y `Desencriptar(string texto)`.

   * Regla: por cada **vocal** se inserta la secuencia `p` + la **misma vocal**.
   * Ejemplos:

     * `gato` → `gapatopo`
     * `Hola` → `Hopolapa`
4. Escribir **tests unitarios** con xUnit que validen el comportamiento de esos métodos.

   * Usar `[Fact]` para casos individuales.
   * Usar `[Theory]` con `[InlineData]` para múltiples casos de prueba.
   * Incluir pruebas con palabras vacías, sin vocales, con mayúsculas y con acentos.
5. Asegurarse de usar **nombres en español**, tipos explícitos (no `var`) y cubrir casos frontera.

> Al finalizar, entregar link al repositorio publico de git con lo implementado.

---

## Cierre

* **Profesionalizar** = escribir código claro, testeable y con historia en Git.
* Git: practica diaria de ramas, commits con mensajes claros y merges.
* Tests unitarios: empezar por casos **simples y deterministas**.
* Próximo paso: profundizar en **TDD** y ampliar el set de tests a reglas más ricas.
