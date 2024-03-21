namespace ImGui;

extension ImGui
{
	extension Vec2
	{
		/// Adds two vectors.
		public static Self operator +(Self a, Self b) { return Self(a.x + b.x, a.y + b.y); }
		/// Subtracts two vectors.
		public static Self operator -(Self a, Self b) { return Self(a.x - b.x, a.y - b.y); }
		/// Mulitplies two vectors.
		public static Self operator *(Self a, Self b) { return Self(a.x * b.x, a.y * b.y); }
		/// Divides two vectors.
		public static Self operator /(Self a, Self b) { return Self(a.x / b.x, a.y / b.y); }
		/// Negates a vector.
		public static Self operator -(Self a) { return Self(-a.x, -a.y); }
		/// Adds a vector by a number.
		public static Self operator +(Self a, float d) { return Self(a.x + d, a.y + d); }
		public static Self operator +(float a, Self d) { return Self(a + d.x, a + d.y); }
		/// Subtracts a vector by a number.
		public static Self operator -(Self a, float d) { return Self(a.x - d, a.y - d); }
		public static Self operator -(float a, Self d) { return Self(a - d.x, a - d.y); }
		/// Multiplies a vector by a number.
		public static Self operator *(Self a, float d) { return Self(a.x * d, a.y * d); }
		public static Self operator *(float a, Self d) { return Self(a * d.x, a * d.y); }
		/// Divides a vector by a number.
		public static Self operator /(Self a, float d) { return Self(a.x / d, a.y / d); }
		public static Self operator /(float a, Self d) { return Self(a / d.x, a / d.y); }
	}
}