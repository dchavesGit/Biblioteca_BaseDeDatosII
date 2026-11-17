using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb
{
    public partial class Editoriales : System.Web.UI.Page
    {
        private EditorialesNegocio negocio = new EditorialesNegocio();

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
                dgvEditoriales.DataSource = negocio.listar();
                dgvEditoriales.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        protected void btnAgregar_Click(object sender, EventArgs e)
        {
            Site master = (Site)Master;

            if (txtNombre.Text.Trim() == "")
            {
                master.MostrarMensaje("Ingresá el nombre de la editorial.", "warning");
                return;
            }

            try
            {
                Editorial nueva = new Editorial();
                nueva.Nombre = txtNombre.Text.Trim();
                nueva.Pais = txtPais.Text.Trim() == "" ? null : txtPais.Text.Trim();

                negocio.agregar(nueva);

                master.GuardarMensaje("Editorial agregada correctamente.", "success");
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
            }
        }

        protected void dgvEditoriales_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Baja" && e.CommandName != "Alta")
            {
                return;
            }

            Site master = (Site)Master;
            int idEditorial = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Baja")
                {
                    negocio.bajaLogica(idEditorial);
                    master.GuardarMensaje("Editorial dada de baja lógicamente.", "success");
                }
                else
                {
                    negocio.altaLogica(idEditorial);
                    master.GuardarMensaje("Editorial reactivada correctamente.", "success");
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
