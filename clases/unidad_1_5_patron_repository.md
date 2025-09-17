# Clase 5 – Patrón Repository: Abstracción de Acceso a Datos y Testabilidad

**Duración:** 3 horas  
**Objetivo general:** dominar el **patrón Repository** para abstraer el acceso a datos, separar la **lógica de negocio** de la **persistencia**, implementar **Unit of Work** para transacciones, y escribir **tests unitarios** efectivos usando **mocks** sin dependencia de base de datos real.

---

## Índice

1. Módulo 1 — El problema del acceso directo a datos
2. Módulo 2 — Repository básico: Abstracción e implementación
3. Módulo 3 — Unit of Work: Transacciones y consistencia
4. Módulo 4 — Testing con mocks: Independencia de infraestructura
5. Módulo 5 — Ejercicios progresivos: Sistema de gestión de pedidos
6. Recursos para persistencia y testing
7. Mejores prácticas de Repository pattern
8. Glosario de términos de persistencia
9. Cierre

---

## Módulo 1 — El problema del acceso directo a datos

> El acceso directo a datos desde la **lógica de negocio** crea **acoplamiento fuerte**, dificulta el **testing** y viola el **principio de responsabilidad única**.

### 1.1 Principios fundamentales

* **Separación de capas**: lógica de negocio independiente de persistencia
* **Inversión de dependencias**: depender de abstracciones, no de implementaciones concretas
* **Testabilidad**: poder probar lógica sin base de datos real
* **Flexibilidad**: cambiar tecnología de persistencia sin afectar negocio

### 1.2 Ejemplo 1 – Gestión de usuarios (problemático vs profesional)

**❌ Problemático (lógica acoplada a SQL directo):**

```csharp
// ServicioUsuarios.cs (MALO - mezcla lógica con persistencia)
public class ServicioUsuarios
{
    private readonly string _connectionString;
    
    public ServicioUsuarios(string connectionString)
    {
        _connectionString = connectionString;
    }
    
    public bool CrearUsuario(string email, string password)
    {
        // Validaciones mezcladas con SQL
        if (string.IsNullOrEmpty(email) || !email.Contains("@"))
            return false;
            
        using var connection = new SqlConnection(_connectionString); // acoplamiento a SQL
        connection.Open();
        
        // Verificar duplicados - lógica mezclada con SQL
        var checkCmd = new SqlCommand("SELECT COUNT(*) FROM Usuarios WHERE Email = @email", connection);
        checkCmd.Parameters.AddWithValue("@email", email);
        int count = (int)checkCmd.ExecuteScalar();
        
        if (count > 0) return false; // duplicado
        
        // Hashear password - lógica mezclada  
        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);
        
        // Insertar - más SQL directo
        var insertCmd = new SqlCommand(
            "INSERT INTO Usuarios (Email, PasswordHash, FechaCreacion) VALUES (@email, @password, @fecha)", 
            connection);
        insertCmd.Parameters.AddWithValue("@email", email);
        insertCmd.Parameters.AddWithValue("@password", hashedPassword);
        insertCmd.Parameters.AddWithValue("@fecha", DateTime.UtcNow);
        
        return insertCmd.ExecuteNonQuery() > 0;
    }
    
    // ¿Cómo testear esto sin base de datos real? ¡IMPOSIBLE!
}
```

**✅ Profesional (Repository separa responsabilidades):**

```csharp
// IUserRepository.cs
public interface IUserRepository
{
    Task<Usuario> ObtenerPorEmailAsync(string email);
    Task<bool> ExisteEmailAsync(string email);
    Task GuardarAsync(Usuario usuario);
    Task ActualizarAsync(Usuario usuario);
    Task EliminarAsync(int usuarioId);
}

// Usuario.cs - Entidad de dominio pura
public class Usuario
{
    public int Id { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; private set; }
    public DateTime FechaCreacion { get; set; }
    
    public void CambiarPassword(string nuevaPassword)
    {
        if (string.IsNullOrEmpty(nuevaPassword))
            throw new ArgumentException("Password no puede estar vacío");
            
        PasswordHash = BCrypt.Net.BCrypt.HashPassword(nuevaPassword);
    }
    
    public bool VerificarPassword(string password)
    {
        return BCrypt.Net.BCrypt.Verify(password, PasswordHash);
    }
}

// ServicioUsuarios.cs - Solo lógica de negocio
public class ServicioUsuarios
{
    private readonly IUserRepository _userRepository;
    
    public ServicioUsuarios(IUserRepository userRepository)
    {
        _userRepository = userRepository; // inyección de dependencia
    }
    
    public async Task<bool> CrearUsuarioAsync(string email, string password)
    {
        // Solo validaciones de negocio
        if (string.IsNullOrEmpty(email) || !email.Contains("@"))
            return false;
            
        // Repository maneja la persistencia
        if (await _userRepository.ExisteEmailAsync(email))
            return false;
            
        var usuario = new Usuario 
        { 
            Email = email, 
            FechaCreacion = DateTime.UtcNow 
        };
        usuario.CambiarPassword(password); // lógica en la entidad
        
        await _userRepository.GuardarAsync(usuario);
        return true;
    }
}
```

**Qué mejora:** separación clara, testabilidad total, flexibilidad de persistencia, código más limpio.

### 1.3 Ventajas del patrón Repository

