# Parcial 2 - Diseño Y Desarrollo de Aplicaciones.

2025-11-19

El parcial deberá codificarse en C# utilizando el repositorio base proporcionado. 

https://github.com/matismasters/Parcial2DDA

Deberán implementarse todas las funcionalidades solicitadas dentro del tiempo de la evaluación. 3 horas.

No se permite el uso de inteligencia artificial para la codificación durante la evaluación.

Al terminar la solución el alumno deberá subir el código a su repositorio personal en GitHub y enviar el enlace al correo del docente.

En caso de de necesitar googlear alguna duda puntual sobre sintaxis o uso de alguna librería, preguntar al profesor para que busque y copie en el pizarrón la sintaxis correcta. No Googlear sin permiso.

## Problema

Un supermercado ha instalado una balanza inteligente en la entrada del local. Cuando los clientes pisan en las baldozas de esta balanza, el dipositivo identifica su huella, mide su peso, y envía esta información a un servidor central aclarando si es una medición de "entrada" o "salida" en cada caso.

El servidor central contará con una API RESTful que es el objeto de este parcial. La API deberá recibir las mediciones, procesarlas y almacenarlas en una base de datos. Además, deberá permitir una serie de endpoints de reportes.

### Requisitos funcionales

1. **Recepción de datos**: La API debe exponer un endpoint, `/medicion` que reciba datos en formato JSON con la siguiente estructura:
   ```json
   {
     "huella": "cliente123",
     "peso": 70.5,
     "tipo": "entrada"
   }
   ```
   Donde:
   - `huella`: es una cadena de texto que representa la huella del cliente.
   - `peso`: es un número decimal que representa el peso del cliente en kg.
   - `tipo`: es una cadena de texto que indica si la medición es de "entrada" o "salida".

2. **Cálculo de tiempo en el local y diferencia de peso**: Al momento de recibir una medición de "salida", la API deberá buscar la última medición de "entrada" para la misma huella, y calcular:
   - El tiempo total que el cliente estuvo en el local.
   - La diferencia de peso entre la entrada y la salida.

3. **Borrado de mediciones completadas**: Cuando se logra encontrar una medición de "entrada" correspondiente a una "salida", ambas mediciones deberán ser eliminadas de la base de datos, ya que se consideran completadas.

4. **Reporte. Total de mediciones completadas**: La API debe exponer un endpoint, `/reportes/total` que permita consultar la cantidad total de mediciones completadas que se han procesado. La respuesta debe ser en formato JSON:
   ```json
   {
     "total_mediciones_completadas": 150
   }
   ```

5. **Reporte. Máxima diferencia de peso**: La API debe exponer un endpoint, `/reportes/maxima_diferencia_peso` que permita consultar la máxima diferencia de peso calculada para todas las huellas en toda la historia. La respuesta debe ser en formato JSON:
   ```json
   {
     "maxima_diferencia_peso": 75.3
   }
   ```

6. **Reporte. Máximo tiempo en el local**: La API debe exponer un endpoint, `/reportes/maximo_tiempo` que permita consultar el máximo tiempo que un cliente ha estado en el local. La respuesta debe ser en formato JSON:
   ```json
   {
     "maximo_tiempo": "3 horas, 15 minutos"
   }
   ```

### Notas adicionales

```
DateTime dt1 = DateTime.UtcNow;
// Simular 5 segundos después
DateTime dt2 = dt1.AddSeconds(5);

int ts1 = (int)((DateTimeOffset)dt1).ToUnixTimeSeconds();
int ts2 = (int)((DateTimeOffset)dt2).ToUnixTimeSeconds();

int diferencia = ts2 - ts1;

Console.WriteLine($"TS1: {ts1}");
Console.WriteLine($"TS2: {ts2}");
Console.WriteLine($"Diferencia de segundos: {diferencia}");
```

Salida ejemplo:
```
TS1: 1700000000
TS2: 1700000005
Diferencia de segundos: 5
```






