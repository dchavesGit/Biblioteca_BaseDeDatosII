<%@ Page Title="Autores" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Autores.aspx.cs" Inherits="BibliotecaWeb.Autores" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Autores</h2>
        <p class="text-muted small mb-0">
            Alta de autores y baja lógica (<code>Activo = 0</code>) para conservar los libros que ya los tienen asociados.
        </p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <asp:Panel ID="pnlForm" runat="server" DefaultButton="btnAgregar" CssClass="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">Alta de autor</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Nombre</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Nacionalidad</label>
                        <asp:TextBox ID="txtNacionalidad" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAgregar" runat="server" Text="Agregar autor" CssClass="btn btn-primary w-100" OnClick="btnAgregar_Click" />
                </div>
            </asp:Panel>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="table-responsive">
                    <asp:GridView ID="dgvAutores" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="No hay autores cargados." OnRowCommand="dgvAutores_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="IDAutor" HeaderText="ID" />
                            <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                            <asp:BoundField DataField="Nacionalidad" HeaderText="Nacionalidad" />
                            <asp:BoundField DataField="Libros" HeaderText="Libros" />
                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'><%# (bool)Eval("Activo") ? "Activo" : "Baja" %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end text-nowrap">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Baja" CommandArgument='<%# Eval("IDAutor") %>'
                                        CssClass="btn btn-sm btn-warning" Visible='<%# (bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Dar de baja lógica a este autor?');">Baja</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Alta" CommandArgument='<%# Eval("IDAutor") %>'
                                        CssClass="btn btn-sm btn-success" Visible='<%# !(bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Reactivar este autor?');">Alta</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
