using System.Data;
using BibliotecaWeb.AccesoDatos;

namespace BibliotecaWeb.DatosNegocio
{
    public class PrestamosNegocio
    {
        // Lee la vista vw_PrestamosActivos
        public DataTable listarActivos()
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearConsulta(
                    "SELECT IDPrestamo, Socio, DNI, Libro, FechaPrestamo, FechaVencimiento, DiasRetraso, Situacion " +
                    "FROM vw_PrestamosActivos ORDER BY FechaVencimiento");
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // sp_RegistrarPrestamo -> el trigger tr_AfterInsert_Prestamos descuenta el stock
        public void registrar(int idSocio, int idLibro, int dias)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_RegistrarPrestamo");
                datos.setearParametro("@IDSocio", idSocio);
                datos.setearParametro("@IDLibro", idLibro);
                datos.setearParametro("@DiasPrestamo", dias);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }

        // sp_RegistrarDevolucion -> el trigger tr_AfterUpdate_Prestamos repone stock y genera la multa si hay retraso.
        // Devuelve el monto de la multa generada, o null si no hubo.
        public decimal? devolver(int idPrestamo)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_RegistrarDevolucion");
                datos.setearParametro("@IDPrestamo", idPrestamo);
                datos.ejecutarAccion();
            }
            finally
            {
                datos.cerrarConexion();
            }

            // Consultamos si el trigger generó una multa para este préstamo
            AccesoADatos consulta = new AccesoADatos();
            try
            {
                consulta.setearConsulta("SELECT Monto FROM MULTAS WHERE IDPrestamo = @IDPrestamo");
                consulta.setearParametro("@IDPrestamo", idPrestamo);
                consulta.ejecutarLectura();
                if (consulta.Lector.Read())
                {
                    return (decimal)consulta.Lector["Monto"];
                }
                return null;
            }
            finally
            {
                consulta.cerrarConexion();
            }
        }
    }
}
