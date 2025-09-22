# Patrón Repository

---

## ¿Qué es el Patrón Repository?

El **patrón Repository** es una abstracción que encapsula la lógica necesaria para acceder a datos. Proporciona una interfaz uniforme para acceder a los datos sin importar dónde están almacenados (base de datos, archivos, servicios web, etc.).

**En términos simples:** Es como tener un "bibliotecario" que sabe dónde están todos los libros y te los trae cuando los necesitas para leer o escribir, sin que tú tengas que saber exactamente en qué estante están o en que orden estan guardados.

---

## ¿Cuándo usar Repository?

✅ **Úsalo cuando:**
- Tu aplicación necesita acceder a datos de diferentes fuentes
- Quieres que tu código sea testeable sin depender de una base de datos
- Necesitas separar la lógica de negocio de cómo se almacenan los datos
- Quieres poder cambiar de base de datos sin afectar tu código de negocio

❌ **No lo uses cuando:**
- Tu aplicación es muy simple y solo hace consultas básicas
- No necesitas tests automatizados
- El costo de la abstracción es mayor que sus beneficios

---

## ¿Por qué usar Repository?

### Problema: Código acoplado a la base de datos

```csharp
public class ServicioUsuarios
{
    public bool CrearUsuario(string nombre, string email)
    {
        // Lógica de negocio mezclada con acceso a datos
        using var connection = new SqlConnection("connection string");
        connection.Open();
        
        var command = new SqlCommand("INSERT INTO Usuarios (Nombre, Email) VALUES (@nombre, @email)", connection);
        command.Parameters.AddWithValue("@nombre", nombre);
        command.Parameters.AddWithValue("@email", email);
        
        // ¿Cómo testear esto?
        return command.ExecuteNonQuery() > 0;
    }
}
```

### Problemas de este enfoque:
- **Difícil de testear**: necesitas una base de datos real
- **Acoplado**: cambiar de base de datos requiere modificar todo el código
- **Mezcla responsabilidades**: lógica de negocio y acceso a datos juntos

---

## Solución: Patrón Repository

### 1. Entidad de Dominio (simple)

```csharp
public class Usuario
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    public string Email { get; set; }
}
```

### 2. Interfaz del Repository

```csharp
public interface IUsuarioRepository
{
    void Agregar(Usuario usuario);
    List<Usuario> ObtenerTodos();
}
```

### 3. Implementación del Repository

```csharp
public class UsuarioRepository : IUsuarioRepository
{
    private readonly List<Usuario> _usuarios = new List<Usuario>();
    private int _contadorId = 1;

    public void Agregar(Usuario usuario)
    {
        usuario.Id = _contadorId++;
        _usuarios.Add(usuario);
    }

    public List<Usuario> ObtenerTodos()
    {
        return _usuarios.ToList();
    }
}
```

### 4. Servicio usando el Repository

```csharp
public class ServicioUsuarios
{
    private readonly IUsuarioRepository _repository;

    public ServicioUsuarios(IUsuarioRepository repository)
    {
        _repository = repository;
    }

    public bool CrearUsuario(string nombre, string email)
    {
        // Solo lógica de negocio
        if (string.IsNullOrEmpty(nombre) || string.IsNullOrEmpty(email))
            return false;

        if (!email.Contains("@"))
            return false;

        var usuario = new Usuario { Nombre = nombre, Email = email };
        _repository.Agregar(usuario);
        return true;
    }

    public List<Usuario> ObtenerTodosLosUsuarios()
    {
        return _repository.ObtenerTodos();
    }
}
```

---

## Ejemplo de uso

```csharp
// En tu aplicación
var repository = new UsuarioRepository();
var servicio = new ServicioUsuarios(repository);

// Crear usuarios
bool exito1 = servicio.CrearUsuario("Juan", "juan@email.com");
bool exito2 = servicio.CrearUsuario("María", "maria@email.com");

// Obtener todos los usuarios
List<Usuario> usuarios = servicio.ObtenerTodosLosUsuarios();

foreach (var usuario in usuarios)
{
    Console.WriteLine($"{usuario.Nombre} - {usuario.Email}");
}
```

---

## Beneficios de esta solución

### ✅ **Testeable**
```csharp
[Test]
public void CrearUsuario_EmailInvalido_RetornaFalso()
{
    // Arrange
    var repository = new UsuarioRepository(); // Sin base de datos!
    var servicio = new ServicioUsuarios(repository);
    
    // Act
    bool resultado = servicio.CrearUsuario("Juan", "email-sin-arroba");
    
    // Assert
    Assert.False(resultado);
}
```

### ✅ **Flexible**
Puedes cambiar la implementación sin afectar el servicio:
```csharp
// Implementación con base de datos real
public class UsuarioSqlRepository : IUsuarioRepository
{
    // Implementación con SQL Server
}

// Implementación con archivos
public class UsuarioArchivoRepository : IUsuarioRepository
{
    // Implementación con archivos JSON
}
```

### ✅ **Separación de responsabilidades**
- **Servicio**: solo lógica de negocio
- **Repository**: solo acceso a datos
- **Entidad**: solo representar los datos

---

## Resumen

El patrón Repository te permite:
1. **Separar** la lógica de negocio del acceso a datos
2. **Testear** tu código fácilmente
3. **Cambiar** la tecnología de almacenamiento sin afectar la lógica
4. **Mantener** un código más limpio y organizad

**Recuerda:** Repository es como un "bibliotecario" que maneja todos los libros (datos) por ti, permitiéndote concentrarte en lo que realmente importa: la lógica de tu aplicación.
