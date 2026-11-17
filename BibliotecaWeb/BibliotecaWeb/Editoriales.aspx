<%@ Page Title="Editoriales" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Editoriales.aspx.cs" Inherits="BibliotecaWeb.Editoriales" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Editoriales</h2>
        <p class="text-muted small mb-0">
            Alta de editoriales y baja lógica (<code>Activo = 0</code>) para conservar el historial de libros.
        </p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">Alta de editorial</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Nombre</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">País</label>
                        <asp:TextBox ID="txtPais" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAgregar" runat="server" Text="Agregar editorial" CssClass="btn btn-primary w-100" OnClick="btnAgregar_Click" />
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="table-responsive">
                    <asp:GridView ID="dgvEditoriales" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="No hay editoriales cargadas." OnRowCommand="dgvEditoriales_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="IDEditorial" HeaderText="ID" />
                            <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                            <asp:BoundField DataField="Pais" HeaderText="País" />
                            <asp:BoundField DataField="Libros" HeaderText="Libros" />
                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'><%# (bool)Eval("Activo") ? "Activa" : "Baja" %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end text-nowrap">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Baja" CommandArgument='<%# Eval("IDEditorial") %>'
                                        CssClass="btn btn-sm btn-warning" Visible='<%# (bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Dar de baja lógica a esta editorial?');">Baja</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Alta" CommandArgument='<%# Eval("IDEditorial") %>'
                                        CssClass="btn btn-sm btn-success" Visible='<%# !(bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Reactivar esta editorial?');">Alta</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
