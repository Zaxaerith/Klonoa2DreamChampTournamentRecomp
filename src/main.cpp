#include "runtime.h"

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <shellapi.h>
#endif

int game_launcher_preboot(std::vector<std::string>&, const gbarecomp::RunOptions&);
int game_validate_inputs(std::vector<std::string>&, const gbarecomp::RunOptions&);

namespace {

int run_host(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        if (arg == "--help" || arg == "-h") {
            std::cout << "Klonoa 2: Dream Champ Tournament (USA, AN6E)\n"
                         "Run without arguments for the launcher, or --launcher to reopen it.\n"
                         "Developer CLI: --rom FILE --bios FILE --config FILE --save FILE\n"
                         "               --window | --no-window --frames N\n";
            return 0;
        }
    }

    gbarecomp::RunOptions options{};
    options.builtin_game_name = "Klonoa 2: Dream Champ Tournament";
    options.builtin_rom_sha1 = "35c05676e65fd4c92220861662cd3709342f36e2";
    options.builtin_rom_crc32 = 0x8BD23A7Fu;
    options.freely_resizable_window = false;
    options.expose_assist_tools = false;
    options.launcher_region = "USA";
    options.launcher_game_config = "player.toml";
    options.launcher_expose_widescreen = false;
    options.launcher_expose_adaptive_view = false;
    options.launcher_save_path = "saves/klonoa2_dct_usa.sav";

    std::vector<std::string> args(argv, argv + argc);
    std::error_code error;
    const auto exe = std::filesystem::absolute(argv[0], error);
    const bool player_launch = argc == 1 || (argc == 2 && args[1] == "--launcher");
    if (player_launch) {
        if (!error) std::filesystem::current_path(exe.parent_path(), error);
    }

    if (game_launcher_preboot(args, options)) return 0;
    if (game_validate_inputs(args, options)) return 1;

    bool explicit_config = false;
    for (const auto& arg : args) {
        if (arg == "--config") {
            explicit_config = true;
            break;
        }
    }
    if (!explicit_config) {
        args.emplace_back("--config");
        args.emplace_back((exe.parent_path() / "player.toml").string());
    }
    if (player_launch) {
        args.emplace_back("--save");
        args.emplace_back(options.launcher_save_path);
        args.emplace_back("--window");
    }

    std::vector<char*> native_args;
    native_args.reserve(args.size());
    for (auto& arg : args) native_args.push_back(arg.data());
    return gbarecomp::run_game(static_cast<int>(native_args.size()), native_args.data(), options);
}

}  // namespace

#ifdef _WIN32
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    int argc = 0;
    LPWSTR* argv_w = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (!argv_w) return 1;

    char** argv = static_cast<char**>(HeapAlloc(
        GetProcessHeap(), HEAP_ZERO_MEMORY, sizeof(char*) * (argc + 1)));
    if (!argv) return 1;
    for (int i = 0; i < argc; ++i) {
        int len = WideCharToMultiByte(CP_UTF8, 0, argv_w[i], -1, nullptr, 0, nullptr, nullptr);
        argv[i] = static_cast<char*>(HeapAlloc(GetProcessHeap(), 0, static_cast<SIZE_T>(len)));
        if (!argv[i]) return 1;
        WideCharToMultiByte(CP_UTF8, 0, argv_w[i], -1, argv[i], len, nullptr, nullptr);
    }
    return run_host(argc, argv);
}
#else
int main(int argc, char** argv) {
    return run_host(argc, argv);
}
#endif
