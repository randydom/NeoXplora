unit SentenceAlgorithm;

interface

uses
  Classes, SysUtils, SentenceListElement, HyperNym, TypesConsts;

type
  TSentenceAlgorithm = class
  private
    type
      TAlignMatchFunction = function(AnIndex1, AnIndex2: Integer): Double of object;
    const
      ConstWeightMatchMax = 2;
      ConstWeightMisMatch = -1;
      ConstWeightGap = -1;
  private
    FElement1: TSentenceListElement;
    FElement2: TSentenceListElement;
    FAlignMatchFunction: TAlignMatchFunction;
    FAlignInList: TStringList;
    FAlignOutList: TStringList;
    FComparisonLog: TStringList;
    FPosAddScore: Integer;
    FHypernym: THypernym;

    // compare methods used in the Smith Waterman algorithm
    function CheckTextMatch(AnIndex1, AnIndex2: Integer): Double;
    function CheckPosMatch(AnIndex1, AnIndex2: Integer): Double;
    function CheckHybridPosMatch(AnIndex1, AnIndex2: Integer): Double;
    function CheckHybridSemMatch(AnIndex1, AnIndex2: Integer): Double;
  public
    // for testing purposes, these should be private
    function GetAdjustedRep(const ARep: string): string;
    function RunSmithWaterman: Double;

    function TestRunTextMatch: Double;
    function TestRunPosMatch: Double;
    function TestRunHybridPosMatch: Double;

    property AlignInList: TStringList read FAlignInList;
    property AlignOutList: TStringList read FAlignOutList;
    property ComparisonLog: TStringList read FComparisonLog;
  public
    constructor Create;
    destructor Destroy; override;

    function DoRunHybridSemMatch: Double;

    procedure RunTextMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess, ASemRepGuess, AMatchSentence: string);
    procedure RunPosMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess, ASemRepGuess, AMatchSentence: string);
    procedure RunHybridPosMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess, ASemRepGuess, AMatchSentence: string);
    procedure RunHybridSemMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess, ASemRepGuess, AMatchSentence: string);
    procedure RunCurrentMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess, ASemRepGuess, AMatchSentence: string);

    property Element1: TSentenceListElement read FElement1 write FElement1;
    property Element2: TSentenceListElement read FElement2 write FElement2;
  end;

implementation

uses
  Math, AppConsts;

{ TSentenceAlgorithm }

function TSentenceAlgorithm.CheckTextMatch(AnIndex1, AnIndex2: Integer): Double;
begin
  if Element1.SentenceWords[AnIndex1] = Element2.SentenceWords[AnIndex2] then
    Result := ConstWeightMatchMax
  else
    Result := ConstWeightMisMatch;
end;

function TSentenceAlgorithm.CheckPosMatch(AnIndex1, AnIndex2: Integer): Double;
var
  TheWord1, TheWord2: string;
  TheMinLength, TheMaxLength: Integer;
  I: Integer;
begin
  Result := ConstWeightMisMatch;
  TheWord1 := Element1.PosWords[AnIndex1];
  TheWord2 := Element2.PosWords[AnIndex2];
  if TheWord1[1] <> TheWord2[1] then
    Exit;
  TheMinLength := Min(Length(TheWord1), Length(TheWord2));
  TheMaxLength := Max(Length(TheWord1), Length(TheWord2));
  for I := 1 to TheMinLength do
    if TheWord1[I] <> TheWord2[I] then
    begin
      Result := FPosAddScore + (I - 1) / TheMaxLength;
      Exit;
    end;
  Result := FPosAddScore + TheMinLength / TheMaxLength;
end;

function TSentenceAlgorithm.CheckHybridPosMatch(AnIndex1, AnIndex2: Integer): Double;
begin
  Result := CheckTextMatch(AnIndex1, AnIndex2);
  if Result <> ConstWeightMisMatch then
    Exit;
  Result := CheckPosMatch(AnIndex1, AnIndex2);
  if Result = ConstWeightMisMatch then
    Exit;
  Result := 1 + 0.4 * Result;
end;

function TSentenceAlgorithm.CheckHybridSemMatch(AnIndex1, AnIndex2: Integer): Double;
begin
  Result := CheckTextMatch(AnIndex1, AnIndex2);
  if Result <> ConstWeightMisMatch then
    Exit;
  Result := FHypernym.GetSimilarityScore(Element1.SentenceWords[AnIndex1], Element2.SentenceWords[AnIndex2]);
  if Result <> 0 then
    Result := 1.4 + 0.4 * 1 / Result
  else begin
    Result := CheckPosMatch(AnIndex1, AnIndex2);
    if Result <> ConstWeightMisMatch then
      Result := 1 + 0.4 * Result;
  end;
end;

