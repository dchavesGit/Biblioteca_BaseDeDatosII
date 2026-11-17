USE bbdBiblioteca;
GO

-- Datos de prueba (autores, libros y socios ficticios). Ejecutar sobre la base recién creada y vacía,
-- DESPUÉS de crear tablas, triggers, procedures y vistas.

INSERT INTO EDITORIALES (Nombre, Pais, Activo) VALUES
('Editorial Austral', 'Argentina', 1),
('Ediciones del Plata', 'Argentina', 1),
('Cuyo Académica', 'Chile', 1);

INSERT INTO CATEGORIAS (Nombre, Descripcion) VALUES
('Bases de Datos', 'Modelado, SQL y administración'),
('Programación', 'Lenguajes y paradigmas'),
('Ingeniería de Software', 'Análisis, diseño y metodologías');

INSERT INTO AUTORES (Nombre, Nacionalidad) VALUES
('Laura Benítez', 'Argentina'),
('Martín Quiroga', 'Argentina'),
('Camila Ferreyra', 'Uruguay'),
('Diego Salvatierra', 'Chile'),
('Valeria Núñez', 'Argentina');

-- Stock inicial; los triggers lo descuentan al insertar los préstamos de más abajo
INSERT INTO LIBROS (Titulo, ISBN, AnioPublicacion, Stock, IDEditorial, IDCategoria) VALUES
('Introducción a las Bases de Datos', '978-987-00-0001-1', 2021, 5, 1, 1),
('SQL Server en la Práctica',         '978-987-00-0002-8', 2022, 3, 2, 1),
('Programación Orientada a Objetos con C#', '978-987-00-0003-5', 2020, 4, 3, 2),
('Análisis y Diseño de Sistemas',     '978-987-00-0004-2', 2019, 2, 1, 3),
('Algoritmos y Estructuras de Datos', '978-987-00-0005-9', 2018, 1, 2, 2);

-- Un libro con dos autores (muchos a muchos)
INSERT INTO LIBROSAUTORES (IDLibro, IDAutor) VALUES
(1, 1), (1, 2),
(2, 2),
(3, 3),
(4, 4), (4, 1),
(5, 5);

INSERT INTO SOCIOS (Nombre, Apellido, DNI, Email, FechaAlta, Activo) VALUES
('Lucía',  'Fernández', '30123456', 'lucia.fernandez@alumnos.utn.edu.ar', '2026-03-01', 1),
('Mateo',  'Gómez',     '31234567', 'mateo.gomez@alumnos.utn.edu.ar',     '2026-03-05', 1),
('Sofía',  'Ramírez',   '32345678', 'sofia.ramirez@alumnos.utn.edu.ar',   '2026-04-10', 1),
('Tomás',  'Herrera',   '33456789', 'tomas.herrera@alumnos.utn.edu.ar',   '2026-04-12', 0);

-- Dos préstamos activos (el trigger tr_AfterInsert_Prestamos descuenta el stock):
-- uno en término y uno ya vencido, para probar la multa al devolver.
INSERT INTO PRESTAMOS (FechaPrestamo, FechaVencimiento, FechaDevolucion, Estado, IDLibro, IDSocio) VALUES
(DATEADD(DAY, -2,  CAST(GETDATE() AS DATE)), DATEADD(DAY, 5,   CAST(GETDATE() AS DATE)), NULL, 'Activo', 1, 1),
(DATEADD(DAY, -20, CAST(GETDATE() AS DATE)), DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), NULL, 'Activo', 5, 2);
GO