* **Testabilidad**: mockear repository para tests rápidos
* **Flexibilidad**: cambiar de SQL a NoSQL sin tocar lógica de negocio  
* **Mantenibilidad**: consultas centralizadas en un lugar
* **Reutilización**: mismo repository para múltiples servicios

---

## Módulo 2 — Repository básico: Abstracción e implementación

> Objetivo: **encapsular la lógica de acceso a datos** y proporcionar una **interfaz orientada a objetos** para el dominio.

### 2.1 Estructura básica del Repository

```csharp
// Entidad de dominio
public class Producto
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    public decimal Precio { get; set; }
    public string Categoria { get; set; }
    public bool EstaActivo { get; set; }
    
    public void Activar() => EstaActivo = true;
    public void Desactivar() => EstaActivo = false;
    
    public void ActualizarPrecio(decimal nuevoPrecio)
    {
        if (nuevoPrecio <= 0)
            throw new ArgumentException("Precio debe ser mayor a cero");
        Precio = nuevoPrecio;
    }
}

// Interfaz del repository
public interface IProductoRepository
{
    // Métodos básicos CRUD
    Task<Producto> ObtenerPorIdAsync(int id);
    Task<IEnumerable<Producto>> ObtenerTodosAsync();
    Task GuardarAsync(Producto producto);
    Task ActualizarAsync(Producto producto);  
    Task EliminarAsync(int id);
    
    // Consultas específicas del dominio
    Task<IEnumerable<Producto>> ObtenerPorCategoriaAsync(string categoria);
    Task<IEnumerable<Producto>> ObtenerActivosAsync();
    Task<bool> ExisteNombreAsync(string nombre);
}
```

### 2.2 Implementación con Entity Framework

```csharp
// ProductoRepository.cs - Implementación concreta
public class ProductoRepository : IProductoRepository
{
    private readonly ApplicationDbContext _context;
    
    public ProductoRepository(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task<Producto> ObtenerPorIdAsync(int id)
    {
        return await _context.Productos.FindAsync(id);
    }
    
    public async Task<IEnumerable<Producto>> ObtenerTodosAsync()
    {
        return await _context.Productos.ToListAsync();
    }
    
    public async Task GuardarAsync(Producto producto)
    {
        _context.Productos.Add(producto);
        await _context.SaveChangesAsync();
    }
    
    public async Task ActualizarAsync(Producto producto)
    {
        _context.Productos.Update(producto);
        await _context.SaveChangesAsync();
    }
    
    public async Task EliminarAsync(int id)
    {
        var producto = await ObtenerPorIdAsync(id);
        if (producto != null)
        {
            _context.Productos.Remove(producto);
            await _context.SaveChangesAsync();
        }
    }
    
    // Consultas específicas del dominio
    public async Task<IEnumerable<Producto>> ObtenerPorCategoriaAsync(string categoria)
    {
        return await _context.Productos
            .Where(p => p.Categoria == categoria)
            .ToListAsync();
    }
    
    public async Task<IEnumerable<Producto>> ObtenerActivosAsync()
    {
        return await _context.Productos
            .Where(p => p.EstaActivo)
            .ToListAsync();
    }
    
    public async Task<bool> ExisteNombreAsync(string nombre)
    {
        return await _context.Productos
            .AnyAsync(p => p.Nombre == nombre);
    }
}
```

### 2.3 Ejercicio guiado (20 min)

> Objetivo: implementar repository para entidad Pedido con relaciones.

1. **Crear la entidad con relaciones:**

```csharp
public class Pedido
{
    public int Id { get; set; }
    public DateTime Fecha { get; set; }
    public int ClienteId { get; set; }
    public EstadoPedido Estado { get; set; }
    public List<DetallePedido> Detalles { get; set; } = new();
    
    public decimal CalcularTotal() => Detalles.Sum(d => d.Subtotal);
    
    public void AgregarDetalle(int productoId, int cantidad, decimal precioUnitario)
    {
        var detalle = new DetallePedido 
        { 
            ProductoId = productoId, 
            Cantidad = cantidad, 
            PrecioUnitario = precioUnitario 
        };
        Detalles.Add(detalle);
    }
}

public class DetallePedido
{
    public int Id { get; set; }
    public int PedidoId { get; set; }
    public int ProductoId { get; set; }
    public int Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    
    public decimal Subtotal => Cantidad * PrecioUnitario;
}

public enum EstadoPedido
{
    Pendiente, Procesando, Enviado, Entregado, Cancelado
}
```

2. **Definir interfaz del repository:**

```csharp
public interface IPedidoRepository
{
    Task<Pedido> ObtenerPorIdAsync(int id);
    Task<IEnumerable<Pedido>> ObtenerPorClienteAsync(int clienteId);
    Task<IEnumerable<Pedido>> ObtenerPorEstadoAsync(EstadoPedido estado);
    Task GuardarAsync(Pedido pedido);
    Task ActualizarAsync(Pedido pedido);
    
    // TODO: Implementar métodos específicos del dominio
}
```

3. **Implementar repository con Include para relaciones:**

```csharp
public class PedidoRepository : IPedidoRepository
{
    private readonly ApplicationDbContext _context;
    
    public PedidoRepository(ApplicationDbContext context)
    {
        _context = context;
    }
    
    public async Task<Pedido> ObtenerPorIdAsync(int id)
    {
        return await _context.Pedidos
            .Include(p => p.Detalles) // incluir detalles
            .FirstOrDefaultAsync(p => p.Id == id);
    }
    
    // TODO: Implementar resto de métodos
}
```

