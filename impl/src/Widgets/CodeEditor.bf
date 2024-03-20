using System;
using ImGui;

namespace ZenIDE.Widgets;

class CodeEditor
{
	private String Text ~ if (_ != null) delete _;

	private int m_FrameCount;

	public void Update()
	{
		m_FrameCount++;
		ImGui.SetNextWindowPos(.(0, 0));
		ImGui.SetNextWindowSize(.(SCREEN_WIDTH, SCREEN_HEIGHT));
		if (ImGui.Begin("Code Editor", null, .NoMove | .NoResize | .NoCollapse | .NoTitleBar))
		{
			ImGui.Text(scope $"{m_FrameCount}");
		}
		ImGui.End();
	}
}