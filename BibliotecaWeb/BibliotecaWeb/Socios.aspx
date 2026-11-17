<%@ Page Title="Socios" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Socios.aspx.cs" Inherits="BibliotecaWeb.Socios" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Socios</h2>
        <p class="text-muted small mb-0">
            Lee la vista <code>vw_EstadoSocios</code>. <b>Baja</b> ejecuta <code>sp_BajaLogicaSocio</code>; <b>Alta</b> reactiva un socio con <code>sp_AltaLogicaSocio</code>;
            <b>Eliminar</b> intenta un DELETE físico y lo intercepta <code>tr_InsteadOfDelete_Socios</code>.
        </p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">Alta de socio</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Nombre</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Apellido</label>
                        <asp:TextBox ID="txtApellido" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">DNI</label>
                        <asp:TextBox ID="txtDni" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="100"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAgregar" runat="server" Text="Agregar socio" CssClass="btn btn-primary w-100" OnClick="btnAgregar_Click" />
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="table-responsive">
                    <asp:GridView ID="dgvSocios" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="No hay socios cargados." OnRowCommand="dgvSocios_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="IDSocio" HeaderText="ID" />
                            <asp:BoundField DataField="Apellido" HeaderText="Apellido" />
                            <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                            <asp:BoundField DataField="DNI" HeaderText="DNI" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'><%# (bool)Eval("Activo") ? "Activo" : "Baja" %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="PrestamosActivos" HeaderText="Préstamos activos" />
                            <asp:BoundField DataField="MultasPendientes" HeaderText="Multas pend." />
                            <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-end text-nowrap">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Baja" CommandArgument='<%# Eval("IDSocio") %>'
                                        CssClass="btn btn-sm btn-warning" Visible='<%# (bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Dar de baja lógica a este socio?');">Baja</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Alta" CommandArgument='<%# Eval("IDSocio") %>'
                                        CssClass="btn btn-sm btn-success" Visible='<%# !(bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Reactivar a este socio?');">Alta</asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDSocio") %>'
                                        CssClass="btn btn-sm btn-outline-danger"
                                        OnClientClick="return confirm('Se intentará un DELETE físico (lo bloquea el trigger). ¿Continuar?');">Eliminar</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
