@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo    CONFIGURADOR DE PROYECTO ASP.NET CORE
echo ==========================================
echo.
echo 📖 USO:
echo    crear-proyecto.bat "NombreDelProyecto"
echo    Ejemplo: crear-proyecto.bat "MiTiendaMVC"
echo.
echo 📁 El proyecto se creará en: ..\..\NombreDelProyecto
echo.

REM Verificar que dotnet esté instalado
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: .NET SDK no está instalado o no está en el PATH
    echo    Descarga e instala .NET SDK desde: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

echo ✅ .NET SDK detectado: 
dotnet --version
echo.

REM Obtener nombre del proyecto desde parámetros
set PROJECT_NAME=%1

REM Si no se proporcionó parámetro, solicitar nombre
if "%PROJECT_NAME%"=="" (
    set /p PROJECT_NAME="📝 Ingresa el nombre del proyecto (ej: MiApp): "
)

REM Validar que se ingresó un nombre
if "%PROJECT_NAME%"=="" (
    echo ❌ ERROR: Debes proporcionar un nombre para el proyecto
    echo    Uso: crear-proyecto.bat "NombreDelProyecto"
    echo    O ejecuta sin parámetros para ingresar el nombre interactivamente
    pause
    exit /b 1
)

REM Crear directorio principal dos niveles arriba
echo.
echo 📁 Creando estructura de directorios...
set PROJECT_PATH=..\..\%PROJECT_NAME%
mkdir "%PROJECT_PATH%" 2>nul
cd "%PROJECT_PATH%"

REM No necesitamos crear carpetas adicionales - los proyectos se crean directamente

echo.
echo 🏗️  Creando proyectos...

REM Crear solución
echo   → Creando solución %PROJECT_NAME%.sln
dotnet new sln -n "%PROJECT_NAME%" --force

REM Crear proyecto MVC
echo   → Creando %PROJECT_NAME%.Web (MVC con Services y Data)
dotnet new mvc -n "%PROJECT_NAME%.Web" -o "%PROJECT_NAME%.Web" --force

REM Crear proyecto de tests
echo   → Creando %PROJECT_NAME%.Tests
dotnet new xunit -n "%PROJECT_NAME%.Tests" -o "%PROJECT_NAME%.Tests" --force

echo.
echo 🔗 Agregando proyectos a la solución...

REM Agregar proyectos a la solución
dotnet sln "%PROJECT_NAME%.sln" add "%PROJECT_NAME%.Web\%PROJECT_NAME%.Web.csproj"
dotnet sln "%PROJECT_NAME%.sln" add "%PROJECT_NAME%.Tests\%PROJECT_NAME%.Tests.csproj"

echo.
echo 📦 Configurando referencias entre proyectos...

REM Referencias de testing
echo   → %PROJECT_NAME%.Tests → %PROJECT_NAME%.Web
dotnet add "%PROJECT_NAME%.Tests" reference "%PROJECT_NAME%.Web"

echo.
echo 🧪 Agregando paquetes de testing...

REM Agregar paquetes para testing
echo   → Agregando Microsoft.AspNetCore.Mvc.Testing
dotnet add "%PROJECT_NAME%.Tests" package Microsoft.AspNetCore.Mvc.Testing

echo   → Agregando Moq para unit tests
dotnet add "%PROJECT_NAME%.Tests" package Moq

echo   → Agregando FluentAssertions para assertions expresivos
dotnet add "%PROJECT_NAME%.Tests" package FluentAssertions

echo.
echo 🧪 Creando tests básicos de integración...

