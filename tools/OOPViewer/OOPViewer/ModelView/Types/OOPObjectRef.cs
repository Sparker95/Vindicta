using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView.Types
{
    public class OOPObjectRef : OOPVariable
    {
        public string Value { get; set; }

        public override string GetTypeName()
        {
            return "Unresolved OOP Object Ref";
        }
    }
}
