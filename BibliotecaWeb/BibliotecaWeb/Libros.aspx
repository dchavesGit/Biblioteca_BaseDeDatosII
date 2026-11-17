<%@ Page Title="Libros" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Libros.aspx.cs" Inherits="BibliotecaWeb.Libros" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Libros</h2>
        <p class="text-muted small mb-0">
            Lee la vista <code>vw_CatalogoLibros</code>. <b>Baja</b> pone el libro como inactivo;
            <b>Eliminar</b> intenta un DELETE físico y <code>tr_InsteadOfDelete_Libros</code> lo convierte en baja lógica.
            El stock cambia solo con los triggers de Préstamos.
        </p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <asp:Panel ID="pnlForm" runat="server" DefaultButton="btnGuardar" CssClass="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">
                    <asp:Label ID="lblTituloForm" runat="server" Text="Alta de libro"></asp:Label>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Título</label>
                        <asp:TextBox ID="txtTitulo" runat="server" CssClass="form-control" MaxLength="150"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">ISBN</label>
                        <asp:TextBox ID="txtIsbn" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label">Año</label>
                            <asp:TextBox ID="txtAnio" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Stock</label>
                            <asp:TextBox ID="txtStock" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Editorial</label>
                        <asp:DropDownList ID="ddlEditorial" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Categoría</label>
                        <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Autores</label>
                        <asp:ListBox ID="lstAutores" runat="server" CssClass="form-select" SelectionMode="Multiple" Rows="5"></asp:ListBox>
                        <div class="form-text">Ctrl + clic para elegir más de uno.</div>
                    </div>
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnGuardar" runat="server" Text="Agregar libro" CssClass="btn btn-primary flex-grow-1" OnClick="btnGuardar_Click" />
                        <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" Visible="false" CausesValidation="false" OnClick="btnCancelar_Click" />
                    </div>
                </div>
            </asp:Panel>
        </div>

        <div class="col-lg-8">
            <asp:Panel ID="pnlBuscar" runat="server" DefaultButton="btnBuscar" CssClass="card shadow-sm border-0 mb-3">
                <div class="card-body">
                    <div class="row g-2">
                        <div class="col-md-8">
                            <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" placeholder="Buscar por título, autor o ISBN..."></asp:TextBox>
                        </div>
                        <div class="col-md-4 d-flex gap-2">
                            <asp:Button ID="btnBuscar" runat="server" Text="Buscar" CssClass="btn btn-primary" OnClick="btnBuscar_Click" />
                            <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <div class="card shadow-sm border-0">
                <div class="table-responsive">
                    <asp:GridView ID="dgvLibros" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-sm table-striped table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="No se encontraron libros." OnRowCommand="dgvLibros_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Titulo" HeaderText="Título" />
                            <asp:BoundField DataField="Autores" HeaderText="Autores" />
                            <asp:BoundField DataField="ISBN" HeaderText="ISBN" />
                            <asp:BoundField DataField="Editorial" HeaderText="Editorial" />
                            <asp:BoundField DataField="Categoria" HeaderText="Categoría" />
                            <asp:TemplateField HeaderText="Stock">
                                <ItemTemplate>
                                    <span class='badge <%# (int)Eval("Stock") > 0 ? "text-bg-success" : "text-bg-danger" %>'><%# Eval("Stock") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'><%# (bool)Eval("Activo") ? "Activo" : "Baja" %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end text-nowrap">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Modificar" CommandArgument='<%# Eval("IDLibro") %>'
                                        CssClass="btn btn-sm btn-outline-primary">Modificar</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Baja" CommandArgument='<%# Eval("IDLibro") %>'
                                        CssClass="btn btn-sm btn-warning" Visible='<%# (bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Dar de baja lógica a este libro?');">Baja</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Alta" CommandArgument='<%# Eval("IDLibro") %>'
                                        CssClass="btn btn-sm btn-success" Visible='<%# !(bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Reactivar este libro?');">Alta</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDLibro") %>'
                                        CssClass="btn btn-sm btn-outline-danger"
                                        OnClientClick="return confirm('Se intentará un DELETE físico (el trigger lo convierte en baja lógica). ¿Continuar?');">Eliminar</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
