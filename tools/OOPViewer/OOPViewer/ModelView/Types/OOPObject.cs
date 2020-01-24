using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView.Types
{
    public class OOPObject : OOPVariable
    {
        public string ObjectName { get; set; }
        public string ClassType { get; set; }
        public Dictionary<string, OOPVariable> Properties { get; set; } = new Dictionary<string, OOPVariable>();
        public override string ToString() { return $"OOP {ClassType}"; }
        public override string GetTypeName() { return "OOP Object"; }
    }
}
