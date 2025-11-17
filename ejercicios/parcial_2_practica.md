# Parcial 2 - Práctica.

## Crear una API RESTful para un sistema de incentivos para los buenos conductores.

El Ministerio de Transporte y Obras Públicas ha decidido implementar un sistema de incentivos para los conductores que sigan las reglas de tránsito en zonas poco señalizadas. La idea es que este sistema será el opuesto a las multas, premiando a los conductores responsables con puntos que podrán canjear por beneficios.

Para lograr esto, son necesarias dos piezas de tecnología, la primera, es el dispositivo que captura la velocidad del vehículo, y su matricula, para luego enviarlo a un servidor central. La segunda pieza es la API RESTful que recibirá estos datos, en el servidor central, los procesará y almacenará en una base de datos. Es sólo sobre esta segunda pieza que trata este parcial.

### Requisitos funcionales

1. **Recepción de datos**: La API debe exponer un endpoint, `/captura` que reciba datos en formato JSON con la siguiente estructura:
   ```json
   {
     "matricula": "ABC123",
     "velocidad": 45,
     "zona": "residencial"
   }
   ```
   Donde:
   - `matricula`: es una cadena de texto que representa la matrícula del vehículo.
   - `velocidad`: es un número entero que representa la velocidad del vehículo en km/h.
   - `zona`: es una cadena de texto que indica el tipo de zona (por ejemplo, "residencial", "escuela", "autopista").

2. **Las zonas**: Tienen cada una un límite de velocidad asociado:
   - Ciudad: 45 km/h
   - Escuela: 30 km/h
   - Ruta: 90 km/h
   - Camino de tierra: 60 km/h
   - Cualquier otra zona: 60 km/h

3. **Cálculo de puntos**:
   - Si la velocidad del vehículo es menor o igual al límite de velocidad de la zona, la matrícula recibe 10 puntos.
    - Si la velocidad del vehículo excede el límite de velocidad, no se realiza ninguna acción.

4. **Consultas de puntos**: La API debe exponer un endpoint, `/matriculas/{matricula}` que permita consultar la cantidad total de puntos acumulados por una matrícula específica. La respuesta debe ser en formato JSON:
   ```json
   {
     "matricula": "ABC123",
     "puntos": 50
   }
   ```