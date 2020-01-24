namespace OOPViewer.ModelView.Types
{
    public class OOPBoolean : OOPVariable
    {
        public bool Value { get; set; }
        public override string ToString() { return Value.ToString(); }
        public override string GetTypeName() { return "Boolean"; }
    }
}
