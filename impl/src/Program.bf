using System;
using GLFW;
using OpenGL;
using ImGui;

namespace ZenIDE;

static
{
	public static ZenIDE.Widgets.CodeEditor s_CodeEditor = new .() ~ delete _;
	public static int SCREEN_WIDTH;
	public static int SCREEN_HEIGHT;
}

class Program
{
	public static void Main(String[] args)
	{
		if (!Glfw.Init())
		{
			Console.WriteLine("Failed to initialize GLFW");
			return;
		}
		else
		{
			int major = 0;
			int minor = 0;
			int rev = 0;
			Glfw.GetVersion(ref major, ref minor, ref rev);

			Console.WriteLine("Initialized GLFW {}.{}.{}", major, minor, rev);
		}
		defer Glfw.Terminate();

		// Set error callback
		Glfw.SetErrorCallback(new (error, description) => Console.WriteLine("Error {}: {}", error, description));

		// Get monitors
		var monitorCount = 0;
		let monitors = Glfw.GetMonitors(ref monitorCount);

		for (let i < monitorCount) {
			String name = scope .();
			Glfw.GetMonitorName(monitors[i], name);

			GlfwVideoMode* videoMode = Glfw.GetVideoMode(monitors[i]);
			Console.WriteLine("Monitor {}: '{}' {}x{}", i, name, videoMode.width, videoMode.height);
		}

		Glfw.WindowHint(.Visible, false);
		Glfw.WindowHint(.ClientApi, Glfw.ClientApi.OpenGlApi);
		Glfw.WindowHint(.ContextVersionMajor, 3);
		Glfw.WindowHint(.ContextVersionMinor, 3);

		let window = Glfw.CreateWindow(1280, 720, "ZenIDE", null, null);
		defer Glfw.DestroyWindow(window);

		Glfw.MakeContextCurrent(window);
		Glfw.SwapInterval(1); // VSync

		GL.Init(=> Glfw.GetProcAddress);

		ImGui.CreateContext();
		defer ImGui.DestroyContext();

		let io = ImGui.GetIO();
		io.ConfigFlags |= .DockingEnable;
		io.Fonts.AddFontFromFileTTF("resources/SourceCodePro-Regular.ttf", 18);

		ImGui.StyleColorsDark();
		ImGui.PushStyleColor(.WindowBg, ZenIDE.GFX.Color("#44444d"));
		/*
		ImGui.PushStyleColor(.ScrollbarBg, ZenIDE.GFX.Color("#44444d"));
		ImGui.PushStyleColor(.ScrollbarGrab, ZenIDE.GFX.Color("#696f75"));
		ImGui.PushStyleColor(.ScrollbarGrabActive, ZenIDE.GFX.Color("#b4b7ba"));
		ImGui.PushStyleColor(.ScrollbarGrabHovered, ZenIDE.GFX.Color("#b4b7ba"));
		*/
		ImGuiImplGlfw.InitForOpenGL(window, true);
		defer ImGuiImplGlfw.Shutdown();

		ImGuiImplOpenGL3.Init("#version 130");
		defer ImGuiImplOpenGL3.Shutdown();

		Glfw.SetKeyCallback(window, new (window, key, scancode, action, mods) => {
			if (key == .Escape && action == .Press) Glfw.SetWindowShouldClose(window, true);
		});
		Glfw.SetWindowSizeCallback(window, new (window, width, height) => {
			draw(window);
		});
		Glfw.SetWindowRefreshCallback(window, new (window) => {
		   draw(window);
		});
		Glfw.SetFramebufferSizeCallback(window, new (window, width, height) => {
			GL.glViewport(0, 0, width, height);
		});
		Glfw.SetWindowPosCallback(window, new (window, x, y) => {
		   draw(window);
		});

		Glfw.ShowWindow(window);

		while (!Glfw.WindowShouldClose(window))
		{
			Glfw.PollEvents();

			draw(window);
		}
	}

	private static void draw(GlfwWindow* window)
	{
		defer
		{
			Glfw.SwapBuffers(window);
			GL.glFinish();
		}

		int display_width = 0, display_height = 0;
		Glfw.GetFramebufferSize(window, ref display_width, ref display_height);
		SCREEN_WIDTH = display_width;
		SCREEN_HEIGHT = display_height;

		ImGuiImplOpenGL3.NewFrame();
		ImGuiImplGlfw.NewFrame();
		ImGui.NewFrame();

		s_CodeEditor.Update();

		ImGui.Render();

		GL.glViewport(0, 0, display_width, display_height);
		GL.glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
		GL.glClear(GL.GL_COLOR_BUFFER_BIT);

		ImGuiImplOpenGL3.RenderDrawData(ImGui.GetDrawData());
	}
}