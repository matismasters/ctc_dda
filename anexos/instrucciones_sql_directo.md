# SQL Directo en C#

## 1. Crear el proyecto de consola

1. Abre una terminal o **Visual Studio / VS Code**.
2. Ejecuta el comando:

   ```bash
   dotnet new console -n MiProyectoConDB
   ```

   Esto crea un proyecto con un `Program.cs`.

---

## 2. Instalar el paquete necesario

Si usas **SQL Server**, necesitas el paquete `System.Data.SqlClient`:

```bash
dotnet add package System.Data.SqlClient
```

Para **MySQL**:

```bash
dotnet add package MySql.Data
```

---

## 3. Importar los espacios de nombres

En tu `Program.cs` agrega:

```csharp
using System;
using System.Data;
using System.Data.SqlClient; // Para SQL Server
```

---

## 4. Definir la cadena de conexión

```csharp
string connectionString = "Server=MI_SERVIDOR;Database=MI_BASE;User Id=USUARIO;Password=PASSWORD;";
```

Ejemplo con SQL Server local:

```csharp
string connectionString = "Server=localhost;Database=PruebaDB;Trusted_Connection=True;";
```

---

## 5. Escribir el comando `INSERT`

```csharp
using (SqlConnection connection = new SqlConnection(connectionString))
{
    try
    {
        connection.Open();

        string query = "INSERT INTO Personas (Nombre, Edad) VALUES (@Nombre, @Edad)";
        
        using (SqlCommand command = new SqlCommand(query, connection))
        {
            command.Parameters.AddWithValue("@Nombre", "Juan");
            command.Parameters.AddWithValue("@Edad", 30);

            int rowsAffected = command.ExecuteNonQuery();
            Console.WriteLine($"{rowsAffected} fila(s) insertada(s).");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine("Error: " + ex.Message);
    }
}
```

---

## 6. Ejecutar el proyecto

En la terminal, corre:

```bash
dotnet run
```

Si todo está bien configurado, deberías ver en consola:

```
1 fila(s) insertada(s).
```

---

## 7. Buenas prácticas adicionales

* **Usar parámetros** como en el ejemplo (para evitar SQL Injection).
* Manejar excepciones con `try-catch`.
* Opcional: separar la lógica de acceso a datos en una clase distinta (ej. `RepositorioPersonas`).
