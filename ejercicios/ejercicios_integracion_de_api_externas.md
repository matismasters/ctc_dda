# Ejercicios 22/10/2025

Todos estos ejercicios deberan realizarse en una aplicación ASP.NET Core Web API, cada uno con su repositorio aparte.

## Crear una API que tenga los siguientes endpoints:

- `GET /api/aleatorios/numero` - Devuelve un número aleatorio entre 1 y 999999.
- `GET /api/aleatorios/palabra` - Devuelve una palabra aleatoria del lenguaje español.
- `GET /api/aleatorios/color` - Devuelve un color aleatorio en formato hexadecimal (por ejemplo, #FF5733).

## Crear una API que tenga los siguientes endpoints:

- `GET /api/ComoEstaElTiempoEn/Tokyo` - Devuelve el estado del tiempo actual en Tokyo.
- `GET /api/ComoEstaElTiempoEn/Londres` - Devuelve el estado del tiempo actual en Londres.
- `GET /api/ComoEstaElTiempoEn/NuevaYork` - Devuelve el estado del tiempo actual en Nueva York.

## Crear una API que tenga los siguientes endpoints:

- `GET /api/Peliculas/buscar?titulo=Inception` - Devuelve información sobre la película "Inception".
- `GET /api/Peliculas/actores?ImdbID=tt1375666` - Devuelve información sobre la película "The Matrix".

https://www.omdbapi.com/apikey.aspx

## Crear una API que tenga los siguientes endpoints:

- `GET /api/Productos` - Devuelve una lista de productos con su nombre, precio y ID.
- `GET /api/Productos/{id}` - Devuelve los detalles de un producto específico por su ID.
- `POST /api/Productos` - Permite agregar un nuevo producto enviando su nombre y precio en el cuerpo de la solicitud. (opcional agregar createdAt y updatedAt)
- `PUT /api/Productos/{id}` - Permite actualizar el nombre y precio de un producto existente por su ID.
- `DELETE /api/Productos/{id}` - Permite eliminar un producto por su ID

## Crear en la aplicacion MVC y en la API el código necesario para lograr lo siguiente

[] Búsqueda por nombre de Producto.
  - En la aplicación MVC, tengo que poder ver un input de busqueda y botón para buscar.
  - Cuando escribo en el input "Laptop" y hago click en el botón, se debe mostrar una lista de productos que contengan "Laptop" en su nombre. La búsqueda debe ser case insensitive.
  - La aplicación MVC debe consumir la API para obtener los productos filtrados.
  - El resultado de la búsqueda debe mostrarse en una nueva página llamada "Resultados de Búsqueda".
  - En la página de resultados de búsqueda, también debe mostrarse el formulario de búsqueda para permitir realizar nuevas búsquedas sin volver a la página principal.
  - En la página de resultados, si no se encuentran productos que coincidan con el término de búsqueda, debe mostrarse un mensaje indicando "No se encontraron productos para 'TérminoDeBúsqueda'".
  - En la página de resultados, se debe mostrar el total de productos encontrados para el término de búsqueda ingresado.

[] Filtrado por rango de precio.
  - En la aplicación MVC, tengo que poder ver dos inputs para ingresar el precio mínimo y máximo, junto con un botón para filtrar.
  - Cuando ingreso un rango de precios (por ejemplo, mínimo: 500, máximo: 1500) y hago click en el botón, se debe mostrar una lista de productos cuyo precio esté dentro de ese rango.
  - La aplicación MVC debe consumir la API para obtener los productos filtrados por precio. 

  ## Crear API por alumno

  - GET `/api/NombreAlumnoPosta` - Envia un request al siguiente alumno
  - GET `/api/JulianPosta` - Envia un request a /api/NachoPosta (apiUrl: de nacho)
  - Console.WriteLine("Por aqui paso la posta de Julian");

  Julian -> Nacho -> Alejandra -> Jimena -> Gabriel -> Fernando -> Joaquin -> Nelson -> Juan -> Angenora