# Guion docente — Semana 3: Kubernetes aplicado a Blockchain

**Módulo:** Migración y Administración de Servicios en la Nube  
**Clase:** Semana 5 — Kubernetes  
**Presentación base:** `Semana_3_Kubernetes_Blockchain_UTPL_REPARADA.pptx`  
**Duración orientativa:** 90 a 110 minutos, incluyendo preguntas y transición a la práctica.

> **Uso sugerido:** este documento está redactado como un guion que puede leerse o adaptarse durante la sesión. Cada sección corresponde a una diapositiva de la presentación. Las preguntas sugeridas ayudan a mantener la clase participativa; no es obligatorio formularlas todas.

---

## Diapositiva 1 — Kubernetes: orquestación de contenedores

**Guion**

Bienvenidos a la quinta semana del módulo. Hasta este punto ya recorrimos dos niveles importantes. En la primera clase entendimos cómo pasar de un servidor completo a contenedores, y vimos que Docker nos permite empaquetar una aplicación con sus dependencias. En la segunda clase usamos Docker Compose para levantar varios servicios relacionados, por ejemplo un frontend, un backend y una base de datos.

Hoy damos el siguiente paso: **Kubernetes**. La pregunta que guía la clase es: ¿qué ocurre cuando ya no tenemos un solo servidor y tres contenedores, sino varios servicios, múltiples réplicas, diferentes nodos, actualizaciones frecuentes y una necesidad real de alta disponibilidad?

Kubernetes no reemplaza el conocimiento de Docker; lo utiliza como base conceptual. Docker nos ayuda a crear imágenes y ejecutar contenedores. Kubernetes utiliza imágenes de contenedor y coordina cómo, dónde y cuántas instancias de esos contenedores se ejecutan dentro de un clúster.

En esta clase conectaremos Kubernetes con redes blockchain. La idea no es pensar únicamente en una API web tradicional. También veremos cómo desplegar nodos RPC, validadores, indexadores, exploradores de bloques y servicios off-chain de forma organizada, observable y escalable.

**Transición**

Primero revisemos el mapa general de los temas que vamos a recorrer.

---

## Diapositiva 2 — Temas de la clase

**Guion**

La clase está organizada en siete bloques. Primero definiremos qué es Kubernetes y por qué apareció. Después veremos los problemas operativos que resuelve: escalamiento, fallos, red, actualizaciones y configuración.

Luego entraremos a la arquitectura del clúster: el plano de control y los nodos worker. Esta parte es muy importante porque Kubernetes no es una sola aplicación; es un conjunto de componentes que toman decisiones y ejecutan cargas de trabajo.

A continuación revisaremos los objetos principales: Pods, Deployments, Services, Ingress y Volumes. Después abordaremos ConfigMaps, Secrets, Namespaces, Labels y NetworkPolicies, que permiten separar ambientes, etiquetar recursos, proteger comunicaciones y configurar aplicaciones.

Finalmente veremos `kubectl`, actualizaciones graduales, rollback, autoscaling y la aplicación de estos conceptos a una red blockchain.

La meta no es memorizar cada manifiesto YAML hoy. La meta es comprender el modelo mental de Kubernetes: **declarar el estado deseado y permitir que el sistema lo mantenga**.

**Pregunta sugerida**

¿Cuál creen que es la diferencia entre “ejecutar un contenedor” y “operar una aplicación distribuida durante meses”?

---

## Diapositiva 3 — De monolito a orquestación

**Guion**

Este diagrama resume una evolución frecuente en arquitectura de software.

En un monolito, tenemos una aplicación grande, normalmente empaquetada y desplegada como una sola unidad. Puede funcionar muy bien, especialmente en sistemas pequeños o al inicio de un producto. El reto aparece cuando cada módulo necesita evolucionar a velocidades distintas, cuando varios equipos trabajan en partes diferentes o cuando una parte requiere más recursos que otra.

Al pasar a microservicios, dividimos responsabilidades: por ejemplo, autenticación, usuarios, pagos, consulta de blockchain, indexación y notificaciones. Esto permite independencia, pero añade comunicación de red, más despliegues y más puntos de fallo.

Docker ayuda a que cada componente viaje de forma reproducible: una API FastAPI, un frontend React, una base de datos, un indexador o un nodo blockchain pueden empaquetarse en imágenes distintas.

Pero cuando tenemos muchos contenedores distribuidos en varios nodos, Docker por sí solo no responde preguntas como: ¿qué pasa si un nodo falla?, ¿cómo mantengo tres réplicas de una API?, ¿cómo actualizo sin detener todo?, ¿cómo doy un nombre estable a pods que cambian de IP?

Ahí entra Kubernetes. Su función no es convertir un monolito en microservicios. Su función es **operar de manera coordinada las unidades que ya decidimos contenerizar**.

**Idea clave para enfatizar**

Docker empaqueta. Kubernetes coordina, observa, reemplaza, escala y expone.

---

## Diapositiva 4 — ¿Qué es Kubernetes?

**Guion**

Kubernetes es una plataforma de orquestación de contenedores. En términos prácticos, administra recursos de cómputo, red y almacenamiento para que una aplicación pueda ejecutarse de forma distribuida sin administrar cada contenedor manualmente.

El concepto más importante es que Kubernetes funciona de manera **declarativa**. En lugar de dar una secuencia de instrucciones del tipo “ejecuta este contenedor aquí, luego reinícialo allá”, declaramos el resultado que queremos: por ejemplo, “quiero tres réplicas de esta API usando esta imagen, expuestas mediante este servicio y conectadas a esta configuración”.

