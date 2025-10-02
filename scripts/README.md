# Scripts de Configuración - Curso ASP.NET Core

Este directorio contiene scripts para **automatizar la configuración inicial** de proyectos ASP.NET Core con arquitectura por capas y testing integrado.

## 🎯 **Problema que resuelve**

Los estudiantes frecuentemente tienen problemas con:
- ❌ Configuración inicial compleja de proyectos MVC
- ❌ Referencias incorrectas entre proyectos  
- ❌ Estructura de directorios inconsistente
- ❌ Problemas con .gitignore y permisos
- ❌ Configuración de proyectos de testing

## 📁 **Archivos incluidos**

### `crear-proyecto.bat`
Script principal que crea la estructura completa del proyecto.

**¿Qué hace?**
- ✅ Crea estructura de directorios profesional
- ✅ Genera todos los proyectos (.Web, .Core, .Data, .Tests)
- ✅ Configura referencias correctas entre proyectos
- ✅ Instala paquetes de testing (Moq, FluentAssertions)
- ✅ Crea .gitignore completo para .NET
- ✅ Genera README.md con documentación
- ✅ Compila y verifica que todo funcione
- ✅ Opcionalmente inicializa Git

### `ejecutar-tests.bat`
Script para ejecutar todos los tests del proyecto.

**¿Qué hace?**
- ✅ Compila la solución completa
- ✅ Ejecuta todos los tests (unitarios + integración)
- ✅ Muestra resultados detallados
- ✅ Genera reportes de cobertura
- ✅ Proporciona comandos útiles adicionales

## 🚀 **Instrucciones de uso**

### **Para estudiantes:**

1. **Descargar scripts:**
   - Copia `crear-proyecto.bat` al directorio donde quieres crear tu proyecto
   - Ejemplo: `C:\MisCodigos\` 

2. **Ejecutar configuración:**
   - Doble clic en `crear-proyecto.bat`
   - Ingresa el nombre de tu proyecto (ej: `MiTienda`)
   - El script creará todo automáticamente

3. **Verificar resultado:**
   ```
   MiTienda/
   ├── src/
   │   ├── MiTienda.Web/           # Aplicación MVC
   │   ├── MiTienda.Core/          # Servicios y lógica  
   │   └── MiTienda.Data/          # Repositorios y datos
   ├── tests/
   │   ├── MiTienda.UnitTests/     # Tests unitarios
   │   └── MiTienda.IntegrationTests/ # Tests integración
   ├── MiTienda.sln                # Solución completa
   ├── .gitignore                  # Git configurado
   └── README.md                   # Documentación
   ```

4. **Abrir en Visual Studio:**
   - Doble clic en `MiTienda.sln` 
   - O desde Visual Studio: File → Open → Project/Solution

5. **Ejecutar tests:**
   - Copia `ejecutar-tests.bat` a la carpeta `MiTienda/`
   - Doble clic para ejecutar todos los tests

### **Para profesores:**

**Distribución a estudiantes:**
1. Comparte el archivo `crear-proyecto.bat` 
2. Instrúyelos que lo coloquen donde quieren crear el proyecto
3. No necesitan conocimientos técnicos avanzados

**Ventajas pedagógicas:**
- ✅ Todos los estudiantes tienen la misma estructura
- ✅ Enfoque en programación, no en configuración
- ✅ Introduce mejores prácticas desde el inicio
- ✅ Tests integrados desde el primer día

## 🔧 **Requisitos técnicos**

- **Windows**: Scripts .bat optimizados para Windows
- **.NET SDK**: Versión 6.0 o superior instalada
- **PowerShell**: Para ejecución de comandos dotnet
- **Git** (opcional): Para inicialización automática de repositorio

**Verificar instalación:**
```bash
dotnet --version    # Debe mostrar versión 6.0+
git --version       # Opcional, para control de versiones
```

## 🏗️ **Estructura generada**

El script crea una **arquitectura por capas profesional**:

### **Proyectos de aplicación (src/):**
- **`.Web`**: Controllers, Views, Program.cs, configuración MVC
- **`.Core`**: Services, interfaces, lógica de negocio  
- **`.Data`**: Repositories, DbContext, modelos de datos

### **Proyectos de testing (tests/):**
- **`.UnitTests`**: Tests de servicios y lógica (con Moq)
- **`.IntegrationTests`**: Tests de controllers y endpoints

### **Referencias configuradas:**
```
Web → Core → Data
UnitTests → Core  
IntegrationTests → Web
```

## 📦 **Paquetes incluidos**

### **Testing básico:**
- `xUnit`: Framework de testing
- `Microsoft.AspNetCore.Mvc.Testing`: Testing de integración
- `Moq`: Mocking framework  
- `FluentAssertions`: Assertions expresivos

### **Configuración automática:**
- ✅ Todas las referencias de proyectos
- ✅ Paquetes de testing instalados
- ✅ .gitignore completo para .NET
- ✅ Estructura de carpetas consistente

## 🚨 **Solución de problemas comunes**

### **Error: "dotnet no se reconoce"**
- **Solución**: Instalar .NET SDK desde https://dotnet.microsoft.com/download
- **Verificar**: Abrir nueva ventana de comando después de instalar

### **Error: "Acceso denegado"**
- **Solución**: Ejecutar como administrador
- **O**: Crear proyecto en carpeta donde tienes permisos de escritura

### **Error: "No se encontró la solución"**
- **Problema**: `ejecutar-tests.bat` no está en directorio correcto
- **Solución**: Colocar el script en la carpeta que contiene el archivo `.sln`

### **Tests fallan inmediatamente**
- **Verificar**: Que la compilación sea exitosa primero
- **Ejecutar**: `dotnet build` manualmente para ver errores específicos

## 💡 **Personalización**

### **Modificar plantillas:**
Los scripts usan plantillas estándar de `dotnet new`. Para personalizar:

1. **Cambiar framework target**: Editar líneas `dotnet new` en el script
2. **Agregar paquetes adicionales**: Añadir líneas `dotnet add package`
3. **Modificar estructura**: Cambiar comandos `mkdir` y rutas

### **Estructura alternativa:**
Si prefieres estructura diferente, modifica las rutas en:
- Líneas `mkdir src` y `mkdir tests`
- Parámetros `-o` en comandos `dotnet new`
- Referencias `dotnet add reference`

## 🎓 **Valor pedagógico**

### **Para estudiantes:**
- **Inmediatez**: Comenzar a programar en minutos, no horas
- **Mejores prácticas**: Estructura profesional desde el inicio  
- **Testing integrado**: Tests como parte natural del desarrollo
- **Enfoque**: En lógica de negocio, no en configuración

### **Para el curso:**
- **Consistencia**: Todos los proyectos tienen la misma estructura
- **Escalabilidad**: Fácil agregar nuevos proyectos y referencias
- **Profesionalización**: Estudiantes aprenden workflows reales
- **Menos fricción**: Más tiempo para conceptos, menos para setup

## 📞 **Soporte**

Si encuentras problemas:
1. **Verificar requisitos**: .NET SDK instalado y actualizado
2. **Permisos**: Ejecutar en directorio donde tienes permisos de escritura
3. **Logs**: Los scripts muestran información detallada de errores
4. **Consultar**: Con el profesor o compañeros de clase

---

> **💡 Tip**: Guarda estos scripts en una carpeta fácil de acceder, como `C:\Scripts\`, para reutilizarlos en futuros proyectos.
