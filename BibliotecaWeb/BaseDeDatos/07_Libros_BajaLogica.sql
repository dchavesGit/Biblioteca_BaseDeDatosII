USE bbdBiblioteca;
GO

-- Agrega la baja lógica a LIBROS (editoriales y socios ya la tienen)
ALTER TABLE LIBROS
ADD Activo BIT NOT NULL CONSTRAINT DF_LIBROS_Activo DEFAULT 1;
GO

-- La vista del catálogo pasa a incluir el estado del libro
ALTER VIEW vw_CatalogoLibros
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
    L.Stock,
    L.Activo
FROM LIBROS L
LEFT JOIN EDITORIALES E ON E.IDEditorial = L.IDEditorial
LEFT JOIN CATEGORIAS C ON C.IDCategoria = L.IDCategoria;
GO

-- Trigger de DELETE: nunca borra físicamente un libro, lo da de baja lógica
-- (se conserva el historial de préstamos y los autores asociados)
CREATE TRIGGER tr_InsteadOfDelete_Libros
ON LIBROS
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE L
    SET L.Activo = 0
    FROM LIBROS L
    INNER JOIN DELETED D ON D.IDLibro = L.IDLibro;
END;
GO
