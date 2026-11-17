using System.Data;
using BibliotecaWeb.AccesoDatos;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb.DatosNegocio
{
    public class EditorialesNegocio
    {
        public DataTable listar()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT E.IDEditorial, E.Nombre, E.Pais, E.Activo, " +
                    "(SELECT COUNT(*) FROM LIBROS L WHERE L.IDEditorial = E.IDEditorial) AS Libros " +
                    "FROM EDITORIALES E ORDER BY E.Nombre");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void agregar(Editorial nueva)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("INSERT INTO EDITORIALES (Nombre, Pais, Activo) VALUES (@Nombre, @Pais, 1)");
                datos.setearParametro("@Nombre", nueva.Nombre);
                datos.setearParametro("@Pais", nueva.Pais);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Baja lógica: se conserva el historial de libros de la editorial
        public void bajaLogica(int idEditorial)
        {
            cambiarEstado(idEditorial, false);
        }

        public void altaLogica(int idEditorial)
        {
            cambiarEstado(idEditorial, true);
        }

        private void cambiarEstado(int idEditorial, bool activo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("UPDATE EDITORIALES SET Activo = @Activo WHERE IDEditorial = @IDEditorial");
                datos.setearParametro("@Activo", activo);
                datos.setearParametro("@IDEditorial", idEditorial);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
