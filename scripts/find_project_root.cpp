#include <filesystem>
#include <iostream>
#include <vector>

namespace fs = std::filesystem;

// List of project root markers
const std::vector<std::string> ROOT_MARKERS = {
    ".git", ".hg", ".svn", "Makefile", "CMakeLists.txt",

    // Python
    "pyproject.toml", "Pipfile", "requirements.txt", "setup.py", "setup.cfg",

    // C/C++
    "compile_commands.json", "meson.build", "configure.ac", "autogen.sh",

    // Java
    "pom.xml", "build.gradle", "settings.gradle", ".classpath", ".project",

    // Rust
    "Cargo.toml"};

// Function to find the project root
fs::path find_project_root(fs::path start_path) {
	// If the input path is a file, get its containing directory
	if (fs::is_regular_file(start_path)) {
		start_path = start_path.parent_path();
	}

	while (true) {
		// Check if any marker exists in the current directory
		for (const auto& marker : ROOT_MARKERS) {
			if (fs::exists(start_path / marker)) {
				return start_path;
			}
		}

		// If we reach the root directory, stop searching
		if (start_path == start_path.root_path()) {
			break;
		}

		// Move up one directory
		start_path = start_path.parent_path();
	}

	// No project root found, return the input directory
	return {};
}

int main(int argc, char* argv[]) {
	fs::path target_path;

	// If a path is provided as an argument, use it; otherwise, use the current directory
	if (argc > 1) {
		fs::path input_path(argv[1]);
		if (!fs::exists(input_path)) {
			std::cerr << "❌ Error: The provided path does not exist: " << input_path.string() << std::endl;
			return 1;
		}
		target_path = fs::canonical(input_path); // Resolve full path
	} else {
		target_path = fs::current_path();
	}

	fs::path project_root = find_project_root(target_path);
	if (project_root.empty()) {
		return 1;
	}

	std::cout << project_root.string() << std::endl;

	// Create .nvim-session/ inside the project root if it doesn't exist
	fs::path session_dir = project_root / ".nvim-session";
	if (!fs::exists(session_dir)) {
		fs::create_directories(session_dir);
		/* std::cerr << "📂 Created session directory: " << session_dir.string() << std::endl; */
	}

	return 0;
}
