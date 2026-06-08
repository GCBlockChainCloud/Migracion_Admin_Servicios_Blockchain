# Semana 1: Contenedores Docker

Esta carpeta contiene ejercicios sencillos para practicar los conceptos iniciales de Docker: imagenes, contenedores, puertos, variables de entorno y uso de archivos `Dockerfile`.

## Comandos basicos de Docker

Verificar la instalacion de Docker:

```bash
docker --version
```

Descargar una imagen desde Docker Hub:

```bash
docker pull ubuntu:22.04
```

Listar imagenes descargadas:

```bash
docker images
```

Ejecutar un contenedor interactivo:

```bash
docker run -it ubuntu:22.04 bash
```

Listar contenedores en ejecucion:

```bash
docker ps
```

Listar todos los contenedores, incluso detenidos:

```bash
docker ps -a
```

Detener un contenedor:

```bash
docker stop NOMBRE_O_ID_DEL_CONTENEDOR
```

Eliminar un contenedor detenido:

```bash
docker rm NOMBRE_O_ID_DEL_CONTENEDOR
```

Eliminar una imagen:

```bash
docker rmi NOMBRE_O_ID_DE_LA_IMAGEN
```

Construir una imagen desde un `Dockerfile`:

```bash
docker build -t nombre-imagen .
```

Ejecutar una imagen publicada en un puerto local:

```bash
docker run --rm -p 8080:80 nombre-imagen
```

Ver logs de un contenedor:

```bash
docker logs NOMBRE_O_ID_DEL_CONTENEDOR
```

## Ejercicios

Ejecuta cada bloque de comandos desde la carpeta indicada.

### 1. `docker-ubuntu`

Ejercicio para crear una imagen basada en Ubuntu y mantener un contenedor activo. Sirve para practicar `docker build`, `docker run`, `docker ps` y `docker stop`.

```bash
cd SEMANA_1/docker-ubuntu
docker build -t semana1-ubuntu .
docker run --name contenedor-ubuntu -d semana1-ubuntu
docker ps
docker logs contenedor-ubuntu
docker stop contenedor-ubuntu
docker rm contenedor-ubuntu
```

### 2. `app_python`

Ejercicio minimo con Python. Construye una imagen que ejecuta un script y muestra un mensaje en consola.

```bash
cd SEMANA_1/app_python
docker build -t semana1-python .
docker run --rm semana1-python
```

### 3. `docker-web`

Ejercicio de pagina web estatica con Nginx. Permite practicar publicacion de puertos con `-p`.

```bash
cd SEMANA_1/docker-web
docker build -t semana1-web .
docker run --rm --name web-docker -p 8080:80 semana1-web
```

Abrir en el navegador:

```text
http://localhost:8080
```

### 4. `docker-flask`

Ejercicio de API sencilla con Flask. Expone una ruta principal y una ruta con parametro.

```bash
cd SEMANA_1/docker-flask
docker build -t semana1-flask .
docker run --rm --name api-flask -p 5000:5000 semana1-flask
```

Probar en el navegador o con `curl`:

```bash
curl http://localhost:5000
curl http://localhost:5000/saludo/Ana
```

### 5. `docker-node`

Ejercicio con Node.js y Express. Muestra como dockerizar un servidor web sencillo en JavaScript.

```bash
cd SEMANA_1/docker-node
docker build -t semana1-node .
docker run --rm --name api-node -p 3000:3000 semana1-node
```

Probar endpoints:

```bash
curl http://localhost:3000
curl http://localhost:3000/estado
```

### 6. `docker-nginx`

Segundo ejemplo con Nginx para reforzar el uso de imagenes base y copia de archivos HTML dentro del contenedor.

```bash
cd SEMANA_1/docker-nginx
docker build -t semana1-nginx .
docker run --rm --name nginx-ejemplo -p 8081:80 semana1-nginx
```

Abrir en el navegador:

```text
http://localhost:8081
```

### 7. `docker-env`

Ejercicio para practicar variables de entorno con `-e`. El contenedor lee valores desde `NOMBRE` y `ENTORNO`.

```bash
cd SEMANA_1/docker-env
docker build -t semana1-env .
docker run --rm semana1-env
docker run --rm -e NOMBRE=Maria -e ENTORNO=produccion semana1-env
```

## Limpieza recomendada

Despues de practicar, puedes limpiar contenedores detenidos, imagenes y recursos no usados:

```bash
docker container prune
docker image prune
docker system prune
```

Usa estos comandos con cuidado, porque eliminan recursos que Docker considera no utilizados.
