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
		private bool spaceHeld;
		private Board board;
		private uint8 currentRule;
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
			board = new Board(++currentRule, 1023, 1023);
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
