using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView.Types
{
    public class OOPArmaObject : OOPVariable
    {
        // Just store it as a string for now
        public string Value { get; set; }
        public override string ToString() { return Value; }
        public override string GetTypeName() { return "Arma Object"; }
    }
}
