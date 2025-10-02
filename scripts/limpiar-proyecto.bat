@echo off
chcp 65001 >nul
echo.
echo ==========================================
echo     LIMPIEZA Y RESTAURACIÓN DE PROYECTO
echo ==========================================
echo.

REM Verificar que dotnet esté instalado
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: .NET SDK no está instalado o no está en el PATH
    pause
    exit /b 1
)

REM Verificar que estamos en un directorio con solución .NET
if not exist "*.sln" (
    echo ❌ ERROR: No se encontró ninguna solución (.sln) en este directorio
    echo    Asegúrate de estar en el directorio raíz del proyecto
    pause
    exit /b 1
)

REM Encontrar archivo de solución
for %%f in (*.sln) do set SOLUTION_FILE=%%f

echo 🔍 Solución encontrada: %SOLUTION_FILE%
echo 📁 Directorio: %cd%
echo.

echo ⚠️  ADVERTENCIA: Este script eliminará:
echo    • Todas las carpetas bin/ y obj/
echo    • Archivos temporales de compilación
echo    • Cache de NuGet local
echo    • Reportes de tests anteriores
echo.

set /p CONFIRM="¿Continuar con la limpieza? (s/n): "
if /i not "%CONFIRM%"=="s" (
    echo ❌ Operación cancelada por el usuario
    pause
    exit /b 0
)

echo.
echo 🧹 Limpiando proyecto...

REM Limpiar solución
echo   → Ejecutando dotnet clean
dotnet clean "%SOLUTION_FILE%" --verbosity minimal

REM Eliminar carpetas bin y obj recursivamente
echo   → Eliminando carpetas bin/
for /d /r . %%d in (bin) do @if exist "%%d" rd /s /q "%%d"

echo   → Eliminando carpetas obj/
for /d /r . %%d in (obj) do @if exist "%%d" rd /s /q "%%d"

REM Eliminar reportes de tests y cobertura
echo   → Eliminando reportes de tests
if exist "TestResults\" rd /s /q "TestResults"
if exist "coverage\" rd /s /q "coverage"
del /q /s *.trx 2>nul
del /q /s *.coverage 2>nul
del /q /s coverage.*.xml 2>nul

REM Limpiar cache de NuGet (opcional)
set /p CLEAN_NUGET="¿Limpiar cache de NuGet también? (s/n): "
if /i "%CLEAN_NUGET%"=="s" (
    echo   → Limpiando cache de NuGet
    dotnet nuget locals all --clear
)

echo.
echo 📦 Restaurando paquetes NuGet...
dotnet restore "%SOLUTION_FILE%" --verbosity minimal

if errorlevel 1 (
    echo ❌ ERROR en la restauración de paquetes
    echo    Verifica tu conexión a internet y configuración de NuGet
    pause
    exit /b 1
)

echo.
echo 🏗️  Compilando proyecto limpio...
dotnet build "%SOLUTION_FILE%" --verbosity minimal

if errorlevel 1 (
    echo ❌ ERROR en la compilación
    echo    Revisa los errores mostrados arriba
    pause
    exit /b 1
)

echo.
echo ✅ LIMPIEZA Y RESTAURACIÓN COMPLETADA
echo.
echo 📊 ESTADO ACTUAL:
echo    • Compilación: ✅ Exitosa
echo    • Paquetes: ✅ Restaurados
echo    • Cache: ✅ Limpio
echo.
echo 💡 PRÓXIMOS PASOS RECOMENDADOS:
echo    • Ejecutar tests: ejecutar-tests.bat
echo    • Abrir en Visual Studio: start %SOLUTION_FILE%
echo    • Ejecutar aplicación: dotnet run --project src\*.Web
echo.

pause
