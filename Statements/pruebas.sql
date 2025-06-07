-- Se actualizan las tablas computacion, tecnologia y linea_blanca para que sean subtipos de la tabla producto
ALTER TABLE computacion
ADD CONSTRAINT FK_computacion_productos FOREIGN KEY (id)
REFERENCES producto(id_producto);

ALTER TABLE tecnologia
ADD CONSTRAINT FK_tecnologia_productos FOREIGN KEY (id)
REFERENCES producto(id_producto);

ALTER TABLE linea_blanca 
ADD CONSTRAINT FK_linea_blanca_productos FOREIGN KEY (id)
REFERENCES producto(id_producto);

-- Se actualiza la tabla compra para que el atributo devoluion haga referencia al id de devolucion
ALTER TABLE compra
ADD CONSTRAINT FK_compra_devolucion FOREIGN KEY (devolucion) REFERENCES devolucion(id_devolucion);  

-- Se actualiza la tabla administrador_producto para que el atributo producto haga referencia al id de producto de la tabla producto
ALTER TABLE administrador_producto
ADD CONSTRAINT FK_administrador_producto_productos FOREIGN KEY (producto) REFERENCES producto(id_producto);

SELECT 
    fk.name AS ForeignKey,
    tp.name AS ParentTable,
    ref.name AS ReferencedTable,
    c1.name AS ParentColumn,
    c2.name AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables AS ref ON fk.referenced_object_id = ref.object_id
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS c1 ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id
INNER JOIN sys.columns AS c2 ON fkc.referenced_object_id = c2.object_id AND fkc.referenced_column_id = c2.column_id
WHERE tp.name = 'linea_blanca';