Kubernetes observa el estado real del clúster y lo compara constantemente con el estado deseado. Si faltan réplicas, crea nuevas. Si un contenedor falla, intenta reemplazarlo. Si una versión nueva no funciona, permite regresar a una versión anterior.

También es importante aclarar qué no es. Kubernetes no es una máquina virtual, no es un sistema operativo y no es simplemente Docker con más comandos. Es un sistema de control para administrar cargas de trabajo basadas en contenedores a escala.

En los nodos modernos, Kubernetes suele usar runtimes compatibles con CRI, como `containerd` o `CRI-O`. Las imágenes Docker siguen siendo compatibles porque la industria usa estándares de imagen de contenedor, no porque Kubernetes dependa del daemon de Docker.

**Pregunta sugerida**

¿En qué parte del problema creen que Kubernetes aporta más valor: construir imágenes, ejecutar un proceso, o mantener una aplicación disponible?

---

## Diapositiva 5 — Origen: de Borg a Kubernetes

**Guion**

Kubernetes no apareció desde cero. Su origen está relacionado con la experiencia interna de Google administrando grandes cantidades de cargas de trabajo distribuidas mediante sistemas como Borg y Omega.

Durante los años dos mil, Google ya necesitaba una forma de colocar, vigilar y reubicar aplicaciones en grandes clústeres. Kubernetes toma muchas de esas ideas, pero las convierte en una plataforma abierta, extensible y accesible para la comunidad.

En 2014 el proyecto se publicó de forma abierta. En 2015 apareció Kubernetes 1.0 y el proyecto fue entregado a la Cloud Native Computing Foundation, o CNCF. Desde entonces se convirtió en una pieza central del ecosistema cloud-native.

Actualmente encontramos Kubernetes administrado en proveedores como Amazon EKS, Google Kubernetes Engine, Azure Kubernetes Service, OpenShift y múltiples distribuciones on-premise. Esto es importante porque Kubernetes no está limitado a una sola nube. Podemos usar el mismo modelo conceptual en local, en infraestructura propia, en una nube pública o en un entorno híbrido.

La lección es que Kubernetes no nació para “usar contenedores porque sí”. Nació para resolver un problema operativo real: administrar aplicaciones distribuidas de forma consistente, repetible y resiliente.

**Transición**

Ahora que entendemos el origen, veamos específicamente qué problemas operativos resuelve.

---

## Diapositiva 6 — ¿Qué problema resuelve?

**Guion**

Cuando una aplicación distribuida crece, aparecen problemas repetitivos.

El primero son los fallos. Si un contenedor falla o un nodo físico deja de funcionar, no queremos que una persona tenga que detectar el problema y levantar manualmente todo otra vez. Kubernetes busca reemplazar o reubicar cargas de trabajo según las reglas definidas.

El segundo es el escalamiento. Si una API recibe más solicitudes, no queremos copiar comandos `docker run` manualmente ni mantener una lista de direcciones IP. Queremos aumentar réplicas usando una definición declarativa.

El tercero es la red. Los Pods son efímeros y pueden cambiar de IP. Los clientes no deberían depender de la IP de un Pod concreto. Kubernetes introduce Services y DNS internos para entregar nombres estables.

También resuelve actualizaciones. En lugar de apagar todo el sistema, instalar una nueva versión y esperar que funcione, Kubernetes puede reemplazar progresivamente las instancias antiguas por nuevas.

Finalmente, separa configuración, secretos y datos persistentes. El código de la aplicación no debería contener credenciales, cadenas de conexión o claves privadas.

Para una red blockchain, estos problemas son aún más sensibles. Un nodo RPC puede escalar, pero un validador no se trata como una réplica genérica. El ledger necesita persistencia, las claves necesitan protección y la participación en consenso requiere gobernanza.

---

## Diapositiva 7 — El cambio mental: estado deseado

**Guion**

Esta es una de las diapositivas más importantes de toda la clase.

En un sistema tradicional, solemos pensar de manera imperativa: primero ejecuto un comando, luego otro, luego verifico si funcionó. Kubernetes cambia esa forma de trabajo hacia un modelo declarativo.

En el ejemplo declaramos un `Deployment` llamado `api` con tres réplicas y una imagen específica. No estamos indicando manualmente en qué nodo debe correr cada contenedor ni escribiendo un script para verificar uno por uno que sigan activos.

La sección `spec` expresa nuestra intención: tres réplicas de la aplicación. La sección `status` representa lo que Kubernetes observa en realidad: por ejemplo, tres Pods disponibles, dos disponibles o un error de despliegue.

Entre ambas aparece el control loop, o bucle de reconciliación. Kubernetes observa, compara y corrige. Si declaramos tres réplicas y actualmente existen dos, un controlador intentará crear la tercera. Si declaramos una imagen nueva, el controlador ejecutará la estrategia de actualización correspondiente.

Este modelo se parece a definir una condición objetivo. No le decimos al sistema cada movimiento interno; le declaramos el resultado esperado y Kubernetes trabaja para mantenerlo.

**Frase de énfasis**

En Kubernetes no administramos contenedores individuales como una colección de comandos. Administramos el estado deseado de una plataforma.

---

## Diapositiva 8 — Anatomía de un clúster

**Guion**

Un clúster de Kubernetes se divide, de manera general, en dos grandes grupos de componentes.

El primero es el **plano de control**, o control plane. Este es el cerebro del sistema. Recibe solicitudes, almacena el estado del clúster, decide dónde colocar los Pods y ejecuta controladores que verifican que lo declarado coincida con lo observado.

El segundo grupo son los **nodos worker**. Estos son los servidores —virtuales o físicos— donde realmente se ejecutan los Pods y los contenedores.

Cada nodo worker ejecuta un agente llamado kubelet, un runtime de contenedores y componentes de red. El plano de control decide que un Pod debe existir; el worker node recibe esa instrucción y crea los contenedores necesarios.

