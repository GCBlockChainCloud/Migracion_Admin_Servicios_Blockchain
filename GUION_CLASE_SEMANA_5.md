# Guion de clase - Semana 5

## 1. Idea central

En esta semana se completa el flujo academico con tres instituciones independientes: una universidad emisora que registra titulos, un Ministerio que autoriza universidades y avala titulos, y una universidad auditora extranjera que verifica titulos y guarda historial de auditoria.

La blockchain no reemplaza las bases de datos internas. Su funcion es servir como una capa comun de evidencia entre instituciones que no comparten el mismo servidor ni la misma base de datos.

## 2. Problema que resolvemos

El problema principal es separar responsabilidades. La universidad puede emitir titulos, pero no debe avalarlos oficialmente. El Ministerio puede avalar titulos y autorizar universidades, pero no debe registrar titulos como si fuera una universidad. La auditora extranjera no debe escribir en blockchain, solo verificar evidencias.

Con estos cambios se controla que cada actor haga solo lo que le corresponde.

## 3. Cambio 1 - Ministerio como autoridad principal

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:5`.

```solidity
address public ministerioPrincipal;
```

Esta variable guarda la direccion blockchain del Ministerio. Esa direccion sera la unica autorizada para aprobar universidades y avalar titulos. Es importante recalcar que la regla queda dentro del contrato, no solamente en la API.

Mostrar tambien el constructor en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:81-88`.

```solidity
constructor(address _ministerioPrincipal, address _universidadInicial, string memory _nombreUniversidadInicial) {
    require(_ministerioPrincipal != address(0), "Ministerio invalido");
    ministerioPrincipal = _ministerioPrincipal;

    if (_universidadInicial != address(0)) {
        _autorizarUniversidad(_universidadInicial, _nombreUniversidadInicial);
    }
}
```

Este constructor configura al Ministerio principal al desplegar el contrato y permite dejar una universidad inicial autorizada, por ejemplo UTPL.

## 4. Cambio 2 - Registro dinamico de universidades

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:30-41`.

```solidity
struct UniversidadAutorizada {
    string nombre;
    bool autorizada;
    uint256 fechaAutorizacion;
    bool existe;
}

mapping(address => UniversidadAutorizada) private universidades;
address[] private direccionesUniversidades;
```

Este cambio permite que el contrato mantenga una lista dinamica de universidades. Si en el futuro llega otra universidad, como UDLA, no se despliega otro contrato. El Ministerio simplemente registra la direccion de esa universidad como autorizada.

## 5. Cambio 3 - Eventos de autorizacion y revocacion

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:43-54`.

```solidity
event UniversidadAutorizadaEvento(
    address indexed universidad,
    string nombre,
    address indexed ministerio,
    uint256 fechaAutorizacion
);

event UniversidadRevocada(
    address indexed universidad,
    address indexed ministerio,
    uint256 fechaRevocacion
);
```

Estos eventos dejan evidencia en blockchain cada vez que el Ministerio autoriza o revoca una universidad. Esto ayuda a auditar cambios de permisos.

## 6. Cambio 4 - Solo el Ministerio administra universidades

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:71-74` y `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:90-98`.

```solidity
modifier soloMinisterio() {
    require(msg.sender == ministerioPrincipal, "Solo el Ministerio puede ejecutar esta accion");
    _;
}

function autorizarUniversidad(address universidad, string memory nombre) public soloMinisterio {
    _autorizarUniversidad(universidad, nombre);
}

function revocarUniversidad(address universidad) public soloMinisterio {
    require(universidades[universidad].existe, "Universidad no registrada");
    universidades[universidad].autorizada = false;
    emit UniversidadRevocada(universidad, msg.sender, block.timestamp);
}
```

El modificador `soloMinisterio` obliga a que esas funciones solo puedan ser ejecutadas por la direccion configurada como Ministerio. Si otra cuenta intenta autorizar una universidad, la transaccion falla.

## 7. Cambio 5 - Autorizacion interna de universidades

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:100-116`.

