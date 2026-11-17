using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb
{
    public partial class Socios : System.Web.UI.Page
    {
        private SociosNegocio negocio = new SociosNegocio();

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
                dgvSocios.DataSource = negocio.listar();
                dgvSocios.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        protected void btnAgregar_Click(object sender, EventArgs e)
        {
            Site master = (Site)Master;

            if (txtNombre.Text.Trim() == "" || txtApellido.Text.Trim() == "" ||
                txtDni.Text.Trim() == "" || txtEmail.Text.Trim() == "")
            {
                master.MostrarMensaje("Completá nombre, apellido, DNI y email.", "warning");
                return;
            }

            try
            {
                Socio nuevo = new Socio();
                nuevo.Nombre = txtNombre.Text.Trim();
                nuevo.Apellido = txtApellido.Text.Trim();
                nuevo.DNI = txtDni.Text.Trim();
                nuevo.Email = txtEmail.Text.Trim();

                negocio.agregar(nuevo);

                master.GuardarMensaje("Socio agregado correctamente.", "success");
                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
            }
        }

        protected void dgvSocios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Baja" && e.CommandName != "Alta" && e.CommandName != "Eliminar")
            {
                return;
            }

            Site master = (Site)Master;
            int idSocio = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Baja")
                {
                    // sp_BajaLogicaSocio (rechaza la baja si hay libros sin devolver)
                    negocio.bajaLogica(idSocio);
                    master.GuardarMensaje("Socio dado de baja lógicamente.", "success");
                }
                else if (e.CommandName == "Alta")
                {
                    // sp_AltaLogicaSocio
                    negocio.altaLogica(idSocio);
                    master.GuardarMensaje("Socio reactivado correctamente.", "success");
                }
                else
                {
                    // DELETE físico: tr_InsteadOfDelete_Socios lanza el error
                    negocio.eliminarFisico(idSocio);
                    master.GuardarMensaje("Socio eliminado.", "success");
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