Es importante no confundirlos. El plano de control normalmente no ejecuta nuestras aplicaciones de negocio. Su tarea principal es gobernar el clúster. Los worker nodes son quienes ejecutan las cargas de trabajo.

En un entorno de nube gestionado, el proveedor puede administrar gran parte del plano de control. En un clúster on-premise, la organización asume una mayor responsabilidad sobre ambos componentes.

**Pregunta sugerida**

Si un worker node falla, ¿qué componente debería detectar la diferencia entre el estado deseado y el estado real?

---

## Diapositiva 9 — Componentes del plano de control

**Guion**

El primer componente es el `kube-apiserver`. Este es el punto de entrada principal al clúster. Cuando ejecutamos `kubectl apply`, cuando un pipeline de CI/CD despliega un manifiesto o cuando un controlador consulta información, normalmente se comunica con la API de Kubernetes.

El segundo componente es `etcd`. Es una base de datos distribuida de tipo clave-valor que almacena el estado del clúster. Allí se registra qué recursos existen, qué configuración se declaró y cuál es la información de coordinación necesaria. Por eso `etcd` es crítico y debe protegerse y respaldarse adecuadamente.

El tercero es el `kube-scheduler`. Cuando existe un Pod pendiente, el scheduler decide en qué nodo debe ejecutarse. Considera recursos disponibles, restricciones, afinidad, toleraciones y otras reglas de programación.

El cuarto es el `controller-manager`. Aquí viven controladores que comparan estado deseado y real: controladores de réplicas, nodos, endpoints y muchos otros.

Finalmente, el cloud-controller-manager se utiliza cuando el clúster se integra con una nube pública. Permite, por ejemplo, aprovisionar balanceadores, discos o direcciones IP usando las APIs del proveedor.

**Idea clave**

El plano de control no es un componente único: es una serie de componentes cooperando mediante la API y el estado almacenado.

---

## Diapositiva 10 — Componentes del nodo worker

**Guion**

Ahora veamos qué existe dentro de un nodo worker.

El `kubelet` es el agente local de Kubernetes. Recibe las especificaciones de Pods asignadas a ese nodo y se asegura de que los contenedores requeridos estén ejecutándose. También reporta salud y estado al plano de control.

El runtime de contenedores es el componente que descarga imágenes y crea contenedores. En entornos actuales es frecuente encontrar `containerd` o `CRI-O`. Kubernetes se comunica con estos runtimes usando la Container Runtime Interface, conocida como CRI.

El `kube-proxy` participa en las reglas de red necesarias para que los Services funcionen y para que el tráfico llegue a los Pods correctos. Dependiendo de la implementación de red del clúster, puede trabajar junto con componentes como iptables, IPVS o eBPF.

La idea importante es que el worker node no decide la arquitectura completa. No sabe por sí mismo cuántos Pods debería tener una aplicación. Recibe instrucciones del plano de control y las ejecuta localmente.

Para un administrador, esto permite separar responsabilidades: el control plane gobierna; los workers ejecutan.

---

## Diapositiva 11 — Objetos de Kubernetes

**Guion**

Kubernetes se usa mediante objetos declarativos, normalmente escritos en YAML o JSON.

En este ejemplo vemos los elementos que aparecen una y otra vez. `apiVersion` indica la familia y versión de la API. `kind` indica qué tipo de recurso estamos creando: aquí es un `Deployment`.

En `metadata` definimos identidad: nombre, namespace, labels y annotations. Las labels son especialmente importantes porque permiten seleccionar recursos de manera flexible.

La sección `spec` define el estado deseado. En este caso, queremos tres réplicas de una aplicación.

La sección `status` no es lo que nosotros editamos normalmente. Es lo que Kubernetes informa después de intentar llevar la intención a la realidad: cuántas réplicas están disponibles, cuáles fallaron, qué condiciones existen y qué generación del objeto se observó.

Cada objeto tiene un propósito: un Deployment administra réplicas sin estado, un Service entrega un punto de acceso estable, un Secret almacena datos sensibles, un PVC solicita almacenamiento persistente.

La habilidad central en Kubernetes es aprender a convertir requerimientos de arquitectura en objetos declarativos conectados entre sí.

**Transición**

El primer objeto que debemos entender es el Pod.

---

## Diapositiva 12 — Pod: la unidad mínima desplegable

**Guion**

Un Pod es la unidad mínima desplegable en Kubernetes. No es exactamente lo mismo que un contenedor, aunque muchas veces contiene un solo contenedor principal.

Un Pod puede incluir varios contenedores que comparten red, almacenamiento y ciclo de vida. Esto permite patrones como un contenedor principal de aplicación acompañado por un sidecar de logs, proxy o métricas.

Todos los contenedores dentro de un Pod comparten una dirección IP y pueden comunicarse por `localhost`. También pueden compartir volúmenes definidos para el Pod.

La advertencia importante es que los Pods son efímeros. No debemos pensar que un Pod es una máquina permanente. Puede morir, ser reemplazado, cambiar de nodo o cambiar de IP. En producción no conviene crear Pods individuales manualmente; conviene utilizar controladores como Deployments o StatefulSets.

En blockchain esto es especialmente relevante. Un nodo validador puede requerir una identidad estable, almacenamiento persistente y un orden de arranque predecible. Por eso un Pod aislado o un Deployment genérico no siempre son adecuados para una red de consenso.

**Pregunta sugerida**

¿Qué información se perdería si un Pod que contiene un nodo blockchain desaparece y no tiene almacenamiento persistente?

---

## Diapositiva 13 — Ciclo de vida del Pod

**Guion**

