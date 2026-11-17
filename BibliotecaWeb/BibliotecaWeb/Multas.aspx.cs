using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;

namespace BibliotecaWeb
{
    public partial class Multas : System.Web.UI.Page
    {
        private MultasNegocio negocio = new MultasNegocio();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                cargarGrilla();
            }
        }

        private void cargarGrilla()
        {
            try
            {
                dgvMultas.DataSource = negocio.listar(ddlEstado.SelectedValue);
                dgvMultas.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        protected void ddlEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            cargarGrilla();
        }

        protected void dgvMultas_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Pagar")
            {
                return;
            }

            Site master = (Site)Master;

            try
            {
                negocio.pagar(Convert.ToInt32(e.CommandArgument));
                master.GuardarMensaje("Multa abonada correctamente.", "success");
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
                cargarGrilla();
            }
        }
    }
}
