using System.Collections.Generic;
using System.Linq;

namespace OOPViewer.ModelView.Types
{
    public class OOPArray : OOPVariable
    {
        public IEnumerable<OOPVariable> Items { get; set; } = new List<OOPVariable>();

        public override string ToString() { return $"Array: {Items.Count()} items"; }
        public override string GetTypeName() { return "Array"; }
    }
}