REM Crear archivo de tests básicos de integración
echo using Microsoft.AspNetCore.Mvc.Testing; > "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo using System.Net; >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo using Xunit; >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo namespace %PROJECT_NAME%.Tests; >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo public class HomeControllerTests : IClassFixture^<WebApplicationFactory^> >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo { >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     private readonly HttpClient _client; >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     public HomeControllerTests^(WebApplicationFactory factory^) >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     { >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         _client = factory.CreateClient^(^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     } >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     [Fact] >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     public async Task GET_Home_ReturnsSuccessStatusCode^(^) >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     { >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Arrange: el setup ya está hecho en constructor >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Act: hacer request real a la página Home >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         var response = await _client.GetAsync^("/"^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Assert: verificar que devuelve status 200 >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         response.EnsureSuccessStatusCode^(^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         Assert.Equal^(HttpStatusCode.OK, response.StatusCode^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     } >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     [Fact] >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     public async Task GET_Privacy_ReturnsSuccessStatusCode^(^) >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     { >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Arrange: el setup ya está hecho en constructor >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Act: hacer request real a la página Privacy >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         var response = await _client.GetAsync^("/Home/Privacy"^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo. >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         // Assert: verificar que devuelve status 200 >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         response.EnsureSuccessStatusCode^(^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo         Assert.Equal^(HttpStatusCode.OK, response.StatusCode^); >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo     } >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"
echo } >> "%PROJECT_NAME%.Tests\HomeControllerTests.cs"

echo   → Tests básicos creados: HomeControllerTests.cs

echo.
echo 📄 Creando archivo .gitignore...
(
echo # Build results
echo [Dd]ebug/
echo [Dd]ebugPublic/
echo [Rr]elease/
echo [Rr]eleases/
echo x64/
echo x86/
echo [Ww][Ii][Nn]32/
echo [Aa][Rr][Mm]/
echo [Aa][Rr][Mm]64/
echo bld/
echo [Bb]in/
echo [Oo]bj/
echo [Ll]og/
echo [Ll]ogs/
echo.
echo # Visual Studio
echo .vs/
echo *.suo
echo *.user
echo *.userosscache
echo *.sln.docstates
echo *.userprefs
echo.
echo # JetBrains Rider
echo .idea/
echo *.sln.iml
echo.
echo # Test Results
echo [Tt]est[Rr]esult*/
echo [Bb]uild[Ll]og.*
echo *.VisualState.xml
echo TestResult.xml
echo [Tt]est[Rr]esults/
echo.
echo # Coverage results
echo *.coverage
echo *.coveragexml
echo coverage/
echo.
echo # NuGet
echo *.nupkg
echo *.snupkg
echo **/[Pp]ackages/*
echo !**/[Pp]ackages/build/
echo.
echo # Entity Framework
echo *.edmx.diagram
echo *.edmx.xml
echo.
echo # ASP.NET Scaffolding
echo ScaffoldingReadMe.txt
echo.
echo # Node.js Tools for Visual Studio
echo .ntvs_analysis.dat
echo node_modules/
echo.
echo # Application specific
echo appsettings.Development.json
echo appsettings.Local.json
echo.
echo # OS generated files
echo .DS_Store
echo .DS_Store?
echo ._*
echo .Spotlight-V100
echo .Trashes
echo ehthumbs.db
echo Thumbs.db
) > .gitignore

echo.
echo 🗂️  Creando README.md...

