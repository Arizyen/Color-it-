local EntitiesData = {}

-- PLAYERS -----------------------------------------------------------------------------------------------------------------------------------
EntitiesData.playersDataLoaded = {} -- dataStoreName, isLoaded (bool value)
EntitiesData.data = {} -- Dictionary {playerUserId = {dataStoreKey = dataStoreValue}}
EntitiesData.sortedData = {} -- Dictionary {dataType = {allTime = {userId = value}, weekly = {userId = value}}}

EntitiesData.topRecords = {}
EntitiesData.top100Names = {}

-- AIs -----------------------------------------------------------------------------------------------------------------------------------

-- MIXED -----------------------------------------------------------------------------------------------------------------------------------

return EntitiesData
