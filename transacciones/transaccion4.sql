-- Codigo de la transaccion 4:
/*
Registrar una garantía: Crear una garantía y vincularla con la 
compra de un producto, si el producto y el dueño desean una garantía.
*/
USE SistemaDeGestion;
GO

CREATE PROCEDURE RegistrarGarantiaConCompra
    -- Parámetros para insertar la nueva garantía
    @fecha_inicio_garantia DATE,
    @fecha_fin_garantia DATE,
    @descripcion_garantia VARCHAR(200),

    -- Parámetros para identificar la compra y el producto a asociar
    @id_compra INT,
    @id_producto INT

AS 
BEGIN 
    SET NOCOUNT ON; -- Evita que SQL Server devuelva mensajes de conteo de filas
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Se declaran variables para validaciones
        DECLARE @id_garantia_generada INT;      -- Para guardar el ID generado de la nueva garantía
        -- DECLARE @cedula_cliente INT;            -- (Reservada para futuras validaciones, si se desea validar dueño del producto)

        -- 1. Verificar si la compra existe
        IF NOT EXISTS (SELECT 1 FROM compra WHERE id_compra = @id_compra)
        BEGIN
            RAISERROR('Error: La compra con ID %d no existe.', 16, 1, @id_compra);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Verificar si el producto existe
        IF NOT EXISTS (SELECT 1 FROM producto WHERE id_producto = @id_producto)
        BEGIN
            RAISERROR('Error: El producto con ID %d no existe.', 16, 1, @id_producto);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 3. Verificar que la compra y el producto están relacionados
        IF NOT EXISTS (SELECT 1 FROM compra_producto WHERE id_compra = @id_compra AND id_producto = @id_producto)
        BEGIN
            RAISERROR('Error: La compra con ID %d no incluye el producto con ID %d.', 16, 1, @id_compra, @id_producto);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 4. Se valida si las fechas de la garantía son válidas
        IF @fecha_inicio_garantia IS NULL OR @fecha_fin_garantia IS NULL OR @fecha_inicio_garantia >= @fecha_fin_garantia
        BEGIN
            RAISERROR('Error: Las fechas de la garantía no son válidas. Asegúrese de que la fecha de inicio sea anterior a la fecha de fin.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @fecha_inicio_garantia < '2000-01-01' OR @fecha_fin_garantia > GETDATE()
        BEGIN
            RAISERROR('Error: Las fechas de la garantía deben estar dentro de un rango razonable (2000-01-01 a hoy).', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validacion de la descripción de la garantía
        IF @descripcion_garantia IS NULL OR LEN(@descripcion_garantia) = 0
        BEGIN
            RAISERROR('Error: La descripción de la garantía no puede estar vacía.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 5. Insertar la garantía usando un procedimiento que retorna el ID generado
        PRINT 'INFO (RegistrarGarantiaConCompra): Insertando garantía...';
        EXEC [dbo].[InsertarGarantia]
            @fecha_inicio = @fecha_inicio_garantia,
            @fecha_fin = @fecha_fin_garantia,
            @descripcion = @descripcion_garantia,
            @id_generado = @id_garantia_generada OUTPUT;  -- Salida para obtener el ID de la garantía

        -- Validar que se haya generado correctamente el ID
        IF @id_garantia_generada IS NULL
        BEGIN
            RAISERROR('Error Crítico: No se pudo obtener el ID para la nueva garantía después de llamar a InsertarGarantia.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        PRINT 'INFO (RegistrarGarantiaConCompra): Garantía registrada con ID ' + CAST(@id_garantia_generada AS VARCHAR);
        
        -- 6. Actualizar la compra_producto para vincular la garantía
        PRINT 'INFO (RegistrarGarantiaConCompra): Actualizando compra_producto para vincular la garantía...';
        UPDATE compra_producto
        SET garantia = @id_garantia_generada
        WHERE id_compra = @id_compra AND id_producto = @id_producto;

        -- Validar que la actualización haya tenido efecto
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Error: No se pudo vincular la garantía con la compra y el producto especificados.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Confirmación visual
        SELECT 'Garantía registrada correctamente con ID = ' + CAST(@id_garantia_generada AS VARCHAR) AS Mensaje;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, se revierte la transacción y se lanza el mensaje
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capturar y mostrar el error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        PRINT 'Error en el procedimiento RegistrarGarantiaConCompra.';
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
END;
GO

-- Datos de prueba para el procedimiento RegistrarGarantiaConCompra
EXEC InsertarPersona @cedula = 11111111, 
                    @nombre = 'Ana', 
                    @apellido1 = 'Rojas', 
                    @apellido2 = 'Jiménez', 
                    @distrito = 1, 
                    @señas = '50m norte del parque central'; 

EXEC InsertarCliente @cedulaCliente = 11111111;                    

EXEC InsertarProducto @nombreProducto = 'Laptop', 
                        @precio = 600000.00, 
                        @marca = 'Dell', 
                        @stock = 10, 
                        @id_categoria = 0, 
                        @descripcion = 'Laptop de alto rendimiento';

--SELECT MAX(id_producto) AS id_producto FROM producto;        -- Para obtener el ID del producto recién insertado                
--SET IDENTITY_INSERT computacion ON;           -- En caso de que InsertarProductoComputación no funcione
EXEC InsertarProductoComputación @id = 4, @gama = 'Media';

UPDATE producto SET id_categoria = 4 WHERE id_producto = 4; -- Se le actualiza la categoría del producto 

DECLARE @id_compra_generado INT; 
EXEC InsertarCompra 
        @fecha = '2024-06-01', 
        @cedula = 11111111, 
        @devolucion = NULL, 
        @id_generado = @id_compra_generado OUTPUT;

EXEC InsertarCompraProducto 
        @id_compra = @id_compra_generado, 
        @id_producto = 4, 
        @garantia = NULL, 
        @monto_pagado = 600000.00, 
        @metodo_pago = 'Efectivo';

------------------- Ejemplo de uso del procedimiento RegistrarGarantiaConCompra -------------------
EXEC RegistrarGarantiaConCompra 
        @fecha_inicio_garantia = '2024-01-01', 
        @fecha_fin_garantia = '2024-12-31', 
        @descripcion_garantia = 'Cobertura completa por 1 año', 
        @id_compra = 16, 
        @id_producto = 4;