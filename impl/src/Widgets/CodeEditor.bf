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
		let content_height_in_lines = window_size.y;
		let font_size = ImGui.GetFontSize();

		// ImGui.SetNextWindowContentSize(.(0, content_height_in_lines));

		if (ImGui.Begin("Code Editor", null, .NoMove | .NoResize | .NoCollapse | .NoTitleBar | .HorizontalScrollbar | .AlwaysVerticalScrollbar))
		{
			let draw_list = ImGui.GetWindowDrawList();
			let draw_pos = ImGui.GetCursorScreenPos() + .(8, 8);
			let draw_max = ImGui.GetContentRegionAvail() - 1;

			var max_width_in_pixels = 0.0f;
			let sidenum_width = ((scope $"{m_Lines.Count}".Length - 1) * font_size) + font_size;

			//draw_list.AddRectFilled(.(draw_pos.x, draw_pos.y), .(draw_pos.x + sidenum_width, draw_max.y + ImGui.GetScrollY() - 16), Color.black);
			let code_rect = ImGui.Rect(.(draw_pos.x + sidenum_width, draw_pos.y), .(draw_max.x - 8, draw_pos.y + (m_Lines.Count * font_size) + 6));
			draw_list.AddRectFilled(code_rect.Min, code_rect.Max, Color("#2d2d31"), 4, .None);
			draw_list.AddRect(code_rect.Min, code_rect.Max, Color.fanty, 4, .None, 1);

			for (var i < m_Lines.Count)
			{
				let line = m_Lines[i];
				let y = i * font_size;

				if (i == m_LongestLine.Index)
				{
					max_width_in_pixels = ImGui.CalcTextSize(line).x;
				}

				draw_list.PushClipRect(.(sidenum_width - ImGui.GetScrollX(), code_rect.Min.y - ImGui.GetScrollY()), code_rect.Max + .(0, ImGui.GetScrollY()));

				draw_list.AddText(.(draw_pos.x + sidenum_width + 4, draw_pos.y + y), Color.white, line);

				draw_list.PopClipRect();

				// side number thing
				draw_list.AddText(.(draw_pos.x, draw_pos.y + y), Color.gray, scope $"{i + 1}");
			}

			// makes sure we can scroll
			ImGui.Dummy(.(max_width_in_pixels + sidenum_width + 24, (content_height_in_lines - 10) + ((m_Lines.Count) * font_size)));

			if (ImGui.IsMouseHoveringRect(code_rect.Min, code_rect.Max))
			{
				ImGui.SetMouseCursor(.TextInput);
			}
		}
		ImGui.End();
	}
}