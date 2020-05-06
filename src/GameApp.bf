using System;
using SDL2;
using System.Collections;

namespace d1
{
	static
	{
		public static GameApp gGameApp;
	}

	class GameApp : SDLApp
	{
		private bool spaceHeld;
		private Board board;
		private uint8 currentRule;

		public this()
		{
			gGameApp = this;
			board = new Board(currentRule, 1023, 1023);
		}

		public ~this()
		{
			delete board;
		}

		public new void Init()
		{
			mWidth = (.)board.Width;
			mHeight = (.)board.Height;
			base.Init();
		}

		public override void Draw()
		{
			Console.WriteLine("Drawing");
			let width = board.Width - 1;
			SDL.SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
			for (var y = 0; y < board.Height; y++)
			{
				for (var x = 0; x < width; x++)
				{
					if (board[y, x])
					{
						SDL.RenderDrawPoint(mRenderer, (.)x, (.)y);
					}
				}
			}
		}

		void HandleInputs()
		{
			if (IsKeyDown(.Space))
			{
				delete board;
				board = new Board(++currentRule, 1023, 1023);
			}
			if (IsKeyDown(.Escape))
			{
				var event = scope SDL2.SDL.Event();
				event.type = .Quit;

				SDL.PushEvent(ref *event);
			}
		}

		public override void Update()
		{
			Console.WriteLine("Update");
			board.CalculateNextRow();

			HandleInputs();
		}
	}
}