**Criterio de éxito:** consultas incluyen relaciones correctamente y mantienen entidades consistentes.

---

## Módulo 3 — Unit of Work: Transacciones y consistencia

> Objetivo: **mantener consistencia transaccional** al trabajar con múltiples repositories y **coordinar cambios** en múltiples entidades.

### 3.1 El problema sin Unit of Work

```csharp
// ❌ PROBLEMÁTICO: No hay garantía de consistencia transaccional
public class ServicioPedidos
{
    private readonly IPedidoRepository _pedidoRepository;
    private readonly IProductoRepository _productoRepository;
    private readonly IClienteRepository _clienteRepository;
    
    public async Task ProcesarPedidoAsync(int pedidoId)
    {
        var pedido = await _pedidoRepository.ObtenerPorIdAsync(pedidoId);
        
        // ¡Cada repository hace su propio SaveChanges!
        // Si uno falla después del otro, queda inconsistente
        await _pedidoRepository.ActualizarAsync(pedido); // SaveChanges 1
        
        // Actualizar stock de productos
        foreach (var detalle in pedido.Detalles)
        {
            var producto = await _productoRepository.ObtenerPorIdAsync(detalle.ProductoId);
            // ¿Qué pasa si esto falla? El pedido ya se guardó arriba
            await _productoRepository.ActualizarAsync(producto); // SaveChanges 2
        }
        
        // Actualizar cliente
        var cliente = await _clienteRepository.ObtenerPorIdAsync(pedido.ClienteId);
        await _clienteRepository.ActualizarAsync(cliente); // SaveChanges 3
        
        // ¡PROBLEMA! Si cualquier paso 2 o 3 falla, 
        // los anteriores ya se guardaron → INCONSISTENCIA
    }
}
```

### 3.2 Unit of Work pattern

```csharp
// IUnitOfWork.cs
public interface IUnitOfWork : IDisposable
{
    // Repositories administrados por el UoW
    IProductoRepository Productos { get; }
    IPedidoRepository Pedidos { get; }
    IClienteRepository Clientes { get; }
    
    // Control transaccional
    Task<int> GuardarCambiosAsync();
    Task IniciarTransaccionAsync();
    Task ConfirmarTransaccionAsync();  
    Task RollbackTransaccionAsync();
}

// UnitOfWork.cs - Implementación con Entity Framework
public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction _transaction;
    
    // Lazy loading de repositories
    private IProductoRepository _productos;
    private IPedidoRepository _pedidos;
    private IClienteRepository _clientes;
    
    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }
    
    // Properties que crean repositories bajo demanda
    public IProductoRepository Productos => 
        _productos ??= new ProductoRepository(_context);
        
    public IPedidoRepository Pedidos => 
        _pedidos ??= new PedidoRepository(_context);
        
    public IClienteRepository Clientes => 
        _clientes ??= new ClienteRepository(_context);
    
    public async Task<int> GuardarCambiosAsync()
    {
        return await _context.SaveChangesAsync();
    }
    
    public async Task IniciarTransaccionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }
    
    public async Task ConfirmarTransaccionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public async Task RollbackTransaccionAsync()
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync();
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public void Dispose()
    {
        _transaction?.Dispose();
        _context?.Dispose();
    }
}
```

### 3.3 Uso del Unit of Work

```csharp
// ✅ CON Unit of Work: Consistencia transaccional garantizada
public class ServicioPedidos
{
    private readonly IUnitOfWork _unitOfWork;
    
    public ServicioPedidos(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }
    
    public async Task<bool> ProcesarPedidoAsync(int pedidoId)
    {
        try
        {
            await _unitOfWork.IniciarTransaccionAsync();
            
            // Todos los repositories comparten la misma transacción
            var pedido = await _unitOfWork.Pedidos.ObtenerPorIdAsync(pedidoId);
            if (pedido == null) return false;
            
            pedido.Estado = EstadoPedido.Procesando;
            
            // Actualizar stock de productos
            foreach (var detalle in pedido.Detalles)
            {
                var producto = await _unitOfWork.Productos.ObtenerPorIdAsync(detalle.ProductoId);
                // Lógica para reducir stock...
                await _unitOfWork.Productos.ActualizarAsync(producto);
            }
            
            // Actualizar cliente
            var cliente = await _unitOfWork.Clientes.ObtenerPorIdAsync(pedido.ClienteId);
            // Lógica para actualizar cliente...
            await _unitOfWork.Clientes.ActualizarAsync(cliente);
            
            // TODO: Una sola operación de guardado - todo o nada
            await _unitOfWork.GuardarCambiosAsync();
            await _unitOfWork.ConfirmarTransaccionAsync();
            
            return true;
        }
        catch (Exception)
        {
            await _unitOfWork.RollbackTransaccionAsync();
            throw; // re-propagar para manejo superior
        }
    }
}
```

---

## Módulo 4 — Testing con mocks: Independencia de infraestructura

> Objetivo: **testear lógica de negocio** sin depender de bases de datos, usando **mocks** para simular repositories.

### 4.1 Testing sin Repository (problemático)

