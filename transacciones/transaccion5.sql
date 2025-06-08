-- Codigo de la transaccion 5:
/*
Insertar nuevos clientes que realicen una compra: registrar persona, 
el cliente, la compra realizada, el teléfono y el correo. 
*/
USE SistemaDeGestion;
GO

CREATE PROCEDURE RegistrarNuevoClienteConCompra
    -- Parámetros para la nueva persona y cliente
    @cedula_nueva INT,
    @nombre_nuevo VARCHAR(30),
    @apellido1_nuevo VARCHAR(30),
    @apellido2_nuevo VARCHAR(30),
    @distrito_nuevo INT,
    @señas_nuevas VARCHAR(200),
    @telefono_nuevo VARCHAR(15) = NULL, -- Teléfono es opcional
    @correo_nuevo VARCHAR(50) = NULL,   -- Correo es opcional

    -- Parámetros para la compra
    @fecha_compra DATE, 
    @id_producto_comprado INT,
    @cantidad_comprada INT = 1, -- Por ahora solo se compra una unidad por transacción
    @monto_pagado_compra FLOAT,
    @metodo_pago_compra VARCHAR(30),
    @id_devolucion_default INT = NULL, 
    @id_garantia_default INT = NULL     
AS
BEGIN
    SET NOCOUNT ON;                 -- Evita que SQL Server devuelva mensajes de conteo de filas
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @id_compra_generada INT;

        -- 1. Registrar nueva persona 
        EXEC [dbo].[InsertarPersona]
            @cedula = @cedula_nueva,
            @nombre = @nombre_nuevo,
            @apellido1 = @apellido1_nuevo,
            @apellido2 = @apellido2_nuevo,
            @distrito = @distrito_nuevo,
            @señas = @señas_nuevas;

        -- 2. Inserta al cliente (subclase de persona)
        EXEC [dbo].[InsertarCliente]
            @cedulaCliente = @cedula_nueva;

        -- 3. Si se proporcionó un teléfono, se inserta
        IF @telefono_nuevo IS NOT NULL AND @telefono_nuevo <> ''
        BEGIN
            EXEC [dbo].[InsertarTelefonoPersona]
                @cedulaTelefono = @cedula_nueva,
                @telefono = @telefono_nuevo;
        END

        -- 4. Si se proporcionó un correo, se inserta
        IF @correo_nuevo IS NOT NULL AND @correo_nuevo <> ''
        BEGIN
            EXEC [dbo].[InsertarCorreoPersona]
                @cedulaCorreo = @cedula_nueva,
                @correo = @correo_nuevo;
        END

        -- 5. Verifica que el producto exista y que haya suficiente stock
        DECLARE @stock_disponible INT;
        SELECT @stock_disponible = stock FROM [dbo].[producto] WHERE [id_producto] = @id_producto_comprado;

        -- Si no existe el producto, se lanza un error
        IF @stock_disponible IS NULL
        BEGIN
            RAISERROR('Error: El producto con ID %d no existe.', 16, 1, @id_producto_comprado);
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        -- Si no hay suficiente stock, se lanza un error
        IF @stock_disponible < @cantidad_comprada 
        BEGIN
            RAISERROR('Error: No hay stock suficiente (%d disponibles) para el producto con ID %d (solicitados: %d).', 16, 1, @stock_disponible, @id_producto_comprado, @cantidad_comprada);
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        -- 6. Inserta la compra en la base de datos
        EXEC [dbo].[InsertarCompra]
            @fecha = @fecha_compra,
            @cedula = @cedula_nueva,
            @devolucion = @id_devolucion_default; 

        -- Recupera el ID generado automáticamente para la compra
        SET @id_compra_generada = SCOPE_IDENTITY(); 
        
        -- Verifica que el ID de la compra se haya generado correctamente
        IF @id_compra_generada IS NULL
        BEGIN
             RAISERROR('Error: No se pudo generar el ID para la nueva compra.', 16, 1);
             ROLLBACK TRANSACTION;
             RETURN;
        END

        -- 7. Inserta el detalle de la compra en la tabla Compra_Producto
        EXEC [dbo].[InsertarCompraProducto]
            @id_compra = @id_compra_generada,
            @id_producto = @id_producto_comprado,
            @garantia = @id_garantia_default, 
            @monto_pagado = @monto_pagado_compra,
            @metodo_pago = @metodo_pago_compra;           

        -- 8. Actualiza el stock del producto restando la cantidad comprada
        UPDATE [dbo].[producto]
        SET stock = stock - @cantidad_comprada 
        WHERE id_producto = @id_producto_comprado;

        -- Verifica que la actualización del stock se haya realizado
        IF @@ROWCOUNT = 0 
        BEGIN
            RAISERROR('Error: No se pudo actualizar el stock del producto con ID %d.', 16, 1, @id_producto_comprado);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si todo salió bien, se confirma la transacción
        PRINT 'Procedimiento RegistrarNuevoClienteConCompra completado exitosamente para cédula: ' + CAST(@cedula_nueva AS VARCHAR(20));
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, se revierte la transacción y se lanza el mensaje
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'Error en el procedimiento RegistrarNuevoClienteConCompra para cédula: ' + CAST(@cedula_nueva AS VARCHAR(20));
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN;
    END CATCH
END;
GO