```solidity
function _autorizarUniversidad(address universidad, string memory nombre) private {
    require(universidad != address(0), "Universidad invalida");
    require(bytes(nombre).length > 0, "Nombre requerido");

    if (!universidades[universidad].existe) {
        direccionesUniversidades.push(universidad);
    }

    universidades[universidad] = UniversidadAutorizada({
        nombre: nombre,
        autorizada: true,
        fechaAutorizacion: block.timestamp,
        existe: true
    });

    emit UniversidadAutorizadaEvento(universidad, nombre, ministerioPrincipal, block.timestamp);
}
```

Esta funcion privada centraliza la logica de autorizacion. Valida que la direccion no sea cero, valida que exista un nombre, agrega la direccion al listado si es nueva y marca la universidad como autorizada.

## 8. Cambio 6 - Solo universidades autorizadas registran titulos

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:76-79` y `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:118-154`.

```solidity
modifier soloUniversidadAutorizada() {
    require(universidades[msg.sender].autorizada, "Universidad no autorizada");
    _;
}

function registrarTitulo(
    bytes32 codigoTituloHash,
    bytes32 documentoHash,
    bytes32 identificacionEstudianteHash,
    string memory universidadEmisora,
    string memory carrera,
    string memory tituloObtenido
) public soloUniversidadAutorizada {
    require(!titulos[codigoTituloHash].existe, "El titulo ya existe");

    titulos[codigoTituloHash] = Titulo({
        codigoTituloHash: codigoTituloHash,
        documentoHash: documentoHash,
        identificacionEstudianteHash: identificacionEstudianteHash,
        universidadEmisora: universidadEmisora,
        carrera: carrera,
        tituloObtenido: tituloObtenido,
        universidad: msg.sender,
        ministerioValidador: address(0),
        estado: EstadoTitulo.REGISTRADO,
        fechaRegistro: block.timestamp,
        fechaAval: 0,
        existe: true
    });
}
```

Este cambio evita que el Ministerio, la Auditora o cualquier cuenta no autorizada registre titulos. El contrato revisa la direccion que firma la transaccion con `msg.sender` y comprueba si esta autorizada como universidad.

## 9. Cambio 7 - Solo el Ministerio avala titulos

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:156-167`.

```solidity
function avalarTitulo(bytes32 codigoTituloHash) public soloMinisterio {
    Titulo storage titulo = titulos[codigoTituloHash];

    require(titulo.existe, "El titulo no existe");
    require(titulo.estado == EstadoTitulo.REGISTRADO, "El titulo no esta pendiente de aval");

    titulo.estado = EstadoTitulo.AVALADO;
    titulo.ministerioValidador = msg.sender;
    titulo.fechaAval = block.timestamp;

    emit TituloAvalado(codigoTituloHash, msg.sender);
}
```

La universidad registra la evidencia academica, pero la validacion oficial la realiza el Ministerio. Si una universidad intenta llamar esta funcion, el contrato rechaza la transaccion.

## 10. Cambio 8 - Verificacion por hashes

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:169-185`.

```solidity
function verificarTitulo(
    bytes32 codigoTituloHash,
    bytes32 documentoHash,
    bytes32 identificacionEstudianteHash
) public view returns (
    bool existe,
    bool documentoCoincide,
    bool identificacionCoincide,
    EstadoTitulo estado
) {
    Titulo memory titulo = titulos[codigoTituloHash];

    existe = titulo.existe;
    documentoCoincide = titulo.documentoHash == documentoHash;
    identificacionCoincide = titulo.identificacionEstudianteHash == identificacionEstudianteHash;
    estado = titulo.estado;
}
```

Esta funcion permite que la Auditora compare el documento y la identificacion presentados por el estudiante contra los hashes registrados. Asi se verifica sin publicar cedulas ni documentos completos en blockchain.

## 11. Cambio 9 - Funciones publicas de consulta

Mostrar en `SEMANA_5/blockchain/contracts/RegistroTitulos.sol:187-209`.

```solidity
function obtenerTitulo(bytes32 codigoTituloHash) public view returns (Titulo memory) {
    return titulos[codigoTituloHash];
}

function obtenerUniversidad(address universidad) public view returns (UniversidadAutorizada memory) {
    return universidades[universidad];
}

function esUniversidadAutorizada(address universidad) public view returns (bool) {
    return universidades[universidad].autorizada;
}

