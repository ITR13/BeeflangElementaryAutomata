using System;
namespace d1
{
	class Board
	{
		private uint8 rule;
		public int Width { get; private set; }
		public int Height { get; private set; }
		private uint8[,] board;
		private int lastCalculatedRow;
		public bool FinishedDrawing => lastCalculatedRow >= Height;

		public this(uint8 rule, int width, int height)
		{
			Width = width;
			Height = height;
			this.rule = rule;

			board = new uint8[height, width];

			board[0, width / 2] = 1;
		}

		public void CalculateNextRow()
		{
			CalculateRow(++lastCalculatedRow);
			Console.WriteLine(lastCalculatedRow);
		}

		private void CalculateRow(int y)
		{
			if (y < 1) return;
			if (y >= Height) return;

			var xMax = Width - 1;
			for (var x = 1; x < xMax; x++)
			{
				CalculateCenter(x, y);
			}
			CalculateEdge(xMax - 1, 0, 1, y);
			CalculateEdge(xMax - 2, xMax - 1, 0, y);
		}

		[Inline]
		private int GetInput(int x0, int x1, int x2, int y)
		{
			return (board[y, x0] << 2) | (board[y, x1] << 1) | (board[y, x2] << 0);
		}

		private void CalculateCenter(int x, int y)
		{
			let input = GetInput(x - 1, x, x + 1, y - 1);
			let output = (rule >> input) % 2;

			board[[Unchecked]y, [Unchecked]x] = output;
		}

		private void CalculateEdge(int x0, int x1, int x2, int y){
			let input = GetInput(x0, x1, x2, y - 1);
			let output = (rule >> input) % 2;

			board[[Unchecked]y, [Unchecked]x1] = output;
		}

		public bool this[int y, int x]
		{
			get { return board[y, x] != 0; }
		}

		public ~this(){
			delete board;
		}
	}
}
