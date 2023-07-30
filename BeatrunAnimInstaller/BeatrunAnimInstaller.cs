using System;
using System.Collections.Generic;
using System.IO;

namespace BeatrunAnimInstaller
{
	internal class BeatrunAnimInstaller
	{
		private static readonly string inDir = ".";
		private static readonly string outDir = "gamemodes\\beatrun\\content\\models";
		private static readonly List<string> choices = new List<string>() { "Old Animations", "New Animations" };

		static void RecursiveCopyDir(string inputDir, string outputDir)
		{
			if (!Directory.Exists(inputDir)) return;
			if (!Directory.Exists(outputDir)) Directory.CreateDirectory(outputDir);

			foreach (string filePath in Directory.GetFiles(inputDir))
			{
				string fileName = Path.GetFileName(filePath);
				File.Copy(filePath, outputDir + Path.DirectorySeparatorChar + fileName, true);
				Console.WriteLine(string.Format("Copied {0}", filePath));
			}

			foreach (string dirPath in Directory.GetDirectories(inputDir))
			{
				string dirName = Path.GetDirectoryName(dirPath);
				RecursiveCopyDir(dirPath, outputDir + Path.DirectorySeparatorChar + dirName);
			}
		}

		static void Main(string[] args)
		{
			Console.WriteLine("Select animations to install:");
			Console.WriteLine("");
			int i = 1;
			foreach (string choice in choices)
			{
				Console.WriteLine(string.Format("{0}. {1}", i, choice));
				i++;
			}
			Console.WriteLine("");

			while (true)
			{
				ConsoleKeyInfo key = Console.ReadKey(true);

				if (key.Key == ConsoleKey.Enter || key.Key == ConsoleKey.Escape) break;

				char keyChar = key.KeyChar;
				if (char.IsDigit(keyChar))
				{
					int index = keyChar - '0';
					string choice = choices[index - 1];
					if (choice != null)
					{
						Console.WriteLine(string.Format("Selected pack: {0}", choice));

						RecursiveCopyDir(inDir + Path.DirectorySeparatorChar + choice, outDir);

						Console.WriteLine("Press any key to exit...");
						Console.ReadKey(true);

						break;
					}
				}
			}
		}
	}
}
