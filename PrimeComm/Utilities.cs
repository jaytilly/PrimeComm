using System;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using PrimeComm.Properties;

namespace PrimeComm
{
    static internal class Utilities
    {
        public static string CommandToken = "????";

        public static void InvokeIfRequired(this Control c, MethodInvoker action)
        {
            if (c.InvokeRequired) c.Invoke(action); else action();
        }

        /// <summary>
        /// TrimStart with String 
        /// http://stackoverflow.com/questions/4335878/c-sharp-trimstart-with-string-parameter
        /// </summary>
        /// <param name="target">Source string</param>
        /// <param name="trimString">String to trim</param>
        /// <param name="recursive">If the string should be processed again</param>
        /// <returns>Trimmed string</returns>
        public static string TrimStart(this string target, string trimString, bool recursive = true)
        {
            var result = target;
            while (result.StartsWith(trimString))
            {
                result = result.Substring(trimString.Length);
                if (!recursive)
                    break;
            }

            return result;
        }

        public static string CreateTemporalFileFromText(string text=null)
        {
            var t = Path.GetTempFileName();
            File.Delete(t);
            Directory.CreateDirectory(t);

            // Get name
            try
            {
                if (!String.IsNullOrEmpty(text))
                    return SaveText(text, t);

                if (Clipboard.ContainsText())
                    return SaveText(Clipboard.GetText(TextDataFormat.UnicodeText).Trim(), t);
                
                if (Clipboard.ContainsImage())
                {
                    t = Path.Combine(t, PrimeLib.Utilities.GetRandomImageName() + ".png");
                    Clipboard.GetImage().Save(t);

                    return t;
                }
            }
            catch
            {
            }
            return null;
        }

        private static string SaveText(string text, string t)
        {
            if (!String.IsNullOrEmpty(text))
            {
                var m = new Regex(Settings.Default.RegexProgramName, RegexOptions.IgnoreCase).Match(text);
                var name = PrimeLib.Utilities.GetRandomProgramName();

                if (m.Success)
                    name = m.Groups["name"].Value;

                t = Path.Combine(t, name + ".txt");
                File.WriteAllText(t, text, Encoding.BigEndianUnicode);
                return t;
            }
            else
                throw new Exception("Nothing to save");
        }

        internal static void AppendToRecentFiles(string fileName)
        {
            if (Settings.Default.RecentOpenedFiles.Contains(fileName))
                Settings.Default.RecentOpenedFiles.Remove(fileName);

            Settings.Default.RecentOpenedFiles.Add(fileName);
            UpdateRecentFiles();
        }

        internal static void UpdateRecentFiles()
        {
            RecentFiles = new ToolStripDropDown() { LayoutStyle = ToolStripLayoutStyle.VerticalStackWithOverflow};

            if (Settings.Default.RecentOpenedFiles != null)
            {
                while (Settings.Default.RecentOpenedFiles.Count > Settings.Default.RecentFilesMaximum &&
                       Settings.Default.RecentOpenedFiles.Count > 0)
                    Settings.Default.RecentOpenedFiles.RemoveAt(0);

                var n = 0;
                for (var i = Settings.Default.RecentOpenedFiles.Count-1; i >=0 ; i--)
                {
                    var m = Settings.Default.RecentOpenedFiles[i];
                    if (File.Exists(m))
                    {
                        RecentFiles.Items.Add(new ToolStripMenuItem("&" + ++n + ": " + m)
                        {
                            Tag = m,
                            Alignment = ToolStripItemAlignment.Left,
                            ShowShortcutKeys = true,
                            TextAlign = ContentAlignment.MiddleLeft
                        });
                    }
                }

                Settings.Default.Save();
            }
            else
                Settings.Default.RecentOpenedFiles = new StringCollection();
        }

        public static ToolStripDropDown RecentFiles { get; private set; }
    }
}