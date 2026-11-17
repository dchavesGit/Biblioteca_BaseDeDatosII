using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;

namespace BibliotecaWeb
{
    public partial class Prestamos : System.Web.UI.Page
    {
        private PrestamosNegocio negocio = new PrestamosNegocio();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                cargarCombos();
                cargarGrilla();
            }
        }

        private void cargarCombos()
        {
            try
            {
                ddlSocio.DataSource = new SociosNegocio().listarActivos();
                ddlSocio.DataTextField = "Descripcion";
                ddlSocio.DataValueField = "IDSocio";
                ddlSocio.DataBind();

                ddlLibro.DataSource = new LibrosNegocio().listarDisponibles();
                ddlLibro.DataTextField = "Descripcion";
                ddlLibro.DataValueField = "IDLibro";
                ddlLibro.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        private void cargarGrilla()
        {
            try
            {
                dgvPrestamos.DataSource = negocio.listarActivos();
                dgvPrestamos.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        protected void btnPrestar_Click(object sender, EventArgs e)
        {
            Site master = (Site)Master;

            if (ddlSocio.Items.Count == 0 || ddlLibro.Items.Count == 0)
            {
                master.MostrarMensaje("No hay socios activos o libros con stock para registrar un préstamo.", "warning");
                return;
            }

            int dias;
            if (!int.TryParse(txtDias.Text, out dias))
            {
                master.MostrarMensaje("Ingresá una cantidad de días válida.", "warning");
                return;
            }

            try
            {
                negocio.registrar(int.Parse(ddlSocio.SelectedValue), int.Parse(ddlLibro.SelectedValue), dias);

                master.GuardarMensaje("Préstamo registrado. El trigger descontó 1 unidad del stock del libro.", "success");
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                // Acá aparecen los mensajes de validación del procedure (socio inactivo, multas pendientes, sin stock)
                master.MostrarError(ex);
            }
        }

        protected void dgvPrestamos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Devolver")
            {
                return;
            }

            Site master = (Site)Master;

            try
            {
                int idPrestamo = Convert.ToInt32(e.CommandArgument);
                decimal? multa = negocio.devolver(idPrestamo);

                if (multa.HasValue)
                {
                    master.GuardarMensaje("Devolución registrada con retraso. El trigger repuso el stock y generó una multa de $" + multa.Value.ToString("N2") + ".", "warning");
                }
                else
                {
                    master.GuardarMensaje("Devolución registrada en término. El trigger repuso 1 unidad al stock.", "success");
                }

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
