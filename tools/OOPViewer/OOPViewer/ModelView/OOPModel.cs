using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PropertyChanged;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer.ModelView
{
    [AddINotifyPropertyChangedInterface]
    public class OOPModel
    {

        public Dictionary<string, Types.OOPObject> Objects { get; set; } = new Dictionary<string, Types.OOPObject>();

        public static OOPModel LoadFromJson(string filePath)
        {
            var newModel = new OOPModel();
            foreach(var obj in JArray.Parse(File.ReadAllText(filePath)))
            {
                Types.OOPObject.ReadFromJson(obj as JObject, newModel.Objects);
            }

            //foreach (var jobj in lines
            //    .Select(l => {
            //        try
            //        {
            //            return JObject.Parse(l);
            //        }
            //        catch (JsonReaderException)
            //        {
            //            return null;
            //        }
            //    })
            //    .Where(o => o != null))
            //{
            //    Types.OOPObject.ReadFromJson(jobj, newModel.Objects);
            //}

            //foreach(var obj in newModel.Objects)
            //{
            //    obj.Value.ResolveObjectStringReferences(newModel.Objects);
            //}

            return newModel;
        }
    }
}