```csharp
// ❌ Test que depende de base de datos - LENTO y FRÁGIL
[TestClass]
public class ServicioUsuariosTests_Malo
{
    [Fact]
    public async Task CrearUsuario_EmailDuplicado_RetornaFalse()
    {
        // Arrange - ¡REQUIERE BASE DE DATOS REAL!
        var connectionString = "Server=localhost;Database=TestDB;";
        var servicio = new ServicioUsuarios(connectionString);
        
        // Pre-condición: insertar usuario existente
        await EjecutarSQL("INSERT INTO Usuarios (Email) VALUES ('test@test.com')");
        
        // Act  
        bool resultado = await servicio.CrearUsuario("test@test.com", "password");
        
        // Assert
        Assert.False(resultado);
        
        // Cleanup - ¡LIMPIAR BASE DE DATOS!
        await EjecutarSQL("DELETE FROM Usuarios WHERE Email = 'test@test.com'");
    }
    
    // Problemas:
    // 1. LENTO: cada test requiere DB
    // 2. FRÁGIL: dependiente de estado de DB
    // 3. COMPLEJO: setup/cleanup complicado
    // 4. NO PORTABLE: requiere DB específica
}
```

### 4.2 Testing con Repository y mocks (profesional)

```csharp
// ✅ Test rápido, confiable, independiente
[TestClass]
public class ServicioUsuariosTests_Bueno
{
    [Fact]
    public async Task CrearUsuario_EmailDuplicado_RetornaFalse()
    {
        // Arrange - Mock del repository (SIN base de datos)
        var mockRepository = new Mock<IUserRepository>();
        mockRepository.Setup(r => r.ExisteEmailAsync("test@test.com"))
                     .ReturnsAsync(true); // simular que existe
        
        var servicio = new ServicioUsuarios(mockRepository.Object);
        
        // Act
        bool resultado = await servicio.CrearUsuario("test@test.com", "password");
        
        // Assert
        Assert.False(resultado);
        
        // Verificar que NO se intentó guardar
        mockRepository.Verify(r => r.GuardarAsync(It.IsAny<Usuario>()), Times.Never);
    }
    
    [Fact]
    public async Task CrearUsuario_EmailNuevo_GuardaUsuario()
    {
        // Arrange
        var mockRepository = new Mock<IUserRepository>();
        mockRepository.Setup(r => r.ExisteEmailAsync("nuevo@test.com"))
                     .ReturnsAsync(false); // simular que NO existe
        
        Usuario usuarioGuardado = null;
        mockRepository.Setup(r => r.GuardarAsync(It.IsAny<Usuario>()))
                     .Callback<Usuario>(u => usuarioGuardado = u)
                     .Returns(Task.CompletedTask);
        
        var servicio = new ServicioUsuarios(mockRepository.Object);
        
        // Act
        bool resultado = await servicio.CrearUsuario("nuevo@test.com", "password123");
        
        // Assert
        Assert.True(resultado);
        Assert.NotNull(usuarioGuardado);
        Assert.Equal("nuevo@test.com", usuarioGuardado.Email);
        Assert.True(usuarioGuardado.VerificarPassword("password123"));
        
        // Verificar interacciones exactas
        mockRepository.Verify(r => r.ExisteEmailAsync("nuevo@test.com"), Times.Once);
        mockRepository.Verify(r => r.GuardarAsync(It.IsAny<Usuario>()), Times.Once);
    }
}
```

### 4.3 Testing de Unit of Work

```csharp
[TestClass]
public class ServicioPedidosTests
{
    [Fact]
    public async Task ProcesarPedido_TodoExitoso_ConfirmaTransaccion()
    {
        // Arrange
        var mockUnitOfWork = new Mock<IUnitOfWork>();
        var mockPedidoRepo = new Mock<IPedidoRepository>();
        var mockProductoRepo = new Mock<IProductoRepository>();
        
        // Setup UnitOfWork para retornar mocks de repositories
        mockUnitOfWork.Setup(u => u.Pedidos).Returns(mockPedidoRepo.Object);
        mockUnitOfWork.Setup(u => u.Productos).Returns(mockProductoRepo.Object);
        
        // Setup datos de prueba
        var pedido = new Pedido { Id = 1, Estado = EstadoPedido.Pendiente };
        pedido.AgregarDetalle(1, 2, 10.0m);
        
        mockPedidoRepo.Setup(r => r.ObtenerPorIdAsync(1))
                     .ReturnsAsync(pedido);
        
        var producto = new Producto { Id = 1, Nombre = "Test" };
        mockProductoRepo.Setup(r => r.ObtenerPorIdAsync(1))
                       .ReturnsAsync(producto);
        
        var servicio = new ServicioPedidos(mockUnitOfWork.Object);
        
        // Act
        bool resultado = await servicio.ProcesarPedidoAsync(1);
        
        // Assert
        Assert.True(resultado);
        
        // Verificar flujo transaccional correcto
        mockUnitOfWork.Verify(u => u.IniciarTransaccionAsync(), Times.Once);
        mockUnitOfWork.Verify(u => u.GuardarCambiosAsync(), Times.Once);
        mockUnitOfWork.Verify(u => u.ConfirmarTransaccionAsync(), Times.Once);
        mockUnitOfWork.Verify(u => u.RollbackTransaccionAsync(), Times.Never);
    }
    
    [Fact]
    public async Task ProcesarPedido_ErrorEnProceso_HaceRollback()
    {
        // Arrange
        var mockUnitOfWork = new Mock<IUnitOfWork>();
        var mockPedidoRepo = new Mock<IPedidoRepository>();
        
        mockUnitOfWork.Setup(u => u.Pedidos).Returns(mockPedidoRepo.Object);
        
        // Simular error en GuardarCambiosAsync
        mockUnitOfWork.Setup(u => u.GuardarCambiosAsync())
                     .ThrowsAsync(new InvalidOperationException("DB Error"));
        
        mockPedidoRepo.Setup(r => r.ObtenerPorIdAsync(1))
                     .ReturnsAsync(new Pedido { Id = 1 });
        
        var servicio = new ServicioPedidos(mockUnitOfWork.Object);
        
        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => servicio.ProcesarPedidoAsync(1));
        
        // Verificar que se hizo rollback
        mockUnitOfWork.Verify(u => u.RollbackTransaccionAsync(), Times.Once);
        mockUnitOfWork.Verify(u => u.ConfirmarTransaccionAsync(), Times.Never);
    }
}
```

