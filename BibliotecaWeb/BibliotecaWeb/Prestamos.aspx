<%@ Page Title="Préstamos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Prestamos.aspx.cs" Inherits="BibliotecaWeb.Prestamos" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Préstamos</h2>
        <p class="text-muted small mb-0">
            <b>Prestar</b> ejecuta <code>sp_RegistrarPrestamo</code> y dispara <code>tr_AfterInsert_Prestamos</code> (descuenta stock).
            <b>Devolver</b> ejecuta <code>sp_RegistrarDevolucion</code> y dispara <code>tr_AfterUpdate_Prestamos</code> (repone stock y genera multa si hay retraso).
        </p>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">Registrar préstamo</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Socio</label>
                        <asp:DropDownList ID="ddlSocio" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Libro</label>
                        <asp:DropDownList ID="ddlLibro" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Días de préstamo</label>
                        <asp:TextBox ID="txtDias" runat="server" CssClass="form-control" TextMode="Number" Text="7"></asp:TextBox>
                        <div class="form-text">Solo para la demo: un valor negativo (por ejemplo -5) simula un préstamo ya vencido y permite ver la multa al devolverlo.</div>
                    </div>
                    <asp:Button ID="btnPrestar" runat="server" Text="Registrar préstamo" CssClass="btn btn-primary w-100" OnClick="btnPrestar_Click" />
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white fw-semibold">Préstamos activos <span class="text-muted fw-normal small">(vista <code>vw_PrestamosActivos</code>)</span></div>
                <div class="table-responsive">
                    <asp:GridView ID="dgvPrestamos" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="No hay préstamos activos." OnRowCommand="dgvPrestamos_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="IDPrestamo" HeaderText="ID" />
                            <asp:BoundField DataField="Socio" HeaderText="Socio" />
                            <asp:BoundField DataField="Libro" HeaderText="Libro" />
                            <asp:BoundField DataField="FechaPrestamo" HeaderText="Préstamo" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                            <asp:BoundField DataField="FechaVencimiento" HeaderText="Vence" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                            <asp:BoundField DataField="DiasRetraso" HeaderText="Días de atraso" />
                            <asp:TemplateField HeaderText="Situación">
                                <ItemTemplate>
                                    <span class='badge <%# Eval("Situacion").ToString() == "Vencido" ? "text-bg-danger" : "text-bg-success" %>'><%# Eval("Situacion") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="text-end">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="Devolver" CommandArgument='<%# Eval("IDPrestamo") %>'
                                        CssClass="btn btn-sm btn-success"
                                        OnClientClick="return confirm('¿Registrar la devolución de este libro?');">Devolver</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
