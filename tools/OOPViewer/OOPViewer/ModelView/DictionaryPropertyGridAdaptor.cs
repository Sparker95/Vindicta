using PropertyChanged;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView
{
    [RefreshProperties(RefreshProperties.All)]
    [AddINotifyPropertyChangedInterface]
    public class DictionaryPropertyGridAdapter<TKey, TValue> : ICustomTypeDescriptor
    {
        private readonly IDictionary<TKey, PropertyAttributes> propertyAttributeDictionary;
        private readonly IDictionary<TKey, TValue> propertyValueDictionary;

        public DictionaryPropertyGridAdapter(
            IDictionary<TKey, TValue> propertyValueDictionary,
            IDictionary<TKey, PropertyAttributes> propertyAttributeDictionary = null)
        {
            this.propertyValueDictionary = propertyValueDictionary;
            this.propertyAttributeDictionary = propertyAttributeDictionary;
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
            foreach (var kvp in this.propertyValueDictionary)
            {
                properties.Add(
                    new DictionaryPropertyDescriptor(
                        kvp.Key,
                        this.propertyValueDictionary,
                        this.propertyAttributeDictionary)
                );
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

        public class PropertyAttributes
        {
            public string Category { get; set; }
            public string Description { get; set; }
            public string DisplayName { get; set; }
            public bool IsReadOnly { get; set; }
        }

        internal class DictionaryPropertyDescriptor : PropertyDescriptor
        {
            private readonly IDictionary<TKey, PropertyAttributes> attributeDictionary;
            private readonly TKey key;
            private readonly IDictionary<TKey, TValue> valueDictionary;
            internal DictionaryPropertyDescriptor(
                TKey key,
                IDictionary<TKey, TValue> valueDictionary,
                IDictionary<TKey, PropertyAttributes> attributeDictionary = null)
                : base(key.ToString(), null)
            {
                this.valueDictionary = valueDictionary;
                this.attributeDictionary = attributeDictionary;
                this.key = key;
            }
            public override string Category => this.attributeDictionary?[this.key].Category ?? base.Category;
            public override Type ComponentType => null;
            public override string Description => this.attributeDictionary?[this.key].Description ?? base.Description;
            public override string DisplayName => this.attributeDictionary?[this.key].DisplayName ?? base.DisplayName;
            public override bool IsReadOnly => this.attributeDictionary?[this.key].IsReadOnly ?? false;
            public override Type PropertyType => this.valueDictionary[this.key].GetType();
            public override bool CanResetValue(object component) => false;
            public override object GetValue(object component) => this.valueDictionary[this.key];
            public override void ResetValue(object component) { }
            public override void SetValue(object component, object value)
            {
                this.valueDictionary[this.key] = (TValue)value;
            }
            public override bool ShouldSerializeValue(object component) => false;
        }
    }
}
