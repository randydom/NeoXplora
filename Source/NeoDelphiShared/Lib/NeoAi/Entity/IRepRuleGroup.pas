unit IRepRuleGroup;

interface

uses
  BaseRuleGroup;

type
  TIRepRuleGroup = class(TBaseRuleGroup)
  published
    property ConjunctionType;
    property Id;
    property Members;
    property Order;
    property ParentId;
    property RuleId;
  end;

implementation

uses
  AppConsts;

initialization
  TIRepRuleGroup.RegisterEntityClassWithMappingToTable(ConstNeoPrefix + 'ireprulegroup');

end.