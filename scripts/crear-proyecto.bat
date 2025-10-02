@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo    CONFIGURADOR DE PROYECTO ASP.NET CORE
echo ==========================================
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

REM Solicitar nombre del proyecto
set /p PROJECT_NAME="📝 Ingresa el nombre del proyecto (ej: MiApp): "

REM Validar que se ingresó un nombre
if "%PROJECT_NAME%"=="" (
    echo ❌ ERROR: Debes ingresar un nombre para el proyecto
    pause
    exit /b 1
)

REM Crear directorio principal
echo.
echo 📁 Creando estructura de directorios...
mkdir "%PROJECT_NAME%" 2>nul
cd "%PROJECT_NAME%"

REM Crear estructura de carpetas
mkdir src 2>nul
mkdir tests 2>nul

echo.
echo 🏗️  Creando proyectos...

REM Crear solución
echo   → Creando solución %PROJECT_NAME%.sln
dotnet new sln -n "%PROJECT_NAME%" --force

REM Crear proyectos en src/
echo   → Creando %PROJECT_NAME%.Web (MVC)
dotnet new mvc -n "%PROJECT_NAME%.Web" -o "src\%PROJECT_NAME%.Web" --force

echo   → Creando %PROJECT_NAME%.Core (Services y lógica)
dotnet new classlib -n "%PROJECT_NAME%.Core" -o "src\%PROJECT_NAME%.Core" --force

echo   → Creando %PROJECT_NAME%.Data (Repositorios y DbContext)
dotnet new classlib -n "%PROJECT_NAME%.Data" -o "src\%PROJECT_NAME%.Data" --force

REM Crear proyectos de tests
echo   → Creando %PROJECT_NAME%.UnitTests
dotnet new xunit -n "%PROJECT_NAME%.UnitTests" -o "tests\%PROJECT_NAME%.UnitTests" --force

echo   → Creando %PROJECT_NAME%.IntegrationTests
dotnet new xunit -n "%PROJECT_NAME%.IntegrationTests" -o "tests\%PROJECT_NAME%.IntegrationTests" --force

echo.
echo 🔗 Agregando proyectos a la solución...

REM Agregar proyectos a la solución
dotnet sln "%PROJECT_NAME%.sln" add "src\%PROJECT_NAME%.Web\%PROJECT_NAME%.Web.csproj"
dotnet sln "%PROJECT_NAME%.sln" add "src\%PROJECT_NAME%.Core\%PROJECT_NAME%.Core.csproj"
dotnet sln "%PROJECT_NAME%.sln" add "src\%PROJECT_NAME%.Data\%PROJECT_NAME%.Data.csproj"
dotnet sln "%PROJECT_NAME%.sln" add "tests\%PROJECT_NAME%.UnitTests\%PROJECT_NAME%.UnitTests.csproj"
dotnet sln "%PROJECT_NAME%.sln" add "tests\%PROJECT_NAME%.IntegrationTests\%PROJECT_NAME%.IntegrationTests.csproj"

echo.
echo 📦 Configurando referencias entre proyectos...

REM Referencias de arquitectura
echo   → %PROJECT_NAME%.Web → %PROJECT_NAME%.Core
dotnet add "src\%PROJECT_NAME%.Web" reference "src\%PROJECT_NAME%.Core"

echo   → %PROJECT_NAME%.Web → %PROJECT_NAME%.Data
dotnet add "src\%PROJECT_NAME%.Web" reference "src\%PROJECT_NAME%.Data"

echo   → %PROJECT_NAME%.Core → %PROJECT_NAME%.Data
dotnet add "src\%PROJECT_NAME%.Core" reference "src\%PROJECT_NAME%.Data"

REM Referencias de testing
echo   → %PROJECT_NAME%.UnitTests → %PROJECT_NAME%.Core
dotnet add "tests\%PROJECT_NAME%.UnitTests" reference "src\%PROJECT_NAME%.Core"

echo   → %PROJECT_NAME%.IntegrationTests → %PROJECT_NAME%.Web
dotnet add "tests\%PROJECT_NAME%.IntegrationTests" reference "src\%PROJECT_NAME%.Web"

echo.
echo 🧪 Agregando paquetes de testing...

REM Agregar paquetes para testing de integración
echo   → Agregando Microsoft.AspNetCore.Mvc.Testing
dotnet add "tests\%PROJECT_NAME%.IntegrationTests" package Microsoft.AspNetCore.Mvc.Testing

echo   → Agregando Moq para unit tests
dotnet add "tests\%PROJECT_NAME%.UnitTests" package Moq

echo   → Agregando FluentAssertions para assertions expresivos
dotnet add "tests\%PROJECT_NAME%.UnitTests" package FluentAssertions
dotnet add "tests\%PROJECT_NAME%.IntegrationTests" package FluentAssertions

echo.
echo 📄 Creando archivo .gitignore...

REM Crear .gitignore completo para .NET
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
echo Proyecto ASP.NET Core con arquitectura por capas.
echo.
echo ## Estructura del Proyecto
echo.
echo ```
echo %PROJECT_NAME%/
echo ├── src/
echo │   ├── %PROJECT_NAME%.Web/          # Aplicación MVC
echo │   ├── %PROJECT_NAME%.Core/         # Servicios y lógica de negocio
echo │   └── %PROJECT_NAME%.Data/         # Repositorios y acceso a datos
echo └── tests/
echo     ├── %PROJECT_NAME%.UnitTests/           # Tests unitarios
echo     └── %PROJECT_NAME%.IntegrationTests/    # Tests de integración
echo ```
echo.
echo ## Comandos Útiles
echo.
echo ```bash
echo # Compilar toda la solución
echo dotnet build
echo.
echo # Ejecutar la aplicación web
echo dotnet run --project src\%PROJECT_NAME%.Web
echo.
echo # Ejecutar todos los tests
echo dotnet test
echo.
echo # Ejecutar solo tests unitarios
echo dotnet test tests\%PROJECT_NAME%.UnitTests
echo.
echo # Ejecutar solo tests de integración
echo dotnet test tests\%PROJECT_NAME%.IntegrationTests
echo ```
echo.
echo ## Configuración de Desarrollo
echo.
echo 1. Restaurar paquetes: `dotnet restore`
echo 2. Compilar: `dotnet build`
echo 3. Ejecutar tests: `dotnet test`
echo 4. Ejecutar aplicación: `dotnet run --project src\%PROJECT_NAME%.Web`
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
echo    1. Ejecuta: git init
echo    2. Ejecuta: git add .
echo    3. Ejecuta: git commit -m "Initial commit"
echo    4. Abre la solución: %PROJECT_NAME%.sln
echo.
echo 💡 COMANDOS ÚTILES:
echo    • Ejecutar aplicación: dotnet run --project src\%PROJECT_NAME%.Web
echo    • Ejecutar todos los tests: dotnet test
echo    • Abrir en Visual Studio: start %PROJECT_NAME%.sln
echo.

REM Preguntar si quiere inicializar Git
set /p INIT_GIT="¿Quieres inicializar Git automáticamente? (s/n): "
if /i "%INIT_GIT%"=="s" (
    echo.
    echo 📚 Inicializando repositorio Git...
    git init
    git add .
    git commit -m "Initial commit: estructura de proyecto ASP.NET Core"
    echo ✅ Repositorio Git inicializado y commit inicial creado
)

echo.
echo 🎉 ¡LISTO PARA DESARROLLAR!
pause
