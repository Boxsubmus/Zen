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

		let window_size = ImGui.Vec2(SCREEN_WIDTH, SCREEN_HEIGHT);
		let content_height_in_lines = window_size.y;
		let font_size = ImGui.GetFontSize();

		// ImGui.SetNextWindowContentSize(.(0, content_height_in_lines));

		if (ImGui.Begin("Code Editor", null, .NoMove | .NoResize | .NoCollapse | .NoTitleBar | .HorizontalScrollbar | .AlwaysVerticalScrollbar))
		{
			let draw_list = ImGui.GetWindowDrawList();
			let draw_pos = ImGui.GetCursorScreenPos();

			var max_width_in_pixels = 0.0f;
			let sidenum_width = (scope $"{m_Lines.Count}".Length * font_size);

			for (var i < m_Lines.Count)
			{
				let line = m_Lines[i];
				let y = i * font_size;

				if (i == m_LongestLine.Index)
				{
					max_width_in_pixels = ImGui.CalcTextSize(line).x;
				}

				draw_list.AddText(.(draw_pos.x + sidenum_width, draw_pos.y + y), Color.white, line);

				// side number thing
				draw_list.AddText(.(draw_pos.x, draw_pos.y + y), Color.gray, scope $"{i + 1}");
			}

			// makes sure we can scroll
			ImGui.Dummy(.(max_width_in_pixels + sidenum_width, (content_height_in_lines - 10) + ((m_Lines.Count - 1) * font_size)));
		}
		ImGui.End();
	}
}