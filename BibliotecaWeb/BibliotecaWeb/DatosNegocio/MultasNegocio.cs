using System.Data;
using BibliotecaWeb.AccesoDatos;

namespace BibliotecaWeb.DatosNegocio
{
    public class MultasNegocio
    {
        // Lee la vista vw_MultasDetalle. estado vacío = todas
        public DataTable listar(string estado)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDMulta, IDPrestamo, Socio, Libro, DiasRetraso, Monto, FechaGeneracion, Estado, FechaPago " +
                    "FROM vw_MultasDetalle " +
                    "WHERE (@Estado = '' OR Estado = @Estado) " +
                    "ORDER BY FechaGeneracion DESC, IDMulta DESC");
                datos.setearParametro("@Estado", estado);
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // Procedimiento almacenado sp_PagarMulta
        public void pagar(int idMulta)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_PagarMulta");
                datos.setearParametro("@IDMulta", idMulta);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
