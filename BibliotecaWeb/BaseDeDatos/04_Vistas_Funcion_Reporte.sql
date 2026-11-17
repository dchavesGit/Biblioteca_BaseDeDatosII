USE bbdBiblioteca;
GO

-- Ejecutar DESPUÉS de: script de creación de tablas, Triggers.sql y Procedures.sql
-- Requiere SQL Server 2017 o superior (usa STRING_AGG).

-- =====================================================
-- FUNCIÓN DE USUARIO
-- =====================================================

-- Días de retraso de un préstamo. Si todavía no se devolvió, compara contra hoy.
CREATE FUNCTION dbo.fn_DiasRetraso
(
    @FechaVencimiento DATE,
    @FechaDevolucion DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Referencia DATE = ISNULL(@FechaDevolucion, CAST(GETDATE() AS DATE));
    DECLARE @Dias INT = DATEDIFF(DAY, @FechaVencimiento, @Referencia);

    RETURN CASE WHEN @Dias > 0 THEN @Dias ELSE 0 END;
END;
GO

-- =====================================================
-- VISTAS
-- =====================================================

-- 1. Catálogo de libros con editorial, categoría, autores (relación muchos a muchos) y stock
CREATE VIEW vw_CatalogoLibros
AS
SELECT
    L.IDLibro,
    L.Titulo,
    ISNULL((SELECT STRING_AGG(A.Nombre, ', ')
            FROM LIBROSAUTORES LA
            INNER JOIN AUTORES A ON A.IDAutor = LA.IDAutor
            WHERE LA.IDLibro = L.IDLibro), 'Sin autor') AS Autores,
    L.ISBN,
    L.AnioPublicacion,
    ISNULL(E.Nombre, '-') AS Editorial,
    ISNULL(C.Nombre, '-') AS Categoria,
    L.Stock
FROM LIBROS L
LEFT JOIN EDITORIALES E ON E.IDEditorial = L.IDEditorial
LEFT JOIN CATEGORIAS C ON C.IDCategoria = L.IDCategoria;
GO

-- 2. Préstamos activos (sin devolver) con situación calculada mediante la función de usuario
CREATE VIEW vw_PrestamosActivos
AS
SELECT
    P.IDPrestamo,
    S.Apellido + ', ' + S.Nombre AS Socio,
    S.DNI,
    L.Titulo AS Libro,
    P.FechaPrestamo,
    P.FechaVencimiento,
    dbo.fn_DiasRetraso(P.FechaVencimiento, P.FechaDevolucion) AS DiasRetraso,
    CASE WHEN dbo.fn_DiasRetraso(P.FechaVencimiento, P.FechaDevolucion) > 0
         THEN 'Vencido' ELSE 'En término' END AS Situacion
FROM PRESTAMOS P
INNER JOIN SOCIOS S ON S.IDSocio = P.IDSocio
INNER JOIN LIBROS L ON L.IDLibro = P.IDLibro
WHERE P.FechaDevolucion IS NULL;
GO

-- 3. Multas con el detalle del socio y del libro
CREATE VIEW vw_MultasDetalle
AS
SELECT
    M.IDMulta,
    M.IDPrestamo,
    S.Apellido + ', ' + S.Nombre AS Socio,
    L.Titulo AS Libro,
    M.DiasRetraso,
    M.Monto,
    M.FechaGeneracion,
    M.Estado,
    M.FechaPago
FROM MULTAS M
INNER JOIN PRESTAMOS P ON P.IDPrestamo = M.IDPrestamo
INNER JOIN SOCIOS S ON S.IDSocio = P.IDSocio
INNER JOIN LIBROS L ON L.IDLibro = P.IDLibro;
GO

-- 4. Estado de cada socio: préstamos activos y multas pendientes
CREATE VIEW vw_EstadoSocios
AS
SELECT
    S.IDSocio,
    S.Apellido,
    S.Nombre,
    S.DNI,
    S.Email,
    S.FechaAlta,
    S.Activo,
    (SELECT COUNT(*)
     FROM PRESTAMOS P
     WHERE P.IDSocio = S.IDSocio AND P.FechaDevolucion IS NULL) AS PrestamosActivos,
    (SELECT COUNT(*)
     FROM MULTAS M
     INNER JOIN PRESTAMOS P ON P.IDPrestamo = M.IDPrestamo
     WHERE P.IDSocio = S.IDSocio AND M.Estado = 'Pendiente') AS MultasPendientes
FROM SOCIOS S;
GO

-- =====================================================
-- PROCEDIMIENTO DE REPORTE (parametrizado, solo lectura)
-- =====================================================

CREATE PROCEDURE sp_ReportePrestamosPorFechas
    @Desde DATE,
    @Hasta DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Desde IS NULL OR @Hasta IS NULL
        BEGIN
            RAISERROR('Debe indicar la fecha desde y la fecha hasta.', 16, 1);
            RETURN;
        END

        IF @Desde > @Hasta
        BEGIN
            RAISERROR('La fecha desde no puede ser posterior a la fecha hasta.', 16, 1);
            RETURN;
        END

        SELECT
            P.IDPrestamo,
            S.Apellido + ', ' + S.Nombre AS Socio,
            L.Titulo AS Libro,
            P.FechaPrestamo,
            P.FechaVencimiento,
            P.FechaDevolucion,
            P.Estado,
            ISNULL(M.Monto, 0) AS MontoMulta
        FROM PRESTAMOS P
        INNER JOIN SOCIOS S ON S.IDSocio = P.IDSocio
        INNER JOIN LIBROS L ON L.IDLibro = P.IDLibro
        LEFT JOIN MULTAS M ON M.IDPrestamo = P.IDPrestamo
        WHERE P.FechaPrestamo BETWEEN @Desde AND @Hasta
        ORDER BY P.FechaPrestamo DESC, P.IDPrestamo DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
