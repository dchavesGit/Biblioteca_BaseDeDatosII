using System.Collections.Generic;
using System.Data;
using BibliotecaWeb.AccesoDatos;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb.DatosNegocio
{
    public class LibrosNegocio
    {
        // Lee la vista vw_CatalogoLibros, con filtro opcional por título, autor o ISBN
        public DataTable listar(string filtro)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDLibro, Titulo, Autores, ISBN, AnioPublicacion, Editorial, Categoria, Stock, Activo " +
                    "FROM vw_CatalogoLibros " +
                    "WHERE Titulo LIKE @filtro OR Autores LIKE @filtro OR ISBN LIKE @filtro " +
                    "ORDER BY Titulo");
                datos.setearParametro("@filtro", "%" + filtro + "%");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Libros activos con stock para el combo de préstamos
        public DataTable listarDisponibles()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDLibro, Titulo + ' (stock: ' + CAST(Stock AS varchar(10)) + ')' AS Descripcion " +
                    "FROM LIBROS WHERE Stock > 0 AND Activo = 1 ORDER BY Titulo");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // ---- Listas para el formulario ----

        public DataTable listarEditorialesActivas()
        {
            return leer("SELECT IDEditorial, Nombre FROM EDITORIALES WHERE Activo = 1 ORDER BY Nombre");
        }

        public DataTable listarCategorias()
        {
            return leer("SELECT IDCategoria, Nombre FROM CATEGORIAS ORDER BY Nombre");
        }

        // soloActivos = true para el alta; false para encontrar autores dados de baja que un libro ya tiene
        public DataTable listarAutores(bool soloActivos)
        {
            return leer("SELECT IDAutor, Nombre FROM AUTORES " + (soloActivos ? "WHERE Activo = 1 " : "") + "ORDER BY Nombre");
        }

        private DataTable leer(string consulta)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(consulta);
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // ---- ABM ----

        public Libro buscarPorId(int id)
        {
            Libro libro = null;

            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDLibro, Titulo, ISBN, AnioPublicacion, Stock, IDEditorial, IDCategoria " +
                    "FROM LIBROS WHERE IDLibro = @id");
                datos.setearParametro("@id", id);
                datos.ejecutarLectura();

                if (datos.Lector.Read())
                {
                    libro = new Libro();
                    libro.IDLibro = (int)datos.Lector["IDLibro"];
                    libro.Titulo = (string)datos.Lector["Titulo"];
                    libro.ISBN = (string)datos.Lector["ISBN"];
                    if (!(datos.Lector["AnioPublicacion"] is System.DBNull))
                        libro.AnioPublicacion = (int)(short)datos.Lector["AnioPublicacion"];
                    libro.Stock = (int)datos.Lector["Stock"];
                    if (!(datos.Lector["IDEditorial"] is System.DBNull))
                        libro.IDEditorial = (int)datos.Lector["IDEditorial"];
                    if (!(datos.Lector["IDCategoria"] is System.DBNull))
                        libro.IDCategoria = (int)datos.Lector["IDCategoria"];
                }
            }
            finally
            {
                datos.cerrarConexion();
            }

            if (libro == null)
            {
                return null;
            }

            AccesoADatos autores = new AccesoADatos();
            try
            {
                autores.setearConsulta("SELECT IDAutor FROM LIBROSAUTORES WHERE IDLibro = @id");
                autores.setearParametro("@id", id);
                autores.ejecutarLectura();
                while (autores.Lector.Read())
                {
                    libro.Autores.Add((int)autores.Lector["IDAutor"]);
                }
            }
            finally
            {
                autores.cerrarConexion();
            }

            return libro;
        }

        // Inserta el libro y sus autores en una sola transacción
        public void agregar(Libro nuevo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                string consulta =
                    "SET XACT_ABORT ON; BEGIN TRANSACTION; " +
                    "INSERT INTO LIBROS (Titulo, ISBN, AnioPublicacion, Stock, IDEditorial, IDCategoria, Activo) " +
                    "VALUES (@Titulo, @ISBN, @Anio, @Stock, @IDEditorial, @IDCategoria, 1); " +
                    "DECLARE @IDLibro INT = SCOPE_IDENTITY(); ";

                consulta += armarInsertAutores(datos, nuevo.Autores);
                consulta += "COMMIT TRANSACTION;";

                datos.setearConsulta(consulta);
                setearParametrosLibro(datos, nuevo);
                setearParametrosAutores(datos, nuevo.Autores);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Modifica el libro y reemplaza sus autores en una sola transacción
        public void modificar(Libro libro)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                string consulta =
                    "SET XACT_ABORT ON; BEGIN TRANSACTION; " +
                    "UPDATE LIBROS SET Titulo = @Titulo, ISBN = @ISBN, AnioPublicacion = @Anio, Stock = @Stock, " +
                    "IDEditorial = @IDEditorial, IDCategoria = @IDCategoria WHERE IDLibro = @IDLibro; " +
                    "DELETE FROM LIBROSAUTORES WHERE IDLibro = @IDLibro; ";

                consulta += armarInsertAutores(datos, libro.Autores);
                consulta += "COMMIT TRANSACTION;";

                datos.setearConsulta(consulta);
                setearParametrosLibro(datos, libro);
                datos.setearParametro("@IDLibro", libro.IDLibro);
                setearParametrosAutores(datos, libro.Autores);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        private string armarInsertAutores(AccesoADatos datos, List<int> autores)
        {
            string sql = "";
            for (int i = 0; i < autores.Count; i++)
            {
                sql += "INSERT INTO LIBROSAUTORES (IDLibro, IDAutor) VALUES (@IDLibro, @Autor" + i + "); ";
            }
            return sql;
        }

        private void setearParametrosLibro(AccesoADatos datos, Libro libro)
        {
            datos.setearParametro("@Titulo", libro.Titulo);
            datos.setearParametro("@ISBN", libro.ISBN);
            datos.setearParametro("@Anio", libro.AnioPublicacion);
            datos.setearParametro("@Stock", libro.Stock);
            datos.setearParametro("@IDEditorial", libro.IDEditorial);
            datos.setearParametro("@IDCategoria", libro.IDCategoria);
        }

        private void setearParametrosAutores(AccesoADatos datos, List<int> autores)
        {
            for (int i = 0; i < autores.Count; i++)
            {
                datos.setearParametro("@Autor" + i, autores[i]);
            }
        }

        public void bajaLogica(int idLibro)
        {
            cambiarEstado(idLibro, false);
        }

        public void altaLogica(int idLibro)
        {
            cambiarEstado(idLibro, true);
        }

        private void cambiarEstado(int idLibro, bool activo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("UPDATE LIBROS SET Activo = @Activo WHERE IDLibro = @IDLibro");
                datos.setearParametro("@Activo", activo);
                datos.setearParametro("@IDLibro", idLibro);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // DELETE físico: el trigger tr_InsteadOfDelete_Libros lo intercepta y hace la baja lógica
        public void eliminarFisico(int idLibro)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("DELETE FROM LIBROS WHERE IDLibro = @IDLibro");
                datos.setearParametro("@IDLibro", idLibro);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