Un Pod puede pasar por distintos estados.

`Pending` significa que Kubernetes aceptó el Pod, pero todavía está esperando asignación a un nodo o descarga de imágenes.

`Running` indica que al menos los contenedores principales se ejecutan, aunque esto no garantiza por sí solo que la aplicación esté lista para recibir tráfico.

`Succeeded` aparece cuando una tarea termina correctamente; es común en Jobs.

`Failed` indica que la ejecución terminó con error no recuperado.

`Unknown` significa que el plano de control no puede determinar el estado, por ejemplo porque el nodo dejó de reportar.

Aquí aparecen las probes, o comprobaciones de salud. Una `livenessProbe` sirve para detectar un contenedor que está vivo como proceso pero bloqueado o no funcional; si falla repetidamente, Kubernetes puede reiniciarlo. Una `readinessProbe` indica si el Pod está listo para recibir tráfico. Un Pod puede estar `Running` y aun así no estar listo.

Para una blockchain, una readiness probe podría comprobar que el endpoint RPC responde, que el nodo alcanzó cierta altura de bloque o que tiene suficiente conectividad P2P. No es lo mismo que simplemente verificar que el proceso está ejecutándose.

**Idea clave**

“Proceso iniciado” no significa “servicio listo”. Las probes transforman esa diferencia en una regla operativa.

---

## Diapositiva 14 — Controladores de carga de trabajo

**Guion**

Kubernetes ofrece distintos controladores porque no todas las aplicaciones se comportan igual.

Un `Deployment` es ideal para APIs, frontends y servicios sin estado. Puede tener varias réplicas idénticas y permite actualizaciones graduales y rollback.

Un `StatefulSet` es apropiado cuando cada réplica necesita identidad propia, nombres estables o almacenamiento individual persistente. Es frecuente en bases de datos, brokers de mensajería y nodos blockchain.

Un `DaemonSet` garantiza que una copia de un Pod se ejecute en cada nodo —o en un subconjunto de nodos—. Es útil para agentes de monitoreo, logging, seguridad o networking.

Un `Job` ejecuta una tarea hasta completarla. Por ejemplo, una migración de base de datos, un proceso de indexación puntual o un script de despliegue de contrato. Un `CronJob` programa Jobs recurrentes, como backups, verificaciones o consolidación de métricas.

La selección del controlador no debe hacerse por costumbre. Debe responder a la naturaleza de la carga. En blockchain, confundir una aplicación stateful con una stateless puede afectar identidad, persistencia y recuperación ante fallos.

---

## Diapositiva 15 — Deployment: réplicas y actualizaciones

**Guion**

Un Deployment mantiene un conjunto de réplicas equivalentes. En el ejemplo vemos una transición desde la versión 1.0 hacia la 1.1.

Durante un rolling update, Kubernetes no elimina todas las instancias antiguas de golpe. Va creando Pods con la nueva versión y retirando progresivamente Pods con la versión anterior, según la estrategia configurada. Esto disminuye el riesgo de indisponibilidad.

Si detectamos que la nueva versión tiene un error, podemos usar un rollback para regresar a una revisión previa. Esto es mucho más seguro que editar servidores manualmente, porque el historial de despliegue está asociado al objeto.

En una API FastAPI, por ejemplo, podríamos pasar de la imagen `api:1.0` a `api:1.1` y dejar que Kubernetes sustituya los Pods gradualmente. Los clientes seguirían usando el Service estable, sin saber qué Pod específico los atiende.

No debemos aplicar esta lógica sin pensar a un conjunto de validadores blockchain. Cambiar simultáneamente una versión de software de consenso puede tener implicaciones de red y compatibilidad. Para esos casos se definen procedimientos de actualización controlada, mantenimiento y validación de quórum.

**Frase de cierre**

Deployment no significa simplemente “subir una nueva imagen”; significa administrar una evolución controlada de réplicas.

---

## Diapositiva 16 — Service: nombre estable para Pods cambiantes

**Guion**

Los Pods pueden cambiar de IP, reiniciarse o reubicarse. Si el frontend tuviera que llamar directamente a la IP de cada backend, la arquitectura sería frágil.

Un Service resuelve este problema proporcionando una dirección y nombre estables. El frontend puede llamar a `backend:80`, y Kubernetes se encarga de dirigir el tráfico hacia los Pods que tengan las labels correspondientes.

`ClusterIP` expone el servicio solo dentro del clúster. Es el tipo común para bases de datos internas, APIs privadas o servicios entre microservicios.

`NodePort` abre un puerto en cada nodo. Es útil para ciertos laboratorios, pero no suele ser la opción preferida en producción.

`LoadBalancer` solicita un balanceador externo al proveedor cloud, permitiendo exponer un servicio hacia Internet.

Un Service headless no crea una IP virtual única; en cambio, permite resolver DNS hacia Pods individuales. Esto es muy útil para StatefulSets, donde necesitamos identificar nodos concretos como `validator-0`, `validator-1` y `validator-2`.

**Ejemplo blockchain**

Un nodo RPC público podría exponerse mediante un LoadBalancer o Ingress. En cambio, nodos validadores internos podrían comunicarse por DNS usando un Service headless.

---

## Diapositiva 17 — Ingress y Gateway

**Guion**

Ingress es un mecanismo orientado a tráfico HTTP y HTTPS. Permite recibir solicitudes desde dominios externos y enrutar cada ruta o subdominio hacia un Service interno.

Por ejemplo, `app.midominio.com` puede dirigir al frontend React, mientras que `api.midominio.com` puede dirigir al backend FastAPI. Para que esto funcione se necesita un Ingress Controller, como NGINX, Traefik o un controlador administrado por el proveedor cloud.

