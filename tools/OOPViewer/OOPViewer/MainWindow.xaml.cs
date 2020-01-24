using Microsoft.Win32;
using PropertyChanged;
using System.Windows;
using System.Windows.Input;

namespace OOPViewer
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    [AddINotifyPropertyChangedInterface]
    public partial class MainWindow : Window
    {
#if RELEASE
        public ModelView.OOPModel Model { get; set; } = new ModelView.OOPModel();
#else
        public ModelView.OOPModel Model { get; set; } = new TestModel();
#endif

        public MainWindow()
        {
            InitializeComponent();

            this.DataContext = Model;
        }

        private void CommandLoad_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            var openFileDialog = new OpenFileDialog { DefaultExt = ".rpt" };
            if (openFileDialog.ShowDialog() == true)
            {
                Model = ModelView.OOPModel.LoadFromJson(openFileDialog.FileName);
                this.DataContext = Model;
            }
        }
    }
}
