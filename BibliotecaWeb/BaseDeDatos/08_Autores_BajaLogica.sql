USE bbdBiblioteca;
GO

-- Agrega la baja lógica a AUTORES (igual que editoriales, socios y libros)
ALTER TABLE AUTORES
ADD Activo BIT NOT NULL CONSTRAINT DF_AUTORES_Activo DEFAULT 1;
GO
