<%@ Page Title="Multas" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Multas.aspx.cs" Inherits="BibliotecaWeb.Multas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Multas</h2>
        <p class="text-muted small mb-0">
            Lee la vista <code>vw_MultasDetalle</code>. Las multas las genera <code>tr_AfterUpdate_Prestamos</code> al devolver con retraso;
            <b>Pagar</b> ejecuta <code>sp_PagarMulta</code>.
        </p>
    </div>

    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body">
            <div class="row g-2 align-items-center">
                <div class="col-auto">
                    <label class="col-form-label" for="<%= ddlEstado.ClientID %>">Estado</label>
                </div>
                <div class="col-auto">
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlEstado_SelectedIndexChanged">
                        <asp:ListItem Text="Todas" Value="" />
                        <asp:ListItem Text="Pendientes" Value="Pendiente" />
                        <asp:ListItem Text="Pagadas" Value="Pagada" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <asp:GridView ID="dgvMultas" runat="server" AutoGenerateColumns="False"
                CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                EmptyDataText="No hay multas para mostrar." OnRowCommand="dgvMultas_RowCommand">
                <Columns>
                    <asp:BoundField DataField="IDMulta" HeaderText="ID" />
                    <asp:BoundField DataField="IDPrestamo" HeaderText="Préstamo" />
                    <asp:BoundField DataField="Socio" HeaderText="Socio" />
                    <asp:BoundField DataField="Libro" HeaderText="Libro" />
                    <asp:BoundField DataField="DiasRetraso" HeaderText="Días de retraso" />
                    <asp:BoundField DataField="Monto" HeaderText="Monto" DataFormatString="${0:N2}" HtmlEncode="false" />
                    <asp:BoundField DataField="FechaGeneracion" HeaderText="Generada" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                    <asp:TemplateField HeaderText="Estado">
                        <ItemTemplate>
                            <span class='badge <%# Eval("Estado").ToString() == "Pendiente" ? "text-bg-warning" : "text-bg-success" %>'><%# Eval("Estado") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="FechaPago" HeaderText="Pagada el" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                    <asp:TemplateField ItemStyle-CssClass="text-end">
                        <ItemTemplate>
                            <asp:LinkButton runat="server" CommandName="Pagar" CommandArgument='<%# Eval("IDMulta") %>'
                                CssClass="btn btn-sm btn-success" Visible='<%# Eval("Estado").ToString() == "Pendiente" %>'
                                OnClientClick="return confirm('¿Registrar el pago de esta multa?');">Pagar</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
