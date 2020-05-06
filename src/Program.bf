using System;

namespace d1
{
	class Program
	{
		public static int Main(String[] args)
		{
			let gameApp = scope GameApp();
			gameApp.Init();
			gameApp.Run();

			return 0;
		}
	}
}