function listarUniversidades() public view returns (address[] memory) {
    return direccionesUniversidades;
}
```

Estas funciones son de lectura y permiten que el Ministerio y la Auditora consulten informacion sin modificar el contrato.

## 12. Cambio 10 - Variables de entorno por actor

Mostrar en `SEMANA_5/.env.example:1-24`.

```env
GANACHE_RPC_URL=http://blockchain-node:8545
GANACHE_PRIVATE_KEY=0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
MINISTERIO_PRIVATE_KEY=0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1
UDLA_PRIVATE_KEY=0x6370fd033414d63c8dbdc28a482b50146d244dfc1510aa5676bb7c2e618af9c2

UNIVERSIDAD_ADDRESS=0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
UNIVERSIDAD_NOMBRE=UTPL
MINISTERIO_ADDRESS=0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0
UDLA_ADDRESS=0x22d491bde2303f2f43325b2108c7e439c87a1243
UDLA_NOMBRE=UDLA

CONTRACT_ADDRESS=0xREEMPLAZAR_CON_LA_DIRECCION_DEL_CONTRATO
```

Estas variables separan las identidades blockchain de cada actor. La Universidad registra con su clave, el Ministerio avala y administra universidades con su clave, y la Auditora solo consulta.

## 13. Cambio 11 - API Universidad registra titulos

Mostrar en `SEMANA_5/api-universidad/main.py:45-88`.

```python
@app.post("/titulos", response_model=TituloRespuesta, status_code=status.HTTP_201_CREATED)
def crear_titulo(payload: TituloCrear, db: Session = Depends(get_db)):
    codigo_titulo_hash = blockchain.hash_text(payload.codigo_titulo)
    documento_hash = blockchain.hash_text(payload.contenido_documento)
    identificacion_estudiante_hash = blockchain.hash_text(payload.identificacion_estudiante)

    titulo = models.Titulo(
        codigo_titulo=payload.codigo_titulo,
        nombre_estudiante=payload.nombre_estudiante,
        identificacion_estudiante=payload.identificacion_estudiante,
        carrera=payload.carrera,
        titulo_obtenido=payload.titulo_obtenido,
        universidad=payload.universidad,
        fecha_emision=payload.fecha_emision,
        contenido_documento=payload.contenido_documento,
        codigo_titulo_hash=codigo_titulo_hash,
        documento_hash=documento_hash,
        contract_address=blockchain.get_contract_address(),
    )

    tx_hash = blockchain.register_title(
        codigo_titulo_hash,
        documento_hash,
        identificacion_estudiante_hash,
        payload.universidad,
        payload.carrera,
        payload.titulo_obtenido,
    )
```

La API Universidad recibe datos completos, calcula hashes y registra la evidencia en blockchain. La base local conserva la informacion completa, mientras blockchain conserva solo la prueba verificable.

Endpoint para demostrar:

```http
POST http://localhost:8000/titulos
```

## 14. Cambio 12 - API Ministerio avala titulos

Mostrar en `SEMANA_5/api-ministerio/main.py:73-113` y `SEMANA_5/api-ministerio/blockchain.py:114-139`.

```python
@app.post("/titulos/{codigo_titulo}/avalar", response_model=AvalRespuesta, status_code=status.HTTP_201_CREATED)
def avalar_titulo(codigo_titulo: str, db: Session = Depends(get_db)):
    titulo = blockchain.get_title_by_code(codigo_titulo)

    if not titulo["existe"]:
        raise HTTPException(status_code=404, detail="Titulo no encontrado en blockchain")

    tx_hash = blockchain.endorse_title(titulo["codigo_titulo_hash"])
    titulo_actualizado = blockchain.get_title_by_code(codigo_titulo)
```

```python
def endorse_title(codigo_titulo_hash: str) -> str:
    web3 = get_web3()
    contract = get_contract()
    private_key = get_private_key()
    account = web3.eth.account.from_key(private_key)

    tx = contract.functions.avalarTitulo(
        Web3.to_bytes(hexstr=codigo_titulo_hash),
    ).build_transaction({"from": account.address, ...})