El Ingress también suele manejar certificados TLS, reglas de host, rutas y redirecciones. Esto permite centralizar el acceso web a la aplicación.

Sin embargo, no todos los protocolos blockchain son HTTP convencional. JSON-RPC puede funcionar sobre HTTP o WebSocket, pero la conectividad P2P de un nodo blockchain, puertos de descubrimiento o conexiones TCP persistentes requieren un diseño diferente.

En esos casos evaluamos Services de tipo LoadBalancer, Gateway API, configuraciones L4, balanceadores específicos o redes privadas. También debemos aplicar autenticación, rate limiting y políticas de acceso a los endpoints RPC para evitar abuso.

**Idea clave**

Ingress es excelente para aplicaciones web; no es una solución universal para todo tipo de tráfico de infraestructura.

---

## Diapositiva 18 — Red en Kubernetes

**Guion**

Kubernetes busca ofrecer un modelo de red relativamente plano: idealmente, cada Pod puede comunicarse con otros Pods sin depender de una traducción de direcciones compleja entre ellos. El componente que hace posible la implementación real se llama CNI, Container Network Interface.

Existen distintos plugins CNI, como Calico, Cilium o Flannel. La elección del CNI influye en seguridad, rendimiento, soporte de políticas y observabilidad de red.

Kubernetes también proporciona DNS interno. Cuando creamos un Service, normalmente aparece un nombre que sigue una estructura como `backend.namespace.svc.cluster.local`. Esto permite que los servicios se encuentren por nombre y no por IP.

Las NetworkPolicies permiten definir reglas de comunicación. Podemos expresar, por ejemplo, que solo un indexador puede conectarse a los validadores por un puerto RPC determinado. Esto ayuda a aplicar el principio de mínimo privilegio.

Hay una advertencia importante: una NetworkPolicy solo se aplica realmente si el CNI del clúster la soporta y está configurado para hacerla cumplir. Declarar la política no basta si la plataforma de red la ignora.

**Aplicación blockchain**

Separar tráfico P2P, RPC interno, administración y observabilidad reduce superficie de ataque y ayuda a evitar que un servicio comprometido alcance componentes críticos.

---

## Diapositiva 19 — Almacenamiento: Volumes, PV y PVC

**Guion**

Los contenedores y los Pods son efímeros. Si guardamos información importante dentro del sistema de archivos temporal de un contenedor, esta puede perderse al recrearlo.

Kubernetes resuelve la persistencia mediante varios conceptos.

Un `PersistentVolume`, o PV, representa un recurso de almacenamiento disponible en el clúster. Puede estar respaldado por un disco cloud, almacenamiento NFS, soluciones CSI u otros mecanismos.

Un `PersistentVolumeClaim`, o PVC, es la solicitud que hace una aplicación: necesita cierta capacidad, modo de acceso y clase de almacenamiento.

Una `StorageClass` define cómo se aprovisiona almacenamiento dinámicamente. En nube, una StorageClass puede mapearse a un tipo de disco con determinadas características de rendimiento.

Para una blockchain, el ledger, las bases de datos de índices y el estado del nodo no deberían vivir únicamente en una capa efímera. Un StatefulSet normalmente crea un PVC independiente por réplica, para que `validator-0` conserve su propio ledger y `validator-1` conserve el suyo.

El rendimiento importa. Una red blockchain que requiere sincronizar bloques o mantener índices grandes puede verse afectada por baja cantidad de IOPS, latencia de disco o políticas de backup mal diseñadas.

**Pregunta sugerida**

¿Un backup es lo mismo que persistencia? No. La persistencia mantiene datos; los backups permiten recuperar datos ante corrupción, error humano o desastre.

---

## Diapositiva 20 — Configuración y secretos

**Guion**

Una aplicación necesita configuración, pero no toda la configuración tiene el mismo nivel de sensibilidad.

Un `ConfigMap` se utiliza para datos no confidenciales: dirección de una API, modo de ejecución, flags de funcionalidad, chain ID, nombre de red, parámetros de logging o URLs públicas.

Un `Secret` se utiliza para datos sensibles: claves privadas, passwords, tokens, certificados TLS, credenciales de base de datos o material criptográfico.

En el ejemplo, `CHAIN_ID` se obtiene desde un ConfigMap y `PRIVATE_KEY` se obtiene desde un Secret. Esto evita incluir información sensible directamente dentro de la imagen de contenedor o del código fuente.

Pero hay una precisión técnica importante: un Secret nativo de Kubernetes no debe considerarse automáticamente un mecanismo completo de protección criptográfica. Su representación suele estar codificada en Base64; se requiere controlar el acceso mediante RBAC, cifrado en reposo y, en entornos sensibles, integrar gestores externos como AWS Secrets Manager, Azure Key Vault, Google Secret Manager o Vault.

En blockchain, una clave privada es un activo crítico. Nunca debe subir al repositorio Git ni quedar embebida en una imagen. La gestión de claves debe diseñarse con el mismo cuidado que la red de consenso.

---

## Diapositiva 21 — Namespaces, labels y selectors

**Guion**

Los Namespaces permiten organizar recursos dentro del mismo clúster. Podemos usar namespaces para separar ambientes como `dev`, `qa` y `prod`; también para agrupar dominios como `blockchain`, `monitoring` o `ingress`.

No debemos considerar un namespace como una frontera de seguridad absoluta por sí solo. Es un mecanismo de organización y alcance que debe complementarse con RBAC, quotas, policies y configuración de red.

Las labels son pares clave-valor que etiquetan recursos. Por ejemplo: `app=validator`, `chain=localnet` y `role=rpc`. Las labels permiten clasificar Pods sin depender de nombres rígidos.

