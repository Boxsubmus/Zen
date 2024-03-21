using System;
using ImGui;
using System.IO;
using ZenIDE.GFX;
using System.Collections;

namespace ZenIDE.Widgets;

class CodeEditor
{
	private String Text = new .() ~ if (_ != null) delete _;
	private List<String> m_Lines = new .() ~ DeleteContainerAndItems!(_);

	private struct LongestLine
	{
		public int Index;
		public int Length;
	}

	private LongestLine m_LongestLine;
	private int m_FrameCount;

	public this()
	{
		let dir = Directory.GetCurrentDirectory(.. scope .());
		Console.WriteLine(dir);
		let text = File.ReadAllText(scope $@"{dir}\..\test\ide.zen", .. scope .());

		var lines = text.Split("\n");
		var i = 0;
		for (var line in lines)
		{
			m_Lines.Add(new String(line));
			if (line.Length > m_LongestLine.Length)
			{
				m_LongestLine.Index = i;
				m_LongestLine.Length = line.Length;
			}
			i++;
		}
	}

	public void Update()
	{
		m_FrameCount++;
		// ImGui.SetNextWindowPos(.(0, 0));
		// ImGui.SetNextWindowSize(.(SCREEN_WIDTH, SCREEN_HEIGHT));

		ImGui.PushStyleVar(.WindowPadding, ImGui.Vec2(8, 8));
		defer ImGui.PopStyleVar();

		let font_size = ImGui.GetFontSize();

		if (ImGui.Begin("Code Editor", null, .NoScrollbar))
		{
			let window_pos = ImGui.GetCursorScreenPos();
			let window_size = ImGui.GetContentRegionMax();

			let content_size = ImGui.Vec2(window_size.x, window_size.y);

			/*
			{
				let draw_list = ImGui.GetWindowDrawList();

				draw_list.AddRectFilled(ImGui.GetCursorScreenPos(), ImGui.GetCursorScreenPos() + .(ImGui.GetContentRegionAvail().x, 16), Color.darkGray);
				ImGui.Text("ide.zen");
			}
			*/
			if (ImGui.BeginChild("__mainEditor", .(0, 0), false, .NoScrollbar))
			{
				let draw_list = ImGui.GetWindowDrawList();
				let screen_pos = ImGui.GetCursorScreenPos();

				let draw_pos_screen = screen_pos + .(ImGui.GetScrollX(), ImGui.GetScrollY());
				let draw_pos_screen_max = draw_pos_screen + ImGui.GetContentRegionAvail();

				var max_width_in_pixels = 0.0f;
				let linecount_digits = scope $"{m_Lines.Count}".Length;
				let sidenum_width = ((Math.Max(linecount_digits - 1, 1)) * font_size) + 8;

				var codeRectScrollY = 0.0f;

				ImGui.SetNextWindowPos(screen_pos + .(sidenum_width + 1, 1));
				if (ImGui.BeginChild("__codeRect", .(-sidenum_width - 3, -3), false, .AlwaysHorizontalScrollbar | .AlwaysVerticalScrollbar))
				{
					codeRectScrollY = ImGui.GetScrollY();
					draw_actual_content(sidenum_width, font_size, linecount_digits, out max_width_in_pixels);
				}
				ImGui.EndChild();

				for (let i < m_Lines.Count)
				{
					let str = scope $"{i + 1}";
					str.PadLeft(linecount_digits, ' ');
					draw_list.AddText(.(draw_pos_screen.x, 2 + draw_pos_screen.y + (i * font_size) - codeRectScrollY), Color.lightGray, str);
				}

				draw_list.AddRectFilled(draw_pos_screen_max - .(16, 16), draw_pos_screen_max - .(1, 1), ImGui.GetColorU32(.ScrollbarBg));
				draw_list.AddRect(draw_pos_screen + .(sidenum_width, 0), draw_pos_screen_max - .(1, 1), Color.fanty, 0, .None, 1);
			}
			ImGui.EndChild();
		}
		ImGui.End();
	}

	private void draw_actual_content(float sidenum_width, float font_size, int linecount_digits, out float max_width_in_pixels)
	{
		max_width_in_pixels = 0;

		let content_size = ImGui.GetWindowSize() - .(14, 14);

		let draw_pos_screen = ImGui.GetCursorScreenPos() + .(ImGui.GetScrollX(), ImGui.GetScrollY());
		let draw_pos_screen_max = draw_pos_screen + content_size;

		let draw_list = ImGui.GetWindowDrawList();
		let code_rect = ImGui.Rect(draw_pos_screen, draw_pos_screen_max);

		let text_padding = 6;
		// draw_list.AddRectFilled(code_rect.Min, code_rect.Max, Color("#2d2d31"), 4, .None);

		draw_list.AddRectFilled(draw_pos_screen, draw_pos_screen_max, Color("#2d2d31"), 0, .None);

		float getLineY(int line)
		{
			return (line * font_size) - ImGui.GetScrollY();
		}

		for (let i < m_Lines.Count)
		{
			let line = m_Lines[i];

			if (i == m_LongestLine.Index)
			{
				max_width_in_pixels = ImGui.CalcTextSize(line).x;
			}

			draw_list.AddText(.(draw_pos_screen.x + text_padding - ImGui.GetScrollX(), draw_pos_screen.y + getLineY(i) - (font_size * 0.2f) + text_padding), Color.white, line);
		}

		// makes sure we can scroll
		ImGui.Dummy(.(max_width_in_pixels + (font_size * 4), ((m_Lines.Count - 1) * font_size) + content_size.y ));

		if (ImGui.IsMouseHoveringRect(code_rect.Min, code_rect.Max))
		{
			ImGui.SetMouseCursor(.TextInput);
		}
	}
}