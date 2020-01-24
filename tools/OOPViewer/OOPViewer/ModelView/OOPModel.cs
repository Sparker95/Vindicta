using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView
{
    public class OOPModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public Types.OOPObject SelectedObject { get; set; }

        public Dictionary<string, Types.OOPObject> Objects { get; set; } = new Dictionary<string, Types.OOPObject>();
    }
}
