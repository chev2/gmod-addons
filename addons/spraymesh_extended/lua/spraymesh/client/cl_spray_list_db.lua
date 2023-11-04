--
-- This code is responsible for managing the player's saved spray list.
--

spraylist = spraylist or {}

if not sql.TableExists("spraymesh_extended_spray_list") then
    spraymesh.DebugPrint("Creating sqlite table spraymesh_extended_spray_list")

    sql.Query([[
        CREATE TABLE spraymesh_extended_spray_list (
        "url" VARCHAR(512),
        "name" VARCHAR(64),
        PRIMARY KEY("url")
    )]])
end

function spraylist.AddSpray(url, name)
    if #url > 512 then
        error("The provided URL is too long! (>512 characters)")
    end

    if #name > 64 then
        name = string.sub(name, 1, 64)
    end

    local queryFmt = Format(
        "REPLACE INTO spraymesh_extended_spray_list (url, name) VALUES (%s, %s)",
        sql.SQLStr(url),
        sql.SQLStr(name)
    )

    sql.Query(queryFmt)
end

function spraylist.RemoveSpray(url)
    local queryFmt = Format(
        "DELETE FROM spraymesh_extended_spray_list WHERE url = %s",
        sql.SQLStr(url)
    )

    sql.Query(queryFmt)
end

function spraylist.GetSprays()
    local queryResults = sql.Query("SELECT url, name FROM spraymesh_extended_spray_list ORDER BY name DESC")

    return queryResults
end