---

## Módulo 5 — Ejercicios progresivos: Sistema de gestión de pedidos

> **Meta general:** construir un sistema completo de gestión de pedidos que integre **Repository**, **Unit of Work** y **testing** con mocks.

### 5.1 Contexto: E-commerce con inventario

**Elementos fundamentales:**

* **Entidades**: Cliente, Producto, Pedido, DetallePedido, Categoria
* **Repositories**: abstracción para cada entidad con consultas específicas  
* **Unit of Work**: coordinar transacciones entre múltiples repositories
* **Servicios**: lógica de negocio usando repositories mediante UoW
* **Testing**: cobertura completa con mocks, sin dependencias externas

### 5.2 Ejercicio 1 — Repositories con consultas complejas

**Objetivo:** implementar repositories con consultas específicas del dominio usando LINQ.

**Metodología TDD:**

1. **Escribir tests primero** para verificar:
   * Consultas retornan resultados esperados
   * Filtros funcionan correctamente
   * Relaciones se cargan apropiadamente
   * Operaciones CRUD mantienen consistencia

```csharp
// Ejemplo de tests para ProductoRepository
[TestClass]
public class ProductoRepositoryTests
{
    [Fact]
    public async Task ObtenerPorCategoriaAsync_CategoriaExistente_RetornaProductos()
    {
        // Arrange - Mock del DbContext y DbSet
        var productos = new List<Producto>
        {
            new Producto { Id = 1, Nombre = "Laptop", Categoria = "Electrónicos" },
            new Producto { Id = 2, Nombre = "Mouse", Categoria = "Electrónicos" },
            new Producto { Id = 3, Nombre = "Mesa", Categoria = "Muebles" }
        }.AsQueryable();
        
        var mockSet = new Mock<DbSet<Producto>>();
        mockSet.As<IQueryable<Producto>>().Setup(m => m.Provider).Returns(productos.Provider);
        mockSet.As<IQueryable<Producto>>().Setup(m => m.Expression).Returns(productos.Expression);
        mockSet.As<IQueryable<Producto>>().Setup(m => m.ElementType).Returns(productos.ElementType);
        mockSet.As<IQueryable<Producto>>().Setup(m => m.GetEnumerator()).Returns(productos.GetEnumerator());
        
        var mockContext = new Mock<ApplicationDbContext>();
        mockContext.Setup(c => c.Productos).Returns(mockSet.Object);
        
        var repository = new ProductoRepository(mockContext.Object);
        
        // Act
        var resultado = await repository.ObtenerPorCategoriaAsync("Electrónicos");
        
        // Assert
        Assert.Equal(2, resultado.Count());
        Assert.All(resultado, p => Assert.Equal("Electrónicos", p.Categoria));
    }
}
```

2. **Implementar** repositories después de tener tests verdes

### 5.3 Ejercicio 2 — Servicios con Unit of Work

**Objetivo:** implementar servicio de pedidos que coordine múltiples repositories usando transacciones.

```csharp
// ServicioPedidos.cs - Lógica de negocio completa
public class ServicioPedidos
{
    private readonly IUnitOfWork _unitOfWork;
    
    public ServicioPedidos(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }
    
    public async Task<ResultadoOperacion> CrearPedidoAsync(CrearPedidoRequest request)
    {
        try
        {
            await _unitOfWork.IniciarTransaccionAsync();
            
            // Validar cliente existe
            var cliente = await _unitOfWork.Clientes.ObtenerPorIdAsync(request.ClienteId);
            if (cliente == null)
                return ResultadoOperacion.Error("Cliente no existe");
            
            // Crear pedido
            var pedido = new Pedido
            {
                ClienteId = request.ClienteId,
                Fecha = DateTime.UtcNow,
                Estado = EstadoPedido.Pendiente
            };
            
            // Procesar cada detalle
            foreach (var detalleRequest in request.Detalles)
            {
                var producto = await _unitOfWork.Productos.ObtenerPorIdAsync(detalleRequest.ProductoId);
                if (producto == null)
                    return ResultadoOperacion.Error($"Producto {detalleRequest.ProductoId} no existe");
                
                if (!producto.EstaActivo)
                    return ResultadoOperacion.Error($"Producto {producto.Nombre} no está disponible");
                
                // Verificar stock disponible
                if (producto.Stock < detalleRequest.Cantidad)
                    return ResultadoOperacion.Error($"Stock insuficiente para {producto.Nombre}");
                
                // Reducir stock
                producto.ReducirStock(detalleRequest.Cantidad);
                await _unitOfWork.Productos.ActualizarAsync(producto);
                
                // Agregar detalle al pedido
                pedido.AgregarDetalle(producto.Id, detalleRequest.Cantidad, producto.Precio);
            }
            
            // Guardar pedido
            await _unitOfWork.Pedidos.GuardarAsync(pedido);
            
            // Confirmar toda la transacción
            await _unitOfWork.GuardarCambiosAsync();
            await _unitOfWork.ConfirmarTransaccionAsync();
            
            return ResultadoOperacion.Exito(pedido.Id);
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransaccionAsync();
            return ResultadoOperacion.Error($"Error procesando pedido: {ex.Message}");
        }
    }
}

// DTOs para las operaciones
public class CrearPedidoRequest
{
    public int ClienteId { get; set; }
    public List<DetallePedidoRequest> Detalles { get; set; } = new();
}

public class DetallePedidoRequest
{
    public int ProductoId { get; set; }
    public int Cantidad { get; set; }
}

public class ResultadoOperacion
{
    public bool EsExitoso { get; set; }
    public string MensajeError { get; set; }
    public object Resultado { get; set; }
    
    public static ResultadoOperacion Exito(object resultado = null)
        => new() { EsExitoso = true, Resultado = resultado };
        
    public static ResultadoOperacion Error(string mensaje)
        => new() { EsExitoso = false, MensajeError = mensaje };
}
```

