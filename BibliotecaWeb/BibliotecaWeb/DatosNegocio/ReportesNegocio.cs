using System;
using System.Data;
using BibliotecaWeb.AccesoDatos;

namespace BibliotecaWeb.DatosNegocio
{
    public class ReportesNegocio
    {
        // Procedimiento almacenado de reporte con parámetros: sp_ReportePrestamosPorFechas
        public DataTable prestamosPorFechas(DateTime desde, DateTime hasta)
        {
            AccesoADatos datos = new AccesoADatos();
            try
            {
                datos.setearProcedimiento("sp_ReportePrestamosPorFechas");
                datos.setearParametro("@Desde", desde);
                datos.setearParametro("@Hasta", hasta);
                return datos.leerTabla();
            }
            finally
            {
                datos.cerrarConexion();
            }
        }
    }
}