REM Crear README básico
(
echo # %PROJECT_NAME%
echo.
echo Proyecto ASP.NET Core con arquitectura por capas y testing MVC integrado.
echo.
echo ## Estructura del Proyecto
echo.
echo ```
echo %PROJECT_NAME%/
echo ├── %PROJECT_NAME%.Web/              # Aplicación MVC (Controllers, Views, Services, Data)
echo └── %PROJECT_NAME%.Tests/            # Tests unitarios e integración
echo ```
echo.
echo ## Testing MVC
echo.
echo Este proyecto incluye configuración completa para testing de aplicaciones MVC:
echo - **Tests Unitarios**: Para servicios y lógica de negocio
echo - **Tests de Integración**: Para controladores y endpoints usando TestServer
echo - **Tests básicos incluidos**: HomeControllerTests con tests para Home y Privacy
echo - **Paquetes incluidos**: xUnit, Moq, FluentAssertions, Microsoft.AspNetCore.Mvc.Testing
echo - **Estructura simple**: Solo 2 proyectos, fácil de entender y mantener
echo.
echo ## Comandos Útiles
echo.
echo ```bash
echo # Compilar toda la solución
echo dotnet build
echo.
echo # Ejecutar la aplicación web
echo dotnet run --project %PROJECT_NAME%.Web
echo.
echo # Ejecutar todos los tests
echo dotnet test
echo.
echo # Ejecutar tests con filtros específicos
echo dotnet test --filter "FullyQualifiedName~Controller"
echo dotnet test --filter "FullyQualifiedName~Service"
echo.
echo # Tests con cobertura de código
echo dotnet test --collect:"XPlat Code Coverage"
echo.
echo # Tests con filtros específicos
echo dotnet test --filter "Category=Unit"
echo dotnet test --filter "FullyQualifiedName~Controller"
echo ```
echo.
echo ## Configuración de Desarrollo
echo.
echo 1. Restaurar paquetes: `dotnet restore`
echo 2. Compilar: `dotnet build`
echo 3. Ejecutar tests: `dotnet test`
echo 4. Ejecutar aplicación: `dotnet run --project %PROJECT_NAME%.Web`
echo.
echo ## Testing MVC - Primeros Pasos
echo.
echo ### Tests Unitarios
echo - Ubicación: `%PROJECT_NAME%.Tests`
echo - Para: Servicios, lógica de negocio, validaciones
echo - Framework: xUnit + Moq + FluentAssertions
echo.
echo ### Tests de Integración
echo - Ubicación: `%PROJECT_NAME%.Tests`
echo - Para: Controladores, endpoints, TestServer
echo - Framework: xUnit + Microsoft.AspNetCore.Mvc.Testing
echo - **Tests incluidos**: HomeControllerTests.cs con tests para Home y Privacy
echo.
echo ### Tests Básicos Incluidos
echo El proyecto incluye tests de ejemplo que verifican:
echo - **GET /**: Página Home devuelve status 200
echo - **GET /Home/Privacy**: Página Privacy devuelve status 200
echo.
echo ### Ejemplo de Test de Integración
echo ```csharp
echo [Fact]
echo public async Task GET_Home_ReturnsSuccessStatusCode()
echo {
echo     var response = await _client.GetAsync("/");
echo     response.EnsureSuccessStatusCode();
echo     Assert.Equal(HttpStatusCode.OK, response.StatusCode);
echo }
echo ```
) > README.md

echo.
echo 🔧 Compilando proyectos para verificar configuración...
dotnet build --verbosity quiet

if errorlevel 1 (
    echo ❌ ERROR: Hubo problemas al compilar los proyectos
    echo    Revisa los errores anteriores
    pause
    exit /b 1
)

echo.
echo 🧪 Ejecutando tests para verificar configuración...
dotnet test --verbosity quiet --no-build

echo.
echo ✅ ¡CONFIGURACIÓN COMPLETADA EXITOSAMENTE!
echo.
echo 📁 Estructura creada en: %cd%
echo.
echo 🚀 PRÓXIMOS PASOS:
echo    1. Abre la solución: %PROJECT_NAME%.sln
echo    2. Si quieres usar Git: git init
echo    3. Ejecuta la aplicación: dotnet run --project %PROJECT_NAME%.Web
echo.
echo 💡 COMANDOS ÚTILES:
echo    • Ejecutar aplicación: dotnet run --project %PROJECT_NAME%.Web
echo    • Ejecutar todos los tests: dotnet test
echo    • Abrir en Visual Studio: start %PROJECT_NAME%.sln
echo.
echo 📍 UBICACIÓN DEL PROYECTO:
echo    El proyecto se creó en: %PROJECT_PATH%
echo    Desde el directorio del script: %~dp0
echo    Ruta absoluta: %cd%
echo.
echo 📁 ARCHIVOS INCLUIDOS:
echo    • .gitignore configurado para .NET
echo    • README.md con documentación completa
echo    • Estructura simple: solo 2 proyectos

echo.
echo 🎉 ¡LISTO PARA DESARROLLAR!
pause
