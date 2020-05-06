using System;
using SDL2;
using System.Collections;
using System.Threading;

namespace d1
{
	static
	{
		public static GameApp gGameApp;
	}

	class GameApp : SDLApp
	{
		// Each pixel will cover Scale * Scale points
		private const int Width = 1024;
		private const int Height = 1024;
		private const int Scale = 8;
		private const int SqrScale = Scale * Scale;

		private bool spaceHeld;
		private Board board;
		private uint8 currentRule = 89;
		private Thread calcThread;

		public this()
		{
			gGameApp = this;
		}

		public ~this()
		{
			let oldBoard = board;
			board = null;
			// Note: thread deletes itself when it finishes, so needs to be called before it ends
			calcThread.Join();
			calcThread = null;
			delete oldBoard;
		}

		public new void Init()
		{
			CreateBoardAndLoop();
			mWidth = Width;
			mHeight = Height;
			base.Init();
		}

		public override void Draw()
		{
			Console.WriteLine("Drawing");
			let width = board.Width - 1;
			for (var y = 0; y < Height; y++)
			{
				for (var x = 0; x < Width; x++)
				{
					var total = 0;
					for (var subY = 0; subY < Scale; subY++)
					{
						for (var subX = 0; subX < Scale; subX++)
						{
							if (board[y*Scale + subY, x*Scale + subX])
							{
								total += 1;
							}
						}
					}
					if (total > 0)
					{
						let brightness = (uint8)((total * 255 + 1) / (SqrScale + 1));
						SDL.SetRenderDrawColor(mRenderer, brightness, brightness, brightness, 255);
						SDL.RenderDrawPoint(mRenderer, (.)x, (.)y);
					}
				}
			}
		}

		void HandleInputs()
		{
			if (IsKeyDown(.Escape))
			{
				var event = scope SDL2.SDL.Event();
				event.type = .Quit;

				SDL.PushEvent(ref *event);
				return;
			}

			if (IsKeyDown(.Space))
			{
				if (spaceHeld) return;
				spaceHeld = true;
				CreateBoardAndLoop();
			} else
			{
				spaceHeld = false;
			}
		}

		public override void Update()
		{
			HandleInputs();
		}

		private void CreateBoardAndLoop()
		{
			let oldBoard = board;
			board = null;
			if (calcThread != null)
			{
				// Note: thread deletes itself when it finishes, so needs to be called before it ends
				calcThread.Join();
				calcThread = null;
			}
			if (oldBoard != null)
			{
				delete oldBoard;
			}
			board = new Board(++currentRule, 1024 * Scale, 1024 * Scale);
			calcThread = new Thread(new => CalculateLoop);
			calcThread.Start();
		}

		private void CalculateLoop()
		{
			while (board != null)
			{
				let cachedBoard = board;
				if (cachedBoard.FinishedDrawing)
				{
					Thread.Sleep(1);
					continue;
				}
				cachedBoard.CalculateNextRow();
				Thread.Sleep(0);
			}
		}
	}
}