function TSentenceAlgorithm.RunSmithWaterman: Double;
type
  TDirection = (diNone, diUp, diLeft, diDiagonal);
var
  TheMaxI, TheMaxJ: Integer;
  TheMaxScore: Double;
  TheDiagonalScore: Double;
  TheLeftScore: Double;
  TheUpScore: Double;
  TheScore: array [0 .. 100, 0 .. 100] of Double;
  TheDirection: array [0 .. 100, 0 .. 100] of TDirection;
  TheCountX, TheCountY: Integer;
  TheCheckI, TheCheckJ: Boolean;
  TheMatchScore: Double;
  I, J: Integer;
begin
  // clear the results
  FAlignInList.Clear;
  FAlignOutList.Clear;
  FComparisonLog.Clear;

  TheCountX := Element1.SentenceWords.Count + 4;
  TheCountY := Element2.SentenceWords.Count + 4;
  if TheCountX > 100 then
    TheCountX := 100;
  if TheCountY > 100 then
    TheCountY := 100;

  for I := 0 to TheCountX do
    for J := 0 to TheCountY do
    begin
      TheScore[I, J] := 0;
      TheDirection[I, J] := diNone;
    end;

  TheMaxI := 0;
  TheMaxJ := 0;
  TheMaxScore := 0;

  // Logic to construct the matrix and find maximum edit distance
  for I := 1 to TheCountX do
  begin
    for J := 1 to TheCountY do
    begin
      TheCheckI := (I < 3) or (I > TheCountX - 2);
      TheCheckJ := (J < 3) or (J > TheCountY - 2);
      if TheCheckI and TheCheckJ then
        TheDiagonalScore := TheScore[I - 1, J - 1] + ConstWeightMatchMax
      else if TheCheckI xor TheCheckJ then
        TheDiagonalScore := TheScore[I - 1, J - 1] + ConstWeightMisMatch
      else begin
        TheMatchScore := FAlignMatchFunction(I - 3, J - 3);
        TheDiagonalScore := TheScore[I - 1, J - 1] + TheMatchScore;

        FComparisonLog.Add(Format('%2.2f %s(%2d) %s(%2d)', [
        TheMatchScore, Element1.SentenceWords[I - 3], I - 3, Element2.SentenceWords[J - 3], J - 3
        ]));

      end;
      TheLeftScore := TheScore[I, J - 1] + ConstWeightGap;
      TheUpScore := TheScore[I - 1, J] + ConstWeightGap;

      // case 1 - all scores are negative, select 0
      if (TheDiagonalScore <= 0) and (TheLeftScore <= 0) and (TheUpScore <= 0) then
      begin
        TheScore[I, J] := 0;
        TheDirection[I, J] := diNone;
        Continue;
      end;

      if TheDiagonalScore >= TheUpScore then
        if TheDiagonalScore >= TheLeftScore then
        begin
          TheScore[I, J] := TheDiagonalScore;
          TheDirection[I, J] := diDiagonal;
        end else begin
          TheScore[I, J] := TheLeftScore;
          TheDirection[I, J] := diLeft;
        end
      else
        if TheUpScore >= TheLeftScore then
        begin
          TheScore[I, J] := TheUpScore;
          TheDirection[I, J] := diUp;
        end else begin
          TheScore[I, J] := TheLeftScore;
          TheDirection[I, J] := diLeft;
        end;

      if TheScore[I, J] > TheMaxScore then
      begin
        TheMaxI := I;
        TheMaxJ := J;
        TheMaxScore := TheScore[I, J];
      end;
    end; // J

  end;

  if Element2.SentenceWords.Count = 0 then
    Result := 0
  else
    Result := TheMaxScore / (Max(TheCountX, TheCountY) * ConstWeightMatchMax);

  // Trace-back
  while (TheMaxI > 0) and (TheMaxJ > 0) do
  begin
    case TheDirection[TheMaxI, TheMaxJ] of
      diUp: begin
        if (TheMaxI >= 3) and (TheMaxI <= TheCountX - 2) then
        begin
          FAlignInList.Insert(0, Element1.SentenceWords[TheMaxI - 3]);
          FAlignOutList.Insert(0, '-');
        end;
        Dec(TheMaxI);
      end;
      diLeft: begin
        if (TheMaxJ >= 3) and (TheMaxJ <= TheCountY - 2) then
        begin
          FAlignInList.Insert(0, '-');
          FAlignOutList.Insert(0, Element2.SentenceWords[TheMaxJ - 3]);
        end;
        Dec(TheMaxJ);
      end;
      diDiagonal: begin
        if (TheMaxI >= 3) and (TheMaxJ >= 3) and (TheMaxI <= TheCountX - 2) and (TheMaxJ <= TheCountY - 2) then
        begin
          FAlignInList.Insert(0, Element1.SentenceWords[TheMaxI - 3]);
          FAlignOutList.Insert(0, Element2.SentenceWords[TheMaxJ - 3]);
        end;
        Dec(TheMaxI);
        Dec(TheMaxJ);
      end;
      diNone:
        Exit;
    end;
  end; // while
