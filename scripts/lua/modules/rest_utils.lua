--
-- (C) 2020 - ntop.org
--
-- 

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
local json = require ("dkjson")

local rest_utils = {
   consts = {
      success = {
         ok                                         = { http_code = 200, rc = 0, str = "OK" },
         snmp_device_deleted                        = { http_code = 200, rc = 0, str = "SNMP_DEVICE_DELETED_SUCCESSFULLY"},
         snmp_device_added                          = { http_code = 200, rc = 0, str = "SNMP_DEVICE_ADDED_SUCCESSFULLY"},
         snmp_device_edited                         = { http_code = 200, rc = 0, str = "SNMP_DEVICE_EDITED_SUCCESSFULLY"},
         pool_deleted                               = { http_code = 200, rc = 0, str = "POOL_DELETED_SUCCESSFULLY"},
         pool_added                                 = { http_code = 200, rc = 0, str = "POOL_ADDED_SUCCESSFULLY"},
         pool_edited                                = { http_code = 200, rc = 0, str = "POOL_EDITED_SUCCESSFULLY"},
         pool_member_bound                          = { http_code = 200, rc = 0, str = "POOL_MEMBER_BOUND_SUCCESSFULLY"},
      },
      err = {
         not_found                                  = { http_code = 404, rc =  -1, str = "NOT_FOUND"},
         invalid_interface                          = { http_code = 400, rc =  -2, str = "INVALID_INTERFACE"},
         not_granted                                = { http_code = 401, rc =  -3, str = "NOT_GRANTED"},
         invalid_host                               = { http_code = 400, rc =  -4, str = "INVALID_HOST"},
         invalid_args                               = { http_code = 400, rc =  -5, str = "INVALID_ARGUMENTS"},
         internal_error                             = { http_code = 500, rc =  -6, str = "INTERNAL_ERROR"},
         bad_format                                 = { http_code = 400, rc =  -7, str = "BAD_FORMAT"},
         bad_content                                = { http_code = 400, rc =  -8, str = "BAD_CONTENT"},
         resolution_failed                          = { http_code = 400, rc =  -9, str = "NAME_RESOLUTION_FAILED"},
         snmp_device_already_added                  = { http_code = 409, rc = -10, str = "SNMP_DEVICE_ALREADY_ADDED"},
         snmp_device_unreachable                    = { http_code = 400, rc = -11, str = "SNMP_DEVICE_UNREACHABLE"},
         snmp_device_no_device_discovered           = { http_code = 400, rc = -12, str = "NO_SNMP_DEVICE_DISCOVERED"},
         add_pool_failed                            = { http_code = 409, rc = -13, str = "ADD_POOL_FAILED"},
         edit_pool_failed                           = { http_code = 409, rc = -14, str = "EDIT_POOL_FAILED"},
         delete_pool_failed                         = { http_code = 409, rc = -15, str = "DELETE_POOL_FAILED"},
         pool_not_found                             = { http_code = 409, rc = -16, str = "POOL_NOT_FOUND"},
         bind_pool_member_failed                    = { http_code = 409, rc = -17, str = "BIND_POOL_MEMBER_FAILED"},
         bind_pool_member_already_bound             = { http_code = 409, rc = -18, str = "BIND_POOL_MEMBER_ALREADY_BOUND"},
         password_mismatch                          = { http_code = 400, rc = -19, str = "PASSWORD_MISMATCH"},
         add_user_failed                            = { http_code = 409, rc = -20, str = "ADD_USER_FAILED"},
         delete_user_failed                         = { http_code = 409, rc = -21, str = "DELETE_USER_FAILED"},
         snmp_unknown_device                        = { http_code = 400, rc = -22, str = "SNMP_UNKNOWN_DEVICE"},
         user_already_existing                      = { http_code = 409, rc = -23, str = "USER_ALREADY_EXISTING"},
         user_does_not_exist                        = { http_code = 409, rc = -24, str = "USER_DOES_NOT_EXIST"},
         edit_user_failed                           = { http_code = 400, rc = -25, str = "EDIT_USER_FAILED"},
	 snmp_device_interface_status_change_failed = { http_code = 400, rc = -26, str = "SNMP_DEVICE_INTERFACE_STATUS_CHANGE_FAILED"},
      },
   }
}

function rest_utils.rc(ret_const, response)
   local ret_code = ret_const.rc
   local rc_str   = ret_const.str  -- String associated to the return code
   local rc_str_hr -- String associated to the retrun code, human readable

   -- Prepare the human readable string
   rc_str_hr = i18n("rest_consts."..rc_str) or "Unknown"

   local client_rsp = {
      rc = ret_code,
      rc_str = rc_str,
      rc_str_hr = rc_str_hr,
      rsp = response or {}
   }

   return json.encode(client_rsp)
end

function rest_utils.answer(ret_const, response)
   sendHTTPHeader('application/json', nil, nil, ret_const.http_code)
   print(rest_utils.rc(ret_const, response))
end

return rest_utils