Los selectors usan estas labels para conectar recursos. Un Service selecciona los Pods a los que enviará tráfico. Un Deployment selecciona los Pods que administra. Una NetworkPolicy selecciona los Pods a los que aplicará reglas de red.

Este patrón es clave en Kubernetes: los objetos no se enlazan típicamente por direcciones IP. Se enlazan mediante labels y selectors.

**Ejemplo**

Si un Service busca `app=validator`, debemos asegurarnos de que los Pods de los validadores tengan exactamente esa label. Un error pequeño en la etiqueta puede hacer que el Service no tenga endpoints y parezca que la aplicación “no responde”.

---

## Diapositiva 22 — kubectl: hablar con la API

**Guion**

`kubectl` es la herramienta de línea de comandos que usamos para comunicarnos con la API del clúster.

`kubectl apply -f` crea o actualiza recursos a partir de archivos YAML. Es el comando típico para aplicar manifiestos declarativos.

`kubectl get` nos muestra el estado actual de recursos: Pods, Services, Nodes, PVCs, Deployments y otros objetos.

`kubectl describe` muestra información detallada y, especialmente, eventos. Cuando algo falla, los eventos suelen ser una de las fuentes más útiles para entender problemas de scheduling, imágenes, volumes o probes.

`kubectl logs -f` permite seguir los logs de un contenedor. Es importante porque en Kubernetes los logs deben escribirse normalmente a salida estándar y error estándar para facilitar recolección.

`kubectl exec -it` permite entrar temporalmente a un contenedor para depurar. Debe usarse con criterio: una corrección manual dentro de un contenedor no es una solución permanente, porque el Pod puede recrearse.

Finalmente, `kubectl rollout` permite revisar el estado de actualizaciones y revertir despliegues cuando corresponda.

La práctica posterior utilizará varios de estos comandos. La secuencia más útil al diagnosticar un problema suele ser: `get`, luego `describe`, luego `logs`, y solo después `exec` si es realmente necesario.

---

## Diapositiva 23 — Escalado y autorreparación

**Guion**

Kubernetes ofrece mecanismos de autorreparación. Si un Pod gestionado por un controlador falla, el controlador intenta crear una nueva instancia. Si un nodo deja de reportar, el clúster puede reprogramar cargas de trabajo en otros nodos, siempre que exista capacidad y la arquitectura lo permita.

El Horizontal Pod Autoscaler, o HPA, aumenta o reduce réplicas de una carga según métricas como CPU, memoria o métricas personalizadas. Por ejemplo, un backend FastAPI que recibe muchas solicitudes puede pasar de dos a cinco réplicas.

El Cluster Autoscaler actúa a otro nivel. Si no hay recursos suficientes para colocar nuevos Pods, puede añadir nodos worker en una nube gestionada. Si sobran nodos y las cargas pueden reubicarse, puede retirarlos.

También tenemos rolling updates y rollback como mecanismos de operación continua.

Sin embargo, debemos distinguir entre componentes que sí pueden escalar automáticamente y componentes que requieren gobernanza. Una API RPC o un indexador puede escalar horizontalmente. Un conjunto de validadores no debería aumentar automáticamente solo porque subió el uso de CPU; agregar validadores afecta membresía, consenso, seguridad y quórum.

**Idea clave**

Kubernetes automatiza operaciones de infraestructura, pero no reemplaza las decisiones de diseño y gobernanza de una blockchain.

---

## Diapositiva 24 — ¿Cuándo conviene usar Kubernetes?

**Guion**

Kubernetes conviene cuando la complejidad operacional ya existe o es previsible.

Es adecuado cuando tenemos varios servicios, despliegues frecuentes, necesidad de alta disponibilidad, escalamiento horizontal, múltiples ambientes, observabilidad centralizada, políticas de seguridad y una necesidad real de portabilidad.

También es útil cuando queremos estandarizar cómo se despliegan aplicaciones entre ambientes locales, on-premise y nube.

Pero Kubernetes no siempre es la respuesta correcta. Para una aplicación pequeña, una API sencilla o una demostración temporal, puede añadir más complejidad que valor. Docker Compose, un PaaS, un servicio serverless o una máquina virtual bien administrada pueden ser opciones más apropiadas.

El criterio no es “usar Kubernetes porque es moderno”. El criterio es evaluar si el problema requiere sus capacidades y si el equipo puede operar el clúster de manera segura.

Kubernetes reduce cierta complejidad cuando el sistema crece, pero inicialmente introduce conceptos, herramientas, costos y responsabilidades nuevas.

**Pregunta sugerida**

¿Dónde está el punto de equilibrio entre simplificar el despliegue y agregar una plataforma compleja de operación?

---

## Diapositiva 25 — Beneficios principales

**Guion**

El primer beneficio es la portabilidad. Un manifiesto de Kubernetes puede describir el mismo modelo de despliegue en un clúster local, una nube pública o infraestructura on-premise, aunque los detalles de almacenamiento, red y balanceo deban adaptarse.

El segundo beneficio es disponibilidad. Mediante réplicas, reinicios, reubicación, Services y balanceadores, Kubernetes ayuda a que una aplicación permanezca disponible frente a fallos comunes.

El tercer beneficio es entrega continua. Con rollouts, rollbacks, versionado de imágenes y herramientas como GitOps, podemos volver el proceso de despliegue más trazable y repetible.

El cuarto es escalabilidad. Podemos aumentar réplicas de servicios sin cambiar manualmente cada servidor.

El quinto es ecosistema. Herramientas como Helm, Prometheus, Grafana, Argo CD, Istio y cert-manager amplían las capacidades de Kubernetes.

Finalmente, Kubernetes permite gobernanza: namespaces, RBAC, quotas, NetworkPolicies y políticas de admisión ayudan a controlar quién puede hacer qué dentro del clúster.

