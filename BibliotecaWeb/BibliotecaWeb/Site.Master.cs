using System;
using System.Data.SqlClient;
using System.Web;

namespace BibliotecaWeb
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Si una página guardó un mensaje antes de redirigir, lo mostramos acá
            if (Session["Mensaje"] != null)
            {
                MostrarMensaje((string)Session["Mensaje"], (string)Session["MensajeTipo"]);
                Session.Remove("Mensaje");
                Session.Remove("MensajeTipo");
            }
        }

        // tipo: success, danger, warning, info
        public void MostrarMensaje(string texto, string tipo)
        {
            pnlMensaje.CssClass = "alert alert-" + tipo;
            lblMensaje.Text = HttpUtility.HtmlEncode(texto);
            pnlMensaje.Visible = true;
        }

        // Para mensajes que se muestran después de un Response.Redirect (evita reenviar el formulario al refrescar)
        public void GuardarMensaje(string texto, string tipo)
        {
            Session["Mensaje"] = texto;
            Session["MensajeTipo"] = tipo;
        }

        // Muestra el mensaje de error de SQL Server (RAISERROR de procedures y triggers) o uno amigable
        public void MostrarError(Exception ex)
        {
            SqlException sql = ex as SqlException;
            string texto;

            if (sql != null && (sql.Number == 2627 || sql.Number == 2601))
            {
                texto = "Ya existe un registro con ese valor único (por ejemplo DNI, email, ISBN o nombre de editorial).";
            }
            else if (sql != null && sql.Number == 547)
            {
                texto = "No se puede completar la operación porque hay registros relacionados (por ejemplo libros, préstamos o autores). Usá la baja lógica.";
            }
            else if (sql != null)
            {
                texto = sql.Message;
            }
            else
            {
                texto = "Ocurrió un error inesperado: " + ex.Message;
            }

            MostrarMensaje(texto, "danger");
        }

        protected string Activo(string pagina)
        {
            string ruta = Request.Path;
            bool esActiva = ruta.EndsWith(pagina, StringComparison.OrdinalIgnoreCase);

            if (pagina == "Default.aspx" && ruta.EndsWith("/"))
            {
                esActiva = true;
            }
            return esActiva ? "active" : "";
        }
    }
}
