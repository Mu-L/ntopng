--
-- (C) 2017-21 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/pools/?.lua;" .. package.path

local pools = require "pools"
local host_pools = require "host_pools"

-- Retrieve the info from the pool
local pool_info = ntop.getDropPoolInfo()
    
local drop_host_pool_utils = {}
local drop_host_pool_id

-- ############################################

function drop_host_pool_utils.check_periodic_hosts_list()
    -- Check the list length
    local list_len = ntop.llenCache(pool_info.list_key)

    if list_len == 0 then
        return
    end     

    -- Retrieve the pool
    local blocked_hosts_pool_id = -2
    -- Get the pool name
    local blocked_hosts_pool_name = pools.DROP_HOST_POOL_NAME
    local host_pool = host_pools:create()
    local all_pools = host_pool:get_all_pools()
    local blocked_hosts_pool_members = {}

    -- Check the existance of the pool   
    for _, value in pairs(all_pools) do
        if value["name"] == blocked_hosts_pool_name then
            blocked_hosts_pool_id = value["id"]
            blocked_hosts_pool_members = value.members
            goto continue
        end
    end

    ::continue::

    -- Check the hosts inside the list
    while list_len > 0 do
        local data = ntop.lpopCache(pool_info.list_key)
        local curr_time = os.time(os.date("!*t"))
        local host
        local time

        host, time = data:match("(%w+)_(%w+)")

        -- The host needs to be unbanned
        if curr_time >= tonumber(time) + pool_info.expiration_time then
            for i, value in pairs(blocked_hosts_pool_members) do
                -- Member found, remove it
                if string.find(value, host) then
                    host_pool:bind_member(value, 0)
                    goto continue_check
                end
            end        
            ::continue_check::
        else
        -- The host needs to be added again at the start of the list (ordered by time)
            ntop.lpushCache(pool_info.list_key, data)
            goto end_check
        end

        list_len = list_len - 1
    end 

    ::end_check::
end 

-- ############################################

return drop_host_pool_utils