using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView.Types
{
    public class OOPArray : OOPVariable
    {
        public List<OOPVariable> Items { get; set; } = new List<OOPVariable>();

        public override string ToString() { return $"Array: {Items.Count} items"; }
        public override string GetTypeName() { return "Array"; }
    }
}
