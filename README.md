## qb-target


I've been seeing a lot of people struggle in the QBCore community discord, with adding ped and vehicle interaction!
This is a fork from BerkieBBs qb-target containing slight CSS and HTML changes, including snippets that include ped and vehicle interactions [Samuel#0008] 👋 

Everything below this will essentially be a copy and paste from the main berkieBBs github Repo besides of course the functions neccessary for the Shops etc! 👋 👋 

---

qb-target is a targeting solution that allows interaction with any predefined entity, model, entity type or polyzone. While activated you can easily and safely replace markers and distance checking, instead relying on intuitive design to improve player experiences and optimize interaction.

## Credits

* Lots of credits goes to [qtarget](https://github.com/overextended/qtarget) for rewriting all of bt-target to make it more optimized and this resource is pretty much a fork of it.

* Huge credit to [bt-target](https://github.com/brentN5/bt-target) from brentN5 for making the target a thing!

* Credit to [ms-peds](https://github.com/MiddleSkillz/ms-peds) for allowing me to use their awesome ped spawner inside the target!

## Dependency

* [PolyZone](https://github.com/mkafrin/PolyZone)

## Optional Dependency

* [QBCore](https://github.com/qbcore-framework/qb-core)

## Information

This repository was originally a direct fork and now it's own repository as it's basically qtarget but with lots of changes to it to make it better, most of the code comes from qtarget as I find their work awesome on this and what they've achieved with it.

You are free to help through Pull Requests and leave as much suggestions or issues, I love some help!

The TEMPLATES.md and EXAMPLES.md are always being improved and new examples can be made on request, just let me know!

## Features 
- Maintains compatibility with bt-target while providing improved utility and performance
- Optimised and improved raycasting function allows interaction with a wider range of entities
- Add generic options to apply for all players, peds, vehicles, or objects
- Trigger an event, function or command after clicking an option, with the ability to pass any data through
- Define distance on a per-option or overall basis when triggering a target option
- Ability to redefine or remove options, and add new options without replacing old ones
- Update option list when moving towards or away from a target with variable distances on their options
- Support for entity bones, with builtin tables for opening doors
- Support checking for job, gang, citizenid, items, or specific entities
- Utilise the `canInteract` function for advanced checks to show or hide an option based on any trigger
- Ped spawner to spawn peds and assign target options to them all in one place

## Issues and Suggestions
Please use the GitHub issues system to report issues or make suggestions, when making suggestion, please keep `[Suggestion]` in the title to make it clear that it is a suggestion or join the [discord](https://discord.gg/qbcore).

## Extras (Shops)

Add this at the bottom of your qb-shops/client/main.lua and remove the marker function!
--

```RegisterNetEvent('qb-shops:247clerk')
AddEventHandler('qb-shops:247clerk', function(shop, itemData, amount)
        local InRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)

        for shop, _ in pairs(Config.Locations) do
            local position = Config.Locations[shop]["coords"]
            for _, loc in pairs(position) do
                local dist = #(PlayerPos - vector3(loc["x"], loc["y"], loc["z"]))
                if dist < 10 then

                        local ShopItems = {}
                        ShopItems.items = {}
                        QBCore.Functions.TriggerCallback('qb-shops:server:getLicenseStatus', function(result)
                            ShopItems.label = Config.Locations[shop]["label"]
                            if Config.Locations[shop].type == "weapon" then
                                if result then
                                    ShopItems.items = Config.Locations[shop]["products"]
                                else
                                    for i = 1, #Config.Locations[shop]["products"] do
                                        if not Config.Locations[shop]["products"][i].requiresLicense then
                                            table.insert(ShopItems.items, Config.Locations[shop]["products"][i])
                                        end
                                    end
                                end
                            else
                                ShopItems.items = Config.Locations[shop]["products"]
                            end
                            ShopItems.slots = 30
                            TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_"..shop, ShopItems)
                        end)
                    end
                end
            end

        if not InRange then
            Citizen.Wait(5000)
        end
        Citizen.Wait(5)
end)

