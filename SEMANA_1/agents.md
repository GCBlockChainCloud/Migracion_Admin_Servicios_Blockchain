# Resumen de la carpeta SEMANA_1

Esta carpeta contiene materiales y ejemplos prácticos relacionados con contenedores Docker.

## Archivos principales

- `Semana_1_Contenedores_Docker_UTPL.pptx`: presentación de la semana 1 sobre contenedores Docker.
- `~$Semana_1_Contenedores_Docker_UTPL.pptx`: archivo temporal de PowerPoint, normalmente creado cuando la presentación está abierta o quedó una sesión pendiente.
- `Unidad 1.mp4`: video de la unidad 1.

## Carpetas

- `app_python/`: contiene un script Python simple.
- `docker-flask/`: contiene una API básica hecha con Flask.
- `docker-ubuntu/`: carpeta vacía actualmente.
- `docker-web/`: contiene una página web HTML simple para ejecutarse en un contenedor con Nginx.

## Detalle por carpeta

### `app_python/`

- `app.py`: imprime el mensaje `Hola, este programa Python está corriendo dentro de Docker`.

### `docker-flask/`

- `app.py`: define una aplicación Flask con dos rutas:
  - `/`: devuelve un mensaje JSON de saludo desde una API Flask dockerizada.
  - `/saludo/<nombre>`: devuelve un saludo personalizado usando el nombre recibido en la URL.
- `requirements.txt`: declara la dependencia `flask`.

### `docker-ubuntu/`

- No contiene archivos por el momento.

### `docker-web/`

- `index.html`: página HTML en español con el título `Mi web en Docker`, un encabezado `Hola desde Docker` y un texto indicando que corre dentro de un contenedor con Nginx.