La ventaja no está en cada herramienta aislada. Está en que todas pueden trabajar sobre un modelo común de objetos declarativos y API.

---

## Diapositiva 26 — Inconvenientes y riesgos

**Guion**

Kubernetes también tiene costos y riesgos.

La curva de aprendizaje es real. Hay muchos objetos, manifiestos, comandos y capas de diagnóstico. Cuando un servicio falla, el problema podría estar en la imagen, el Pod, el scheduler, la red, el DNS, el Service, el Ingress, el volumen o las políticas de acceso.

La red es una fuente frecuente de complejidad. Debemos entender CNI, DNS, TLS, Ingress, balanceadores, NetworkPolicies y exposición externa.

La persistencia requiere diseño. No basta con crear un PVC; hay que evaluar rendimiento, replicación, snapshots, restauración y políticas de retención.

La seguridad exige RBAC bien diseñado, control de imágenes, escaneo de vulnerabilidades, protección de secretos, contextos de seguridad y políticas de admisión.

También existen costos invisibles: nodos subutilizados, discos persistentes, transferencia de red, logs, métricas, tracing y herramientas de observabilidad.

Por último, está el riesgo de overengineering. Una arquitectura demasiado compleja puede ser más difícil de mantener que una solución simple bien construida.

**Frase de énfasis**

Kubernetes no elimina la complejidad: la organiza y la automatiza, pero exige disciplina técnica.

---

## Diapositiva 27 — Kubernetes aplicado a redes blockchain

**Guion**

En una arquitectura blockchain podemos ejecutar varios tipos de componentes en Kubernetes.

Podemos ejecutar nodos validadores, nodos RPC de lectura, indexadores, exploradores de bloques, APIs off-chain, oráculos, colas de mensajería, workers de procesamiento y dashboards de observabilidad.

Kubernetes aporta disponibilidad, reemplazo de fallos, DNS interno, despliegues controlados, persistencia y monitoreo. Por ejemplo, una API que consulta un nodo blockchain puede escalar según carga. Un indexador puede ejecutarse como Deployment. Una tarea de sincronización puntual puede ser un Job.

Sin embargo, una red blockchain requiere un nivel de cuidado mayor que una API tradicional. Un validador maneja identidad, claves y estado de consenso. La pérdida o corrupción de almacenamiento puede tener consecuencias graves. Una actualización de versión puede afectar compatibilidad entre nodos. La exposición de endpoints RPC puede facilitar abuso o ataques.

Por eso Kubernetes es una plataforma de operación, no una solución automática de seguridad blockchain. La arquitectura debe incluir gobernanza, backups, control de claves, segmentación de red, monitoreo y procedimientos de recuperación.

---

## Diapositiva 28 — Patrón para nodos blockchain

**Guion**

Este patrón muestra por qué StatefulSet suele ser más apropiado para nodos blockchain que un Deployment genérico.

Tenemos un Service headless llamado `validator`. En lugar de esconder todas las réplicas detrás de una sola IP virtual, permite que cada Pod tenga un nombre DNS estable.

El StatefulSet crea Pods con nombres predecibles: `validator-0`, `validator-1` y `validator-2`. Cada uno tiene un volumen persistente propio: `PVC-0`, `PVC-1` y `PVC-2`.

Esto significa que si `validator-1` se reinicia, puede volver a montarse sobre su propio almacenamiento y conservar la identidad y el ledger asociados. No queremos que un validador nuevo aparezca con datos aleatorios o con el almacenamiento de otro nodo.

En entornos internos, los nodos pueden encontrarse mediante nombres DNS estables como `validator-0.validator.blockchain.svc.cluster.local`.

El valor de este patrón no es solo técnico. Ayuda a que la operación refleje la realidad de la red: cada nodo es una entidad con estado, identidad, configuración y responsabilidad propia.

---

## Diapositiva 29 — Ejemplo mínimo: StatefulSet de validador

**Guion**

Revisemos este manifiesto de forma conceptual.

Primero, el `kind` es `StatefulSet`, lo cual indica que queremos administrar una carga stateful.

El nombre es `validator`, dentro del namespace `blockchain`. Se solicitan tres réplicas. El selector busca Pods con la label `app: validator`.

Dentro de la plantilla se define un contenedor llamado `node`, usando la imagen `usuario/blockchain-node:1.0`. El puerto 8545 es un ejemplo típico de un endpoint JSON-RPC de Ethereum, pero en una implementación real se debe validar qué puertos se necesitan para RPC, WebSocket, P2P, métricas y administración.

El volumen llamado `ledger` se monta en `/data`. Lo crítico aparece en `volumeClaimTemplates`: Kubernetes creará una solicitud de volumen por cada réplica. Esto evita que todos los validadores compartan accidentalmente el mismo disco de tipo `ReadWriteOnce`.

Después aparece un Service con `clusterIP: None`. Esto lo convierte en un Service headless. Su función es habilitar DNS estable para cada Pod, no balancear tráfico de forma tradicional.

Este ejemplo es deliberadamente mínimo. En un entorno productivo agregaríamos recursos de CPU y memoria, probes, configuración, secretos, políticas de red, anti-affinity, backups, observabilidad, políticas de actualización y procedimientos de recuperación.

**Idea de énfasis**

El YAML no es la arquitectura completa: es una forma declarativa de expresar una parte controlable de la arquitectura.

---

## Diapositiva 30 — Buenas prácticas para blockchain en Kubernetes

**Guion**

La primera área es seguridad. Las claves privadas y credenciales deben manejarse mediante mecanismos de secretos adecuados, RBAC con mínimo privilegio, imágenes verificadas y segmentación de red mediante NetworkPolicies.