### 5.4 Ejercicio 3 — Testing integral con escenarios complejos

**Objetivo:** crear test suite completa que verifique todos los flujos de negocio.

```csharp
[TestClass]
public class ServicioPedidosIntegracionTests
{
    private Mock<IUnitOfWork> _mockUnitOfWork;
    private Mock<IPedidoRepository> _mockPedidoRepo;
    private Mock<IProductoRepository> _mockProductoRepo;  
    private Mock<IClienteRepository> _mockClienteRepo;
    private ServicioPedidos _servicio;
    
    [TestInitialize]
    public void Setup()
    {
        _mockUnitOfWork = new Mock<IUnitOfWork>();
        _mockPedidoRepo = new Mock<IPedidoRepository>();
        _mockProductoRepo = new Mock<IProductoRepository>();
        _mockClienteRepo = new Mock<IClienteRepository>();
        
        _mockUnitOfWork.Setup(u => u.Pedidos).Returns(_mockPedidoRepo.Object);
        _mockUnitOfWork.Setup(u => u.Productos).Returns(_mockProductoRepo.Object);
        _mockUnitOfWork.Setup(u => u.Clientes).Returns(_mockClienteRepo.Object);
        
        _servicio = new ServicioPedidos(_mockUnitOfWork.Object);
    }
    
    [Fact]
    public async Task CrearPedido_ClienteNoExiste_RetornaError()
    {
        // Arrange
        _mockClienteRepo.Setup(r => r.ObtenerPorIdAsync(1))
                       .ReturnsAsync((Cliente)null);
        
        var request = new CrearPedidoRequest { ClienteId = 1 };
        
        // Act
        var resultado = await _servicio.CrearPedidoAsync(request);
        
        // Assert
        Assert.False(resultado.EsExitoso);
        Assert.Contains("Cliente no existe", resultado.MensajeError);
        
        // Verificar que no se guardó nada
        _mockPedidoRepo.Verify(r => r.GuardarAsync(It.IsAny<Pedido>()), Times.Never);
        _mockUnitOfWork.Verify(u => u.ConfirmarTransaccionAsync(), Times.Never);
    }
    
    [Fact]  
    public async Task CrearPedido_StockInsuficiente_HaceRollback()
    {
        // Arrange - cliente válido
        _mockClienteRepo.Setup(r => r.ObtenerPorIdAsync(1))
                       .ReturnsAsync(new Cliente { Id = 1, Nombre = "Test" });
        
        // Producto con stock insuficiente
        var producto = new Producto { Id = 1, Nombre = "Test", Stock = 5, EstaActivo = true };
        _mockProductoRepo.Setup(r => r.ObtenerPorIdAsync(1))
                        .ReturnsAsync(producto);
        
        var request = new CrearPedidoRequest 
        { 
            ClienteId = 1,
            Detalles = new List<DetallePedidoRequest>
            {
                new() { ProductoId = 1, Cantidad = 10 } // Más de lo disponible
            }
        };
        
        // Act
        var resultado = await _servicio.CrearPedidoAsync(request);
        
        // Assert
        Assert.False(resultado.EsExitoso);
        Assert.Contains("Stock insuficiente", resultado.MensajeError);
        
        // Verificar rollback
        _mockUnitOfWork.Verify(u => u.RollbackTransaccionAsync(), Times.Once);
        _mockUnitOfWork.Verify(u => u.ConfirmarTransaccionAsync(), Times.Never);
    }
    
    [Fact]
    public async Task CrearPedido_TodoValido_CreaCorrectamente()
    {
        // Arrange - setup completo para caso exitoso
        var cliente = new Cliente { Id = 1, Nombre = "Test Cliente" };
        _mockClienteRepo.Setup(r => r.ObtenerPorIdAsync(1)).ReturnsAsync(cliente);
        
        var producto1 = new Producto { Id = 1, Nombre = "Producto 1", Stock = 10, Precio = 15.0m, EstaActivo = true };
        var producto2 = new Producto { Id = 2, Nombre = "Producto 2", Stock = 5, Precio = 25.0m, EstaActivo = true };
        
        _mockProductoRepo.Setup(r => r.ObtenerPorIdAsync(1)).ReturnsAsync(producto1);
        _mockProductoRepo.Setup(r => r.ObtenerPorIdAsync(2)).ReturnsAsync(producto2);
        
        Pedido pedidoGuardado = null;
        _mockPedidoRepo.Setup(r => r.GuardarAsync(It.IsAny<Pedido>()))
                      .Callback<Pedido>(p => pedidoGuardado = p)
                      .Returns(Task.CompletedTask);
        
        var request = new CrearPedidoRequest
        {
            ClienteId = 1,
            Detalles = new List<DetallePedidoRequest>
            {
                new() { ProductoId = 1, Cantidad = 2 },
                new() { ProductoId = 2, Cantidad = 1 }
            }
        };
        
        // Act
        var resultado = await _servicio.CrearPedidoAsync(request);
        
        // Assert
        Assert.True(resultado.EsExitoso);
        Assert.NotNull(pedidoGuardado);
        Assert.Equal(2, pedidoGuardado.Detalles.Count);
        Assert.Equal(65.0m, pedidoGuardado.CalcularTotal()); // (2*15) + (1*25)
        
        // Verificar que se redujo stock
        Assert.Equal(8, producto1.Stock); // 10 - 2
        Assert.Equal(4, producto2.Stock); // 5 - 1
        
        // Verificar flujo transaccional
        _mockUnitOfWork.Verify(u => u.IniciarTransaccionAsync(), Times.Once);
        _mockUnitOfWork.Verify(u => u.GuardarCambiosAsync(), Times.Once);
        _mockUnitOfWork.Verify(u => u.ConfirmarTransaccionAsync(), Times.Once);
        _mockProductoRepo.Verify(r => r.ActualizarAsync(It.IsAny<Producto>()), Times.Exactly(2));
    }
}
```

