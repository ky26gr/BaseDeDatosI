USE SistemaDeGestion

-->Creación de tablas de datos 

-->TABLA PERSONAS: llave primaria cedula, llave foranea id_distrio 
CREATE TABLE persona 
(
    cedula       INT NOT NULL, 
    nombre       VARCHAR(30) NOT NULL, 
    apellido1    VARCHAR(30) NOT NULL,
    apellido2    VARCHAR(30) NOT NULL,
    distrito     INT NOT NULL,
    señas        VARCHAR(200) NOT NULL
    CONSTRAINT PK_cedula PRIMARY KEY (cedula)
);

ALTER TABLE persona
ADD CONSTRAINT FK_distrito FOREIGN KEY (distrito) 
REFERENCES distritos(id_distrito);

-->TABLA DISTRITOS: llave primaria id_distrito, llave foranea id_canton
CREATE TABLE distritos
(
    id_distrito   INT NOT NULL IDENTITY(1,1), 
    distrito      VARCHAR(30) NOT NULL,
    id_canton     INT NOT NULL,
    CONSTRAINT PK_id_distrito PRIMARY KEY (id_distrito)
);

ALTER TABLE distritos 
ADD CONSTRAINT FK_id_canton FOREIGN KEY (id_canton) 
REFERENCES cantones(id_canton);

-->TABLA CANTONES: llave primaria id_canton, llave foranea id_provincia
CREATE TABLE cantones 
(
    id_canton INT NOT NULL IDENTITY(1,1), 
    canton VARCHAR(30) NOT NULL,
    id_provincia INT NOT NULL, 
    CONSTRAINT PK_id_canton PRIMARY KEY (id_canton)
);

ALTER TABLE cantones 
ADD CONSTRAINT FK_id_provincia FOREIGN KEY (id_provincia) 
REFERENCES provincias(id_provincia);

-->TABLA PROVINCIAS: llave primaria id_provincia
CREATE TABLE provincias 
(
    id_provincia INT NOT NULL IDENTITY(1,1), 
    provincia VARCHAR(30) NOT NULL,
    CONSTRAINT PK_id_provincia PRIMARY KEY (id_provincia)
);

-->TABLA TELEFONOS_PERSONAS: llave primaria cedula, telefono, llave foranea cedula
CREATE TABLE telefonos_personas
(
    cedula INT NOT NULL, 
    telefono CHAR(9) NOT NULL, 
    CONSTRAINT PK_telefono_persona PRIMARY KEY (cedula, telefono)
); 

ALTER TABLE telefonos_personas
ADD CONSTRAINT FK_telefono_persona FOREIGN KEY (cedula) 
REFERENCES persona(cedula);

-->TABLA CORREOS_PERSONAS: llave primaria cedula, correo, llave foranea cedula
CREATE TABLE correos_personas 
(
    cedula INT NOT NULL, 
    correo VARCHAR(50) NOT NULL,
    CONSTRAINT PK_correo_persona PRIMARY KEY (cedula, correo)
);

ALTER TABLE correos_personas
ADD CONSTRAINT FK_correo_persona FOREIGN KEY (cedula) 
REFERENCES persona(cedula);

-->TABLA DE CLIENTES: llave primaria cedula, llave foranea cedula de persona
CREATE TABLE cliente
(
    cedula INT NOT NULL, 
    CONSTRAINT PK_cliente PRIMARY KEY (cedula)
);

ALTER TABLE cliente 
ADD CONSTRAINT FK_cliente FOREIGN KEY (cedula)
REFERENCES persona(cedula); 

-->TABLA DE ADMINSITRATIVOS: llave primaria cedula, llave foranea cedula de persona
CREATE TABLE administrativos
(
    cedula INT NOT NULL, 
    CONSTRAINT PK_administrativo PRIMARY KEY (cedula)
);

ALTER TABLE administrativos 
ADD CONSTRAINT FK_administrativo FOREIGN KEY (cedula)
REFERENCES persona(cedula); 

-->TABLA DE ADMINISTRADORES_PRODUCTO: llave primaria cedula, producto, llave foranea cedula de administrativos y llave foranea id_producto de producto
CREATE TABLE administrador_producto
(
    cedula INT NOT NULL, 
    producto INT NOT NULL, 
    CONSTRAINT PK_administrador_producto PRIMARY KEY (cedula, producto)
); 

ALTER TABLE administrador_producto
ADD CONSTRAINT FK_administrador_producto FOREIGN KEY (cedula)
REFERENCES administrativos(cedula);

ALTER TABLE administrador_producto
ADD CONSTRAINT FK_producto FOREIGN KEY (producto)
REFERENCES producto(id_producto);


-->TABLA DE PRODUCTOS: llave primaria id_producto, llave foranea id_categoria de categoria
CREATE TABLE producto
(
    id_producto INT NOT NULL IDENTITY(1,1), 
    nombre VARCHAR(30) NOT NULL,
    precio FLOAT NOT NULL,
    marca VARCHAR(30) NOT NULL,
    stock INT NOT NULL,
    id_categoria INT NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    CONSTRAINT PK_id_producto PRIMARY KEY (id_producto)
); 

-->TABLAS QUE HAY QUE REVISAR PARA AÑADIR CATEGORIA 
CREATE TABLE computacion
(
    id INT NOT NULL IDENTITY(1,1),
    gama VARCHAR(30) NOT NULL,
    CONSTRAINT PK_id_computacion PRIMARY KEY (id)
);

