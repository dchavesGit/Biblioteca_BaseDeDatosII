using System;
using System.Web.UI.WebControls;
using BibliotecaWeb.DatosNegocio;
using BibliotecaWeb.Dominio;

namespace BibliotecaWeb
{
    public partial class Libros : System.Web.UI.Page
    {
        private LibrosNegocio negocio = new LibrosNegocio();

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
                ddlEditorial.DataSource = negocio.listarEditorialesActivas();
                ddlEditorial.DataTextField = "Nombre";
                ddlEditorial.DataValueField = "IDEditorial";
                ddlEditorial.DataBind();
                ddlEditorial.Items.Insert(0, new ListItem("(sin editorial)", ""));

                ddlCategoria.DataSource = negocio.listarCategorias();
                ddlCategoria.DataTextField = "Nombre";
                ddlCategoria.DataValueField = "IDCategoria";
                ddlCategoria.DataBind();
                ddlCategoria.Items.Insert(0, new ListItem("(sin categoría)", ""));

                lstAutores.DataSource = negocio.listarAutores(true);
                lstAutores.DataTextField = "Nombre";
                lstAutores.DataValueField = "IDAutor";
                lstAutores.DataBind();
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
                dgvLibros.DataSource = negocio.listar(txtBuscar.Text.Trim());
                dgvLibros.DataBind();
            }
            catch (Exception ex)
            {
                ((Site)Master).MostrarError(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            cargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            cargarGrilla();
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            limpiarFormulario();
        }

        private void limpiarFormulario()
        {
            txtTitulo.Text = "";
            txtIsbn.Text = "";
            txtAnio.Text = "";
            txtStock.Text = "1";
            ddlEditorial.SelectedIndex = 0;
            ddlCategoria.SelectedIndex = 0;
            lstAutores.ClearSelection();

            ViewState["IDLibroEditar"] = null;
            lblTituloForm.Text = "Alta de libro";
            btnGuardar.Text = "Agregar libro";
            btnCancelar.Visible = false;
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            Site master = (Site)Master;

            if (txtTitulo.Text.Trim() == "" || txtIsbn.Text.Trim() == "")
            {
                master.MostrarMensaje("Completá el título y el ISBN.", "warning");
                return;
            }

            int stock;
            if (!int.TryParse(txtStock.Text, out stock) || stock < 0)
            {
                master.MostrarMensaje("El stock tiene que ser un número mayor o igual a 0.", "warning");
                return;
            }

            int? anio = null;
            if (txtAnio.Text.Trim() != "")
            {
                int anioLeido;
                if (!int.TryParse(txtAnio.Text, out anioLeido) || anioLeido < 1000 || anioLeido > 9999)
                {
                    master.MostrarMensaje("Ingresá un año válido de cuatro cifras.", "warning");
                    return;
                }
                anio = anioLeido;
            }

            try
            {
                Libro libro = new Libro();
                libro.Titulo = txtTitulo.Text.Trim();
                libro.ISBN = txtIsbn.Text.Trim();
                libro.AnioPublicacion = anio;
                libro.Stock = stock;
                if (ddlEditorial.SelectedValue != "")
                    libro.IDEditorial = int.Parse(ddlEditorial.SelectedValue);
                if (ddlCategoria.SelectedValue != "")
                    libro.IDCategoria = int.Parse(ddlCategoria.SelectedValue);

                foreach (ListItem item in lstAutores.Items)
                {
                    if (item.Selected)
                    {
                        libro.Autores.Add(int.Parse(item.Value));
                    }
                }

                if (ViewState["IDLibroEditar"] != null)
                {
                    libro.IDLibro = (int)ViewState["IDLibroEditar"];
                    negocio.modificar(libro);
                    master.GuardarMensaje("Libro modificado correctamente.", "success");
                }
                else
                {
                    negocio.agregar(libro);
                    master.GuardarMensaje("Libro agregado correctamente.", "success");
                }

                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
            }
        }

        protected void dgvLibros_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Modificar" && e.CommandName != "Baja" &&
                e.CommandName != "Alta" && e.CommandName != "Eliminar")
            {
                return;
            }

            Site master = (Site)Master;
            int idLibro = Convert.ToInt32(e.CommandArgument);

            try
            {
                if (e.CommandName == "Modificar")
                {
                    cargarParaEditar(idLibro);
                    return;
                }

                if (e.CommandName == "Baja")
                {
                    negocio.bajaLogica(idLibro);
                    master.GuardarMensaje("Libro dado de baja lógicamente.", "success");
                }
                else if (e.CommandName == "Alta")
                {
                    negocio.altaLogica(idLibro);
                    master.GuardarMensaje("Libro reactivado correctamente.", "success");
                }
                else
                {
                    // DELETE físico: tr_InsteadOfDelete_Libros lo convierte en baja lógica
                    negocio.eliminarFisico(idLibro);
                    master.GuardarMensaje("Se intentó eliminar el libro: el trigger tr_InsteadOfDelete_Libros interceptó el DELETE y realizó la baja lógica.", "info");
                }

                Response.Redirect(Request.RawUrl, false);
            }
            catch (Exception ex)
            {
                master.MostrarError(ex);
                cargarGrilla();
            }
        }

        private void cargarParaEditar(int idLibro)
        {
            Libro libro = negocio.buscarPorId(idLibro);
            if (libro == null)
            {
                ((Site)Master).MostrarMensaje("No se encontró el libro.", "warning");
                return;
            }

            txtTitulo.Text = libro.Titulo;
            txtIsbn.Text = libro.ISBN;
            txtAnio.Text = libro.AnioPublicacion.HasValue ? libro.AnioPublicacion.Value.ToString() : "";
            txtStock.Text = libro.Stock.ToString();

            seleccionarEditorial(libro.IDEditorial);
            ddlCategoria.ClearSelection();
            string categoria = libro.IDCategoria.HasValue ? libro.IDCategoria.Value.ToString() : "";
            ListItem itemCategoria = ddlCategoria.Items.FindByValue(categoria);
            if (itemCategoria != null) itemCategoria.Selected = true;

            // Si el libro tiene autores dados de baja, los sumamos a la lista para no perderlos al guardar
            foreach (System.Data.DataRow fila in negocio.listarAutores(false).Rows)
            {
                string id = fila["IDAutor"].ToString();
                if (libro.Autores.Contains(int.Parse(id)) && lstAutores.Items.FindByValue(id) == null)
                {
                    lstAutores.Items.Add(new ListItem(fila["Nombre"] + " (baja)", id));
                }
            }

            foreach (ListItem item in lstAutores.Items)
            {
                item.Selected = libro.Autores.Contains(int.Parse(item.Value));
            }

            ViewState["IDLibroEditar"] = libro.IDLibro;
            lblTituloForm.Text = "Modificar libro";
            btnGuardar.Text = "Guardar cambios";
            btnCancelar.Visible = true;
        }

        private void seleccionarEditorial(int? idEditorial)
        {
            ddlEditorial.ClearSelection();
            string valor = idEditorial.HasValue ? idEditorial.Value.ToString() : "";
            ListItem item = ddlEditorial.Items.FindByValue(valor);

            if (item == null)
            {
                // La editorial del libro está dada de baja y no figura en el combo
                item = new ListItem("(editorial dada de baja)", valor);
                ddlEditorial.Items.Add(item);
            }
            item.Selected = true;
        }
    }
}
