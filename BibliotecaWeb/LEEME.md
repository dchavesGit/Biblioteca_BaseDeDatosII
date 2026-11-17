# BibliotecaWeb – front ASP.NET Web Forms + Bootstrap

Front simple para el TPI de Base de Datos II (bbdBiblioteca). Misma estructura que el RestoBar:
master page + pages con forms/GridView + capas `Dominio` / `DatosNegocio` / `AccesoDatos`.

## Puesta en marcha
1. En SQL Server ejecutar, en este orden: script de creación de tablas, `Triggers.sql`, `Procedures.sql`,
   `BaseDeDatos/04_Vistas_Funcion_Reporte.sql`, `BaseDeDatos/06_sp_AltaLogicaSocio.sql` y (opcional) `BaseDeDatos/05_DatosEjemplo.sql`.
2. Abrir `BibliotecaWeb.slnx` (o `BibliotecaWeb/BibliotecaWeb.csproj`) con Visual Studio 2022.
3. Editar el connection string `Biblioteca` en `Web.config` (servidor, usuario y contraseña).
4. Ejecutar (F5). No requiere paquetes NuGet.

## Pantallas y qué dispara cada una
| Pantalla | Acción | Objeto de la base |
|---|---|---|
| Libros | listar / buscar | vw_CatalogoLibros |
| Socios | listar | vw_EstadoSocios |
| Socios | Baja | sp_BajaLogicaSocio |
| Editoriales | alta / baja lógica / alta | tabla EDITORIALES (Activo) |
| Socios | Alta (reactivar) | sp_AltaLogicaSocio |
| Socios | Eliminar | DELETE -> tr_InsteadOfDelete_Socios (bloquea) |
| Préstamos | listar activos | vw_PrestamosActivos (usa fn_DiasRetraso) |
| Préstamos | Registrar préstamo | sp_RegistrarPrestamo -> tr_AfterInsert_Prestamos |
| Préstamos | Devolver | sp_RegistrarDevolucion -> tr_AfterUpdate_Prestamos |
| Multas | listar | vw_MultasDetalle |
| Multas | Pagar | sp_PagarMulta |
| Reportes | generar | sp_ReportePrestamosPorFechas |

## Guion rápido para la demo
- Préstamo en término: Préstamos > registrar con 7 días > en Libros baja el stock.
- Validaciones del procedure: socio dado de baja, socio con multa pendiente, libro sin stock.
- Multa: registrar un préstamo con días negativos (ej. -5) > Devolver > se genera la multa > pagarla en Multas.
- Trigger DELETE: Socios > Eliminar.
