#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

bool VERBOSE = false; // Global verbosity flag
const bool USE_GIT_ONLY = false;

// List of project root markers
const std::vector<std::string> ROOT_MARKERS = {
    ".git", ".hg", ".svn", "Makefile", "CMakeLists.txt",
    "pyproject.toml", "Pipfile", "requirements.txt", "setup.py", "setup.cfg",
    "compile_commands.json", "meson.build", "configure.ac", "autogen.sh",
    "pom.xml", "build.gradle", "settings.gradle", ".classpath", ".project",
    "Cargo.toml"};

const std::vector<std::string> GIT_MARKER = {".git"};
const std::vector<std::string>& CHOSEN_ROOT_MARKERS = USE_GIT_ONLY ? GIT_MARKER : ROOT_MARKERS;

fs::path find_project_root(fs::path start_path) {
	if (fs::is_regular_file(start_path)) {
		start_path = start_path.parent_path();
	}

	while (true) {
		for (const auto& marker : CHOSEN_ROOT_MARKERS) {
			if (fs::exists(start_path / marker)) {
				if (VERBOSE) {
					std::cout << "✅ Found project root marker: " << marker << " in " << start_path << std::endl;
				}
				return start_path;
			}
		}

		if (start_path == start_path.root_path()) {
			break;
		}

		start_path = start_path.parent_path();
	}

	if (VERBOSE) {
		std::cerr << "⚠️ No project root found, returning empty path.\n";
	}
	return {};
}

int main(int argc, char* argv[]) {
	fs::path target_path;

	// Check if at least one argument (file path) is provided
	if (argc < 2) {
		target_path = fs::current_path(); // Default to CWD
	} else {
		target_path = argv[1]; // First argument is the file path
	}

	// Check for second argument (`--verbose`)
	if (argc > 2 && std::string(argv[2]) == "--verbose") {
		VERBOSE = true;
	}

	// Validate path
	if (!fs::exists(target_path)) {
		if (VERBOSE) {
			std::cerr << "❌ Error: The provided path does not exist: " << target_path.string() << std::endl;
		}
		return 1;
	}

	// Resolve full path
	target_path = fs::weakly_canonical(target_path);

	if (VERBOSE) {
		std::cout << "🔍 Searching for project root starting from: " << target_path << std::endl;
	}

	fs::path project_root;
	try {
		project_root = find_project_root(target_path);
	} catch (const std::exception& e) {
		if (VERBOSE) {
			std::cerr << "⚠️ Error finding project root: " << e.what() << std::endl;
		}
		return 2;
	}

	if (project_root.empty()) {
		if (VERBOSE) {
			std::cerr << "⚠️ No project root found from: " << target_path << std::endl;
			std::cerr << "  So, using cwd as root path" << std::endl;
		}
		std::cout << fs::current_path().string() << std::endl;
		return 1;
	}

	std::cout << project_root.string() << std::endl; // Always print if found
	return 0;
}
