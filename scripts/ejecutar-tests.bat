@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo      EJECUTOR DE TESTS - ASP.NET CORE
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

REM Verificar que estamos en un directorio con solución .NET
if not exist "*.sln" (
    echo ❌ ERROR: No se encontró ninguna solución (.sln) en este directorio
    echo    Asegúrate de estar en el directorio raíz del proyecto
    echo    Directorio actual: %cd%
    pause
    exit /b 1
)

REM Encontrar archivo de solución
for %%f in (*.sln) do set SOLUTION_FILE=%%f

echo 🔍 Solución encontrada: %SOLUTION_FILE%
echo 📁 Directorio: %cd%
echo.

REM Verificar que existan proyectos de test
set TESTS_FOUND=0
if exist "tests\" (
    set TESTS_FOUND=1
) else if exist "*Tests*" (
    set TESTS_FOUND=1
) else if exist "*Test*" (
    set TESTS_FOUND=1
)

if %TESTS_FOUND%==0 (
    echo ⚠️  ADVERTENCIA: No se encontraron directorios de tests
    echo    Buscando proyectos de test en la solución...
)

echo 🏗️  Compilando solución...
dotnet build "%SOLUTION_FILE%" --configuration Release --verbosity minimal

if errorlevel 1 (
    echo.
    echo ❌ ERROR: Fallo en la compilación
    echo    Los tests no se pueden ejecutar hasta que se resuelvan los errores de compilación
    pause
    exit /b 1
)

echo ✅ Compilación exitosa
echo.

echo 🧪 Ejecutando TODOS los tests...
echo.
echo ========================================
echo           RESULTADOS DE TESTS
echo ========================================

REM Ejecutar todos los tests con configuración detallada
dotnet test "%SOLUTION_FILE%" ^
    --configuration Release ^
    --no-build ^
    --verbosity normal ^
    --logger "console;verbosity=detailed" ^
    --collect:"XPlat Code Coverage"

set TEST_EXIT_CODE=%errorlevel%

echo.
echo ========================================
echo            RESUMEN FINAL
echo ========================================

if %TEST_EXIT_CODE%==0 (
    echo ✅ TODOS LOS TESTS PASARON EXITOSAMENTE
    echo 🎉 Tu código está funcionando correctamente
) else (
    echo ❌ ALGUNOS TESTS FALLARON
    echo 🔧 Revisa los errores anteriores y corrige tu código
)

echo.
echo 📊 COMANDOS ÚTILES ADICIONALES:
echo.
echo    • Tests unitarios únicamente:
echo      dotnet test --filter "FullyQualifiedName~UnitTests"
echo.
echo    • Tests de integración únicamente:  
echo      dotnet test --filter "FullyQualifiedName~IntegrationTests"
echo.
echo    • Tests con cobertura de código:
echo      dotnet test --collect:"XPlat Code Coverage"
echo.
echo    • Tests de una categoría específica:
echo      dotnet test --filter "Category=Unit"
echo.
echo    • Ejecutar tests en modo watch (re-ejecuta al cambiar código):
echo      dotnet watch test
echo.

REM Buscar reportes de cobertura generados
if exist "**\coverage.cobertura.xml" (
    echo 📈 REPORTES DE COBERTURA GENERADOS:
    echo    Se generaron reportes de cobertura de código
    echo    Para generar reporte HTML instala: dotnet tool install -g dotnet-reportgenerator-globaltool
    echo    Luego ejecuta: reportgenerator -reports:**\coverage.cobertura.xml -targetdir:coverage
    echo.
)

echo 🕐 Ejecutado en: %date% %time%
echo.

if %TEST_EXIT_CODE%==0 (
    echo 🚀 ¡CONTINÚA DESARROLLANDO CON CONFIANZA!
) else (
    echo 🔧 ¡CORRIGE LOS ERRORES Y VUELVE A EJECUTAR!
)

pause
exit /b %TEST_EXIT_CODE%
