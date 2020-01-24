using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOPViewer
{
    public class TestModel : ModelView.OOPModel
    {
        public TestModel()
        {
            var rnd = new Random();

            ModelView.Types.OOPArray MakePos()
            {
                return new ModelView.Types.OOPArray
                {
                    Items = new List<ModelView.Types.OOPVariable>
                    {
                        new ModelView.Types.OOPNumber{Value = rnd.NextDouble() * 10000},
                        new ModelView.Types.OOPNumber{Value = rnd.NextDouble() * 10000},
                        new ModelView.Types.OOPNumber{Value = rnd.NextDouble() * 10000}
                    }
                };
            }
            ModelView.Types.OOPObject AddObject(ModelView.Types.OOPObject obj)
            {
                Objects.Add(obj.ID, obj);
                return obj;
            }

            var unit1 = AddObject(new ModelView.Types.OOPObject
            {
                Properties = new Dictionary<string, ModelView.Types.OOPVariable>
                {
                    { "_id", new ModelView.Types.OOPString{Value = "unit1"} },
                    { "oop_parent", new ModelView.Types.OOPString{Value = "UnitModel"} },
                    { "Name", new ModelView.Types.OOPString{Value = "Alpha1-1"} },
                    { "Dammage", new ModelView.Types.OOPNumber{Value = 0.5} },
                    { "Position", MakePos() },
                    { "TargetPosition", MakePos() }
                }
            });
            AddObject(new ModelView.Types.OOPObject
            {
                Properties = new Dictionary<string, ModelView.Types.OOPVariable>
                {
                    { "_id", new ModelView.Types.OOPString{Value = "unit2"} },
                    { "oop_parent", new ModelView.Types.OOPString{Value = "UnitModel"} },
                    { "Name", new ModelView.Types.OOPString{Value = "Alpha1-2"} },
                    { "Dammage", new ModelView.Types.OOPNumber{Value = 0.75} },
                    { "Position", MakePos() },
                    { "Leader", unit1 },
                    { "TargetPosition", MakePos() }
                }
            });
        }
    }
}
