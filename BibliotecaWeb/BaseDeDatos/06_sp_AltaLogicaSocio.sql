USE bbdBiblioteca;
GO

-- Reactiva un socio dado de baja lógica (inverso de sp_BajaLogicaSocio)
CREATE PROCEDURE sp_AltaLogicaSocio
    @IDSocio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SOCIOS WHERE IDSocio = @IDSocio)
        BEGIN
            RAISERROR('El socio no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM SOCIOS WHERE IDSocio = @IDSocio AND Activo = 1)
        BEGIN
            RAISERROR('El socio ya se encuentra activo.', 16, 1);
            RETURN;
        END

        UPDATE SOCIOS
        SET Activo = 1
        WHERE IDSocio = @IDSocio;

        PRINT 'Socio reactivado correctamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