---

## Recursos para persistencia y testing

### Frameworks y librerías relacionadas

* **Entity Framework Core**: ORM principal para .NET con soporte completo para Repository/UoW
* **Dapper**: Micro-ORM para consultas SQL directas con mejor performance  
* **MediatR**: Patrón mediator que funciona bien con repositories
* **AutoMapper**: Mapping entre entidades de dominio y DTOs

### Testing de repositories

```bash
# Paquetes para testing de persistencia
dotnet add package Microsoft.EntityFrameworkCore.InMemory    # DB en memoria para tests
dotnet add package Moq                                       # Mocking framework
dotnet add package FluentAssertions                         # Assertions expresivos
dotnet add package Microsoft.Extensions.DependencyInjection # IoC container
```

### Configuración de dependency injection

```csharp
// Program.cs - Registro de servicios
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Registro de repositories y UoW
builder.Services.AddScoped<IProductoRepository, ProductoRepository>();
builder.Services.AddScoped<IPedidoRepository, PedidoRepository>();
builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// Registro de servicios de dominio
builder.Services.AddScoped<ServicioPedidos>();
builder.Services.AddScoped<ServicioUsuarios>();
```

---

## Mejores prácticas de Repository pattern

### Diseño de interfaces

* **Específicas del dominio**: métodos que reflejen el lenguaje del negocio
* **Async por defecto**: todas las operaciones de I/O deben ser asíncronas
* **Retornar entidades**: no DTOs ni tipos primitivos
* **Consultas expresivas**: usar nombres descriptivos como `ObtenerActivosPorCategoria`

### Implementación

```csharp
// ✅ Buenas prácticas en implementación
public class ProductoRepository : IProductoRepository
{
    private readonly ApplicationDbContext _context;
    
    public ProductoRepository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }
    
    public async Task<IEnumerable<Producto>> ObtenerDestacadosPorCategoriaAsync(string categoria, int limite)
    {
        return await _context.Productos
            .Where(p => p.Categoria == categoria && p.EstaActivo && p.EsDestacado)
            .OrderByDescending(p => p.Puntuacion)
            .Take(limite)
            .AsNoTracking() // Optimización para queries read-only
            .ToListAsync();
    }
    
    public async Task<bool> TieneStockSuficienteAsync(int productoId, int cantidadRequerida)
    {
        var stockActual = await _context.Productos
            .Where(p => p.Id == productoId)
            .Select(p => p.Stock)
            .FirstOrDefaultAsync();
            
        return stockActual >= cantidadRequerida;
    }
}
```

### Testing avanzado

```csharp
// ✅ Test con InMemory database para casos complejos
[TestClass]
public class ProductoRepositoryIntegrationTests
{
    private ApplicationDbContext GetInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
            
        var context = new ApplicationDbContext(options);
        
        // Seed data
        context.Productos.AddRange(
            new Producto { Id = 1, Nombre = "Laptop", Categoria = "Tech", EsDestacado = true, Puntuacion = 4.5m },
            new Producto { Id = 2, Nombre = "Mouse", Categoria = "Tech", EsDestacado = false, Puntuacion = 4.0m }
        );
        context.SaveChanges();
        
        return context;
    }
    
    [Fact]
    public async Task ObtenerDestacadosPorCategoria_ConDatos_RetornaOrdenadosPorPuntuacion()
    {
        // Arrange
        using var context = GetInMemoryContext();
        var repository = new ProductoRepository(context);
        
        // Act
        var destacados = await repository.ObtenerDestacadosPorCategoriaAsync("Tech", 5);
        
        // Assert
        var listaDestacados = destacados.ToList();
        Assert.Single(listaDestacados); // Solo hay uno destacado
        Assert.Equal("Laptop", listaDestacados[0].Nombre);
    }
}
```

