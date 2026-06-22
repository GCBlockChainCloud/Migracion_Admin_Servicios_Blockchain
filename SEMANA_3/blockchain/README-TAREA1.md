# Semana 3 - Registro de Títulos Blockchain con Docker

## Autor

**Giovanny Cholca**

Especialización en Sistemas de Información mención Blockchain y Arquitectura en la Nube

---

# Descripción

Esta práctica implementa un entorno de desarrollo Blockchain utilizando Docker, Hardhat y Solidity para el registro y validación de títulos académicos.

La solución permite:

* Compilar contratos inteligentes desarrollados en Solidity.
* Ejecutar pruebas automatizadas mediante Hardhat.
* Empaquetar el entorno en una imagen Docker reutilizable.
* Publicar la imagen en Docker Hub para su distribución y reutilización.
* Ejecutar el contrato desde cualquier equipo sin necesidad de instalar dependencias adicionales.

---

# Repositorio GitHub

Repositorio base proporcionado para la práctica:

https://github.com/GCBlockChainCloud/administracion_cloud_utpl/tree/main/SEMANA_3/blockchain

El repositorio contiene:

* Dockerfile
* Contrato inteligente Solidity
* Scripts de despliegue
* Configuración de Hardhat
* Dependencias necesarias para la ejecución

---

# Imagen Docker Hub

Repositorio público Docker Hub:

https://hub.docker.com/r/giovannydevops/registro-titulos-blockchain

Imagen utilizada:

```bash
giovannydevops/registro-titulos-blockchain:1.0
```

---

# Descargar la imagen

```bash
docker pull giovannydevops/registro-titulos-blockchain:1.0
```

---

# Verificar compilación del contrato

Ejecutar el comando por defecto de la imagen:

```bash
docker run --rm giovannydevops/registro-titulos-blockchain:1.0
```

Este comando ejecuta:

```bash
npx hardhat compile
```

---

# Ejecutar prueba del contrato

```bash
docker run --rm giovannydevops/registro-titulos-blockchain:1.0 npx hardhat run scripts/crear-titulo.ts
```

La ejecución realiza automáticamente:

1. Creación de una blockchain temporal Hardhat.
2. Despliegue del contrato RegistroTitulos.
3. Registro de un título de prueba.
4. Generación de hashes criptográficos.
5. Verificación de integridad del documento.

---

# Construcción de la imagen

Para reproducir la construcción localmente:

Clonar el repositorio:

```bash
git clone https://github.com/GCBlockChainCloud/administracion_cloud_utpl.git
```

Ingresar al directorio:

```bash
cd administracion_cloud_utpl/SEMANA_3/blockchain
```

Construir la imagen:

```bash
docker build -t giovannydevops/registro-titulos-blockchain:1.0 .
```

---

# Publicación en Docker Hub

Autenticarse en Docker Hub:

```bash
docker login
```

Publicar la imagen:

```bash
docker push giovannydevops/registro-titulos-blockchain:1.0
```

---

# Verificación

Comprobar imágenes locales:

```bash
docker images
```

Comprobar descarga desde Docker Hub:

```bash
docker pull giovannydevops/registro-titulos-blockchain:1.0
```

---

# Tecnologías utilizadas

* Docker
* Docker Hub
* Hardhat
* Solidity
* Node.js
* Blockchain
* Smart Contracts

---

# Conclusión

Durante esta práctica se implementó y distribuyó un contrato inteligente utilizando Docker como mecanismo de empaquetado y Docker Hub como repositorio de distribución. La solución permitió validar el proceso completo de compilación y ejecución de contratos Solidity mediante Hardhat, demostrando cómo los contenedores facilitan la portabilidad, reproducibilidad y despliegue de aplicaciones Blockchain en diferentes entornos de trabajo.
