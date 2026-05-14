-- This is a debug plugin, remove the following if block to enable it
-- if true then
--     return { disabled = true, }
-- end

local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Event = require("ui/event")
local _ = require("gettext")

local const GLOSS_NOTE = "__gloss__"

local Gloss = WidgetContainer:extend{
    name = "gloss",
    is_doc_only = false,
}

function Gloss:onDispatcherRegisterActions()
    Dispatcher:registerAction("helloworld_action", {category="none", event="HelloWorld", title=_("Hello World"), general=true,})
end

function Gloss:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Gloss:addToMainMenu(menu_items)
    menu_items.hello_world = {
        text = _("Hello World"),
        -- in which menu this should be appended
        sorting_hint = "more_tools",
        -- a callback when tapping
        callback = function()
            UIManager:show(InfoMessage:new{
                text = _("Hello, plugin world"),
            })
        end,
    }
end

function Gloss:onHelloWorld()
    local popup = InfoMessage:new{
        text = _("Hello World"),
    }
    UIManager:show(popup)
end

function Gloss:onPageUpdate(pageno)
    self:deleteAllHighlights()

    -- pattern, origin, direction, case_insensitive, page (does nothing for EPUB), regex, max_hits
    local results = self.ui.document:findText("pour", 0, 0, true, 0, false, 1)
    self.ui.document:clearSelection() -- clear crengine's native selection highlight

    local result = results[1]

    self.ui.annotation:addItem({
        datetime = os.date("%Y-%m-%d %H:%M:%S"),
        page     = result.start,
        pos0     = result.start,
        pos1     = result["end"],
        drawer   = "underscore",
        color    = "black",
        note     = GLOSS_NOTE,
    })
    self.ui:handleEvent(Event:new("AnnotationsModified", { nb_highlights_added = 1 }))

    self.ui.annotation.removeItem()
end

function Gloss:deleteAllHighlights()
    local annotations = self.ui.annotation.annotations
    for i = #annotations, 1, -1 do
        self.ui.highlight:deleteHighlight(i)
    end
end

return Gloss