```

El Ministerio consulta el titulo en blockchain, firma la transaccion con su clave privada y llama la funcion `avalarTitulo`. Despues guarda el aval en su base local.

## 15. Cambio 13 - API Ministerio autoriza universidades

Mostrar en `SEMANA_5/api-ministerio/main.py:121-140` y `SEMANA_5/api-ministerio/blockchain.py:142-166`.

```python
@app.post("/universidades", response_model=UniversidadHistorialRespuesta, status_code=status.HTTP_201_CREATED)
def autorizar_universidad(payload: UniversidadCrear, db: Session = Depends(get_db)):
    tx_hash = blockchain.authorize_university(payload.address, payload.nombre)
    universidad = blockchain.get_university(payload.address)

    registro = models.UniversidadMinisterio(
        nombre=universidad["nombre"],
        address=universidad["address"],
        accion="AUTORIZAR",
        autorizada=str(universidad["autorizada"]).lower(),
        contract_address=blockchain.get_contract_address(),
        tx_hash=tx_hash,
    )
```

```python
def authorize_university(address: str, nombre: str) -> str:
    web3 = get_web3()
    contract = get_contract()
    private_key = get_private_key()
    account = web3.eth.account.from_key(private_key)
    university_address = Web3.to_checksum_address(address)

    tx = contract.functions.autorizarUniversidad(university_address, nombre).build_transaction(
        {"from": account.address, ...}
    )
```

Este es el flujo correcto para agregar universidades. Se hace desde la API del Ministerio, no con un script manual de administracion. El contrato sigue siendo el mismo.

Endpoint para demostrar:

```http
POST http://localhost:8002/universidades
```

Body:

```json
{
  "nombre": "UDLA",
  "address": "0x22d491bde2303f2f43325b2108c7e439c87a1243"
}
```

## 16. Cambio 14 - API Ministerio revoca universidades

Mostrar en `SEMANA_5/api-ministerio/main.py:164-184` y `SEMANA_5/api-ministerio/blockchain.py:169-193`.

```python
@app.delete("/universidades/{address}", response_model=UniversidadHistorialRespuesta)
def revocar_universidad(address: str, db: Session = Depends(get_db)):
    universidad_previa = blockchain.get_university(address)
    tx_hash = blockchain.revoke_university(address)
    universidad = blockchain.get_university(address)

    registro = models.UniversidadMinisterio(
        nombre=universidad["nombre"] or universidad_previa["nombre"],
        address=universidad["address"],
        accion="REVOCAR",
        autorizada=str(universidad["autorizada"]).lower(),
        contract_address=blockchain.get_contract_address(),
        tx_hash=tx_hash,
    )
```

```python
def revoke_university(address: str) -> str:
    web3 = get_web3()
    contract = get_contract()
    private_key = get_private_key()
    account = web3.eth.account.from_key(private_key)
    university_address = Web3.to_checksum_address(address)

    tx = contract.functions.revocarUniversidad(university_address).build_transaction(
        {"from": account.address, ...}
    )
```

Si una universidad deja de estar autorizada, el Ministerio la revoca desde su API. Desde ese momento la direccion ya no puede registrar nuevos titulos.

## 17. Cambio 15 - Historial local del Ministerio

Mostrar en `SEMANA_5/api-ministerio/models.py:9-36`.

```python
class AvalMinisterio(Base):
    __tablename__ = "avales_ministerio"
    codigo_titulo: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    codigo_titulo_hash: Mapped[str] = mapped_column(String(66), index=True)
    estado: Mapped[str] = mapped_column(String(50))
    tx_hash: Mapped[str] = mapped_column(String(66))

class UniversidadMinisterio(Base):
    __tablename__ = "universidades_ministerio"
    nombre: Mapped[str] = mapped_column(String(200))
    address: Mapped[str] = mapped_column(String(42), index=True)
    accion: Mapped[str] = mapped_column(String(20))
    autorizada: Mapped[str] = mapped_column(String(5))
    tx_hash: Mapped[str] = mapped_column(String(66))
```

El Ministerio mantiene su propio historial de avales y de decisiones sobre universidades. Esto simula el registro administrativo interno del Ministerio.

## 18. Cambio 16 - API Auditora independiente

Mostrar en `SEMANA_5/api-auditora/main.py:19-24` y `SEMANA_5/api-auditora/main.py:44-54`.

```python
app = FastAPI(
    title="API Auditora - Verificacion Internacional de Titulos",
    description="API didactica de una universidad extranjera que verifica titulos avalados y guarda historial local.",
    version="1.0.0",
    lifespan=lifespan,
)

