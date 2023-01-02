-- Add basic screenshot editor frames
hook.Add("ScreenshotEditorInitialize", "ScreenshotEditor_AddBasicFrames", function()
    -- Generic/Unthemed/Miscellaneous
    screenshot_editor.AddFrame({
        FrameName = "None",
        MaterialPath = "chev/frames/none.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Vignette",
        MaterialPath = "chev/frames/vignette.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Action",
        MaterialPath = "chev/frames/action.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Comic Book",
        MaterialPath = "chev/frames/comicbook.png"
    })

    -- Garry's Mod
    screenshot_editor.AddFrame({
        FrameName = "Garry's Mod Logo (White)",
        MaterialPath = "chev/frames/gmod_logo_white.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Garry's Mod Logo (Black)",
        MaterialPath = "chev/frames/gmod_logo_black.png"
    })

    -- Holiday/seasonal
    screenshot_editor.AddFrame({
        FrameName = "Hearts",
        MaterialPath = "chev/frames/hearts.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Season's Greetings",
        MaterialPath = "chev/frames/seasons_greetings.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Icicles",
        MaterialPath = "chev/frames/icicles.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Fire",
        MaterialPath = "chev/frames/fire.png"
    })

    -- Shitposts
    screenshot_editor.AddFrame({
        FrameName = "Epic Fail",
        MaterialPath = "chev/frames/epic_fail.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Quote Bubble",
        MaterialPath = "chev/frames/quote_bubble.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Clickbait",
        MaterialPath = "chev/frames/clickbait.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Soy Point",
        MaterialPath = "chev/frames/soy_point.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Highly Toxic",
        MaterialPath = "chev/frames/highly_toxic.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Tom Scott",
        MaterialPath = "chev/frames/tom_scott.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "Clearly you don't own an air fryer",
        MaterialPath = "chev/frames/air_fryer_demotivator.png"
    })
    screenshot_editor.AddFrame({
        FrameName = "To Be Continued",
        MaterialPath = "chev/frames/to_be_continued.png"
    })
end)
