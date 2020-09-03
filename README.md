


# Especificaciones técnicas

  
## Pre - requisitos

El ambiente de pruebas debe estar instalado y configurado correctamente. Para más información, consulte la siguiente documentación:

1. **GOV UK\_IIR\_Interconnection of S2 and S3 of the PDN:** el cual muestra los pasos para la preparación del ambiente local, contempla lo relacionado a Docker, Docker Compose y Mongo, [Ref.[1]](#2q02kq3lfhwc).
2. **GOV UK\_Gen\_Interconnection of S2 and S3 of the PDN:** documentación del generador de datos sintéticos para los dos sistemas, [Ref.[2]](#a3ggzjvxdivo).
3. **GOV UK\_Oauth2\_Interconnection of S2 and S3 of the PDN:** documentación para la implementación del protocolo Oauth 2.0, [Ref.[3]](#kix.c7de96b3ai57).

Adicionalmente, se cuenta con un Anexo que incluye una de guía de ayuda sobre las diversas tecnologías utilizadas:

- **GOV UK\_Anexo\_Interconnection of S2 and S3 of the PDN** , [Ref.[4]](#xdfe451pw6sm).

  
## Ejecución del programa

El API para el sistema S3 Servidores se encuentra en el repositorio de Github de la PDN, en el siguiente link:

[https://github.com/PDNMX/piloto_s3s.git](https://github.com/PDNMX/piloto_s3s.git
)

- Para clonar el repositorio desde el CLI (Interfaz de línea de comandos) de su computador utilice el siguiente comando:

| $ **git clone https://github.com/PDNMX/piloto_s3s.git** |
| --- |

- Se le solicitará su usuario y contraseña de Github para acceder.

- Agregar el servicio S3 Servidores al final del archivo docker-compose.yml que se encuentra en el directorio   &#60;home_directory&#62;/sistema\_pdn/mongodb de la siguiente forma:


```sh
version: '3.1'
services:
  mongodb:
    image: mongo
    container_name: mongodb
    restart: always
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${DB_ROOT_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    volumes:
      - ./mongo-volume:/data/db
      - ./mongod.conf:/etc/mongod.conf
      - ./log/:/var/log/mongodb/
    env_file:
      - .env
    command: ["-f", "/etc/mongod.conf"] 
  oauth20:
    restart: always
    container_name: oauth20
    build:
      context: ../piloto_oauth2.0/
      dockerfile: Dockerfile
    ports:
      - 9003:9003    
    links:
      - mongodb
    depends_on:
      - mongodb
  s3_servidores:
    restart: always
    container_name: s3_servidores
    build:
        context: ../piloto_s3s/
        dockerfile: Dockerfile
    ports:
      - 8082:8080
    links:
      - mongodb
    depends_on:
      - mongodb
 ```

Nota: La identación es importante, utilizar espacios, no tabuladores.

La variable context especifica la ubicación relativa ../piloto\_s3s/ donde fue descargada la aplicación, y además, contiene el archivo Dockerfile incluido en la descarga de github.

La variable ports incluye el mapeo entre el puerto del host y el puerto interno del contenedor 8080:8080.

La variable container\_name especifica el nombre del contenedor s3_servidores donde se encuentra la aplicación para el S3 Servidores.

La variable links apunta al contenedor mongodb para que este contenedor s3_servidores tenga acceso al contenedor mongodb equivalente a su dirección IP.

La variable depends\_on apunta al contenedor mongodb lo que establece la dependencia de este contenedor s3_servidores sobre el contenedor mongodb.

  1.
## Variables de entorno

El archivo donde se contemplan las variables de entorno estará localizado en la siguiente ruta:

&#60;home_directory&#62;/sistema\_pdn/piloto\_s3s/utils/.env

A continuación, se muestra un ejemplo del contenido que debe tener.

```sh
// SEED
SEED = YTBGD9YjAUhkjQk9ZXcb

USERMONGO = apiUsr
PASSWORDMONGO = <password>
HOSTMONGO = mongodb:27017
DATABASE= S3_Servidores
```

Nota: Las diagonales // al inicio de línea indican que es un comentario

**USERMONGO** : Contiene el nombre del usuario apiUsr para acceder a la base de datos S3_Servidores. Este usuario debe contar con los privilegios correspondientes y fue creado durante la instalación de MongoDB, [Ref.[1]](#2q02kq3lfhwc).

**PASSWORDMONGO** : Contiene la contraseña &#60;password&#62; del usuario apiUsr para acceder a la base de datos S3_Servidores.

**HOSTMONGO** : Contiene la dirección IP mongodb y el puerto 27017 donde se encuentra alojada la base de datos. Se utiliza el link mongodb que se encuentra declarado en el archivo docker-compose.yml en lugar de la dirección IP. En este caso, tiene el valor de mongodb:27017.

**DATABASE** : Contiene el nombre de la base de datos S3_Servidores.

**SEED** : Contiene la semilla YTBGD9YjAUhkjQk9ZXcb para la codificación del JSON Web Token (JWT)

**SEED**  **debe contener el mismo valor que se colocó en las variables de entorno del sistema de autorización Oauth 2.0** , [Ref.[3]](#kix.c7de96b3ai57).

  1.
## Desplegar Contenedor

- Una vez hecho lo anterior, ejecutar el docker compose desde el directorio &#60;home\_directory&#62;/sistema\_pdn/mongodb que contiene el archivo docker-compose.yml de la siguiente forma:

| $ **docker-compose up -d** |
| --- |

Nota: En caso que MongoDB ya esté corriendo en un contenedor, sólo construirá la nueva imagen y se creará el nuevo contenedor s2.

- Verificar que todos los contenedores dentro del archivo docker-compose.yml estén corriendo con el siguiente comando:


| $ docker-compose ps|
| --- |

         Name                    Command            State        Ports          
-------------------------------------------------------------------------------------------
mongodb&ensp;&ensp;   				  docker-entrypoint.sh -f /e ...&ensp;   Up&ensp;      0.0.0.0:27017->27017/tcp  
oauth20&ensp; &ensp;        		  docker-entrypoint.sh yarn  ...&ensp;   Up&ensp;      0.0.0.0:9003->9003/tcp  
s3_servidores&ensp;&ensp;&ensp;&ensp; 			              docker-entrypoint.sh yarn  ...&ensp;   Up&ensp;      0.0.0.0:8080->8080/tcp  


Nota: El resultado puede variar de la imagen mostrada, verifique que los servicios definidos estén presentes en el resultado esperado.

  1.
## Esquemas en la base de datos

Dentro de MongoDB, se tiene la base de datos S3_Servidores para las siguientes colecciones que conciernen a la implementación de la API para el Sistema 2, y que ya fueron creadas durante la instalación de MongoDB, [Ref.[1]](#2q02kq3lfhwc).

Cada documento creado es almacenado en la base de datos S3_Servidores bajo la colección llamada  ssancionados (servidores públicos sancionados). El esquema de esta colección está basado en el documento _Esquema de servidores públicos que intervienen en procesos de contrataciones_, [Ref.[5]](#kix.ta64ysrh3hmd).


## Envío header de autorización

El header de las solicitudes GET y POST debe contener la siguiente sintaxis:

Authorization:Bearer &#60;token&#62;

El valor &#60;token&#62; es generado por el servidor de autorización Oauth 2.0, [Ref.[3]](#kix.c7de96b3ai57).

Por ejemplo:

 Authorization:Bearer  
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImVjYW1hcmdvIiwianRpIjoiRUQ4bjgzQUkiLCJzY29wZSI6InJlYWQgIiwiaWF0IjoxNTk3ODQ5NTg4LCJleHAiOjE1OTgzNTM1ODh9.PYaSHrCPpynk63ThlLOlAE\_o60QAqLDDz\_rUIi\_LGe8 |


## Solicitud GET

La solicitud GET permite obtener la información de las dependencias almacenadas en la base de datos S3_Servidores.

El esquema de retorno de las solicitudes devuelve un arreglo de objetos, donde cada objeto corresponde a una dependencia.

Ejemplo de solicitud GET por medio del enlace &#39;http://&#60;IP\_HOST&#62;:8080/v1/ssancionados/dependencias&#39; y la herramienta curl:

``` sh
curl --location --request GET 'http://<IP_HOST>:8080/v1/ssancionados/dependencias' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImVjYW1hcmdvIiwianRpIjoiRUQ4bjgzQUkiLCJzY29wZSI6InJlYWQgIiwiaWF0IjoxNTk3ODQ5NTg4LCJleHAiOjE1OTgzNTM1ODh9.PYaSHrCPpynk63ThlLOlAE_o60QAqLDDz_rUIi_LGe8'
```


Cambiar &#60;IP\_HOST&#62; por el valor de la dirección IP del host.

Lo siguiente es una posible respuesta a la solicitud GET anterior.
``` javascript
  
[
 {
   "nombre": "Instituto Federal de Telecomunicaciones",
   "clave": "IFT",
   "siglas": "IFT"
 },
 {
   "nombre": "Secretaría de Hacienda y Crédito Público",
   "clave": "SHCP",
   "siglas": "SHCP"
 },
 {
   "nombre": "Secretaría de la Función Pública",
   "clave": "SFP",
   "siglas": "SFP"
 }
]

```

  1.
## Solicitud POST

La solicitud POST permite obtener la información de los servidores públicos que intervienen en procesos de contrataciones almacenados en la base de datos S3_Servidores.

El esquema de retorno de las solicitudes devuelve un arreglo de objetos, donde cada objeto corresponde a un servidor público.

Con la solicitud POST, se tiene la capacidad de filtrar, ordenar y paginar la información.

Ejemplo de solicitud POST por medio del enlace &#39;http://&#60;IP\_HOST&#62;:8080/v1/ssancionados/&#39; y la herramienta curl:

``` sh
curl --location --request POST 'http://<IP_HOST>:8080/v1/ssancionados/' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImVjYW1hcmdvIiwianRpIjoiRUQ4bjgzQUkiLCJzY29wZSI6InJlYWQgIiwiaWF0IjoxNTk3ODQ5NTg4LCJleHAiOjE1OTgzNTM1ODh9.PYaSHrCPpynk63ThlLOlAE_o60QAqLDDz_rUIi_LGe8' \
--header 'Content-Type: application/json' \
--data-raw '{
   "sort": {"nombres" : "asc"},
   "page" : 1,
   "pageSize": 1,
   "query": {"primerApellido": "valdez", "nombres": "al"}
}'
```

Cambiar &#60;IP\_HOST&#62; por el valor de la dirección IP del host.

Lo siguiente es una posible respuesta a la solicitud POST anterior.

```json
 
{
    "pagination": {
        "hasNextPage": true,
        "page": 1,
        "pageSize": 1,
        "totalRows": 29
    },
    "results": [
        {
            "id": "5f4ec3c60c844b56647fb917",
            "institucionDependencia": {
                "nombre": "Secretaría de la Función Pública",
                "clave": "SFP",
                "siglas": "SFP"
            },
            "servidorPublicoSancionado": {
                "genero": {
                    "clave": "M",
                    "valor": "MASCULINO"
                },
                "nombres": "Alberto",
                "primerApellido": "Valdéz",
                "segundoApellido": "Morales",
                "rfc": "VAMA831116B60",
                "curp": "VAMA970310HOXLRB98",
                "puesto": "Jefe de departamento",
                "nivel": "O21"
            },
            "tipoFalta": {
                "clave": "DSCT",
                "valor": "DESACATO",
                "descripcion": "DESACATO"
            },
            "resolucion": {
                "url": " ",
                "fechaResolucion": "2020-10-08T10:15:14.824Z"
            },
            "multa": {
                "moneda": {
                    "clave": "MXN",
                    "valor": "Peso mexicano"
                },
                "monto": "21577.00"
            },
            "inhabilitacion": {
                "plazo": "4 años",
                "fechaInicial": "2016-01-08T10:15:14.824Z",
                "fechaFinal": "2020-01-08T10:15:14.824Z"
            },
            "fechaCaptura": "2020-09-01T21:57:26.084Z",
            "expediente": "431/2015",
            "autoridadSancionadora": "PGR",
            "tipoSancion": [
                {
                    "clave": "IRSC",
                    "valor": "INDEMNIZACIÓN RESARCITORIA",
                    "descripcion": ""
                }
            ],
            "causaMotivoHechos": "NO HABER EXHIBIDO LA GARANTÍA DE CUMPLIMIENTO DENTRO DEL PLAZO ESTABLECIDO EN LA CONVOCATORIA DE CONFORMIDAD CON LO DISPUESTO EN LOS ARTÍCULOS 48 Y 49 DE LA LEY DE ADQUISICIONES, ARRENDAMIENTOS Y SERVICIOS DEL SECTOR PÚBLICO, POR LO QUE SE RECINDIÓ EL CONTRATO",
            "observaciones": " ",
            "documentos": [
                {
                    "tipo": "CONSTANCIA_ABSTENCION",
                    "id": "1887AL",
                    "titulo": "CONSTANCIA_ABSTENCION",
                    "descripcion": " ",
                    "url": " ",
                    "fecha": "2018-02-19T20:10:29.448Z"
                }
            ],
            "__v": 0
        }
    ]
}
```

La estructura del body de la solicitud POST es un objeto JSON incluido en --data-raw que contiene los siguientes parámetros para filtrar, ordenar y paginar los datos.

Dado que las especificaciones pueden cambiar, para mayor referencia se recomienda consultar el estándar de datos en su versión más reciente disponible en: [https://app.swaggerhub.com/apis/pdn-mx/s3-Sancionados_Servidores_Publicos/1.1.0](https://app.swaggerhub.com/apis/pdn-mx/s3-Sancionados_Servidores_Publicos/1.1.0)

| **Parámetro** | **Tipo de dato** | **Definición** | **Valores posibles** |
| --- | --- | --- | --- |
| sort | Par clave valor JSON Object | Tipo de ordenamiento por parámetro válido | [Tabla 2. Parámetros para el ordenamiento](#kix.gegn3mk8xi8z) |
| page | Integer | Número de página | Rango: 1.. (totalrows/ pageSize) Valor default: 1 |
| pageSize | Integer | Número máximo de elementos dentro de la respuesta | Rango: 1.. 200
 Valor default: 10 |
| quey | Par clave valor JSON Object | Campos a filtrar | [Tabla 3. Parámetros para el filtrado](#kix.i9huztfumsl6) |

Tabla 1. Parámetros para filtrar, ordenar y paginar

En la siguiente tabla, se muestran los valores posibles para el parámetro sort:

| **Clave** | **Valor** | **Descripción** |
| --- | --- | --- |
| nombres | asc, desc | asc Ascendentedesc Descendente |
| primerApellido | asc, desc | asc Ascendentedesc Descendente |
| segundoApellido | asc, desc | asc Ascendentedesc Descendente |
| institucionDependencia | asc, desc | asc Ascendentedesc Descendente |
| rfc | asc, desc | asc Ascendentedesc Descendente |
| curp | asc, desc | asc Ascendentedesc Descendente |

Tabla 2. Parámetros para el ordenamiento

En la siguiente tabla, se muestran los valores posibles para el parámetro query:

| **Clave** | **Valor** | **Tipo** | **Propiedades del filtrado** |
| --- | --- | --- | --- |
| id | Ejemplo: 5f1b2bcdd53c6e32c61f95e2 | String | Filtrado estrictamente exacto. En caso de recibir cadena vacía, se omite el filtro. |
| nombres <br> Nota: El campo a comparar dentro de la base de datos es servidorPublicoSancionado.nombres | Ejemplos: &quot;Giovanni&quot; &quot;Vanni&quot; | String | Insensible a acentosBúsqueda por fragmento (valor parcial).Insensible a mayúsculas y minúsculas |
| primerApellido <br> Nota: El campo a comparar dentro de la base de datos es servidorPublicoSancionado.primerApellido | Ejemplos: &quot;Valdez&quot; &quot;ldez&quot;&quot;valdez&quot; | String | Insensible a acentosBúsqueda por fragmento (valor parcial).Insensible a mayúsculas y minúsculas |
| segundoApellido <br> Nota: El campo a comparar dentro de la base de datos es servidorPublicoSancionado.segundoApellido | Ejemplos: &quot;Juarez&quot; &quot;arez&quot;&quot;Juárez&quot; | String | Insensible a acentosBúsqueda por fragmento (valor parcial)insensible a mayúsculas y minúsculas |
| curp <br> Nota: El campo a comparar dentro de la base de datos es servidorPublicoSancionado.curp| Ejemplo: VAJA970708HVZLÁB62 | String | Insensible a acentosBúsqueda por fragmento (valor parcial).Insensible a mayúsculas y minúsculas |
| rfc <br> Nota: El campo a comparar dentro de la base de datos es servidorPublicoSancionado.rfc| Ejemplo: VAJA870610B19 | String | Insensible a acentosBúsqueda por fragmento (valor parcial).Insensible a mayúsculas y minúsculas |
|institucionDependencia <br> Nota: El campo a comparar dentro de la base de datos es  institucionDependencia.nombre | Ejemplo: Instituto Federal de Telecomunicaciones | String | Insensible a acentosBúsqueda por fragmento (valor parcial).Insensible a mayúsculas y minúsculas |
| tipoSancion |{I,M,S,D,O,IRSC,SE} <br> Ejemplo:[I,M]| Array of String (enum) | Filtrado estrictamente exacto |

Tabla 3. Parámetros para el filtrado

La estructura de la respuesta de la solicitud POST tiene dos objetos, pagination que se refiere a la funcionalidad de la paginación, y results que se refiere a los documentos obtenidos.

En la siguiente tabla, se describen los parámetros para la paginación.

| **Campo** | **Valor** | **Tipo** | **Descripción** |
| --- | --- | --- | --- |
| hasNextPage | True, False | Boolean | Indica si existe una página siguiente que tenga datos |
| pageSize | Min = 1 <br> Default = 10 <br> Max = 200 | Integer | [Tabla 1. Parámetros para filtrar, ordenar y paginar](#9dnfdqhtbo2i) |
| page | Min = 1 <br>Default = 1 | Integer | [Tabla 1. Parámetros para filtrar, ordenar y paginar](#9dnfdqhtbo2i) |
| totalRows | Min = 0 | Integer | Número total de documentos obtenidos |

Tabla 4. Parámetros de la Paginación

Para los documentos obtenidos, se tiene el objeto results el cual es un arreglo de documentos, donde cada uno tiene el esquema de la colección ssancionados, y que corresponden al filtrado y ordenamiento según los parámetros enviados en la solicitud POST. Para más información, ver la sección [Esquemas en la base de datos](#_7k0wgkx72mql).

# Transferencia de conocimiento



index.js Este archivo contiene la lógica para la inicialización y configuración de swagger; además, de la conexión a la base de datos S2

write.js    Este archivo le da formato a la respuesta. 
datos S2
openapi.yaml    Este archivo define las rutas, los esquemas de entrada y salida, y las restricciones de cada uno de ellos para ser utilizado por el archivo de index.js. Para más información, ver Ref.[5] 

Ssancionados.js    Este archivo contiene la lógica de la API para el Sistema 3 Servidores Públicos Sancionados para recibir las solicitud ReqSsancionados y enviar la respuesta resSsancionados; además, valida que tenga autorización Oauth 2.0

models.js Este archivo contiene la definición del modelo y esquema ssancionados

SsancionadosService.js     Este archivo contiene la lógica principal de las solicitudes a la base de datos S2

**Tecnologías utilizadas**

- NodeJS v12.18.2
- MongoDB 4.2.8

  1.
## index.js

&#60;home\_directory&#62;/sistema\_pdn/piloto\_s2/index.js es elarchivo que se utiliza para la inicialización y configuración de Swagger, y también para la conexión a la base de datos S2.

Las siguientes porciones de código muestran la inicialización y configuración de Swagger:

```javascript

var path = require('path');
var http = require('http');

var oas3Tools = require('oas3-tools');
var serverPort = 8080;

// swaggerRouter configuration
var options = {
    controllers: path.join(__dirname, './controllers')
};
require('dotenv').config({path: './utils/.env'});

var expressAppConfig = oas3Tools.expressAppConfig(path.join(__dirname, 'api/openapi.yaml'), options);
expressAppConfig.addValidator();
var app = expressAppConfig.getApp();

// Initialize the Swagger middleware
http.createServer(app).listen(serverPort, function () {
    console.log('Your server is listening on port %d (http://localhost:%d)', serverPort, serverPort);
    console.log('Swagger-ui is available on http://localhost:%d/docs', serverPort);
});
```

La lógica de conexión a la base de datos S2 de MongoDB se muestra en el siguiente fragmento de código.

```javascript
//connection mongo db
const db = mongoose.connect('mongodb://'+process.env.USERMONGO+':'+process.env.PASSWORDMONGO+'@'+process.env.HOSTMONGO+'/'+process.env.DATABASE, { useNewUrlParser: true,  useUnifiedTopology: true  })
   .then(() => console.log('Connect to MongoDB..'))
   .catch(err => console.error('Could not connect to MongoDB..', err))

```

  1.
## Ssancionados.js

&#60;home\_directory&#62;/sistema\_pdn/piloto\_s3s/controllers/Ssancionados.js es el archivo que contiene los controladores, los cuales son las funciones que interactúan directamente con las solicitudes del usuario. Estas funciones se vinculan con las rutas definidas en el archivo &#60;home\_directory&#62;/sistema\_pdn/piloto\_s3s/api/openapi.yaml

Las siguientes funciones son utilizadas en el archivo Ssancionados.js:

- validateToken(req)
- get\_dependencias (req, res, next)
- post\_ssancionados(req, res, next, body))


### validateToken(req)

Esta función toma los parámetros de entrada de la solicitud req, busca en el header la llave Authorization:Bearer &#60;token&#62; para obtener y validar el token, para esto, se utiliza la librería jsonwebtoken y la variable de entorno SEED. En caso de que el token sea válido y se tenga los roles necesarios, entonces se autoriza la solicitud de caso contrario se obtienen los mensajes de error los cuales se traducen al español.

A continuación, se muestra el código de la función validateToken(req):

```javascript

var validateToken = function(req){
    var inToken = null;
    var auth = req.headers['authorization'];
    if (auth && auth.toLowerCase().indexOf('bearer') == 0) {
        inToken = auth.slice('bearer '.length);
    } else if (req.body && req.body.access_token) {
        inToken = req.body.access_token;
    } else if (req.query && req.query.access_token) {
        inToken = req.query.access_token;
    }
    // invalid token - synchronous
    try {
        var decoded =  jwt.verify(inToken, process.env.SEED );
        return {code: 200, message: decoded};
    } catch(err) {
        // err
        let error="" ;
        if (err.message === "jwt must be provided"){
            error = "Error el token de autenticación (JWT) es requerido en el header, favor de verificar"
        }else if(err.message === "invalid signature" || err.message.includes("Unexpected token")){
            error = "Error token invalido, el token probablemente ha sido modificado favor de verificar"
        }else if (err.message ==="jwt expired"){
            error = "Error el token de autenticación (JWT) ha expirado, favor de enviar uno válido "
        }else {
            error = err.message;
        }

        let obj = {code: 401, message: error};
        return obj;
    }
}

```

La sentencia para acceder al header es la siguiente:

| req.headers[&#39;authorization&#39;]; |
| --- |

La sentencia para validar el token es la siguiente:

| jwt.verify(inToken, process.env.SEED ); |
| --- |


### get\_dependencias (req, res, next)

Esta función obtiene las distintas dependencias almacenadas en la base de datos S3_Servidores. En primer lugar, se valida el token, si el token no es válido retornará un error, y si es válido llamará a la función  getDependencias() que está en el archivo SsancionadosService.js y retornará el resultado a través de la función writeJson que está en el archivo writer.js. 

``` javascript
async function get_dependencias (req, res, next) {
     var code = validateToken(req);
     if(code.code == 401){
         console.log(code);
         res.status(401).json({code: '401', message: code.message});
     }else if (code.code == 200 ){
         let dependencias = await Ssancionados.getDependencias();
         utils.writeJson(res,dependencias);
     }
};
```

  
### post\_ssancionados(req, res, next, body)

Esta función obtiene los documentos de la base de datos S3_Servidores (esquema ssancionados) de acuerdo al filtrado, ordenamiento, y paginación solicitados. El siguiente fragmento de código muestra la función  post_ssancionados(req, res, next, body).

En primer lugar se realiza la validación del token, si no es válido o en caso de que el flujo refleje un error se atrapan las excepciones que son enviadas desde el servicio  y les da el formato solicitado del esquema de swagger resError.

En caso de que el token sea válido, se llama a la función post_ssancionados(body) del archivo SsancionadosService.js y se retorna su valor utilizando writeJson del archivo  writer.js.


``` javascript
async  function post_ssancionados (req, res, next, body) {
    var code = validateToken(req);
    if(code.code == 401){
        res.status(401).json({code: '401', message: code.message});
    }else if (code.code == 200 ){
        Ssancionados.post_ssancionados(body)
            .then(function (response) {
                utils.writeJson(res, response);
            })
            .catch(function (response) {
                if(response instanceof  RangeError){
                    res.status(422).json({code: '422', message:  response.message});
                }else if (response instanceof  SyntaxError){
                    res.status(422).json({code: '422', message:  response.message});
                }
            });
    }
};
```

## models.js

El esquema ssancionados y el modelo se encuentran en el archivo &#60;home\_directory&#62;/sistema\_pdn/piloto\_s3s/utils/models.js

```javascript

const { Schema, model } = require('mongoose');
const mongoosePaginate = require('mongoose-paginate-v2');

let ssancionadosSchema = new Schema({
    fechaCaptura: String,
    expediente: String,
    institucionDependencia: {
        nombre: String,
        clave: String,
        siglas: String
    },
    servidorPublicoSancionado:{
        rfc: String,
        curp: String,
        nombres: String,
        primerApellido: String,
        segundoApellido: String,
        genero: {
            clave: String,
            valor: String
        },
        puesto: String,
        nivel: String
    },
    autoridadSancionadora: String,
    tipoFalta: {
        clave: String,
        valor: String,
        descripcion: String
    },
    tipoSancion: { type: [], default: void 0 },
    causaMotivoHechos: String,
    resolucion:{
        url:String,
        fechaResolucion: String
    },
    multa:{
        monto: String,
        moneda: {
            clave:String,
            valor:String
        }
    },
    inhabilitacion:{
        plazo: String,
        fechaInicial:String,
        fechaFinal:String
    },
    documentos: { type: [], default: void 0 },
    observaciones:String
});

ssancionadosSchema.plugin(mongoosePaginate);

let Ssancionados = model('Ssancionados', ssancionadosSchema, 'ssancionados');

module.exports = {
    ssancionadosSchema,
    Ssancionados
};

```

Los esquemas o &quot;schemas&quot; son la definición de la entidad, es decir, del documento. Dentro de cada schema se definen los campos y el tipo de dato de cada uno de ellos.

El modelo o &quot;model&quot; se genera con base al schema, y permite generar operaciones CRUD hacia la base de datos, en este caso es usado en services/SsancionadosService.js.

En el código anterior, se hace uso de la función paginate() de la librería paginate-v2 una vez que se haya creado el modelo.

| ssancionadosSchema.plugin(mongoosePaginate); |
| --- |


## SsancionadosService.js

La lógica principal de las solicitudes al sistema S3 Servidores Públicos Sancionados está contenida en el archivo &#60;home\_directory&#62;/sistema\_pdn/piloto\_s3s/service/SsancionadosService.js

Las funciones dentro de los servicios son de tipo async, esto porque los métodos que provee mongoose retornan un promise_._ Por lo tanto, cuando se invoquen las funciones de los servicios, se tiene que anteponer la palabra await.

Al final de los archivos de servicios, se exportan las funciones para ser reconocidas a la hora de importarlos en el archivo controllers/Ssancionados.js.

Los servicios correspondientes a MongoDB están en el directorio &#60;home\_directory&#62;/sistema\_pdn/piloto\_s3s/service.

Dentro del archivo SsancionadosService.js, se tienen varias funciones que se describen en las siguientes secciones.

### diacriticSensitiveRegex(text)

La función diacriticSensitiveRegex(text) se utiliza en la sensibilidad de los acentos. Recibe el parámetro text, el cual es una cadena de texto, y reemplaza las vocales por la sintaxis correcta para que sea insensible a los acentos mediante una función regex.

```javascript
function diacriticSensitiveRegex(string = '') {
    string = string.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    return string.replace(/a/g, '[a,á,à,ä]')
        .replace(/e/g, '[e,é,ë]')
        .replace(/i/g, '[i,í,ï]')
        .replace(/o/g, '[o,ó,ö,ò]')
        .replace(/u/g, '[u,ü,ú,ù]')
        .replace(/A/g, '[a,á,à,ä]')
        .replace(/E/g, '[e,é,ë]')
        .replace(/I/g, '[i,í,ï]')
        .replace(/O/g, '[o,ó,ö,ò]')
        .replace(/U/g, '[u,ü,ú,ù]')
}
```
### getDependencias()

La función getDependencias() devuelve las dependencias. Estas dependencias son extraídas de la misma colección ssancionados de la base de datos S3_Servidores. En el siguiente código se muestra las instrucciones para obtener las dependencias que son distintas.

```javascript
async function getDependencias (){
    let dependencias = await Ssancionados.find({institucionDependencia : {$exists: true }}).distinct('institucionDependencia').exec();
    return dependencias;
}
```

El código utiliza el modelo Ssancionados exportado y generado en el archivo utils/models.js

Este modelo hace una solicitud a la base de datos con el método find(), dentro del método mandamos el campo solicitado en este caso institucionDependencia e indicamos validar que exista este campo en los documentos a retornar con la sentencia {$exists: true }

Después de tener los documentos filtrados, se eliminan los duplicados con la función distinct(&quot;institucionDependencia&quot;).

   
### post\_ssancionados(body)

La función post\_ssancionados(body) devuelve la información del esquema ssancionados y tiene la capacidad de filtrar, ordenar y paginar. utilizando el método POST. Esta función se divide en tres partes importantes, como se describe a continuación:

- **Recepción del body**

El método recibe el body en formato json y extrae los parámetros de la siguiente manera

```javascript
let pageSize = body.pageSize;
let query = body.query === undefined ? {} : body.query;
```

Dentro de la función también se realizan validaciones para los parámetros recibidos, por ejemplo el parámetro page no puede ser menor que 1.
``` javascript
  if(page <= 0 ){
        throw new RangeError("Error campo page fuera de rango");
}
```
- **Extracción de filtros de query**

Del parámetro query, se obtienen los campos para el filtrado en forma de clave y valor, en donde cada clave tiene requerimientos diferentes en cuanto a reglas de negocio y validaciones necesarias. Ver [Tabla 3. Parámetros para el filtrado](#kix.i9huztfumsl6).

Dentro de la función se irá armando un objeto json nuevo correspondiente al parámetro query, para armarlo se recorren los valores extraídos del query recibido en la petición del usuario, en búsqueda de los filtros permitidos y/o reconocidos por el estándar. En caso de ser necesario, se realizarán validaciones y/o mapeos. 

Por ejemplo, en el siguiente código se aprecia que en caso de recibir dentro del query el parámetro segundoApellido, se agregará al objeto nuevo pero una vez que sea transformado por la función diacriticSensitiveRegex, para hacer que el filtro no sea sensible a acentos 

``` javascript
for (let [key, value] of Object.entries(query)) {
 if( key === "curp" || key === "rfc"){
        newQuery["servidorPublicoSancionado."+key] = { $regex : value,  $options : 'i'}
      }
.
.
.
            }
```

- Ordenamiento

Dentro de la función se irá armando un objeto json nuevo correspondiente al parámetro sort, para armarlo se recorren los valores extraídos del campo sort recibido en la petición del usuario, en búsqueda de los filtros permitidos y/o reconocidos por el estándar. En caso de ser necesario, se realizarán validaciones y/o mapeos. 


``` javascript
for (let [key, value] of Object.entries(sortObj)) {
      if(key === "curp" || key === "rfc" || key === "nombres" || key === "segundoApellido" || key === "primerApellido" ){
        newSort["servidorPublicoSancionado."+key] = value;
      }
      if(key === "institucionDependencia"){
        newSort[key+".nombre"]= value
      }else{
        newSort[key]= value;
      }
    }
```

- **Obtención de datos y Paginación**

**Una vez que se han procesado los parámetros recibidos en la petición, se armará la respuesta de la misma. Esta respuesta consiste, de acuerdo al estándar, en el parámetro de paginación y el arreglo de resultados.**

Para la consulta hacia la base de datos, se utiliza la librería paginate-v2 la cual a través de la función paginate() genera la consulta y permite obtener los resultados filtrados por el query y la paginación correspondiente, que formarán parte de la respuesta del API.

``` javascript 
 let paginationResult  = await Ssancionados.paginate(newQuery,{page :page , limit: pageSize, sort: newSort}).then();
 let objpagination ={hasNextPage : paginationResult.hasNextPage, page:paginationResult.page, pageSize : paginationResult.limit, totalRows: paginationResult.totalDocs }
 let objresults = paginationResult.docs;
```

La función paginate() de la liberia paginate-v2 recibe 2 argumentos:

1. newQuery
2. objeto json {page :page , limit: pageSize, sort: newSort} con los valores para la paginación

Page : Número de página

Limit: Límite de registros por página

Sort: Objeto clave valor, la clave refiere al nombre del campo y el valor refiere a uno de los dos posibles valores [asc,desc]

En la implementación realizada, el campo _id es el identificador de cada documento de la base de datos, pero en el request su nombre es id, por lo tanto, a los documentos retornados por la base de datos es necesario reemplazar el atributo _id por id:

``` javascript
 try {
            var strippedRows = _.map(objresults, function (row) {
               let rowExtend=  _.extend({id: row._id} , row.toObject());
               return _.omit(rowExtend, '_id');
                });
     }catch (e) {
            console.log(e);
     }

```

Finalmente se puede construir la respuesta del API la cual tendrá el campo pagination y results.

``` javascript
 let objResponse= {};
            objResponse["pagination"] = objpagination;
            objResponse["results"]= strippedRows;
            return objResponse;
```

## Respuestas de error y causas

La mayoría de los mensajes de error son proporcionados por las librerías utilizadas.

| **Mensaje de error** | **Status del error** | **causa** |
| --- | --- | --- |
| Error el token de autenticación (JWT) es requerido en el header, favor de verificar | 401 | Verificar que se está mandando el token en el encabezado |
| Error el token de autenticación (JWT) ha expirado, favor de enviar uno válido | 401 | El token expiró por lo tanto ya no es válido |
| Error token inválido, el token probablemente ha sido modificado favor de verificar | 401 | El token no es válido |
| Error token inválido, el token probablemente ha sido modificado favor de verificar | 401 | El token está mal formado verificar token |
| Error campo pageSize fuera de rango, el rango del campo es 1..200 | 422 | Verificar el rango del campo pageSize |
| Error campo page fuera de rango | 422 | Verificar el rango del campo page |

1.
# Glosario

El glosario general se incluye en el anexo Guía de ayuda, [Ref.[4]](#xdfe451pw6sm).

1.
# Referencias

| **Ref.** | **Nombre del documento** | **Número del documento** |
| --- | --- | --- |
| 1 | [Reporte de instalación](https://docs.google.com/document/d/1T31p7_n89bOMkW9ZC_G0ZGoldc_XyB_fWuMZ7u9Qlvo/edit?usp=sharing)[GOV UK\_IIR\_Interconnection of S2 and S3 of the PDN](https://docs.google.com/document/d/1T31p7_n89bOMkW9ZC_G0ZGoldc_XyB_fWuMZ7u9Qlvo/edit?usp=sharing) | TXMG-00848 |
| 2 | [Generador de Datos Sintéticos](https://docs.google.com/document/d/1RQQssZpUOH6d5103QMPkY6v2wakRvQk0yLqobm1AzB8/edit?usp=sharing)[GOV UK\_Gen\_Interconnection of S2 and S3 to the PDN](https://docs.google.com/document/d/1RQQssZpUOH6d5103QMPkY6v2wakRvQk0yLqobm1AzB8/edit?usp=sharing) | TXMG-00850 |
| 3 | [Servidor de Autorización Oauth 2.0](https://docs.google.com/document/d/1Fbb7jzxH6Ql10vVJ2UejaTI1vzSeherNILmrDlJgr6k/edit?usp=sharing)[GOV UK\_Oauth2 Interconnection of S2 and S3 to the PDN](https://docs.google.com/document/d/1Fbb7jzxH6Ql10vVJ2UejaTI1vzSeherNILmrDlJgr6k/edit?usp=sharing) | TXMG-00849 |
| 4 | [Guía de ayuda](https://docs.google.com/document/d/1qbxdN9IKSrzdO57NoIgWctBiBNZo4r1-PwfW2Ac2YWc/edit?usp=sharing)[GOV UK\_Anexo\_Interconnection of S2 and S3 of the PDN](https://docs.google.com/document/d/1qbxdN9IKSrzdO57NoIgWctBiBNZo4r1-PwfW2Ac2YWc/edit?usp=sharing) | TXMG-00853 |
| 5 | [Esquema de servidores públicos sancionados](https://app.swaggerhub.com/apis/pdn-mx/s3-Sancionados_Servidores_Publicos/1.1.0) | - |
