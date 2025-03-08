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
	return fs::current_path();
}

int main(int argc, char* argv[]) {
	fs::path target_path;

	// If a path is provided as an argument, use it; otherwise, use the current directory
	if (argc > 1) {
		target_path = fs::canonical(argv[1]); // Resolve full path
	} else {
		target_path = fs::current_path();
	}

	fs::path project_root = find_project_root(target_path);
	std::cout << project_root.string() << std::endl;
	return 0;
}
