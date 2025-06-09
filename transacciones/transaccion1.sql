-- Codigo de la transaccion 1:
/*
Registrar compra: Insertar compra, compra producto y reduce stock del 
producto en la tabla de productos. (Ver que el cliente ya exista en la 
base para asignarle la compra o sino crear la persona cliente)
*/
USE SistemaDeGestion;
GO

CREATE PROCEDURE RegistrarCompraCliente
    @cedula_cliente INT,

    -- Parámetros para la compra
    @id_producto_comprado INT,
    @fecha_compra DATE,
    @monto_pagado FLOAT,
    @metodo_pago VARCHAR(30),
    
    -- Parámetros opcionales para devolución y garantía
    @id_devolucion_param INT = NULL,
    @id_garantia_param INT = NULL
AS
BEGIN
    SET NOCOUNT ON; 
    
    BEGIN TRANSACTION;

    BEGIN TRY 
        DECLARE @id_compra_nueva INT;
        DECLARE @stock_actual INT;

        -- 1. Verificar si la persona existe. Si no existe se cancela la transacción y pide crearla, usando la transacción 5
        IF NOT EXISTS (SELECT 1 FROM persona WHERE cedula = @cedula_cliente)
        BEGIN
            RAISERROR('Error: El cliente con cédula %d no existe. Por favor regístrelo primero.', 16, 1, @cedula_cliente);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Verificar stock del producto
        SELECT @stock_actual = stock FROM producto WHERE id_producto = @id_producto_comprado;
        
        IF @stock_actual IS NULL
        BEGIN
            RAISERROR('Error (SP RegistrarCompraCliente): El producto con ID %d no existe.', 16, 1, @id_producto_comprado);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @stock_actual < 1
        BEGIN
            RAISERROR('Error (SP RegistrarCompraCliente): No hay suficiente stock (%d disponibles) para el producto ID %d (solicitados: 1).', 16, 1, @stock_actual, @id_producto_comprado);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        PRINT 'INFO (SP RegistrarCompraCliente): Stock verificado para producto ID ' + CAST(@id_producto_comprado AS VARCHAR) + '. Disponible: ' + CAST(@stock_actual AS VARCHAR);

        DECLARE @id_generado INT;           -- Variable para almacenar el ID de la compra generada
        -- 3. Insertar en la tabla compra
        PRINT 'INFO (SP RegistrarCompraCliente): Insertando en tabla compra...';
        EXEC [dbo].[InsertarCompra]
            @fecha = @fecha_compra,
            @cedula = @cedula_cliente,
            @devolucion = @id_devolucion_param,  -- Puede ser NULL si no hay devolución
            @id_generado = @id_generado OUTPUT;  -- Salida para obtener el ID de la compra
        
        SET @id_compra_nueva = @id_generado;  -- Asignar el ID generado a la variable de salida
        PRINT 'INFO (SP RegistrarCompraCliente): Compra registrada con ID ' + CAST(@id_compra_nueva AS VARCHAR);
        IF @id_compra_nueva IS NULL
        BEGIN
            RAISERROR('Error Crítico (SP RegistrarCompraCliente): No se pudo obtener el ID para la nueva compra después de llamar a InsertarCompra.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        PRINT 'INFO (SP RegistrarCompraCliente): Compra insertada con ID: ' + CAST(@id_compra_nueva AS VARCHAR);

        -- 4. Insertar en la tabla compra_producto
        PRINT 'INFO (SP RegistrarCompraCliente): Insertando en tabla compra_producto...';
        EXEC [dbo].[InsertarCompraProducto]
            @id_compra = @id_compra_nueva,
            @id_producto = @id_producto_comprado,
            @garantia = @id_garantia_param,  -- Puede ser NULL si no hay garantía
            @monto_pagado = @monto_pagado,
            @metodo_pago = @metodo_pago;        

        PRINT 'INFO (SP RegistrarCompraCliente): Detalle de compra (compra_producto) insertado.';

        -- 5. Reducir el stock del producto
        PRINT 'INFO (SP RegistrarCompraCliente): Actualizando stock del producto ID ' + CAST(@id_producto_comprado AS VARCHAR) + '...';
        UPDATE producto
        SET stock = stock - 1
        WHERE id_producto = @id_producto_comprado;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Error (SP RegistrarCompraCliente): No se pudo actualizar el stock del producto con ID %d.', 16, 1, @id_producto_comprado);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        PRINT 'INFO (SP RegistrarCompraCliente): Stock actualizado.';
        PRINT 'Procedimiento RegistrarCompraCliente completado: Compra registrada exitosamente para cédula ' + CAST(@cedula_cliente AS VARCHAR);
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error en Procedimiento RegistrarCompraCliente: Se realizará ROLLBACK.';
        
        DECLARE @ErrorMessage_catch NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity_catch INT = ERROR_SEVERITY();
        DECLARE @ErrorState_catch INT = ERROR_STATE();
        DECLARE @ErrorLine_catch INT = ERROR_LINE();
        DECLARE @ErrorProcedure_catch NVARCHAR(128) = ERROR_PROCEDURE();

        PRINT 'Detalles del Error:';
        PRINT '  Mensaje: ' + @ErrorMessage_catch;
        PRINT '  Procedimiento Origen: ' + ISNULL(@ErrorProcedure_catch, 'N/A');
        PRINT '  Línea: ' + CAST(@ErrorLine_catch AS VARCHAR);
        
        RAISERROR (@ErrorMessage_catch, @ErrorSeverity_catch, @ErrorState_catch);
        RETURN;
    END CATCH
END;
GO

INSERT INTO distritos (id_canton, distrito, id_distrito)
VALUES (62, 'La rita', 1);

-- DATOS DE PRUEBA
EXEC InsertarPersona @cedula = 725451009, 
                    @nombre = 'Luis', 
                    @apellido1 = 'Ramírez', 
                    @apellido2 = 'Soto', 
                    @distrito = 1, 
                    @señas = 'Del parque 100m norte';

EXEC InsertarCliente @cedulaCliente = 725451009;      

SELECT * FROM producto;
EXEC InsertarProducto @nombreProducto = 'Mouse Gamer', 
@precio = 12800.00, @marca = 'Logitech', 
@stock = 10, @id_categoria = 1, 
@descripcion = 'Mouse óptico con luces RGB';

EXEC InsertarProductoComputación @id = 1,
                                @gama = 'media';

EXEC InsetarGarantia @fecha_inicio = '2024-01-01', 
                    @fecha_fin = '2025-01-01', 
                    @descripcion = '1 año de cobertura total';

SELECT * FROM cliente;

-- Ejemplo de uso del procedimiento RegistrarCompraCliente
EXEC RegistrarCompraCliente
    @cedula_cliente = 725451009,
    @id_producto_comprado = 1,
    @fecha_compra = '2024-01-01',
    @monto_pagado = 12800.00,
    @metodo_pago = 'Tarjeta de crédito',
    @id_devolucion_param = NULL,
    @id_garantia_param = 1;