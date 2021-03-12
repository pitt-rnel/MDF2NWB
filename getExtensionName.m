function extName = getExtensionName(name)

if endsWith(name, 'Extension')
    extName = [upper(name(1)) name(2:end)];
else
    extName = [upper(name(1)) name(2:end) 'Extension'];
end
