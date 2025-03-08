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
fs::path find_project_root(fs::path start_dir) {
	while (true) {
		// Check if any marker exists in the current directory
		for (const auto& marker : ROOT_MARKERS) {
			if (fs::exists(start_dir / marker)) {
				return start_dir;
			}
		}

		// If we reach the root directory, stop searching
		if (start_dir == start_dir.root_path()) {
			break;
		}

		// Move up one directory
		start_dir = start_dir.parent_path();
	}

	// No project root found, return current directory
	return fs::current_path();
}

int main() {
	fs::path project_root = find_project_root(fs::current_path());
	std::cout << project_root.string() << std::endl;
	return 0;
}
