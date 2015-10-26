customSchema = class({})

function customSchema:init()

    -- Check the schema_examples folder for different implementations

    -- Flag Example
    -- statCollection:setFlags({version = GetVersion()})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        -- Send custom stats when the game ends
        if state == DOTA_GAMERULES_STATE_POST_GAME then

            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game,players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({game=game, players=players})
            end
        end
    end, nil)
end

-------------------------------------

-- In the statcollection/lib/utilities.lua, you'll find many useful functions to build your schema.
-- You are also encouraged to call your custom mod-specific functions

-- Returns a table with our custom game tracking.
function BuildGameArray()
    local game = {}
    table.insert(game, {
        Total_Time = math.floor(GameRules:GetGameTime()/60),
        Max_Round = GameRules._roundnumber,
        Finished_Game = GameRules._finish
    })

    -- Add game values here as game.someValue = GetSomeGameValue()

    return game
end

-- Returns a table containing data for every player in the game
function BuildPlayersArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)

                table.insert(players, {
                    -- steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),
                    Player_Hero_Name = GetHeroName(playerID),                                             -- name
                    Player_Level = hero:GetLevel(),                                                   -- level
                    Player_NetWorth = GetNetworth(PlayerResource:GetSelectedHeroEntity(playerID)),      -- Networth
                    Player_Team = hero:GetTeam(),                                           -- Hero's team
                    Player_Connection_State = PlayerResource:GetConnectionState(playerID), -- Player connection state
                    Player_Kill = hero:GetKills(),                                         -- Kills
                    Player_Death = hero:GetDeaths(),                                       -- Deaths
                    Player_LH = PlayerResource:GetLastHits(hero:GetPlayerOwnerID()),    -- Last hits
                    Player_Heal = PlayerResource:GetHealing(hero:GetPlayerOwnerID()),       -- Healing
                    Player_Gold_Per_Min = math.floor(PlayerResource:GetGoldPerMin(hero:GetPlayerOwnerID())),        -- GPM
                    item_list = GetItemList(hero)                                           -- Item list

                    -- Example functions for generic stats are defined in statcollection/lib/utilities.lua
                    -- Add player values here as someValue = GetSomePlayerValue(),

                })
            end
        end
    end

    return players
end

-- Prints the custom schema, required to get an schemaID
function PrintSchema( gameArray, playerArray )
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

-- Write 'test_schema' on the console to test your current functions instead of having to end the game
if Convars:GetBool('developer') then
    Convars:RegisterCommand("test_schema", function() PrintSchema(BuildGameArray(),BuildPlayersArray()) end, "Test the custom schema arrays", 0)
end

-------------------------------------

-- If your gamemode is round-based, you can use statCollection:submitRound(bLastRound) at any point of your main game logic code to send a round
-- If you intend to send rounds, make sure your settings.kv has the 'HAS_ROUNDS' set to true. Each round will send the game and player arrays defined earlier
-- The round number is incremented internally, lastRound can be marked to notify that the game ended properly
function customSchema:submitRound(isLastRound)

    local winners = BuildRoundWinnerArray()
    local game = BuildGameArray()
    local players = BuildPlayersArray()

    statCollection:sendCustom({game=game, players=players})

    isLastRound = isLastRound or false --If the function is passed with no parameter, default to false.
    return {winners = winners, lastRound = isLastRound}
end

-- A list of players marking who won this round
function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0 --You'll need to provide your own way of determining which team won the round
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

-------------------------------------
