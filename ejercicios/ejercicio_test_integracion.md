# Ejercicio: Testing con Mocks - Notificaciones

## Objetivo
Practicar mocking creando endpoints que usen el `SimpleService` y testear todos los caminos posibles.

## Tarea

### 1. Agregar métodos al SimpleService
Agregar estos métodos a `ISimpleService` y `SimpleService`:

```csharp
// En ISimpleService
bool EsFinDeSemana();
string ObtenerSaludo(string nombre);
int CalcularEdad(DateTime fechaNacimiento);
bool EsUsuarioPremium(string email);
```

### 2. Crear 4 endpoints en HomeController
- `GET /Home/FinDeSemana` - Muestra mensaje diferente si es fin de semana
- `GET /Home/Saludo?nombre=Juan` - Muestra saludo personalizado
- `GET /Home/Edad?fecha=1990-01-01` - Muestra si es mayor de edad
- `GET /Home/Premium?email=test@email.com` - Muestra si es usuario premium

### 3. Crear vistas correspondientes
Cada vista debe mostrar contenido diferente según el resultado del servicio:
- **Si es true**: Mensaje verde de éxito
- **Si es false**: Mensaje rojo de error
- **Para strings**: Mostrar el mensaje del servicio
- **Para números**: Mostrar el número calculado

### 4. Escribir tests completos
Para cada endpoint, crear tests que:
- **Mockeen el servicio** con diferentes valores
- **Verifiquen el HTML** que se muestra
- **Cubran todos los caminos** (true/false, diferentes strings, etc.)

## Ejemplo de test

```csharp
[Fact]
public async Task FinDeSemana_CuandoEsFinDeSemana_MuestraMensajeVerde()
{
    // Arrange
    var mockService = new Mock<ISimpleService>();
    mockService.Setup(x => x.EsFinDeSemana()).Returns(true);
    
    // Act & Assert
    // ... completar el test
}
```

## Criterios de éxito
- 4 endpoints funcionando
- 4 métodos en el servicio
- Mínimo 8 tests (2 por endpoint)
- Tests verifican HTML correcto
- Todos los tests pasan

## Segunda parte 

[] Crear un nuevo servicio `IServicioNotificacion` con métodos para enviar notificaciones por email y SMS. Implementar este servicio en una clase `ServicioNotificacion` que simule el envío de notificaciones (no es necesario enviar realmente). La interfaz puede estar en el mismo archivo.

[] Crear un nuevo endpoint en `HomeController` llamado `EnviarNotificacion` que reciba parámetros para el tipo de notificación (email o SMS) y el mensaje. Este endpoint debe usar el `IServicioNotificacion` para enviar la notificación. En la vista de este endpoint, mostrar un mensaje que diga por que medio se envió la notificación y el mensaje enviado. Ejemplo:
```
Mensaje recibido como parametro: 
"Hola, este es un mensaje de prueba".

Notificación enviada por Email.
```

[] Escribir tests para el nuevo endpoint `EnviarNotificacion` que mockeen el `IServicioNotificacion` y verifiquen que se llama al método correcto según el tipo de notificación. También verificar que la vista muestra el mensaje correcto indicando por qué medio se envió la notificación.