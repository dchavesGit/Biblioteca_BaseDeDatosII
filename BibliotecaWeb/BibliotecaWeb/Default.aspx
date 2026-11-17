<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BibliotecaWeb.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="mb-4">
        <h2 class="fw-bold mb-1">Sistema de Biblioteca Universitaria</h2>
        <p class="text-muted mb-0">Cliente web para la base <code>bbdBiblioteca</code>: cada pantalla ejecuta vistas, procedimientos almacenados y dispara triggers.</p>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-white fw-semibold">Qué ejecuta cada pantalla</div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Pantalla</th>
                        <th>Acción</th>
                        <th>Objeto de la base</th>
                        <th>Efecto</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td rowspan="4"><a href="Libros.aspx">Libros</a></td>
                        <td>Listar y buscar</td>
                        <td><code>vw_CatalogoLibros</code></td>
                        <td>Muestra el stock actualizado por los triggers</td>
                    </tr>
                    <tr>
                        <td>Agregar / Modificar</td>
                        <td>Tablas <code>LIBROS</code> y <code>LIBROSAUTORES</code></td>
                        <td>Guarda el libro con sus autores (muchos a muchos)</td>
                    </tr>
                    <tr>
                        <td>Baja / Alta</td>
                        <td>Columna <code>LIBROS.Activo</code></td>
                        <td>Baja lógica y reactivación</td>
                    </tr>
                    <tr>
                        <td>Eliminar</td>
                        <td><code>tr_InsteadOfDelete_Libros</code> (DELETE)</td>
                        <td>Intercepta el borrado físico y hace la baja lógica</td>
                    </tr>
                    <tr>
                        <td rowspan="4"><a href="Socios.aspx">Socios</a></td>
                        <td>Listar</td>
                        <td><code>vw_EstadoSocios</code></td>
                        <td>Préstamos activos y multas pendientes por socio</td>
                    </tr>
                    <tr>
                        <td>Dar de baja</td>
                        <td><code>sp_BajaLogicaSocio</code></td>
                        <td>Baja lógica con validación de préstamos sin devolver</td>
                    </tr>
                    <tr>
                        <td>Reactivar (Alta)</td>
                        <td><code>sp_AltaLogicaSocio</code></td>
                        <td>Vuelve a dejar activo a un socio dado de baja</td>
                    </tr>
                    <tr>
                        <td>Eliminar</td>
                        <td><code>tr_InsteadOfDelete_Socios</code> (DELETE)</td>
                        <td>Bloquea el borrado físico y muestra el error</td>
                    </tr>
                    <tr>
                        <td rowspan="3"><a href="Prestamos.aspx">Préstamos</a></td>
                        <td>Listar activos</td>
                        <td><code>vw_PrestamosActivos</code> (usa <code>fn_DiasRetraso</code>)</td>
                        <td>Situación y días de atraso</td>
                    </tr>
                    <tr>
                        <td>Registrar préstamo</td>
                        <td><code>sp_RegistrarPrestamo</code> + <code>tr_AfterInsert_Prestamos</code> (INSERT)</td>
                        <td>Valida y descuenta el stock</td>
                    </tr>
                    <tr>
                        <td>Registrar devolución</td>
                        <td><code>sp_RegistrarDevolucion</code> + <code>tr_AfterUpdate_Prestamos</code> (UPDATE)</td>
                        <td>Repone stock y genera la multa si hay retraso</td>
                    </tr>
                    <tr>
                        <td rowspan="2"><a href="Multas.aspx">Multas</a></td>
                        <td>Listar</td>
                        <td><code>vw_MultasDetalle</code></td>
                        <td>Detalle por socio y libro</td>
                    </tr>
                    <tr>
                        <td>Pagar multa</td>
                        <td><code>sp_PagarMulta</code></td>
                        <td>Pasa la multa a Pagada</td>
                    </tr>
                    <tr>
                        <td><a href="Editoriales.aspx">Editoriales</a></td>
                        <td>Alta, baja y reactivación lógica</td>
                        <td>Tabla <code>EDITORIALES</code> (<code>Activo</code>)</td>
                        <td>Conserva el historial de libros de la editorial</td>
                    </tr>
                    <tr>
                        <td><a href="Autores.aspx">Autores</a></td>
                        <td>Alta, baja y reactivación lógica</td>
                        <td>Tabla <code>AUTORES</code> (<code>Activo</code>)</td>
                        <td>Conserva los libros que ya tienen ese autor</td>
                    </tr>
                    <tr>
                        <td><a href="Reportes.aspx">Reportes</a></td>
                        <td>Generar reporte</td>
                        <td><code>sp_ReportePrestamosPorFechas</code> (parámetros)</td>
                        <td>Préstamos entre dos fechas con su multa</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
