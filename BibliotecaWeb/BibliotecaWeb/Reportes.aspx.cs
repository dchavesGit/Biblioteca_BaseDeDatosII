using System;
using System.Data;
using System.Globalization;
using BibliotecaWeb.DatosNegocio;

namespace BibliotecaWeb
{
    public partial class Reportes : System.Web.UI.Page
    {
        private ReportesNegocio negocio = new ReportesNegocio();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDesde.Text = DateTime.Today.AddDays(-30).ToString("yyyy-MM-dd");
                txtHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");
                generar();
            }
        }

        protected void btnGenerar_Click(object sender, EventArgs e)
        {
            generar();
        }

        private void generar()
        {
            Site master = (Site)Master;
            DateTime desde;
            DateTime hasta;

            if (!DateTime.TryParseExact(txtDesde.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out desde) ||
                !DateTime.TryParseExact(txtHasta.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out hasta))
            {
                master.MostrarMensaje("Elegí las dos fechas del reporte.", "warning");
                return;
            }

            try
            {
                DataTable tabla = negocio.prestamosPorFechas(desde, hasta);
                dgvReporte.DataSource = tabla;
                dgvReporte.DataBind();
                lblResumen.Text = tabla.Rows.Count + " préstamo(s) entre " + desde.ToString("dd/MM/yyyy") + " y " + hasta.ToString("dd/MM/yyyy") + ".";
            }
            catch (Exception ex)
            {
                // Por ejemplo: "La fecha desde no puede ser posterior a la fecha hasta."
                master.MostrarError(ex);
            }
        }
    }
}
