using System;
using ImGui;

namespace ZenIDE.Widgets;

class CodeEditor
{
	private String Text ~ if (_ != null) delete _;

	public void Update()
	{
		ImGui.SetNextWindowPos(.(0, 0));
		ImGui.SetNextWindowSize(.(SCREEN_WIDTH, SCREEN_HEIGHT));
		if (ImGui.Begin("Code Editor", null, .NoMove | .NoResize | .NoCollapse | .NoTitleBar))
		{
			ImGui.Text("Test");
		}
		ImGui.End();
	}
}