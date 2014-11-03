unit SplitGuess;

interface

uses
  Entity, EntityList, TypesConsts;

type
  TSplitGuess = class(TEntity)
  private
    FSplitStatus: Boolean;
    FMatchPos: string;
    FSplits: TEntityList;
    FSentence: string;
    FPos: string;
    FMatchScore: Double;
    FMatchId: TId;
    FMatchText: string;
  published
    property Sentence: string read FSentence write FSentence;
    property Pos: string read FPos write FPos;

    property MatchText: string read FMatchText write FMatchText;
    property MatchId: TId read FMatchId write FMatchId;
    property MatchPos: string read FMatchPos write FMatchPos;
    property MatchScore: Double read FMatchScore write FMatchScore;
    property SplitStatus: Boolean read FSplitStatus write FSplitStatus;
    property Splits: TEntityList read FSplits write FSplits;
  end;

implementation

end.