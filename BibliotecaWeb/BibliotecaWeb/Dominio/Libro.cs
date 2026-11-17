using System.Collections.Generic;

namespace BibliotecaWeb.Dominio
{
    public class Libro
    {
        public int IDLibro { get; set; }
        public string Titulo { get; set; }
        public string ISBN { get; set; }
        public int? AnioPublicacion { get; set; }
        public int Stock { get; set; }
        public int? IDEditorial { get; set; }
        public int? IDCategoria { get; set; }
        public List<int> Autores { get; set; }

        public Libro()
        {
            Autores = new List<int>();
        }
    }
}
