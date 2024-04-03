add_rules("mode.debug", "mode.release")

option("utf", {showmenu = true,  default = "8"})

local modules = {
    juce_analytics = {},
    juce_audio_basics = {
        syslinks = {
            iphoneos = {"Accelerate"},
            macosx = {"Accelerate"},
        },
    },
    juce_audio_devices = {
        syslinks = {
            iphoneos = {"CoreAudio", "CoreMIDI", "AudioToolbox"},
            macosx = {"CoreAudio", "CoreMIDI", "AudioToolbox", "AVFoundation"},
            linux = {"alsa"},
            mingw = {"winmm"}
        }
    },
    juce_audio_formats = {
        syslinks = {
            iphoneos = {"AudioToolbox", "QuartzCore"},
            macosx = {"CoreAudio", "CoreMIDI", "QuartzCore", "AudioToolbox"},
        }
    },
    juce_audio_plugin_client = {},
    juce_audio_processors = {
        syslinks = {
            iphoneos = {"AudioToolbox"},
            macosx = {"CoreAudio", "CoreMIDI", "AudioToolbox"},
        },
    },
    juce_audio_utils = {
        syslinks = {
            iphoneos = {"CoreAudioKit"},
            macosx = {"CoreAudioKit", "DiscRecording"},
        },
    },
    juce_box2d = {},
    juce_core = {
        syslinks = {
            windows = {"kernel32", "user32", "shell32", "gdi32", "vfw32", "comdlg32", "winmm", "wininet", "rpcrt4", "ole32", "advapi32", "ws2_32", "Version", "Imm32", "Shlwapi"},
            linux = {"rt", "dl", "pthread"},
            macosx = {"Cocoa", "Foundation", "IOKit", "Security"},
            iphoneos = {"Foundation"},
            mingw = {"uuid", "wsock32", "wininet", "version", "ole32", "ws2_32", "oleaut32", "imm32", "comdlg32", "shlwapi", "rpcrt4", "winmm"}
        },
        flags = {
            macosx = {"objective-c++"},
            iphoneos = {"objective-c++"}
        },
        packages = {
            "libcurl"
        }
    },
    juce_cryptography = {},
    juce_data_structures = {},
    juce_dsp = {
        syslinks = {
            iphoneos = {"Accelerate"},
            macosx = {"Accelerate"},
        },
    },
    juce_events = {},
    juce_graphics = {
        syslinks = {
            iphoneos = {"CoreGraphics", "CoreImage", "CoreText", "QuartzCore"},
            macosx = {"Cocoa", "QuartzCore"},
            linux = {"freetype2"}
        },
    },
    juce_gui_basics = {
        syslinks = {
            iphoneos = {"CoreServices", "UIKit", "Metal", "MetalKit"},
            macosx = {"Cocoa", "QuartzCore", "Metal", "MetalKit"},
            linux = {"freetype2"},
            mingw = {"dxgi"}
        },
    },
    juce_gui_extra = {
        syslinks = {
            iphoneos = {"WebKit", "UserNotifications"},
            macosx = {"WebKit", "UserNotifications"},
        },
    },
    juce_midi_ci = {},
    juce_opengl = {
        syslinks = {
            iphoneos = {"OpenGLES"},
            macosx = {"OpenGL"},
            linux = {"hl"},
            mingw = {"opengl32"}
        },
    },
    juce_osc = {},
    juce_product_unlocking = {},
    juce_video = {
        syslinks = {
            iphoneos = {"AVKit", "AVFoundation", "CoreMedia"},
            macosx = {"AVKit", "AVFoundation", "CoreMedia"},
        },
    }
}

for modulename, config in pairs(modules) do
    option(modulename, {showmenu = true,  default = false})
    if config.packages then
        for _, package in ipairs(config.packages) do
            add_requires(package)
        end
    end
end

target("juce")
    set_kind("$(kind)")
    set_languages("cxx17")
    add_defines("JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED", {public = true})

    if has_config("utf") then
        add_defines("JUCE_STRING_UTF_TYPE=" .. get_config("utf") , {public = true})
    else
        add_defines("JUCE_STRING_UTF_TYPE=8", {public = true})
    end

    if is_kind("shared") then
        add_defines("JUCE_DLL_BUILD")
    end

    if is_mode('debug') then
        set_symbols('debug')
    end

    for module, options in pairs(modules) do
        if has_config(module) then
            if is_plat("macosx") or is_plat("iphoneos") then
                add_files("modules/" .. module .. "/" .. module .. ".mm")
            else
                add_files("modules/" .. module .. "/" .. module .. ".cpp")
            end
            add_includedirs("modules/", { public = true })
            add_headerfiles("modules/(" .. module .. "/" .. module .. ".h)")

            for _, dir in ipairs(os.dirs("modules/" .. module .. "/**")) do
                add_includedirs(dir, { public = true })
            end

            for _, dir in ipairs(os.files("modules/" .. module .. "/**.h")) do
                dir = dir:gsub("\\", "/"):gsub("modules/", "")
                add_headerfiles("modules/(" .. dir .. ")")
            end

            if options.syslinks and options.syslinks[os.host()] then
                for _, syslinks in ipairs(options.syslinks[os.host()]) do
                    add_syslinks(syslinks)
                end
            end

            if options.flags and options.flags[os.host()] then
                for _, flags in ipairs(options.flags[os.host()]) do
                    add_cxxflags(flags)
                end
            end

            if options.packages then
                for _, package in ipairs(options.packages) do
                    add_packages(package)
                end
            end
        end
    end
