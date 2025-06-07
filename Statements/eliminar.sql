--> Procedimeintos de eliminación de datos en todas las tablas 

USE SistemaDeGestion

-->Visualizar las tablas de la base de datos junto con el tipo de dato de cada columna, para consulta
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'garantia';

-->Procedimeinto para ELIMINAR personas, con verificación de datos para saber si la persona se encuentra en la tabla mediante su cedula, 
-- eliminando tambien sus teléfonos y correos asociados.
-- La cedula es la llave primaria de la tabla persona, y se elimina de las tablas telefonos_personas y correos_personas 
GO
CREATE PROCEDURE EliminarPersona
(
    @cedula INT 
)
AS 
BEGIN 
    BEGIN TRY
        IF @cedula IN (SELECT cedula FROM telefonos_personas)
            BEGIN 
                DELETE FROM telefonos_personas
                WHERE cedula = @cedula;
            END
        IF @cedula IN (SELECT cedula FROM correos_personas)
            BEGIN 
                DELETE FROM correos_personas
                WHERE cedula = @cedula;
            END
        IF @cedula NOT IN (SELECT cedula FROM persona)
            BEGIN 
                SELECT 'La persona no existe en la base de datos.' AS Mensaje;
                RETURN;
            END

        DELETE FROM persona
        WHERE cedula = @cedula;
    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorMensaje;
    END CATCH
END; 
GO 
