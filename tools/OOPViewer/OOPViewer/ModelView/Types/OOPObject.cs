using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView.Types
{
    [RefreshProperties(RefreshProperties.All)]
    public class OOPObject : OOPVariable, ICustomTypeDescriptor
    {
        public string ID => Properties["_id"].ToString(); //{ get; set; }
        public string Parent => Properties["oop_parent"].ToString(); //{ get; set; }
        public Dictionary<string, OOPVariable> Properties { get; set; } = new Dictionary<string, OOPVariable>();
        public override string ToString() { return $"{ID} ({Parent})"; }
        public override string GetTypeName() { return "OOP Object"; }

        public static OOPObject ReadFromJson(JObject json, Dictionary<string, OOPObject> objectDictionary)
        {
            OOPVariable ReadVariable(JToken val)
            {
                switch (val.Type)
                {
                    case JTokenType.Object:
                        return ReadFromJson(val as JObject, objectDictionary);
                    case JTokenType.Array:
                        return new OOPArray { Items = val.Select(innerVal => ReadVariable(innerVal)).ToList() };
                    case JTokenType.Float:
                        return new OOPNumber { Value = (double)((val as JValue).Value) };
                    case JTokenType.Integer:
                        return new OOPNumber { Value = (long)((val as JValue).Value) };
                    case JTokenType.Boolean:
                        return new OOPBoolean { Value = (bool)((val as JValue).Value) };
                    case JTokenType.String:
                        return new OOPString { Value = (string)((val as JValue).Value) };
                }
                return null;
            }

            string id = (string)(json["_id"] as JValue).Value;
            if (objectDictionary.TryGetValue(id, out OOPObject obj))
            {
                return obj;
            }

            var newObj = new OOPObject
            {
                Properties = json.Properties()
                    .ToDictionary(
                        prop => prop.Name,
                        prop => ReadVariable(prop.Value)
                    )
            };
            objectDictionary[newObj.ID] = newObj;
            return newObj;
        }


        public AttributeCollection GetAttributes() => TypeDescriptor.GetAttributes(this, true);
        public string GetClassName() => TypeDescriptor.GetClassName(this, true);
        public string GetComponentName() => TypeDescriptor.GetComponentName(this, true);
        public TypeConverter GetConverter() => TypeDescriptor.GetConverter(this, true);
        public EventDescriptor GetDefaultEvent() => TypeDescriptor.GetDefaultEvent(this, true);
        public PropertyDescriptor GetDefaultProperty() => null;
        public object GetEditor(Type editorBaseType) => TypeDescriptor.GetEditor(this, editorBaseType, true);
        public EventDescriptorCollection GetEvents(Attribute[] attributes) => TypeDescriptor.GetEvents(this, attributes, true);
        public PropertyDescriptorCollection GetProperties(Attribute[] attributes)
        {
            ArrayList properties = new ArrayList();
            foreach (var kvp in this.Properties)
            {
                properties.Add(new DictionaryPropertyDescriptor(kvp.Key, kvp.Value));
            }
            PropertyDescriptor[] props = (PropertyDescriptor[])properties.ToArray(typeof(PropertyDescriptor));
            return new PropertyDescriptorCollection(props);
        }
        public object GetPropertyOwner(PropertyDescriptor pd) => this;
        EventDescriptorCollection ICustomTypeDescriptor.GetEvents() => TypeDescriptor.GetEvents(this, true);
        PropertyDescriptorCollection ICustomTypeDescriptor.GetProperties() => ((ICustomTypeDescriptor)this).GetProperties(new Attribute[0]);

        //[NotifyPropertyChangedInvocator]
        //protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        //{
        //    this.PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        //}

        //public class PropertyAttributes
        //{
        //    public string Category { get; set; }
        //    public string Description { get; set; }
        //    public string DisplayName { get; set; }
        //    public bool IsReadOnly { get; set; }
        //}

        internal class DictionaryPropertyDescriptor : PropertyDescriptor
        {
            //private readonly string key;
            private readonly OOPVariable value;

            internal DictionaryPropertyDescriptor(string key, OOPVariable value) : base(key, null)
            {
                //this.key = key;
                this.value = value;
            }

            public override Type ComponentType => null;
            public override bool IsReadOnly => true;
            public override Type PropertyType => typeof(OOPVariable);
            public override bool CanResetValue(object component) => false;
            public override object GetValue(object component) => this.value;
            public override void ResetValue(object component) { }
            public override void SetValue(object component, object value) { }
            public override bool ShouldSerializeValue(object component) => false;
        }
        //public void ResolveObjectStringReferences(Dictionary<string, OOPObject> objects)
        //{
        //    var mappings = Properties
        //        .Where(prop => prop.Value is OOPString)
        //        .ToDictionary(
        //        prop => prop.Key,
        //        prop => {
        //            if(objects.TryGetValue((prop.Value as OOPString).Value, out OOPObject foundObj))
        //            {
        //                return foundObj;
        //            }
        //            return null;
        //        }
        //        )
        //        .Where(kv => kv.Value != null);

        //    foreach(var mapping in mappings)
        //    {
        //        Properties[mapping.Key] = mapping.Value;
        //    }
        //    //foreach (var prop in Properties)
        //    //{
        //    //    if(prop.Value is OOPString && objects.TryGetValue((prop.Value as OOPString).Value, out OOPObject foundObj))
        //    //    {
        //    //        Properties[prop.Key] = foundObj;
        //    //    }
        //    //}
        //}
    }
}
