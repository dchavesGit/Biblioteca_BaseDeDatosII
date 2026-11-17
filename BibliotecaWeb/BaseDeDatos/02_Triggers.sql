USE bbdBiblioteca;
GO

-- 1. DESCONTAR STOCK AL REGISTRAR UN PRÉSTAMO

CREATE TRIGGER tr_AfterInsert_Prestamos
ON PRESTAMOS
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Descuenta 1 al stock de los libros prestados
    UPDATE L
    SET L.Stock = L.Stock - 1
    FROM LIBROS L
    INNER JOIN INSERTED I ON L.IDLibro = I.IDLibro;
END;

GO

-- 2. REPONER STOCK Y GENERAR MULTA AL DEVOLVER

CREATE TRIGGER tr_AfterUpdate_Prestamos
ON PRESTAMOS
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Solo actuar si se acaba de cargar una FechaDevolucion (antes era NULL)
    IF UPDATE(FechaDevolucion)
    BEGIN
        -- A) Devolver 1 al stock del libro
        UPDATE L
        SET L.Stock = L.Stock + 1
        FROM LIBROS L
        INNER JOIN INSERTED I ON L.IDLibro = I.IDLibro
        INNER JOIN DELETED D ON I.IDPrestamo = D.IDPrestamo
        WHERE D.FechaDevolucion IS NULL AND I.FechaDevolucion IS NOT NULL;

        -- B) Generar multa automática si devolvió fuera de término
        -- Por ejemplo: $1000 por día de retraso
        INSERT INTO MULTAS (IDPrestamo, DiasRetraso, Monto, FechaGeneracion, Estado, FechaPago)
        SELECT 
            I.IDPrestamo,
            DATEDIFF(DAY, I.FechaVencimiento, I.FechaDevolucion) AS DiasRetraso,
            DATEDIFF(DAY, I.FechaVencimiento, I.FechaDevolucion) * 1000.00 AS Monto,
            CAST(GETDATE() AS DATE) AS FechaGeneracion,
            'Pendiente' AS Estado,
            NULL AS FechaPago
        FROM INSERTED I
        INNER JOIN DELETED D ON I.IDPrestamo = D.IDPrestamo
        WHERE D.FechaDevolucion IS NULL 
          AND I.FechaDevolucion IS NOT NULL
          AND I.FechaDevolucion > I.FechaVencimiento;
    END
END;
GO

-- 3. EVITAR BORRADO FÍSICO EN SOCIOS (Baja lógica)

CREATE TRIGGER tr_InsteadOfDelete_Socios
ON SOCIOS
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    RAISERROR('No se permite eliminar socios físicamente. Utilice la baja lógica (Activo = 0).', 16, 1);
END;
GO
