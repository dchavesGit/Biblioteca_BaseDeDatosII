using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace BibliotecaWeb.AccesoDatos
{
    public class AccesoADatos
    {
        private SqlConnection conexion;
        private SqlCommand comando;
        private SqlDataReader lector;

        public SqlDataReader Lector
        {
            get { return lector; }
        }

        public AccesoADatos()
        {
            string cadenaConexion = ConfigurationManager.ConnectionStrings["Biblioteca"].ConnectionString;
            conexion = new SqlConnection(cadenaConexion);
            comando = new SqlCommand();
        }

        public void setearConsulta(string consulta)
        {
            comando.Parameters.Clear();
            comando.CommandType = CommandType.Text;
            comando.CommandText = consulta;
        }

        // Igual que setearConsulta pero para ejecutar un procedimiento almacenado
        public void setearProcedimiento(string procedimiento)
        {
            comando.Parameters.Clear();
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = procedimiento;
        }

        public void setearParametro(string nombre, object valor)
        {
            comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);
        }

        public void ejecutarLectura()
        {
            comando.Connection = conexion;
            if (conexion.State != ConnectionState.Open)
            {
                conexion.Open();
            }
            lector = comando.ExecuteReader();
        }

        // Ejecuta la lectura y devuelve todo en un DataTable (sirve para enlazar a un GridView o DropDownList)
        public DataTable leerTabla()
        {
            ejecutarLectura();
            DataTable tabla = new DataTable();
            tabla.Load(lector);
            return tabla;
        }

        public void ejecutarAccion()
        {
            comando.Connection = conexion;
            if (conexion.State != ConnectionState.Open)
            {
                conexion.Open();
            }
            comando.ExecuteNonQuery();
        }

        public void cerrarConexion()
        {
            if (lector != null)
                lector.Close();
            if (conexion.State == ConnectionState.Open)
                conexion.Close();
        }
    }
}
