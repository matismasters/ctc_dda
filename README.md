# Guía del Curso – Diseño y Desarrollo de Aplicaciones

**Carga horaria:** 2 clases semanales de 3 horas cada una.
**Duración:** 16 semanas.

---

## Alcance de la Materia

La asignatura **Diseño y Desarrollo de Aplicaciones** tiene como objetivo la **profesionalización de las competencias técnicas** de los estudiantes en programación.
No aborda la gestión de proyectos, el levantamiento de requerimientos ni la documentación funcional (contenidos cubiertos en otras materias del semestre), sino que se centra en:

* **Diseño y arquitectura de software.**
* **Programación profesional en C# y ASP.NET Core.**
* **Buenas prácticas de desarrollo:** pruebas automatizadas, seguridad, versionado y patrones de diseño.
* **Ciclo de vida técnico de una aplicación:** desde el diseño hasta el despliegue en un entorno real.

---

## Perfil del Egresado

Al finalizar el curso, el estudiante será capaz de:

1. **Diseñar arquitecturas de software web profesionales** aplicando principios SOLID, utilizando patrones de diseño básicos (Repository, Dependency Injection, DTOs) y separando adecuadamente las capas de presentación, negocio y datos.

2. **Desarrollar aplicaciones completas en C# con ASP.NET Core**, incluyendo aplicaciones Web MVC como front-end y servicios Web API RESTful como back-end, integrados con persistencia mediante Entity Framework.

3. **Aplicar buenas prácticas de desarrollo**, incorporando control de versiones con Git, manejo de errores y validaciones, uso de logging y estándares de diseño de APIs (verbos HTTP, status codes, Swagger).

4. **Garantizar la calidad del software** a través de pruebas automatizadas (unitarias e integración), asegurando la mantenibilidad y escalabilidad del código.

5. **Desplegar aplicaciones en entornos reales**, configurando servidores o servicios cloud (Azure, Railway, IIS), diferenciando entornos de desarrollo, testing y producción, y publicando APIs documentadas listas para consumo por terceros.

El egresado de la materia adquiere el perfil de un **Desarrollador Full-Stack Junior con foco en ASP.NET Core**, capacitado para entregar software de principio a fin en un entorno profesional.

---

## Objetivo General

Que el estudiante sea capaz de **diseñar, desarrollar, probar y desplegar aplicaciones web profesionales en C# utilizando ASP.NET Core**, integrando MVC y Web API, aplicando principios de arquitectura limpia, pruebas automatizadas y control de versiones, de manera que pueda **entregar soluciones reales y mantenibles para terceros**.

---

## Estructura del Curso (16 Semanas)

### Unidad 1 – Introducción a la Profesionalización del Desarrollo

**Semanas 1–2**

* Repaso de C#, ASP.NET Core MVC y Web API.
* Diferencia entre programar y desarrollar profesionalmente.
* Arquitectura limpia y separación de capas.
* Introducción a Git (repositorios, ramas, PRs).
* Introducción a pruebas automatizadas (xUnit/NUnit).

**Actividades en clase:**

* Configuración inicial de un proyecto MVC por capas.
* Creación de repositorio en GitHub y primeros PRs.
* Primeros tests unitarios.

**Actividades domiciliarias:**

* Mini CRUD en MVC con control de versiones.
* Tests unitarios básicos.

---

### Unidad 2 – Diseño y Arquitectura de Aplicaciones

**Semanas 3–4**

* Principios SOLID en C#.
* Patrones de diseño: Repository, Dependency Injection, DTOs.
* Buenas prácticas en controladores y servicios.
* Validaciones y manejo de excepciones.

**Actividades en clase:**

* Refactorización de proyecto MVC aplicando patrones.
* Ejercicios de testing unitario.

**Actividades domiciliarias:**

* Refactorizar CRUD aplicando SOLID y patrones.
* Implementar tests adicionales.

---

### Semana 5 – **Parcial 1**

* **Clase 1:** Repaso integral de contenidos.
* **Clase 2:** **Parcial 1** – Evaluación teórico-práctica.

---

### Semana 6 – **Entrega de Proyecto Obligatorio Domiciliario 1 (POD 1)**

* **Clase 1:** Puesta a punto, consultas y revisión de avances.
* **Clase 2:** **Entrega y defensa oral de POD 1** – Aplicación MVC con arquitectura por capas, Git y tests básicos.

---

### Unidad 3 – Desarrollo de APIs Profesionales

**Semanas 7–8**

* Diseño de APIs RESTful: verbos HTTP, status codes, convenciones.
* Documentación automática con Swagger.
* Consumo y prueba de APIs con Postman.
* Introducción a seguridad con JWT.

**Actividades en clase:**

* Creación de API CRUD en ASP.NET Core.
* Documentación con Swagger y prueba en Postman.
* Tests de integración sobre endpoints.

**Actividades domiciliarias:**

* Extender la API creada en clase.
* Incorporar validaciones y manejo de errores.

---

### Unidad 4 – Persistencia Avanzada con Entity Framework

**Semanas 9–10**

* Relaciones uno-a-muchos y muchos-a-muchos.
* Configuración con Fluent API.
* Migraciones y actualización de la base de datos.
* Optimización de consultas (Lazy/Eager loading).

**Actividades en clase:**

* Creación de modelo relacional con EF.
* Ejercicios con LINQ y EF.
* Tests de integración con BD en memoria.

**Actividades domiciliarias:**

* Incorporar persistencia avanzada en la API.
* Tests de integración sobre datos persistidos.

---

### Semana 11 – **Parcial 2**

* **Clase 1:** Repaso integral de contenidos.
* **Clase 2:** **Parcial 2** – Evaluación teórico-práctica.

---

### Unidad 5 – Seguridad, Calidad y Preparación para Producción

**Semanas 12–13**

* Autenticación y autorización con JWT.
* Validación avanzada de datos y sanitización.
* Logging y manejo centralizado de excepciones.
* Introducción a CI/CD (pipelines básicos).

**Actividades en clase:**

* Configuración de autenticación JWT.
* Ejercicios de autorización por roles.
* Tests de endpoints protegidos.

**Actividades domiciliarias:**

* Integrar seguridad en la API.
* Conectar el MVC front del POD 1 con la API.

---

### Semana 14 – **Entrega de Proyecto Obligatorio Domiciliario 2 (POD 2)**

* **Clase 1:** Puesta a punto, consultas y revisión de avances.
* **Clase 2:** **Entrega y defensa oral de POD 2** – API RESTful conectada al MVC, persistencia con EF, seguridad con JWT, documentación con Swagger y tests.

---

### Unidad 6 – Despliegue y Proyecto Final

**Semanas 15–16**

* Conceptos de entornos: desarrollo, testing y producción.
* Configuración de aplicaciones para distintos entornos.
* Opciones de despliegue: Azure App Service, Railway, IIS.
* Publicación de API y front en la nube.

**Actividades en clase:**

* Ejercicio guiado de despliegue en servicio cloud.
* Prueba de endpoints publicados en Postman.

**Actividades domiciliarias:**

* Ajustar el proyecto integrador para despliegue online.
* Documentar con README + Swagger accesible públicamente.

---

### Semana 16 – **Entrega Final**

* **Clase 2:** Entrega y defensa final.
* **Requisitos:**

  * Proyecto completo (MVC + API).
  * Desplegado en servidor online accesible públicamente.
  * Documentación técnica (README y Swagger).
  * Presentación con demo en vivo.
