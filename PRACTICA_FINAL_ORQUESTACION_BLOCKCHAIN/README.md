# Orquestación de un smart contract con Kubernetes

Implementación de un registro simplificado de certificados académicos
digitales relacionado con el proyecto de titulación:

> Arquitectura blockchain en la nube para la emisión y validación de
> certificados académicos digitales del Instituto Universitario Japón.


## Datos generales

- Estudiante: **Byron Giovanny Cholca**
- Asignatura: **MIGRACION Y ADMINISTRACIÓN DE SERVICIOS**
- Docente: **Jonathan Rosero**
- Práctica: **Orquestación de blockchain utilizando Kubernetes**

## Objetivo

Demostrar:

- Despliegue de un smart contract mediante un Job.
- Deployment inicial con tres réplicas.
- Service para mantener un punto estable de acceso.
- Escalamiento en caliente de tres a cinco réplicas.
- Rolling update de la imagen V1 a V2.
- Historial de ReplicaSets.

## Arquitectura

```text
                         Kubernetes

                  Deployment contract-service
                             |
                         ReplicaSet
                       /      |      \
                    Pod 1   Pod 2   Pod 3
                       \      |      /
                      Service HTTP

  Job Hardhat ------------------------------> Ganache
  Pods contract-service --------------------> Ganache
```

El Job despliega el contrato una sola vez. Las réplicas permanecen disponibles
para demostrar escalamiento, balanceo y actualización gradual.

## Smart contract

`AcademicCertificateRegistry` permite:

- Emitir certificados.
- Consultarlos.
- Validar el hash del documento.
- Revocarlos.
- Consultar su existencia.
- Consultar la versión del contrato.

La versión 2 agrega la función `institution()`. El documento académico completo
no se almacena en blockchain.

## Requisitos

- Docker Desktop.
- Kind.
- kubectl.
- PowerShell.
- Git.

Verificar:

```powershell
docker --version
kind --version
kubectl version --client
git --version
```

## 1. Crear el clúster

Ejecutar desde la raíz de esta carpeta:

```powershell
kind create cluster --name practica-blockchain
kubectl get nodes
```

## 2. Construir y cargar la imagen V1

```powershell
docker build --target v1 -t academic-certificate-tools:v1 .
kind load docker-image academic-certificate-tools:v1 --name practica-blockchain
```

## 3. Crear el namespace y Ganache

```powershell
kubectl apply -f .\kubernetes\00-namespace.yaml
kubectl apply -f .\kubernetes\01-ganache.yaml
kubectl -n practica-blockchain rollout status deployment/ganache
kubectl -n practica-blockchain get pods
```

## 4. Desplegar el contrato

```powershell
kubectl apply -f .\kubernetes\02-deploy-contract-job.yaml
kubectl -n practica-blockchain wait --for=condition=complete job/deploy-academic-certificate --timeout=120s
kubectl -n practica-blockchain logs job/deploy-academic-certificate
```

El log presenta la dirección y versión del contrato. 

## 5. Crear tres réplicas

```powershell
kubectl apply -f .\kubernetes\03-contract-service.yaml
kubectl -n practica-blockchain rollout status deployment/contract-service
kubectl -n practica-blockchain get pods -o wide
kubectl -n practica-blockchain get rs
```

El resultado esperado es un Deployment `3/3` y tres Pods del servicio en estado
`Running`.

## 6. Probar el Service

En una terminal independiente:

```powershell
kubectl -n practica-blockchain port-forward service/contract-service 8080:80
```

En otra terminal:

```powershell
Invoke-RestMethod http://localhost:8080/health
Invoke-RestMethod http://localhost:8080/version
Invoke-RestMethod http://localhost:8080/blockchain
```

La versión inicial es `1.0.0`.

## 7. Primer cambio: escalar a cinco

```powershell
kubectl -n practica-blockchain scale deployment/contract-service --replicas=5
kubectl -n practica-blockchain rollout status deployment/contract-service
kubectl -n practica-blockchain get pods -o wide
kubectl -n practica-blockchain get rs
```

## 8. Construir y cargar la versión 2

```powershell
docker build --target v2 -t academic-certificate-tools:v2 .
kind load docker-image academic-certificate-tools:v2 --name practica-blockchain
```

## 9. Segundo cambio: rolling update

Ejecutar:

```powershell
kubectl -n practica-blockchain set image deployment/contract-service contract-service=academic-certificate-tools:v2
kubectl -n practica-blockchain rollout status deployment/contract-service
```

Durante el cambio se puede observar el reemplazo de Pods:

```powershell
kubectl -n practica-blockchain get pods -w
```

Al finalizar:

```powershell
kubectl -n practica-blockchain get pods -o wide
kubectl -n practica-blockchain get rs
kubectl -n practica-blockchain rollout history deployment/contract-service
```

Verificar la nueva versión:

```powershell
Invoke-RestMethod http://localhost:8080/version
```

El resultado cambia a `2.0.0`.

## Solución de problemas

Ver todos los recursos:

```powershell
kubectl -n practica-blockchain get all
```

Ver eventos:

```powershell
kubectl -n practica-blockchain get events --sort-by=.metadata.creationTimestamp
```

Ver logs:

```powershell
kubectl -n practica-blockchain logs deployment/ganache
kubectl -n practica-blockchain logs deployment/contract-service
kubectl -n practica-blockchain logs job/deploy-academic-certificate
```

Si se necesita repetir el Job:

```powershell
kubectl -n practica-blockchain delete job deploy-academic-certificate
kubectl apply -f .\kubernetes\02-deploy-contract-job.yaml
```

## Limpieza

```powershell
kind delete cluster --name practica-blockchain
```

## Seguridad

La clave privada incluida corresponde a una cuenta determinista de Ganache y
solo se utiliza en esta red local. No debe utilizarse en una red pública ni
con fondos reales.
