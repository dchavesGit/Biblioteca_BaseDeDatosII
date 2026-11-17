USE bbdBiblioteca;
GO

-- 1. REGISTRAR UN NUEVO PRÉSTAMO

CREATE PROCEDURE sp_RegistrarPrestamo
    @IDSocio INT,
    @IDLibro INT,
    @DiasPrestamo INT = 7 -- Por defecto 7 días si no se especifica
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que el socio exista y esté activo
        IF NOT EXISTS (SELECT 1 FROM SOCIOS WHERE IDSocio = @IDSocio AND Activo = 1)
        BEGIN
            RAISERROR('El socio no existe o se encuentra inactivo.', 16, 1);
            RETURN;
        END

        -- Validar que el socio no tenga multas pendientes
        IF EXISTS (
            SELECT 1 
            FROM MULTAS M
            INNER JOIN PRESTAMOS P ON M.IDPrestamo = P.IDPrestamo
            WHERE P.IDSocio = @IDSocio AND M.Estado = 'Pendiente'
        )
        BEGIN
            RAISERROR('El socio tiene multas pendientes de pago. No puede retirar libros.', 16, 1);
            RETURN;
        END

        -- Validar que el libro exista y tenga stock disponible
        IF NOT EXISTS (SELECT 1 FROM LIBROS WHERE IDLibro = @IDLibro AND Stock > 0)
        BEGIN
            RAISERROR('El libro no existe o no cuenta con stock disponible.', 16, 1);
            RETURN;
        END

        -- Insertar el préstamo (el stock se descontará automáticamente con el Trigger)
        INSERT INTO PRESTAMOS (FechaPrestamo, FechaVencimiento, FechaDevolucion, Estado, IDLibro, IDSocio)
        VALUES (
            CAST(GETDATE() AS DATE),
            DATEADD(DAY, @DiasPrestamo, CAST(GETDATE() AS DATE)),
            NULL,
            'Activo',
            @IDLibro,
            @IDSocio
        );

        PRINT 'Préstamo registrado correctamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 2. REGISTRAR LA DEVOLUCIÓN DE UN LIBRO

CREATE PROCEDURE sp_RegistrarDevolucion
    @IDPrestamo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que el préstamo exista y siga activo
        IF NOT EXISTS (SELECT 1 FROM PRESTAMOS WHERE IDPrestamo = @IDPrestamo AND FechaDevolucion IS NULL)
        BEGIN
            RAISERROR('El préstamo no existe o el libro ya fue devuelto anteriormente.', 16, 1);
            RETURN;
        END

        -- Actualizar fecha de devolución y estado
        -- (El Trigger se encargará de devolver el stock y generar multa si hay retraso)
        UPDATE PRESTAMOS
        SET FechaDevolucion = CAST(GETDATE() AS DATE),
            Estado = 'Devuelto'
        WHERE IDPrestamo = @IDPrestamo;

        PRINT 'Devolución registrada correctamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 3. PAGAR UNA MULTA

CREATE PROCEDURE sp_PagarMulta
    @IDMulta INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que la multa exista y esté pendiente
        IF NOT EXISTS (SELECT 1 FROM MULTAS WHERE IDMulta = @IDMulta AND Estado = 'Pendiente')
        BEGIN
            RAISERROR('La multa no existe o ya figura como pagada.', 16, 1);
            RETURN;
        END

        UPDATE MULTAS
        SET Estado = 'Pagada',
            FechaPago = CAST(GETDATE() AS DATE)
        WHERE IDMulta = @IDMulta;

        PRINT 'Multa abonada correctamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 4. BAJA LÓGICA DE SOCIO (Con validación)

CREATE PROCEDURE sp_BajaLogicaSocio
    @IDSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que no tenga préstamos sin devolver
        IF EXISTS (SELECT 1 FROM PRESTAMOS WHERE IDSocio = @IDSocio AND FechaDevolucion IS NULL)
        BEGIN
            RAISERROR('No se puede dar de baja al socio porque aún tiene libros sin devolver.', 16, 1);
            RETURN;
        END

        UPDATE SOCIOS
        SET Activo = 0
        WHERE IDSocio = @IDSocio;

        PRINT 'Socio dado de baja lógicamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