@app.get("/titulos/{codigo_titulo}", response_model=TituloBlockchain)
def obtener_titulo(codigo_titulo: str):
    titulo = blockchain.get_title_by_code(codigo_titulo)
```

La Auditora tiene su propio backend. No consulta directamente la base de la Universidad ni la del Ministerio; consulta blockchain.

## 19. Cambio 17 - Verificacion internacional del titulo

Mostrar en `SEMANA_5/api-auditora/main.py:57-87` y `SEMANA_5/api-auditora/blockchain.py:97-147`.

```python
@app.post("/verificar", response_model=AuditoriaRespuesta, status_code=status.HTTP_201_CREATED)
def verificar_titulo(payload: VerificacionCrear, db: Session = Depends(get_db)):
    resultado = blockchain.verify_title(
        payload.codigo_titulo,
        payload.contenido_documento,
        payload.identificacion_estudiante,
    )
```

```python
def verify_title(codigo_titulo: str, contenido_documento: str, identificacion_estudiante: str) -> dict:
    codigo_titulo_hash = hash_text(codigo_titulo)
    documento_hash = hash_text(contenido_documento)
    identificacion_hash = hash_text(identificacion_estudiante)

    existe, documento_coincide, identificacion_coincide, estado = contract.functions.verificarTitulo(
        Web3.to_bytes(hexstr=codigo_titulo_hash),
        Web3.to_bytes(hexstr=documento_hash),
        Web3.to_bytes(hexstr=identificacion_hash),
    ).call()

    apto = bool(
        existe
        and documento_coincide
        and identificacion_coincide
        and int(estado) == 2
        and avalado_por_ministerio
        and titulo["universidad_autorizada"]
    )
```

La Auditora calcula hashes con lo que presenta el estudiante y compara contra blockchain. El titulo solo es apto si existe, el documento coincide, la identificacion coincide, esta avalado por el Ministerio y la universidad emisora esta autorizada.

## 20. Cambio 18 - Historial local de auditorias

Mostrar en `SEMANA_5/api-auditora/models.py:9-27` y `SEMANA_5/api-auditora/main.py:68-87`.

```python
class AuditoriaTitulo(Base):
    __tablename__ = "auditorias_titulos"

    codigo_titulo: Mapped[str] = mapped_column(String(100), index=True)
    codigo_titulo_hash: Mapped[str] = mapped_column(String(66), index=True)
    documento_hash_presentado: Mapped[str] = mapped_column(String(66), index=True)
    identificacion_estudiante_hash_presentado: Mapped[str] = mapped_column(String(66), index=True)
    documento_coincide: Mapped[bool] = mapped_column(Boolean)
    identificacion_coincide: Mapped[bool] = mapped_column(Boolean)
    apto_para_admision: Mapped[bool] = mapped_column(Boolean)
    motivo_resultado: Mapped[str] = mapped_column(String(500))
```

```python
auditoria = models.AuditoriaTitulo(
    codigo_titulo=payload.codigo_titulo,
    codigo_titulo_hash=resultado["codigo_titulo_hash"],
    documento_hash_presentado=resultado["documento_hash_presentado"],
    identificacion_estudiante_hash_presentado=resultado["identificacion_estudiante_hash_presentado"],
    documento_coincide=resultado["documento_coincide"],
    identificacion_coincide=resultado["identificacion_coincide"],
    apto_para_admision=resultado["apto_para_admision"],
    motivo_resultado=resultado["motivo_resultado"],
)
```

Cada verificacion queda guardada en la base propia de la Auditora. Esto permite demostrar que la universidad extranjera no solo consulta, sino que conserva evidencia de su decision.

## 21. Cambio 19 - Docker Compose con tres instituciones

Mostrar en `SEMANA_5/docker-compose.yml:26-99`.

```yaml
postgres-universidad:
  image: postgres:16-alpine
  ports:
    - "5432:5432"

postgres-ministerio:
  image: postgres:16-alpine
  ports:
    - "5433:5432"

postgres-auditora:
  image: postgres:16-alpine
  ports:
    - "5434:5432"

api-universidad:
  ports:
    - "8000:8000"

api-ministerio:
  ports:
    - "8002:8000"

api-auditora:
  ports:
    - "8003:8000"