end;

function TSentenceAlgorithm.TestRunTextMatch: Double;
begin
  FAlignMatchFunction := CheckTextMatch;
  Result := RunSmithWaterman;
end;

function TSentenceAlgorithm.TestRunPosMatch: Double;
begin
  FAlignMatchFunction := CheckPosMatch;
  FPosAddScore := 1;
  Result := RunSmithWaterman;
end;

function TSentenceAlgorithm.TestRunHybridPosMatch: Double;
begin
  FAlignMatchFunction := CheckHybridPosMatch;
  FPosAddScore := 0;
  Result := RunSmithWaterman;
end;

function TSentenceAlgorithm.DoRunHybridSemMatch: Double;
begin
  FAlignMatchFunction := CheckHybridSemMatch;
  FPosAddScore := 0;
  Result := RunSmithWaterman;
end;

function TSentenceAlgorithm.GetAdjustedRep(const ARep: string): string;
var
  TheListIndex: Integer;
  TheWordIndex: Integer;
  TheWord: string;
begin
  Result := '';
  TheWordIndex := 1;
  while TheWordIndex <= Length(ARep) do
  begin
    // find the word start
    while TheWordIndex <= Length(ARep) do
    begin
      if not CharInSet(ARep[TheWordIndex], ConstSplitChars) then
        Break;
      Result := Result + ARep[TheWordIndex];
      Inc(TheWordIndex);
    end;
    if TheWordIndex > Length(ARep) then
      Exit;

    // read the word
    TheWord := '';
    while TheWordIndex <= Length(ARep) do
    begin
      if CharInSet(ARep[TheWordIndex], ConstSplitChars) then
        Break;
      TheWord := TheWord + ARep[TheWordIndex];
      Inc(TheWordIndex);
    end;

    // replace the word if found
    TheListIndex := FAlignOutList.IndexOf(TheWord);
    if (TheListIndex <> -1) and (FAlignInList[TheListIndex] <> '-') then
      Result := Result + FAlignInList[TheListIndex]
    else
      Result := Result + TheWord;
  end;
end;

constructor TSentenceAlgorithm.Create;
begin
  FAlignOutList := TStringList.Create;
  FAlignInList := TStringList.Create;
  FComparisonLog := TStringList.Create;
  FHyperNym := THyperNym.Create;
end;

destructor TSentenceAlgorithm.Destroy;
begin
  FHyperNym.Free;
  FAlignOutList.Free;
  FAlignInList.Free;
  FComparisonLog.Free;
  inherited Destroy;
end;

procedure TSentenceAlgorithm.RunCurrentMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess,
  ASemRepGuess, AMatchSentence: string);
var
  TheNewScore: Double;
begin
  if (Element2 = nil) or (not (Element1.Valid and Element2.Valid)) then
   Exit;
  TheNewScore := RunSmithWaterman;
  if TheNewScore <= ACurrentBestScore then
    Exit;
  AMatchSentence := Element2.Sentence;
  ARepGuess := GetAdjustedRep(Element2.Representation);
  ASemRepGuess := GetAdjustedRep(Element2.SemRep);
  ACurrentBestScore := TheNewScore;
  AnId := Element2.Id;
end;

procedure TSentenceAlgorithm.RunTextMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess,
  ASemRepGuess, AMatchSentence: string);
begin
  FAlignMatchFunction := CheckTextMatch;
  RunCurrentMatch(ACurrentBestScore, AnId, ARepGuess, ASemRepGuess, AMatchSentence);
end;

procedure TSentenceAlgorithm.RunPosMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess,
  ASemRepGuess, AMatchSentence: string);
begin
  FAlignMatchFunction := CheckPosMatch;
  RunCurrentMatch(ACurrentBestScore, AnId, ARepGuess, ASemRepGuess, AMatchSentence);
end;

procedure TSentenceAlgorithm.RunHybridPosMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess,
  ASemRepGuess, AMatchSentence: string);
begin
  FAlignMatchFunction := CheckHybridPosMatch;
  RunCurrentMatch(ACurrentBestScore, AnId, ARepGuess, ASemRepGuess, AMatchSentence);
end;

procedure TSentenceAlgorithm.RunHybridSemMatch(var ACurrentBestScore: Double; var AnId: TId; var ARepGuess,
  ASemRepGuess, AMatchSentence: string);
begin
  FAlignMatchFunction := CheckHybridSemMatch;
  RunCurrentMatch(ACurrentBestScore, AnId, ARepGuess, ASemRepGuess, AMatchSentence);
end;

end.

