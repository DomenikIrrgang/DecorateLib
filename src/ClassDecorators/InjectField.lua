function InjectField(class, field_name, injectable)
    class.MetaData.Fields[field_name] = injectable
    return class
end