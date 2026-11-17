<%@ Page Title="Reportes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reportes.aspx.cs" Inherits="BibliotecaWeb.Reportes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-3">
        <h2 class="fw-bold mb-1">Reporte de préstamos por fechas</h2>
        <p class="text-muted small mb-0">Ejecuta el procedimiento de reporte <code>sp_ReportePrestamosPorFechas @Desde, @Hasta</code>.</p>
    </div>

    <div class="card shadow-sm border-0 mb-3">
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">Desde</label>
                    <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Hasta</label>
                    <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <asp:Button ID="btnGenerar" runat="server" Text="Generar reporte" CssClass="btn btn-primary w-100" OnClick="btnGenerar_Click" />
                </div>
            </div>
        </div>
    </div>

    <asp:Label ID="lblResumen" runat="server" CssClass="d-block text-muted small mb-2"></asp:Label>

    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <asp:GridView ID="dgvReporte" runat="server" AutoGenerateColumns="False"
                CssClass="table table-striped table-hover align-middle mb-0" GridLines="None"
                EmptyDataText="No hay préstamos en el rango elegido.">
                <Columns>
                    <asp:BoundField DataField="IDPrestamo" HeaderText="ID" />
                    <asp:BoundField DataField="Socio" HeaderText="Socio" />
                    <asp:BoundField DataField="Libro" HeaderText="Libro" />
                    <asp:BoundField DataField="FechaPrestamo" HeaderText="Préstamo" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                    <asp:BoundField DataField="FechaVencimiento" HeaderText="Vence" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                    <asp:BoundField DataField="FechaDevolucion" HeaderText="Devuelto" DataFormatString="{0:dd/MM/yyyy}" HtmlEncode="false" />
                    <asp:BoundField DataField="Estado" HeaderText="Estado" />
                    <asp:BoundField DataField="MontoMulta" HeaderText="Multa" DataFormatString="${0:N2}" HtmlEncode="false" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