```

Cada actor tiene su propia API y su propia base de datos. La capa comun es el nodo blockchain local.

## 22. Ejecucion de la demo

Ubicarse en la carpeta del proyecto:

```powershell
cd "C:\Users\Usuario iTC\Desktop\Administracion Cloud\administracion_cloud_utpl\SEMANA_5"
```

Levantar blockchain:

```powershell
docker compose up -d blockchain-node
```

Desplegar contrato y copiar la direccion en `.env`:

```powershell
docker compose build contract-tools
docker compose run --rm contract-tools npx hardhat compile
docker compose run --rm contract-tools npx hardhat run scripts/deploy-registro-titulos.ts --network ganache
```

Levantar servicios:

```powershell
docker compose up -d --build postgres-universidad api-universidad postgres-ministerio api-ministerio postgres-auditora api-auditora
```

Verificar contrato desde las tres APIs:

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/blockchain/contract"
Invoke-RestMethod -Uri "http://localhost:8002/blockchain/contract"
Invoke-RestMethod -Uri "http://localhost:8003/blockchain/contract"
```

Debe devolver `existe_en_blockchain = true` en las tres APIs.

## 23. Orden recomendado para exponer la demo

1. Abrir `http://localhost:8000/docs` y registrar un titulo desde Universidad.
2. Abrir `http://localhost:8002/docs` y avalar el titulo desde Ministerio.
3. Abrir `http://localhost:8003/docs` y verificar el titulo desde Auditora.
4. Mostrar `GET /auditorias` para comprobar que la Auditora guardo historial.
5. Volver al Ministerio y ejecutar `POST /universidades` para autorizar UDLA.
6. Mostrar `GET /universidades` para comprobar que UDLA quedo autorizada.
7. Explicar que no se desplego un contrato nuevo.
8. Ejecutar una prueba negativa cambiando documento o identificacion.

## 24. Body para registrar titulo

Usar en `POST http://localhost:8000/titulos`.

```json
{
  "codigo_titulo": "UTPL-SIS-2026-0002",
  "nombre_estudiante": "Maria Loja",
  "identificacion_estudiante": "1100000002",
  "carrera": "Sistemas",
  "titulo_obtenido": "Ingeniera en Sistemas",
  "universidad": "UTPL",
  "fecha_emision": "2026-06-15",
  "contenido_documento": "Titulo de Maria Loja como Ingeniera en Sistemas emitido por UTPL"
}
```

## 25. Body para verificar titulo correcto

Usar en `POST http://localhost:8003/verificar`.

```json
{
  "codigo_titulo": "UTPL-SIS-2026-0002",
  "identificacion_estudiante": "1100000002",
  "contenido_documento": "Titulo de Maria Loja como Ingeniera en Sistemas emitido por UTPL"
}
```

El resultado esperado es `documento_coincide = true`, `identificacion_coincide = true` y `apto_para_admision = true`.

## 26. Prueba negativa - Documento alterado

Usar en `POST http://localhost:8003/verificar`.

```json
{
  "codigo_titulo": "UTPL-SIS-2026-0002",
  "identificacion_estudiante": "1100000002",
  "contenido_documento": "Documento alterado"
}
```

El resultado esperado es `documento_coincide = false` y `apto_para_admision = false`.

## 27. Prueba negativa - Identificacion incorrecta

Usar en `POST http://localhost:8003/verificar`.

```json
{
  "codigo_titulo": "UTPL-SIS-2026-0002",
  "identificacion_estudiante": "9999999999",
  "contenido_documento": "Titulo de Maria Loja como Ingeniera en Sistemas emitido por UTPL"
}
```

El resultado esperado es `identificacion_coincide = false` y `apto_para_admision = false`.

## 28. Body para autorizar UDLA desde Ministerio

Usar en `POST http://localhost:8002/universidades`.

```json
{
  "nombre": "UDLA",
  "address": "0x22d491bde2303f2f43325b2108c7e439c87a1243"
}
```

El resultado esperado es `accion = AUTORIZAR` y `autorizada = true`.

## 29. Cierre de la explicacion

La universidad emite, el Ministerio regula y avala, y la Auditora verifica. La blockchain une a las instituciones con evidencia comun, sin obligarlas a compartir sus bases internas ni exponer documentos completos o datos personales.
