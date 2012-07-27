unit SamInit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ACR122s, Dialogs, StdCtrls;

type
  TfInitSAM = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    tbGlobal: TEdit;
    tbIssuer: TEdit;
    tbCard: TEdit;
    tbTerm: TEdit;
    tbDebit: TEdit;
    tbCredit: TEdit;
    tbCert: TEdit;
    tbRevoke: TEdit;
    bInitSAM: TButton;
    bCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure tMemAddKeyPress(Sender: TObject; var Key: Char);
    procedure bInitSAMClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fInitSAM: TfInitSAM;
  PrintText : String;

function CheckInput(): Integer;
implementation

uses KeyManage;
{$R *.dfm}

function CheckInput() : Integer;
begin

    if Length(fInitSAM.tbGlobal.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Global PIN');
      fInitSAM.tbGlobal.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbIssuer.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Issuer Code');
      fInitSAM.tbIssuer.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbCard.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Card Key');
      fInitSAM.tbCard.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbTerm.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Terminal Key');
      fInitSAM.tbTerm.SetFocus;
      CheckInput := 1;
    end;

    if Length(fInitSAM.tbDebit.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Debit Key');
      fInitSAM.tbDebit.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbCredit.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Credit Key');
      fInitSAM.tbCredit.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbCert.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Certify Key');
      fInitSAM.tbCert.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    if Length(fInitSAM.tbRevoke.Text) < 16 then
    begin
      ShowMessage('Please enter 8 bytes of keys for Revoke Debit Key');
      fInitSAM.tbRevoke.SetFocus;
      CheckInput := 1;
      Exit;
    end;

    CheckInput := 0;

end;

procedure TfInitSAM.bCancelClick(Sender: TObject);
begin
      fInitSAM.Close;
end;

procedure TfInitSAM.bInitSAMClick(Sender: TObject);
var
tmpData : String;
indx : Integer;
begin

      retCode := CheckInput();

      if retCode = 1 then
         Exit;

      ClearBuffers();

      //Clear Card
      SendBuff[0] := $80;
      SendBuff[1] := $30;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $00;

      SendLen := 5;
      RecvLen := 255;

      retCode := SendAPDUandDisplay(1);

      if retCode = 0 then begin
           displayOut( 0, 0, 'Clear SAM success');
      end
      else begin
           displayOut( 1, 0, 'Clear SAM failed');
           fInitSam.Close;
      end;

      //Reset SAM
      retCode := ACR122_PoweroffICC( hReader, 0);
      retCode := ACR122_Close(hReader);
      retCode := ACR122_OpenA(fKeyManage.cbPort.Text, @hReader);
      RecvLen := 255;
      retCode := ACR122_PowerOnIcc( hReader, 0, @RecvBuff, @RecvLen);

      if Not retCode = 0 then begin
        displayOut( 1, 0, 'Reset Failed');
        Exit;
        fInitSam.Close;
      end
      else begin
        displayOut( 0, 0, 'Reset Success');
      end;

      ClearBuffers();
      //Create Master File
      SendBuff[0] := $00;
      SendBuff[1] := $E0;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $0F;
      SendBuff[5] := $62;
      SendBuff[6] := $0D;
      SendBuff[7] := $82;
      SendBuff[8] := $01;
      SendBuff[9] := $3F;
      SendBuff[10] := $83;
      SendBuff[11] := $02;
      SendBuff[12] := $3F;
      SendBuff[13] := $00;
      SendBuff[14] := $8A;
      SendBuff[15] := $01;
      SendBuff[16] := $01;
      SendBuff[17] := $8C;
      SendBuff[18] := $01;
      SendBuff[19] := $00;

      SendLen := 20;
      RecvLen := 255;

      retCode := SendAPDUandDisplay(1);

      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Creating master file failed');
        fInitSam.Close;
        Exit;
      end;

      ClearBuffers();
      //Create EF1 to Store PIN
      SendBuff[0] := $00;
      SendBuff[1] := $E0;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $1B;
      SendBuff[5] := $62;
      SendBuff[6] := $19;
      SendBuff[7] := $83;
      SendBuff[8] := $02;
      SendBuff[9] := $FF;
      SendBuff[10] := $0A;
      SendBuff[11] := $88;
      SendBuff[12] := $01;
      SendBuff[13] := $01;
      SendBuff[14] := $82;
      SendBuff[15] := $06;
      SendBuff[16] := $0C;
      SendBuff[17] := $00;
      SendBuff[18] := $00;
      SendBuff[19] := $0A;
      SendBuff[20] := $00;
      SendBuff[21] := $01;
      SendBuff[22] := $8C;
      SendBuff[23] := $08;
      SendBuff[24] := $7F;
      SendBuff[25] := $FF;
      SendBuff[26] := $FF;
      SendBuff[27] := $FF;
      SendBuff[28] := $FF;
      SendBuff[29] := $27;
      SendBuff[30] := $27;
      SendBuff[31] := $FF;

      SendLen := 32;
      RecvLen := 255;

      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Creating EF1 failed');
        fInitSam.Close;
        Exit;
      end;

      ClearBuffers();
      //Set Global PIN
      SendBuff[0] := $00;
      SendBuff[1] := $DC;
      SendBuff[2] := $01;
      SendBuff[3] := $04;
      SendBuff[4] := $0A;
      SendBuff[5] := $01;
      SendBuff[6] := $88;


      for indx :=0 to Length(tbGlobal.Text) div 2 - 1 do
      begin
           SendBuff[indx + 7] := StrToInt('$' + copy(tbGlobal.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 15;
      RecvLen := 255;

      retCode := SendAPDUandDisplay(1);
      if (Not retCode = 0) then
      begin
        displayOut( 1, 0, 'Setting Global PIN failed');
        fInitSam.Close;
        Exit;
      end;

      ClearBuffers();
      //Create DF
      SendBuff[0] := $00;
      SendBuff[1] := $E0;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $2B;
      SendBuff[5] := $62;
      SendBuff[6] := $29;
      SendBuff[7] := $82;
      SendBuff[8] := $01;
      SendBuff[9] := $38;
      SendBuff[10] := $83;
      SendBuff[11] := $02;
      SendBuff[12] := $11;
      SendBuff[13] := $00;
      SendBuff[14] := $8A;
      SendBuff[15] := $01;
      SendBuff[16] := $01;
      SendBuff[17] := $8C;
      SendBuff[18] := $08;
      SendBuff[19] := $7F;
      SendBuff[20] := $03;
      SendBuff[21] := $03;
      SendBuff[22] := $03;
      SendBuff[23] := $03;
      SendBuff[24] := $03;
      SendBuff[25] := $03;
      SendBuff[26] := $03;
      SendBuff[27] := $8D;
      SendBuff[28] := $02;
      SendBuff[29] := $41;
      SendBuff[30] := $03;
      SendBuff[31] := $80;
      SendBuff[32] := $02;
      SendBuff[33] := $03;
      SendBuff[34] := $20;
      SendBuff[35] := $AB;
      SendBuff[36] := $0B;
      SendBuff[37] := $84;
      SendBuff[38] := $01;
      SendBuff[39] := $88;
      SendBuff[40] := $A4;
      SendBuff[41] := $06;
      SendBuff[42] := $83;
      SendBuff[43] := $01;
      SendBuff[44] := $81;
      SendBuff[45] := $95;
      SendBuff[46] := $01;
      SendBuff[47] := $FF;

      SendLen := 48;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Creating DF failed');
        fInitSam.Close;
        Exit;
      end;

      ClearBuffers();
      //Create Key File EF2
      SendBuff[0] := $00;
      SendBuff[1] := $E0;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $1D;
      SendBuff[5] := $62;
      SendBuff[6] := $1B;
      SendBuff[7] := $82;
      SendBuff[8] := $05;
      SendBuff[9] := $0C;
      SendBuff[10] := $41;
      SendBuff[11] := $00;
      SendBuff[12] := $16;
      SendBuff[13] := $08;
      SendBuff[14] := $83;
      SendBuff[15] := $02;
      SendBuff[16] := $11;
      SendBuff[17] := $01;
      SendBuff[18] := $88;
      SendBuff[19] := $01;
      SendBuff[20] := $02;
      SendBuff[21] := $8A;
      SendBuff[22] := $01;
      SendBuff[23] := $01;
      SendBuff[24] := $8C;
      SendBuff[25] := $08;
      SendBuff[26] := $7F;
      SendBuff[27] := $03;
      SendBuff[28] := $03;
      SendBuff[29] := $03;
      SendBuff[30] := $03;
      SendBuff[31] := $03;
      SendBuff[32] := $03;
      SendBuff[33] := $03;

      SendLen := 34;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Creating EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //Acquires the Global SAM PIN and assigns to Global array
      for indx :=0 to Length(tbGlobal.Text) div 2 - 1 do
      begin
           Buffer[indx] := StrToInt('$' + copy(tbGlobal.Text,(indx*2+1),2));
      end;

      //Append Record To EF2, Define 8 Key Records in EF2 - Master Keys
      //1st Master key, key ID=81, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $81;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbIssuer.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbIssuer.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Issuer Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //2nd Master key, key ID=82, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $82;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbCard.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbCard.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Card Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //3rd Master key, key ID=83, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $83;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbTerm.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbTerm.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Terminal Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //4th Master key, key ID=84, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $84;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbDebit.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbDebit.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Debit Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //5th Master key, key ID=85, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $85;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbCredit.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbCredit.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Credit Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //'6th Master key, key ID=86, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $86;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbCert.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbCert.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Certify Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      //'7th Master key, key ID=87, key type=03, int/ext authenticate, usage counter = FF FF
      ClearBuffers();
      SendBuff[0] := $00;
      SendBuff[1] := $E2;
      SendBuff[2] := $00;
      SendBuff[3] := $00;
      SendBuff[4] := $16;
      SendBuff[5] := $87;
      SendBuff[6] := $03;
      SendBuff[7] := $FF;
      SendBuff[8] := $FF;
      SendBuff[9] := $88;
      SendBuff[10] := $00;

      for indx :=0 to Length(tbRevoke.Text) div 2 - 1 do
      begin
           SendBuff[indx + 11] := StrToInt('$' + copy(tbRevoke.Text,(indx*2+1),2)); // Format Data In
      end;

      SendLen := 19;
      RecvLen := 255;
      retCode := SendAPDUandDisplay(1);
      if Not ((retCode = 0) and ((RecvBuff[0] = $90) and (RecvBuff[1] = $00))) then
      begin
        displayOut( 1, 0, 'Appending Revoke Key to EF2 failed');
        fInitSam.Close;
        Exit;
      end;

      fInitSam.Close;


end;

procedure TfInitSAM.FormShow(Sender: TObject);
begin
      tbGlobal.Text := '';
      tbIssuer.Text := '';
      tbCard.Text := '';
      tbTerm.Text := '';
      tbDebit.Text := '';
      tbCredit.Text := '';
      tbCert.Text := '';
      tbRevoke.Text := '';

end;

procedure TfInitSAM.tMemAddKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> chr($08) then begin
    if Key in ['a'..'z'] then
      Dec(Key, 32);
    if Not (Key in ['0'..'9', 'A'..'F'])then
      Key := Chr($00);
  end;
end;

end.
