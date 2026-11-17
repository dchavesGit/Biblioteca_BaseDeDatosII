using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb
{
    public partial class Autores : System.Web.UI.Page
    {
        private AutoresNegocio negocio = new AutoresNegocio();

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
                dgvAutores.DataSource = negocio.listar();
                dgvAutores.DataBind();
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
                master.MostrarMensaje("Ingresá el nombre del autor.", "warning");
                return;
            }

            try
            {
                Autor nuevo = new Autor();
                nuevo.Nombre = txtNombre.Text.Trim();
                nuevo.Nacionalidad = txtNacionalidad.Text.Trim() == "" ? null : txtNacionalidad.Text.Trim();

                negocio.agregar(nuevo);

                master.GuardarMensaje("Autor agregado correctamente.", "success");
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
            }
        }

        protected void dgvAutores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Baja" && e.CommandName != "Alta")
            {
                return;
            }

            Site master = (Site)Master;
            int idAutor = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Baja")
                {
                    negocio.bajaLogica(idAutor);
                    master.GuardarMensaje("Autor dado de baja lógicamente.", "success");
                }
                else
                {
                    negocio.altaLogica(idAutor);
                    master.GuardarMensaje("Autor reactivado correctamente.", "success");
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
