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
		ImGui.SetNextWindowPos(.(0, 0));
		ImGui.SetNextWindowSize(.(SCREEN_WIDTH, SCREEN_HEIGHT));
		ImGui.PushStyleVar(.WindowPadding, ImGui.Vec2(0, 0));
		defer ImGui.PopStyleVar();

		let window_size = ImGui.Vec2(SCREEN_WIDTH, SCREEN_HEIGHT);
		let font_size = ImGui.GetFontSize();

		// ImGui.SetNextWindowContentSize(.(0, content_height_in_lines));

		if (ImGui.Begin("Code Editor", null, .NoMove | .NoResize | .NoCollapse | .NoTitleBar | .NoScrollbar))
		{
			ImGui.SetNextWindowPos(.(8, 8));
			let content_size = ImGui.Vec2(window_size.x - 16, window_size.y - 16);
			if (ImGui.BeginChild("__mainEditor", content_size, false, .NoScrollbar))
			{
				let draw_list = ImGui.GetWindowDrawList();
				let draw_pos_screen = ImGui.GetCursorScreenPos() + .(ImGui.GetScrollX(), ImGui.GetScrollY());

				/*
				let draw_pos = ImGui.GetCursorScreenPos() + .(0, 0);
				let draw_max = ImGui.GetContentRegionMax();
				let draw_pos_screen_max = draw_pos_screen + content_size;
				*/

				var max_width_in_pixels = 0.0f;
				let linecount_digits = scope $"{m_Lines.Count}".Length;
				let sidenum_width = ((Math.Max(linecount_digits - 1, 1)) * font_size) + 8;

				var codeRectScrollY = 0.0f;

				ImGui.SetNextWindowPos(ImGui.GetCursorScreenPos() + .(sidenum_width, 0));
				if (ImGui.BeginChild("__codeRect", .(-sidenum_width, 0), false, .AlwaysHorizontalScrollbar | .AlwaysVerticalScrollbar))
				{
					codeRectScrollY = ImGui.GetScrollY();
					draw_actual_content(sidenum_width, font_size, linecount_digits, out max_width_in_pixels);
				}
				ImGui.EndChild();

				
				for (var i < m_Lines.Count)
				{
					let str = scope $"{i + 1}";
					str.PadLeft(linecount_digits, ' ');
					draw_list.AddText(.(draw_pos_screen.x, draw_pos_screen.y + (i * font_size) - codeRectScrollY), Color.lightGray, str);
				}
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

		draw_list.AddRectFilled(draw_pos_screen, draw_pos_screen_max, Color("#2d2d31"), 6, .None);

		float getLineY(int line)
		{
			return (line * font_size) - ImGui.GetScrollY();
		}

		for (var i < m_Lines.Count)
		{
			let line = m_Lines[i];

			if (i == m_LongestLine.Index)
			{
				max_width_in_pixels = ImGui.CalcTextSize(line).x;
			}

			draw_list.AddText(.(draw_pos_screen.x + text_padding - ImGui.GetScrollX(), draw_pos_screen.y + getLineY(i) - (font_size * 0.2f) + text_padding), Color.white, line);
		}

		// main border
		draw_list.AddRect(code_rect.Min, code_rect.Max, Color.fanty, 0, .None, 1);

		// makes sure we can scroll
		ImGui.Dummy(.(max_width_in_pixels + (font_size * 4), ((m_Lines.Count - 1) * font_size) + content_size.y ));

		if (ImGui.IsMouseHoveringRect(code_rect.Min, code_rect.Max))
		{
			ImGui.SetMouseCursor(.TextInput);
		}
	}
}