---

## Glosario de términos de persistencia

* **Repository Pattern**: patrón que encapsula lógica de acceso a datos y proporciona API orientada a objetos.
* **Unit of Work**: patrón que mantiene lista de objetos afectados por transacción y coordina cambios.
* **Entity**: objeto de dominio que tiene identidad y ciclo de vida.
* **Value Object**: objeto inmutable que se define por sus valores, no por identidad.
* **Aggregate**: grupo de entidades y value objects tratados como unidad para cambios de datos.
* **Domain Model**: modelo de objetos del dominio que incorpora comportamiento y datos.
* **Data Transfer Object (DTO)**: objeto que transporta datos entre procesos para reducir llamadas remotas.
* **Object-Relational Mapping (ORM)**: técnica para convertir datos entre sistemas incompatibles usando lenguajes OO.
* **Lazy Loading**: patrón donde datos se cargan bajo demanda la primera vez que se acceden.
* **Eager Loading**: patrón donde datos relacionados se cargan explícitamente en la consulta inicial.

---

## Anexo 1 — Ejercicio Completo: Sistema de biblioteca

**Instrucciones:**

1. Implementar entidades para sistema de biblioteca: Libro, Autor, Usuario, Prestamo.
2. Crear repositories con consultas específicas del dominio:
   * Libros disponibles por categoría
   * Préstamos vencidos por usuario  
   * Autores con más de X libros publicados

3. Desarrollar Unit of Work que coordine:
   * Crear préstamo: verificar disponibilidad, actualizar stock, registrar préstamo
   * Devolver libro: actualizar estado, calcular multas si aplica

4. Implementar servicios de dominio:
   * ServicioPrestamos: maneja lógica de préstamos y devoluciones
   * ServicioMultas: calcula penalizaciones por retraso

5. Testing comprehensivo:
   * Tests unitarios para cada repository con mocks
   * Tests de integración usando InMemory database
   * Tests de servicios con scenarios complejos

> Criterio de éxito: sistema funcional con cobertura de tests 90%+, sin queries N+1, transacciones correctas.

---

## Anexo 2 — Ejercicio Completo: E-commerce con inventario avanzado

**Instrucciones:**

1. **Diseñar modelo de dominio complejo:**
   * Producto, Categoria, Proveedor, Cliente, Pedido, DetallePedido
   * Carrito de compras como aggregate separado
   * Inventario con movimientos y trazabilidad

2. **Implementar repositories especializados:**
   * Consultas de reportes: ventas por período, productos más vendidos
   * Búsqueda avanzada: filtros múltiples, ordenamiento, paginación
   * Operaciones batch: actualización masiva de precios

3. **Desarrollar Unit of Work con transacciones complejas:**
   * Procesamiento de pedido: inventario, facturación, envío
   * Cancelación de pedido: rollback de stock, reembolsos
   * Transferencia entre almacenes

4. **Crear servicios de dominio robustos:**
   * ServicioPedidos: workflow completo de pedidos
   * ServicioInventario: gestión de stock y movimientos
   * ServicioReportes: analytics y métricas de negocio

5. **Testing de performance y concurrencia:**
   * Tests de carga con múltiples usuarios concurrentes
   * Verificación de deadlocks en transacciones
   * Benchmarks de queries complejas

6. **Estructura de proyecto avanzada:**
   * Proyecto Core: entidades, interfaces, servicios de dominio
   * Proyecto Infrastructure: repositories, Unit of Work, DbContext  
   * Proyecto Tests: unitarios, integración, performance
   * Proyecto API: controladores que consumen servicios

**Entregables:**
* Repositorio con arquitectura limpia implementada
* Documentación de patrones utilizados
* Suite de tests con diferentes tipos de verificación
* Demostración de escenarios complejos funcionando
* Análisis de performance con métricas

---

## Cierre

* **Abstracción**: Repository pattern separa lógica de negocio de persistencia completamente
* **Consistencia**: Unit of Work garantiza integridad transaccional en operaciones complejas  
* **Testabilidad**: mocks permiten testing rápido y confiable sin infraestructura externa
* **Próximo paso**: combinar con patrón Strategy para algoritmos de negocio intercambiables

### Transformación lograda

**❌ Enfoque anterior (problemático):**
```csharp
// Servicio acoplado directamente a SQL
using var connection = new SqlConnection(connectionString);
var command = new SqlCommand("SELECT * FROM Users WHERE Email = @email", connection);
// Testing requiere base de datos real, lento y frágil
```

**✅ Enfoque profesional (desacoplado):**
```csharp
// Servicio usa abstracción, testeable con mocks
var usuario = await _userRepository.ObtenerPorEmailAsync(email);
// Testing rápido con mocks, sin dependencias externas
```

### Beneficios del cambio

- **Testabilidad**: tests rápidos, confiables, independientes de infraestructura
- **Flexibilidad**: cambiar tecnología de persistencia sin afectar lógica de negocio
- **Mantenibilidad**: consultas centralizadas, código más limpio y organizado  
- **Escalabilidad**: Unit of Work maneja transacciones complejas correctamente

### Para recordar

> **"Nunca accedas a datos directamente desde servicios; usa repositories para mantener tu código testeable y flexible"**

El patrón Repository es esencial para arquitecturas profesionales, especialmente cuando se combina con Unit of Work para garantizar consistencia transaccional y con mocking para testing efectivo.