La segunda es persistencia. Cada nodo debe tener almacenamiento acorde a su rol, snapshots y procesos de restauración probados. No basta con tener un backup; hay que verificar que se pueda restaurar de forma operativa.

La tercera es observabilidad. En una red blockchain debemos medir altura de bloques, retraso de sincronización, número de peers, latencia RPC, uso de disco, errores de consenso, colas internas y disponibilidad de endpoints.

La cuarta es despliegue. GitOps, Helm o Kustomize ayudan a versionar la infraestructura y mantener trazabilidad. Se deben separar ambientes y documentar claramente los procesos de rollback.

La quinta es consenso. Los validadores no se administran igual que un frontend. Debemos evaluar quórum, compatibilidad de versiones, orden de arranque, reglas de membresía y readiness basada en sincronización real.

Finalmente, costos. En blockchain, el almacenamiento persistente, el tráfico de red y la observabilidad pueden representar un costo importante. La arquitectura debe considerar rendimiento y presupuesto desde el inicio.

---

## Diapositiva 31 — De Docker Compose a Kubernetes

**Guion**

Esta tabla conecta lo visto en la semana anterior con Kubernetes.

En Docker Compose, un `service` representa un componente de la aplicación. En Kubernetes, ese componente puede mapearse a un Deployment, StatefulSet o Job, dependiendo de su comportamiento.

Los `ports` de Compose se convierten normalmente en Services, Ingress o Gateway en Kubernetes.

Los `volumes` se modelan mediante PVC, PV y StorageClass, con mayor separación entre la solicitud de almacenamiento y la infraestructura que lo proporciona.

Las variables `environment` se dividen en ConfigMaps y Secrets.

`depends_on` de Docker Compose ayuda a ordenar el arranque de contenedores, pero no garantiza que una aplicación esté realmente lista. En Kubernetes, se usan readiness probes, init containers, controladores y mecanismos de reintento para tratar la disponibilidad de manera más robusta.

`docker compose up` levanta una pila en un host. `kubectl apply` aplica un estado deseado en un clúster. Con GitOps, incluso el `apply` puede automatizarse desde un repositorio.

La lógica declarativa es similar, pero Kubernetes trabaja con un alcance operativo mucho mayor: múltiples nodos, reubicación, políticas, escalado y servicios distribuidos.

---

## Diapositiva 32 — Fuentes base

**Guion**

Para profundizar, la fuente principal es la documentación oficial de Kubernetes. No es necesario intentar leerla completa de una sola vez. Lo recomendable es consultarla por conceptos conforme aparezcan necesidades reales: Pods, Services, Deployments, StatefulSets, ConfigMaps, Secrets, Volumes, Ingress, NetworkPolicies y arquitectura.

También pueden apoyarse en la guía didáctica del módulo, que conecta contenedores, orquestación y blockchain con actividades prácticas.

El objetivo de esta clase fue construir un mapa mental. En la práctica, ese mapa se convertirá en manifiestos YAML y comandos de operación.

En las siguientes actividades no solo se evaluará si un Pod aparece como `Running`. Se evaluará si el diseño es reproducible, si el almacenamiento es persistente, si la red está bien definida y si los componentes tienen roles claros.

**Transición**

Con esta base conceptual, estamos listos para pasar de la teoría al manifiesto.

---

## Diapositiva 33 — ¿Listos para la práctica?

**Guion**

Ahora vamos a convertir estos conceptos en acciones concretas.

La práctica comienza con manifiestos YAML y comandos `kubectl`. Primero veremos cómo desplegar un componente simple. Después conectaremos Pods mediante Services. Finalmente revisaremos cuándo usar un Deployment y cuándo usar un StatefulSet para una red blockchain de prueba.

La meta no es solo que el comando `kubectl apply -f k8s/` termine sin errores. La meta es entender qué recursos se crean, cómo se relacionan y cómo diagnosticar problemas cuando el estado observado no coincide con el estado esperado.

A partir de este punto, cada manifiesto debe responder tres preguntas: ¿qué recurso estoy creando?, ¿qué estado deseo mantener?, y ¿cómo se conecta con los demás componentes de la arquitectura?

**Cierre**

Listos para la práctica.

---

# Recordatorio rápido para el docente

- **Idea central de la clase:** Kubernetes administra el estado deseado de aplicaciones contenerizadas en un clúster.
- **Diferencia esencial:** Docker ejecuta contenedores; Kubernetes los orquesta a escala.
- **Para workloads sin estado:** Deployment + Service.
- **Para workloads con identidad y datos persistentes:** StatefulSet + Headless Service + PVC.
- **Para blockchain:** separar nodos RPC, validadores, indexadores y servicios off-chain; no escalar validadores automáticamente sin considerar consenso y gobernanza.
- **Regla de seguridad:** claves privadas fuera de código, imágenes y repositorios.
- **Regla de persistencia:** un Pod puede desaparecer; el dato crítico debe tener almacenamiento y recuperación diseñados.

# Referencias de consulta recomendadas

- Kubernetes Documentation — Conceptos: https://kubernetes.io/es/docs/concepts/
- Kubernetes Documentation — Arquitectura: https://kubernetes.io/es/docs/concepts/architecture/
- Kubernetes Documentation — Objetos: https://kubernetes.io/es/docs/concepts/overview/working-with-objects/
- Kubernetes Documentation — Pods: https://kubernetes.io/es/docs/concepts/workloads/pods/
- Kubernetes Documentation — Services: https://kubernetes.io/es/docs/concepts/services-networking/service/
- Kubernetes Documentation — Persistent Volumes: https://kubernetes.io/es/docs/concepts/storage/persistent-volumes/
