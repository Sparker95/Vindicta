local data = read_file("addons/main/script_version.hpp");

local ver = ""
for k, v in string.gmatch(data, "#define ([A-Z]+) ([0-9]+)") do
    ver = ver .. v .. "."
end

return ver:sub(1, -2);