CREATE TABLE tecnologia
(
    id INT NOT NULL IDENTITY(1,1),
    resistencia VARCHAR(30) NOT NULL,
    CONSTRAINT PK_id_tecnologia PRIMARY KEY (id)
);

CREATE TABLE linea_blanca
(
    id INT NOT NULL IDENTITY(1,1),
    demensiones VARCHAR(30) NOT NULL,
    CONSTRAINT PK_id_linea_blanca PRIMARY KEY (id)
); 


-->TABLA DE PEDIDOS: llave primaria id_pedido, llave foranea cedula de cliente, llave foranea distrito de distritos
CREATE TABLE pedido
(
    id_pedido INT NOT NULL IDENTITY(1,1),
    cedula INT NOT NULL, 
    estado TINYINT NOT NULL, 
    detalles VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    distrito INT NOT NULL, 
    señas VARCHAR(200) NOT NULL,
    CONSTRAINT PK_id_pedido PRIMARY KEY (id_pedido)
);

ALTER TABLE pedido
ADD CONSTRAINT FK_pedido_cliente FOREIGN KEY (cedula)
REFERENCES cliente(cedula);

ALTER TABLE pedido
ADD CONSTRAINT FK_pedido_distrito FOREIGN KEY (distrito)
REFERENCES distritos(id_distrito);

-->TABLA DE DETALLES_PEDIDO: llave primaria id_pedido, llave foranea id_pedido de pedido
CREATE TABLE detalles_pedido
(
    id_pedido INT NOT NULL, 
    cantidad INT NOT NULL, 
    observaciones VARCHAR(200) NOT NULL,
    CONSTRAINT PK_detalles_pedido PRIMARY KEY (id_pedido)
);

ALTER TABLE detalles_pedido
ADD CONSTRAINT FK_detalles_pedido FOREIGN KEY (id_pedido)
REFERENCES pedido(id_pedido);

-->TABLA DE PEDIDOS_COMPRA: llave primaria id_pedido, id_compra, llave foranea id_pedido de pedido y llave foranea id_compra de compra
CREATE TABLE pedido_compra
(
    id_pedido INT NOT NULL, 
    id_compra INT NOT NULL, 
    CONSTRAINT PK_pedido_compra PRIMARY KEY (id_pedido, id_compra)
);

ALTER TABLE pedido_compra
ADD CONSTRAINT FK_pedido_compra FOREIGN KEY (id_pedido)
REFERENCES pedido(id_pedido);

ALTER TABLE pedido_compra
ADD CONSTRAINT FK_compra FOREIGN KEY (id_compra)
REFERENCES compra(id_compra);

-->TABLA DE COMPRAS: llave primaria id_compra, llave foranea cedula de cliente y llave foranea devolucion de devolucion
CREATE TABLE compra
(
    id_compra INT NOT NULL IDENTITY(1,1), 
    fecha DATE NOT NULL, 
    cedula INT NOT NULL, 
    devolucion INT NOT NULL, 
    CONSTRAINT PK_id_compra PRIMARY KEY (id_compra)
);

ALTER TABLE compra
ADD CONSTRAINT FK_compra_cliente FOREIGN KEY (cedula)
REFERENCES cliente(cedula);

ALTER TABLE compra 
ADD CONSTRAINT FK_compra_devolucion FOREIGN KEY (devolucion)
REFERENCES devolucion(id_devolucion);

-->TABLA DE COMPRA_PRODUCTO: llave primaria id_compra, id_producto, llave foranea id_compra de compra, 
-->llave foranea id_producto de producto y llave foranea garantia de garantia
CREATE TABLE compra_producto
(
    id_compra INT NOT NULL, 
    id_producto INT NOT NULL,
    garantia INT NULL, 
    monto_pagado FLOAT NULL, 
    metodo_pago VARCHAR(30) NULL,
    CONSTRAINT PK_compra_producto PRIMARY KEY (id_compra, id_producto)
);

ALTER TABLE compra_producto
ADD CONSTRAINT FK_compra_producto FOREIGN KEY (id_compra)
REFERENCES compra(id_compra);

ALTER TABLE compra_producto
ADD CONSTRAINT FK_grantia FOREIGN KEY (garantia)
REFERENCES garantia(id_garantia);

ALTER TABLE compra_producto
ADD CONSTRAINT FK_producto_compra FOREIGN KEY (id_producto)
REFERENCES producto(id_producto);

-->TABLA DE DEVOLUCIONES: llave primaria id_devolucion
CREATE TABLE devolucion
(
    id_devolucion INT NOT NULL IDENTITY(1,1), 
    producto_devuelto VARCHAR(15) NOT NULL, 
    fecha_devolucion DATE NOT NULL, 
    razon VARCHAR(200) NOT NULL,
    estado TINYINT NOT NULL,
    CONSTRAINT PK_id_devolucion PRIMARY KEY (id_devolucion)
);

-->TABLA DE GARANTIAS: llave primaria id_garantia
CREATE TABLE garantia
(
    id_garantia INT NOT NULL IDENTITY(1,1), 
    fecha_inicio DATE NOT NULL, 
    fecha_fin DATE NOT NULL, 
    descripcion VARCHAR(200) NOT NULL,
    CONSTRAINT PK_id_garantia PRIMARY KEY (id_garantia)
); 


