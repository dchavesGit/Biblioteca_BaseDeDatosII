using System.Data;
using BibliotecaWeb.AccesoDatos;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb.DatosNegocio
{
    public class AutoresNegocio
    {
        public DataTable listar()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT A.IDAutor, A.Nombre, A.Nacionalidad, A.Activo, " +
                    "(SELECT COUNT(*) FROM LIBROSAUTORES LA WHERE LA.IDAutor = A.IDAutor) AS Libros " +
                    "FROM AUTORES A ORDER BY A.Nombre");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void agregar(Autor nuevo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("INSERT INTO AUTORES (Nombre, Nacionalidad, Activo) VALUES (@Nombre, @Nacionalidad, 1)");
                datos.setearParametro("@Nombre", nuevo.Nombre);
                datos.setearParametro("@Nacionalidad", nuevo.Nacionalidad);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void bajaLogica(int idAutor)
        {
            cambiarEstado(idAutor, false);
        }

        public void altaLogica(int idAutor)
        {
            cambiarEstado(idAutor, true);
        }

        private void cambiarEstado(int idAutor, bool activo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("UPDATE AUTORES SET Activo = @Activo WHERE IDAutor = @IDAutor");
                datos.setearParametro("@Activo", activo);
                datos.setearParametro("@IDAutor", idAutor);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
