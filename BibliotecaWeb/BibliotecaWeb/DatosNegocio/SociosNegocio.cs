using System.Data;
using BibliotecaWeb.AccesoDatos;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb.DatosNegocio
{
    public class SociosNegocio
    {
        // Lee la vista vw_EstadoSocios
        public DataTable listar()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDSocio, Apellido, Nombre, DNI, Email, FechaAlta, Activo, PrestamosActivos, MultasPendientes " +
                    "FROM vw_EstadoSocios ORDER BY Apellido, Nombre");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Socios activos para el combo de préstamos
        public DataTable listarActivos()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDSocio, Apellido + ', ' + Nombre + ' (' + DNI + ')' AS Descripcion " +
                    "FROM SOCIOS WHERE Activo = 1 ORDER BY Apellido, Nombre");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        public void agregar(Socio nuevo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "INSERT INTO SOCIOS (Nombre, Apellido, DNI, Email, FechaAlta, Activo) " +
                    "VALUES (@Nombre, @Apellido, @DNI, @Email, CAST(GETDATE() AS date), 1)");
                datos.setearParametro("@Nombre", nuevo.Nombre);
                datos.setearParametro("@Apellido", nuevo.Apellido);
                datos.setearParametro("@DNI", nuevo.DNI);
                datos.setearParametro("@Email", nuevo.Email);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Procedimiento almacenado sp_BajaLogicaSocio
        public void bajaLogica(int idSocio)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_BajaLogicaSocio");
                datos.setearParametro("@IDSocio", idSocio);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Procedimiento almacenado sp_AltaLogicaSocio (reactiva un socio dado de baja)
        public void altaLogica(int idSocio)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_AltaLogicaSocio");
                datos.setearParametro("@IDSocio", idSocio);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // DELETE físico: el trigger tr_InsteadOfDelete_Socios lo intercepta y lanza error
        public void eliminarFisico(int idSocio)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta("DELETE FROM SOCIOS WHERE IDSocio = @IDSocio");
                datos.setearParametro("@IDSocio", idSocio);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
