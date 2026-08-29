local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local VirtualInputManager = game:GetService("VirtualInputManager")

local BuyEvent = GameEvents:WaitForChild("BuyEventShopStock")
local RefreshFunction = GameEvents:WaitForChild("HarvestMoonIndexService"):WaitForChild("RefreshIndex")

local TARGET_ITEMS = {
    "Night",
    "Night Egg",
    "Moon Cat",
    "Night Seed Pack",
    "Celestiberry Seed",
    "Moon Mango Seed",
    "Blood Banana Seed",
    "Moon Melon Seed",
    "Springtide Egg"
}

local SHOPS = {
    "Blood Moon Shop",
    "Twilight Shop",
    "Easter Event Shop"
}

local DELAY_AFTER_RESTOCK = 2.5
local DELAY_BETWEEN_BUYS = 0.6
local DELAY_BETWEEN_CYCLES = 5
local ANTI_AFK_INTERVAL = 60

local function antiAFK()
    while true do
        task.wait(ANTI_AFK_INTERVAL)
        VirtualInputManager:SendMouseMoveEvent(1, 0, false)
        task.wait(0.1)
        VirtualInputManager:SendMouseMoveEvent(-1, 0, false)
    end
end

task.spawn(antiAFK)

print("Auto-Buy Started!")

while true do
    local restockSuccess, err = pcall(function()
        return RefreshFunction:InvokeServer()
    end)

    if restockSuccess then
        print("[Restock] Success")
    else
        warn("[Restock] Failed: ", err)
    end

    task.wait(DELAY_AFTER_RESTOCK)

    local itemCounts = {}
    for _, item in ipairs(TARGET_ITEMS) do
        itemCounts[item] = 0
    end

    for _, shopName in ipairs(SHOPS) do
        for _, itemName in ipairs(TARGET_ITEMS) do
            local buySuccess, err = pcall(function()
                BuyEvent:FireServer(itemName, shopName)
            end)

            if buySuccess then
                print(string.format("[Buy] %s from %s", itemName, shopName))
                itemCounts[itemName] = itemCounts[itemName] + 1
            end

            task.wait(DELAY_BETWEEN_BUYS)
        end
    end

    print("----- Cycle Summary -----")
    for _, item in ipairs(TARGET_ITEMS) do
        print(string.format("%s : %d", item, itemCounts[item]))
    end
    print("--------------------------")

    task.wait(DELAY_BETWEEN_CYCLES)
end