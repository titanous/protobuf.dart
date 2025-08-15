enum PhoneNumber_PhoneType implements $pb.ProtobufEnum {
  MOBILE(0, _omitEnumNames ? '' : 'MOBILE'),

  HOME(1, _omitEnumNames ? '' : 'HOME'),

  WORK(2, _omitEnumNames ? '' : 'WORK'),

  ;

  static const PhoneNumber_PhoneType BUSINESS = WORK;

  static final $core.Map<$core.int, PhoneNumber_PhoneType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PhoneNumber_PhoneType? valueOf($core.int value) => _byValue[value];

  static PhoneNumber_PhoneType? valueByName($core.String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    switch (name) {
      case 'BUSINESS':
        return WORK;
      default:
        return null;
    }
  }

  static const $core.List<PhoneNumber_PhoneType> valuesWithAliases = <PhoneNumber_PhoneType> [
    MOBILE,
    HOME,
    WORK,
    BUSINESS,
  ];

  @$core.override
  final $core.int value;

  @$core.override
  final $core.String name;

  const PhoneNumber_PhoneType(this.value, this.name);

  /// Returns this enum's [name] or the [value] if names are not represented.
  @$core.override
  $core.String toString() => name == '' ? value.toString() : name;
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
