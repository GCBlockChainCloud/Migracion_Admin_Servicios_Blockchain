# Tarea 1 - Implementación inicial de Smart Contract en contenedor Docker

## Información de la práctica

Práctica desarrollada para la asignatura de Administración Cloud, basada en el proyecto proporcionado por la UTPL para la implementación de contratos inteligentes utilizando Solidity, Hardhat y Docker.

---

## Repositorio de referencia

Proyecto original proporcionado por el docente:

https://github.com/GCBlockChainCloud/administracion_cloud_utpl/tree/main/SEMANA_3/blockchain

El repositorio contiene:

* Contrato inteligente `RegistroTitulos.sol`
* Dockerfile para construcción de la imagen
* Configuración Hardhat
* Scripts de despliegue y pruebas
* Dependencias del proyecto Blockchain

---

## Imagen Docker Hub

Imagen publicada:

```text
giovannydevops/registro-titulos-blockchain:1.0
```

URL pública:

```text
https://hub.docker.com/r/giovannydevops/registro-titulos-blockchain
```

La imagen contiene:

* Node.js
* Hardhat
* Contrato Solidity
* Scripts de prueba
* Dependencias necesarias para compilación y ejecución

---

## Descarga de la imagen

```bash
docker pull giovannydevops/registro-titulos-blockchain:1.0
```

---

## Verificación de compilación

Ejecutar:

```bash
docker run --rm giovannydevops/registro-titulos-blockchain:1.0
```

Este comando ejecuta:

```bash
npx hardhat compile
```

Resultado esperado:

```text
Compiled successfully
```

---

## Ejecución de prueba del contrato

Ejecutar:

```bash
docker run --rm giovannydevops/registro-titulos-blockchain:1.0 npx hardhat run scripts/crear-titulo.ts
```

Este script realiza automáticamente:

1. Creación de una red temporal Hardhat.
2. Despliegue del contrato RegistroTitulos.
3. Generación de hashes de prueba.
4. Registro de un título académico.
5. Verificación de la información registrada.
6. Presentación de resultados en consola.

---

## Construcción de la imagen

Desde la carpeta del proyecto:

```bash
docker build -t giovannydevops/registro-titulos-blockchain:1.0 .
```

Verificar imagen:

```bash
docker images
```

---

## Publicación en Docker Hub

Iniciar sesión:

```bash
docker login
```

Publicar imagen:

```bash
docker push giovannydevops/registro-titulos-blockchain:1.0
```

---

## Evidencia de funcionamiento

Comandos ejecutados:

```bash
docker pull giovannydevops/registro-titulos-blockchain:1.0

docker run --rm giovannydevops/registro-titulos-blockchain:1.0

docker run --rm giovannydevops/registro-titulos-blockchain:1.0 npx hardhat run scripts/crear-titulo.ts
```

---

## Conclusión

Durante esta práctica se implementó y distribuyó un contrato inteligente mediante Docker, permitiendo su compilación y ejecución de forma reproducible en cualquier entorno. El uso de Docker Hub facilitó la publicación y reutilización de la imagen, mientras que Hardhat permitió validar el funcionamiento del contrato de registro y verificación de títulos académicos. Esta práctica demuestra cómo las tecnologías Blockchain y los contenedores pueden integrarse para construir soluciones portables, escalables y verificables.
